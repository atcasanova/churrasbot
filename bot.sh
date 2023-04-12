#!/bin/bash
cd $(dirname $0)

declare -A file_timestamps

load_functions(){
    for function in src/*.sh; do
        current_timestamp=$(stat -c %Y "$function")

        if [[ ! ${file_timestamps["$function"]+isset} ]] || (( ${file_timestamps["$function"]} < $current_timestamp )); then
            source $function
            file_timestamps["$function"]=$current_timestamp
        fi
    done
    check_env
}

offset=$(cat offset)
while true; do
    load_functions
    main
    sleep 1
done
