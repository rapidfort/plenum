#!/bin/bash

set -e
set -x

# shellcheck disable=SC1091
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
. "${SCRIPTPATH}"/../../common/scripts/bash_helper.sh

test_vault() {
    VAULT_CONTAINER=$1
    NAMESPACE=$2
    KUBERNETES_PORT_443_TCP_ADDR=$(minikube ip)
    K8S_API_PORT=8443
    # verify that the vault is installed correctly
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault version

    # generate the unseal keys and root token and store in cluster-keys.json
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json

    VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault operator unseal "${VAULT_UNSEAL_KEY}"

    ROOT_TOKEN=$(jq -r ".root_token" cluster-keys.json)
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault login "${ROOT_TOKEN}"

    # Enable an instance of the kv-v2 secrets engine at the path secret
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault secrets enable -path=secret kv-v2

    # check the help on this path
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault path-help secret

    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault kv put secret/webapp/config username="static-user" password="static-password"
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault kv get secret/webapp/config

    # enable kubernetes based authentication
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault auth enable kubernetes
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault write auth/kubernetes/config kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:${K8S_API_PORT}"
    kubectl cp "${SCRIPTPATH}"/policy.hcl -n "${NAMESPACE}" "${VAULT_CONTAINER}":/tmp/
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault policy write webapp /tmp/policy.hcl
    kubectl exec -n "${NAMESPACE}" "${VAULT_CONTAINER}" -- vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=webapp \
        ttl=24h

    NAMESPACE="${NAMESPACE}" kubectl apply --filename deployment-webapp.yml
    echo "sleeping for 30 seconds"
    sleep 30
    # wait for the earlier pod/deployment to finish
    # the pod goes into the running state 
    with_backoff kubectl wait deployments -n "${NAMESPACE}" webapp --for=condition=Available=True --timeout=20m
    kubectl port-forward "$(kubectl get pod -n "${NAMESPACE}" -l app=webapp -o jsonpath="{.items[0].metadata.name}")" 8080:8080
    PID_PF="$!"

    out=$(curl http://localhost:8080 | grep -ic "static-secret")
    # verify the output
    if (( out < 1 )); then
        echo "the secret is not correctly mounted to the web application"
        return 1
    fi

    out=$(curl http://localhost:8080 | grep -ic "static-user")
    # verify the output
    if (( out < 1 )); then
        echo "the secret is not correctly mounted to the web application"
        return 1
    fi

    # kill the port forward process
    kill -9 "${PID_PF}"
}