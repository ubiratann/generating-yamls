#!/bin/bash

#print text using green color
function green(){
    echo -e "\033[32m$1\033[0m"
}

#print text using red color
function red(){
    echo -e "\033[31m$1\033[m"
}

# Verify if namespace already exists
function verify_target_namespace(){
    target_namespace=$1
    test=$(oc get namespaces  | awk '{print $1}' | grep -E "(^|\s)${target_namespace}($|\s)")
    if [ -z "$test" ];
    then
        green "Creating namespace $target_namespace, because it doesn't exists"
        oc create namespace $target_namespace
    fi
}

# Applying configmaps to the new namespace
function apply_configmaps(){
    local source_namespace=$1
    local target_namespace=$2

    if [ -d "${source_namespace}/configmaps/" ];
    then
        green "Applying configmaps from ${source_namespace} to ${target_namespace}"
        for configmap in ./$source_namespace/configmaps/*.yaml
        do
            echo "Current configmap ${configmap}"
            oc apply -f $configmap -n $target_namespace
        done
    fi
}

# Applying secrets to the new mamespace
function apply_secrets(){
    local source_namespace=$1
    local target_namespace=$2
    if [ -d "${source_namespace}/secrets/" ];
    then
        green "Applying secrets from ${source_namespace} to ${target_namespace}"
        for secret in ./$source_namespace/secrets/*.yaml
        do
            echo "Current secret ${secret}"
            oc apply -f $secret -n $target_namespace
        done
    fi
}

# main function
function main(){
    local mapped_namespaces=$1
    echo -e "\n"
    while IFS= read -r line || [ -n "$line" ]
    do
        source_namespace=$(echo $line |  awk -F  ":" '{print $1}')
        target_namespace=$(echo $line |  awk -F  ":" '{print $2}')
        
        verify_target_namespace $target_namespace
        
        apply_configmaps $source_namespace $target_namespace
        apply_secrets $source_namespace $target_namespace

    done < "$mapped_namespaces"

}

main "$1"