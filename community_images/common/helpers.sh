#!/bin/bash

set -x
set -e

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/retry_helper.sh

DOCKERHUB_REGISTRY="${DOCKERHUB_REGISTRY:-docker.io}"
RAPIDFORT_ACCOUNT="${RAPIDFORT_ACCOUNT:-rapidfort}"
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
NAMESPACE_TO_CLEANUP=
declare -A PULL_COUNTER

function create_stub()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local OUTPUT_REPOSITORY=$4
    local TAG=$5

    local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
    if [[ "$INPUT_ACCOUNT" == "_" ]]; then
        INPUT_IMAGE_FULL="${INPUT_REGISTRY}/${REPOSITORY}:${TAG}"
    fi

    local STUB_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${OUTPUT_REPOSITORY}:${TAG}-rfstub

    # login to output docker register as input and output docker registry could be different
    docker login "${DOCKERHUB_REGISTRY}" -u "${DOCKERHUB_USERNAME}" -p "${DOCKERHUB_PASSWORD}"

    # Create stub for docker image
    rfstub "${INPUT_IMAGE_FULL}"

    # Change tag to point to rapidfort docker account
    docker tag "${INPUT_IMAGE_FULL}"-rfstub "${STUB_IMAGE_FULL}"

    # Push stub to our dockerhub account
    docker push "${STUB_IMAGE_FULL}"
}

function add_sha256_tag()
{
    local REPOSITORY=$1
    local INPUT_TAG=$2

    local FULL_IMAGE_TAG="$REPOSITORY:$INPUT_TAG"

    docker pull "${FULL_IMAGE_TAG}"

    local SHA_TAG

    SHA_TAG=$(docker inspect --format='{{index .RepoDigests 0}}' "${FULL_IMAGE_TAG}")

    IFS=":"
    # shellcheck disable=SC2162
    read -a input_arr <<< "$SHA_TAG"

    local SHA256_TAG="${input_arr[1]}"

    local FULL_SHA256_TAG="$REPOSITORY:$SHA256_TAG"

    docker tag "${FULL_IMAGE_TAG}" "${FULL_SHA256_TAG}"
    docker push "${FULL_SHA256_TAG}"
}

function add_rolling_tags()
{
    local REPOSITORY=$1
    local INPUT_TAG=$2 # example: 10.6.8-debian-10-r2
    local IS_LATEST_TAG=$3

    IFS='-'
    # shellcheck disable=SC2162
    read -a input_arr <<< "$INPUT_TAG"

    local version="${input_arr[0]}"
    local os="${input_arr[1]}"
    local os_ver="${input_arr[2]}"

    FULL_VER_TAG="$version" # 10.6.8
    declare -a rolling_tags=("$FULL_VER_TAG")

    if [[ "$os" != "" ]]; then
        IFS="."
        # shellcheck disable=SC2162
        read -a ver_arr <<< "$version"
        maj_v="${ver_arr[0]}"
        min_v="${ver_arr[1]}"

        VER_OS_TAG="$maj_v"."$min_v"-"$os"-"$os_ver" # 10.6-debian-10
        MAJ_MINOR_TAG="$maj_v"."$min_v" # 10.6

        rolling_tags+=("$VER_OS_TAG" "$MAJ_MINOR_TAG")
    fi

    if [[ "$IS_LATEST_TAG" = "yes" ]]; then
        rolling_tags+=("latest")
    fi

    for rolling_tag in "${rolling_tags[@]}"; do
        docker tag "${REPOSITORY}:${INPUT_TAG}" "${REPOSITORY}:$rolling_tag"
        docker push "${REPOSITORY}:$rolling_tag"
    done
}

function harden_image()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local TAG=$4
    local OUTPUT_REPOSITORY=$5
    local PUBLISH_IMAGE=$6
    local IS_LATEST_TAG=$7

    local INPUT_IMAGE_FULL="${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}"
    if [[ "$INPUT_ACCOUNT" == "_" ]]; then
        INPUT_IMAGE_FULL="${INPUT_REGISTRY}/${REPOSITORY}:${TAG}"
    fi

    local OUTPUT_IMAGE_FULL=${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${OUTPUT_REPOSITORY}:${TAG}

    # Create stub for docker image
    if [[ -f "${SCRIPTPATH}"/.rfignore ]]; then
        rfharden "${INPUT_IMAGE_FULL}"-rfstub --put-meta --profile "${SCRIPTPATH}"/.rfignore
    else
        rfharden "${INPUT_IMAGE_FULL}"-rfstub --put-meta
    fi

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then

        # Change tag to point to rapidfort docker account
        docker tag "${INPUT_IMAGE_FULL}"-rfhardened "${OUTPUT_IMAGE_FULL}"

        # Push stub to our dockerhub account
        docker push "${OUTPUT_IMAGE_FULL}"

        # add rolling tags like move latest tag
        add_rolling_tags "${DOCKERHUB_REGISTRY}/${RAPIDFORT_ACCOUNT}/${OUTPUT_REPOSITORY}" "${TAG}" "${IS_LATEST_TAG}"

        echo "Hardened images pushed to ${OUTPUT_IMAGE_FULL}"
    else
        echo "Non publish mode"
    fi
}

function get_namespace_string()
{
    local REPOSITORY=$1
    echo "${REPOSITORY}-$(echo $RANDOM | md5sum | head -c 10; echo;)"
}

function setup_namespace()
{
    local NAMESPACE=$1
    kubectl create namespace "${NAMESPACE}"

    # add rapidfortbot credentials
    kubectl --namespace "${NAMESPACE}" create secret generic rf-regcred --from-file=.dockerconfigjson="${HOME}"/.docker/config.json --type=kubernetes.io/dockerconfigjson

    # add tls certs
    kubectl apply -f "${SCRIPTPATH}"/../../common/cert_managet_ns.yml --namespace "${NAMESPACE}"
}

function cleanup_namespace()
{
    local NAMESPACE=$1
    kubectl delete namespace "${NAMESPACE}"
}


function build_image()
{
    local INPUT_REGISTRY=$1
    local INPUT_ACCOUNT=$2
    local REPOSITORY=$3
    local BASE_TAG=$4
    local OUTPUT_REPOSITORY=$5
    local TEST_FUNCTION=$6
    local PUBLISH_IMAGE=$7
    local IS_LATEST_TAG=$8

    local TAG NAMESPACE

    if [[ "${INPUT_REGISTRY}" = "docker.io" ]]; then
        local RAPIDFORT_TAG

        TAG=$(python3 "${SCRIPTPATH}"/../../common/latest_tag.py "${INPUT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

        if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
            # dont create image for publish mode if tag exists
            RAPIDFORT_TAG=$(python3 "${SCRIPTPATH}"/../../common/latest_tag.py "${RAPIDFORT_ACCOUNT}"/"${REPOSITORY}" "${BASE_TAG}")

            if [[ "${TAG}" = "${RAPIDFORT_TAG}" ]]; then
                echo "Rapidfort image exists:${RAPIDFORT_TAG}, aborting run"
                return
            fi
        fi
    else
        TAG="${BASE_TAG}"
    fi

    if [[ "${INPUT_ACCOUNT}" = "bitnami" ]]; then
        echo "Embedding RF welcome message in bitnami images"
        mkdir -p "${SCRIPTPATH}"/temp_docker

        sed "s#@REPO#${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}#g" "${SCRIPTPATH}"/../../common/Dockerfile.base > "${SCRIPTPATH}"/temp_docker/Dockerfile
        cp "${SCRIPTPATH}"/../../common/libbitnami.sh "${SCRIPTPATH}"/temp_docker/libbitnami.sh
        local CWD="${PWD}"
        cd "${SCRIPTPATH}"/temp_docker
        docker build . -t "${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}"
        cd "$CWD"

        rm -rf "${SCRIPTPATH}"/temp_docker
    else
        local INPUT_IMAGE_FULL=${INPUT_REGISTRY}/${INPUT_ACCOUNT}/${REPOSITORY}:${TAG}
        if [[ "$INPUT_ACCOUNT" == "_" ]]; then
            INPUT_IMAGE_FULL="${INPUT_REGISTRY}/${REPOSITORY}:${TAG}"
        fi

        # pull image only when we dont build it locally
        docker pull "${INPUT_IMAGE_FULL}"
    fi

    NAMESPACE=$(get_namespace_string "${REPOSITORY}")
    NAMESPACE_TO_CLEANUP="${NAMESPACE}"
    echo "Running image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
    setup_namespace "${NAMESPACE}"

    TAG="2.37.0-debian-11-r11"
    #create_stub "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${OUTPUT_REPOSITORY}" "${TAG}"
    "${TEST_FUNCTION}" "${RAPIDFORT_ACCOUNT}"/"${OUTPUT_REPOSITORY}" "${TAG}"-rfstub "${NAMESPACE}"
    harden_image "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${TAG}" "${OUTPUT_REPOSITORY}" "${PUBLISH_IMAGE}" "${IS_LATEST_TAG}"

    if [[ "${PUBLISH_IMAGE}" = "yes" ]]; then
        "${TEST_FUNCTION}" "${RAPIDFORT_ACCOUNT}"/"${OUTPUT_REPOSITORY}" "${TAG}" "${NAMESPACE}"
    else
        echo "Non publish mode, cant test image as image not published"
    fi

    bash -c "${SCRIPTPATH}/../../common/delete_tag.sh ${OUTPUT_REPOSITORY} ${TAG}-rfstub"
    cleanup_namespace "${NAMESPACE}"
    NAMESPACE_TO_CLEANUP=
    echo "Completed image generation for ${INPUT_ACCOUNT}/${REPOSITORY} ${TAG}"
}

function build_images()
{
    local INPUT_REGISTRY=$1
    shift
    local INPUT_ACCOUNT=$1
    shift
    local REPOSITORY=$1
    shift
    local OUTPUT_REPOSITORY=$1
    shift
    local TEST_FUNCTION=$1
    shift
    local PUBLISH_IMAGE=$1
    shift
    local BASE_TAG_ARRAY=( "$@" )

    for index in "${!BASE_TAG_ARRAY[@]}"; do
        tag="${BASE_TAG_ARRAY[$index]}"
        IS_LATEST_TAG="no"
        if [[ "$index" = 0 ]]; then
            IS_LATEST_TAG="yes"
        fi
        build_image "${INPUT_REGISTRY}" "${INPUT_ACCOUNT}" "${REPOSITORY}" "${tag}" "${OUTPUT_REPOSITORY}" test "${PUBLISH_IMAGE}" "${IS_LATEST_TAG}"
    done
}

function cleanup_certs()
{
    rm -rf "${SCRIPTPATH}"/certs
    mkdir -p "${SCRIPTPATH}"/certs
}

function create_certs()
{
    cleanup_certs

    openssl req -newkey rsa:4096 \
                -x509 \
                -sha256 \
                -days 3650 \
                -nodes \
                -out "${SCRIPTPATH}"/certs/server.crt \
                -keyout "${SCRIPTPATH}"/certs/server.key \
                -subj "/C=SI/ST=Ljubljana/L=Ljubljana/O=Security/OU=IT Department/CN=www.example.com"
}

function report_pulls()
{
    local REPO_NAME="${1}"
    local PULL_COUNT=1 # use 1 as docker caching might be kicking in. ${2-1} # default to single pull count
    echo "docker pull counter: $REPO_NAME $PULL_COUNT"
    if [ -z "${PULL_COUNTER[$REPO_NAME]}" ]; then
        PULL_COUNTER["$REPO_NAME"]=0
    fi
    echo "docker pull count previous value:" ${PULL_COUNTER[$REPO_NAME]}

    # shellcheck disable=SC2004
    PULL_COUNTER["$REPO_NAME"]=$((PULL_COUNTER[$REPO_NAME]+"$PULL_COUNT"))
    echo "docker pull count updated to:" ${PULL_COUNTER[$REPO_NAME]}
}

function finish {
    if [[ -z "$NAMESPACE_TO_CLEANUP" ]]; then
        kubectl get pods --all-namespaces
        kubectl get services --all-namespaces
    else
        kubectl -n "${NAMESPACE_TO_CLEANUP}" get pods
        kubectl -n "${NAMESPACE_TO_CLEANUP}" delete all --all
        kubectl delete namespace "${NAMESPACE_TO_CLEANUP}"
    fi

    JSON_STR="{"
    FIRST=1
    for key in "${!PULL_COUNTER[@]}"; do
        if [ "$FIRST" = "0" ] ; then JSON_STR+=", " ; fi
        JSON_STR+="\"$key\":${PULL_COUNTER[$key]}"
        FIRST=0
    done
    JSON_STR+="}"

    if [[ -n "$PULL_COUNTER_MAGIC_TOKEN" ]]; then
        curl -X POST \
            -H "Accept: application/json" \
            -H "Authorization: Bearer ${PULL_COUNTER_MAGIC_TOKEN}" \
            -d "${JSON_STR}" https://data-receiver.rapidfort.com/counts/internal_image_pulls
    fi
}
trap finish EXIT
