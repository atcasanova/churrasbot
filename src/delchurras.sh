delchurras(){
    (( $# != 3 )) && return 2
    # pegar variáveis na posição correta
    # independente da ordem, por regex
    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")
    # se as variáveis não forem preenchidas
    # dropa erro
    [ -z "$data" ] && { 
        echo "data invalida";
        return 1;
    }
    [ -z "$hora" ] && {
        echo "hora invalida";
        return 2;
    }
    [ -z "$place" ] && {
        echo "local invalido";
        return 3;
    }
    local p d t pin
    IFS='|' read p d t pin <<< $(grep -m1 "$place|$data|${hora//h/:}" CHURRAS)
    [ ! -z "$pin" ] && {
        filename="C_${p// /_}_${d//\//}"
        [ -e $filename -a ! -s $filename ] && rm $filename && echo "$filename vazio. Apagado";
        envia "$pin" "Esse churrasco foi cancelado!"
        curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
        sed -i "/|$pin$/d" CHURRAS
    } || envia "Nem sei de que churrasco vc tá falando"
}