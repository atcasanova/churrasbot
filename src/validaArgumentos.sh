#!/bin/bash
validaArgumentos(){
    local data hora place
    data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")

    echo "$data|$hora|$place"
}