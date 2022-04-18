#!/bin/bash


if [ ! -f "/usr/local/bin/yq" ];
then
    echo "Downloading yq binary"
    sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    sudo chmod a+x /usr/local/bin/yq
fi

NAMESPACE=$1

echo "#Generating folders to ${NAMESPACE}"
mkdir -p ./${NAMESPACE}/secrets
mkdir -p ./${NAMESPACE}/configmaps

echo "# Getting configmaps from ${NAMESPACE}"
for configmap in $(kubectl get cm --no-headers | awk '{print $1}'); 
do 
    kubectl get cm/$configmap -o json | jq "del(.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.namespace)" > ./${NAMESPACE}/configmaps/$configmap.json ; 
    
done

# echo "#Getting secrets"

# for secret in $(kubectl get secrets --no-headers | awk '{print $1}'); 
# do 
#     echo "# CONFIGMAP: $secret"
#     kubectl get sc/$secret -n $NAMESPACE -o yaml >> ./${NAMESPACE}/secrets/$secret.yaml

# done