#!/bin/bash
fake(){
    (( $# != 1 )) && return 2;
    churrasAtivo && {
        filename=C_${lugar// /_}_${data//\//}
        local malandro="$1"
        local userid=$(getId "$malandro")
        grep -qi "^$userid:" $filename && {
            sed -i "/^$userid:/d" $filename && {
                envia "Checkin do $malandro removido"
                echo "$userid" >> penalidades
            }
        }
    }
}