#!/bin/bash
fake(){
    (( $# != 1 )) && return 2;
    churrasAtivo && {
        filename=C_${lugar// /_}_${data//\//}
        local malandro="$1"
        grep -qi "^$malandro:" $filename && {
            sed -i "/^$malandro:/d" $filename && {
                envia "Checkin do $malandro removido"
                echo "$malandro" >> penalidades
                envia "$(cut -f1 -d: $filename)"
            }
        }
    }
}