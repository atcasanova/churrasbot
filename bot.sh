#!/bin/bash
cd $(dirname $0)

load_functions(){
    for function in src/*.sh; do
        source $function
    done
    check_env
}

offset=$(cat offset)
while true; do
    load_functions
    main
done