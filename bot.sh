#!/bin/bash
cd $(dirname $0)

load_functions(){
    for function in src/*.sh; do
        source $function
    done
}
load_functions

check_env

offset=$(cat offset)
while true; do
    load_functions
    main
done