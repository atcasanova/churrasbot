newchurras(){
    (( $# != 3 )) && return 2
    # pegar variáveis na posição correta
    # independente da ordem, por regex
    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")
    local lugar latitude longitude
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
    
    IFS='|' read lugar latitude longitude <<< "$(grep "^${place^^}|" localizacoes)"
    
    # caso o lugar não seja encontrado no arquivo de localizações
    # envia mensagem avisando.
    [[ -z "$lugar" ]] && {
        envia "Não sei onde é ${place^^}. Cadastre com /newplace nome lat long endereço";
        return 4;
    }
    
    # chama a função de limpar churras já passados
    clearChurras

    # Caso nenhum erro seja encontrado, cadastra o churras
    timeLimit $data ${hora//h/:} && { 
        envia "Churras marcado no dia $data, às ${hora//h/:} na $lugar. Checkin válido de 1h antes até 2h depois do horário."
        echo "$lugar|$data|${hora//h/:}|$id_msg" >> CHURRAS
    } || {
        envia "Churras deve ser marcado com no mínimo 18h de antecedência"
        return 3
    }
    
    # pina a mensagem enviada marcando churrasco
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg&disable_notification=false"

    # envia o arquivo.ics
    geraIcs "$lugar" "${data:6:4}${data:3:2}${data:0:2}" "${hora//h/:}"
    sendLocation "$lugar"
    notificaUsers

    # cria o arquivo de presença pro churrasco
    touch C_${lugar// /_}_${data//\//}
}