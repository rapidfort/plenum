#!/bin/bash

set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <k8s-namespace> <tag>"
    exit 1
fi

NAMESPACE=$1 #ci-dev
TAG=$2 #6.2.6-debian-10-r95
echo "Running image generation for $0 $1 $2"

IREGISTRY=docker.io
IREPO=bitnami/postgresql
OREPO=rapidfort/postgresql-rfstub
PUB_REPO=rapidfort/postgresql
HELM_RELEASE=postgresql-release


create_stub()
{
    # Pull docker image
    docker pull ${IREGISTRY}/${IREPO}:${TAG}
    # Create stub for docker image
    rfstub ${IREGISTRY}/${IREPO}:${TAG}

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfstub ${OREPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${OREPO}:${TAG}

}


test()
{
    echo "Testing postgresql"
    # Install postgresql
    helm install ${HELM_RELEASE}  ${IREPO} --namespace ${NAMESPACE} --set image.tag=${TAG} -f overrides.yml

    # sleep for 2 min
    echo "waiting for 2 min for setup"
    sleep 2m

    # get postgresql passwordk
    POSTGRES_PASSWORD=$(kubectl get secret --namespace ${NAMESPACE} ${HELM_RELEASE} -o jsonpath="{.data.postgres-password}" | base64 --decode)

    # exec into container
    kubectl -n ${NAMESPACE} exec -it ${HELM_RELEASE}-0 -- /bin/bash -c "PGPASSWORD=${POSTGRES_PASSWORD} psql --host ${HELM_RELEASE} -U postgres -d postgres -p 5432"

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30

    # bring down helm install
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}

    # sleep for 30 sec
    echo "waiting for 30 sec"
    sleep 30
}

harden_image()
{
    # Create stub for docker image
    rfharden ${IREGISTRY}/${IREPO}:${TAG}-rfstub

    # Change tag to point to rapidfort docker account
    docker tag ${IREGISTRY}/${IREPO}:${TAG}-rfhardened ${PUB_REPO}:${TAG}

    # Push stub to our dockerhub account
    docker push ${PUB_REPO}:${TAG}

    echo "Hardened images pushed to ${PUB_REPO}:${TAG}" 
}


main()
{
    create_stub
    test
    harden_image
}

main
