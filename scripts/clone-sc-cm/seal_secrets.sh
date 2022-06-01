#!/bin/bash

function main(){
    NAMESPACES_PATH="$1"
    TEMPLATES_PATH="$2"
    MAP_FILE="$3"
    echo -e "\n"
    while IFS= read -r line || [ -n "$line" ]
    do
        SRC_NAMESPACE=$(echo $line |  awk -F  ":" '{print $1}')
        TGT_NAMESPACE=$(echo $line |  awk -F  ":" '{print $2}')
        SECRETS_PATH="${NAMESPACES_PATH}/${SRC_NAMESPACE}/secrets" 
        
        if [ -d $SECRETS_PATH ]; then
            pushd $SECRETS_PATH > /dev/null 2>&1
            for secret in *; do
                secret_name=$(echo $secret | awk -F  "." '{print $1}')
                kubeseal<$secret > ${TEMPLATES_PATH}/${secret_name}/Secret_sealed.yaml -o yaml -n $TGT_NAMESPACE 
            done
            popd > /dev/null 2>&1
        fi

    done < "$MAP_FILE"
}

main "$1" "$2" "$3"