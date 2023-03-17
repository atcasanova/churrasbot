delchurras() {
    (( $# != 3 )) && return 2

    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")

    if [[ -z "$data" ]]; then
        echo "Data inválida"
        return 1
    elif [[ -z "$hora" ]]; then
        echo "Hora inválida"
        return 2
    elif [[ -z "$place" ]]; then
        echo "Local inválido"
        return 3
    fi

    local p d t pin
    IFS='|' read -r p d t pin <<< $(grep -m1 "$place|$data|${hora//h/:}" CHURRAS)

    if [[ ! -z "$pin" ]]; then
        filename="C_${p// /_}_${d//\//}"
        [[ -e $filename && ! -s $filename ]] && rm $filename && echo "$filename vazio. Apagado"
        
        envia "$pin" "Esse churrasco foi cancelado!"
        curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
        sed -i "/|$pin$/d" CHURRAS
    else
        envia "Nem sei de que churrasco você está falando"
    fi
}