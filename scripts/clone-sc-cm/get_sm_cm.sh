#!/bin/bash

#file with namespaces
namespace_file=$1

#print text using green color
function green(){
    echo -e "\033[32m$1\033[0m"
}

function red(){
    echo -e "\033[31m$1\033[m"
}


function download_yq(){
    if [ ! -f "/usr/local/bin/yq" ];
    then
        echo "Downloading yq binary"
        sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        sudo chmod a+x /usr/local/bin/yq
        green "yq has been installed"
    else
        green "yq is already installed"
    fi
}


function generate_confimaps_files(){
    local NAMESPACE=$1

    local configmaps=$(kubectl get cm --no-headers -n $NAMESPACE| awk '{print $1}')
    if [ ! -z "$configmaps" ];
    then
        mkdir -p ./${NAMESPACE}/configmaps
        
        for configmap in $configmaps ; 
        do 
            echo "Current configmap: $configmap"
            kubectl get cm/$configmap -o yaml -n $NAMESPACE | yq "del(.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.namespace)" > ./${NAMESPACE}/configmaps/$configmap.yaml ; 
        done
    else
        red "No configmap found for namespace: $NAMESPACE"
    fi
    configmaps=""

}

function generate_secrets_files(){
    local NAMESPACE=$1

    local secrets=$(kubectl get secrets --no-headers -n $NAMESPACE | awk '{print $1}')
    if [ ! -z "$secrets" ];
    then
        mkdir -p ./${NAMESPACE}/secrets
        for secret in $secrets; 
        do 
            echo "Current secret: $secret"
            kubectl get secrets/$secret -n $NAMESPACE -o yaml | yq "del(.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.namespace)" > ./${NAMESPACE}/secrets/$secret.yaml
        done
    else
        red "No secret found for namespace: $NAMESPACE"
    fi
    secrets=""
}



function main(){
    download_yq
    echo -e "\n"
    while IFS= read -r line || [ -n "$line" ]
    do
        green "Getting files from namespace: $line"
        generate_confimaps_files $line
        generate_secrets_files $line
        echo -e "\n"
    done < "$namespace_file"
}

main