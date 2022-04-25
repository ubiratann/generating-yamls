#!/bin/bash

# print text using green color
function green(){
    echo -e "\033[32m$1\033[0m"
}

# print text using red color
function red(){
    echo -e "\033[31m$1\033[m"
}

# download yq tool to update yaml files
function download_yq(){
    if [ ! -f "/usr/local/bin/yq" ];
    then
        echo "Downloading yq binary"
        wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        chmod a+x /usr/local/bin/yq
        green "yq has been installed"
    else
        green "yq is already installed"
    fi
}

# generating configmaps by namespace
function generate_confimaps_files(){
    local NAMESPACE=$1

    local configmaps=$(kubectl get cm --no-headers -n $NAMESPACE| awk '{print $1}')
    if [ ! -z "$configmaps" ];
    then
        for configmap in $configmaps ; 
        do 
            if [[ "$configmap" != *.crt ]];
            then
                mkdir -p ./${NAMESPACE}/configmaps
                echo "Current configmap: $configmap"
                kubectl get cm/$configmap -o yaml -n $NAMESPACE | yq "del(.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.namespace, .metadata.annotations)" > ./${NAMESPACE}/configmaps/$configmap.yaml ; 
            fi
        done
    else
        red "No configmap found for namespace: $NAMESPACE"
    fi
    configmaps=""

}

#generating secrets by namespace
function generate_secrets_files(){
    local NAMESPACE=$1

    local secrets=$(kubectl get secrets --no-headers -n $NAMESPACE | grep opaque | awk '{print $1}')
    if [ ! -z "$secrets" ];
    then
        mkdir -p ./${NAMESPACE}/secrets
        for secret in $secrets; 
        do 
            echo "Current secret: $secret"
            kubectl get secrets/$secret -o yaml -n $NAMESPACE | yq "del(.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.namespace, .metadata.annotations)" > ./${NAMESPACE}/secrets/$secret.yaml
        done
    else
        red "No secret found for namespace: $NAMESPACE"
    fi
    secrets=""
}

#main
function main(){
    #file with namespaces
    local namespace_file=$1
    
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

main "$1"