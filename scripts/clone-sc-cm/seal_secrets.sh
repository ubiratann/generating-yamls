#!/bin/bash

function main(){
    NAMESPACES_PATH="$1"
    for dir in $NAMESPACES_PATH/*/ ; do
        if [ -d "$dir/secrets" ]; then
            pushd "$dir/secrets"
            for secret in *; do
                secret_name=$(echo $secret | awk -F  "." '{print $1}')
                kubeseal<$secret > ${TEMPLATES_PATH}/${secret_name}/${secret_name}.yaml -o yaml
            done
            popd
        else
            echo "No secret found in the namespace"
        fi
    done
}


TEMPLATES_PATH="$2"
main "$1"