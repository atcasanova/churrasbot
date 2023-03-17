newchurras(){
    (( $# != 3 )) && return 2
    # Extrai data, hora e lugar das entradas, usando regex
    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")
    local lugar latitude longitude

    # Verifica se as variáveis foram preenchidas corretamente, senão retorna erro
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
    
    [ ! -f localizacoes ] && {
        envia "Nenhuma localização disponível. Cadastre antes com /newplace"
        return 2
    }

    # Lê as informações do lugar no arquivo de localizações
    IFS='|' read lugar latitude longitude <<< "$(grep "^${place^^}|" localizacoes)"
    
    # Caso o lugar não seja encontrado no arquivo de localizações, envia mensagem de erro
    [[ -z "$lugar" ]] && {
        envia "Não sei onde é ${place^^}. Cadastre com /newplace nome lat long endereço";
        return 4;
    }
    
    # Limpa os churrascos passados e verifica se o novo churrasco não conflita com outro já existente
    clearChurras
    timeLimit $data ${hora//h/:} && checkOverlap $data ${hora//h/:} && {
        envia "Churras marcado no dia $data, às ${hora//h/:} na $lugar. Checkin válido de 1h antes até 2h depois do horário."
        echo "$lugar|$data|${hora//h/:}|$id_msg" >> CHURRAS
    } || {
        return 3
    }

    # Fixa a mensagem do churrasco no chat e envia o arquivo .ics
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg&disable_notification=false"
    geraIcs "$lugar" "${data:6:4}${data:3:2}${data:0:2}" "${hora//h/:}"
    sendLocation "$lugar"
    notificaUsers
    lembrete "$id_msg" "$data" "$hora"

    # Cria o arquivo de presença para o churrasco
    touch C_${lugar// /_}_${data//\//}
}