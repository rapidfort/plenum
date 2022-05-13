#!/bin/bash

set -x
set -e

HELM_RELEASE=rf-mongodb-cluster
NAMESPACE=ci-test

test()
{
    helm install ${HELM_RELEASE} bitnami/mongodb --set image.repository=rapidfort/mongodb --namespace ${NAMESPACE}
    kubectl wait pods ${HELM_RELEASE} -n ${NAMESPACE} --for=condition=ready --timeout=10m
    kubectl -n ${NAMESPACE} get pods
}

clean()
{
    helm delete ${HELM_RELEASE} --namespace ${NAMESPACE}
    kubectl -n ${NAMESPACE} delete pvc --all
}

main()
{
    test
    clean
}

main