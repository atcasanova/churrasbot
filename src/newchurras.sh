newchurras(){
    (( $# != 3 )) && return 2

    local argValido lugar latitude longitude
    argValido=$(validaArgumentos "$*")

    IFS='|' read -r data hora place <<< "$argValido"
    # Verifica se as variáveis foram preenchidas corretamente, senão retorna erro
    checkVars "$data" "$hora" "$place" || return 3
    
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
        local pin="$id_msg"
        echo "$lugar|$data|${hora//h/:}|$pin" >> CHURRAS
    } || {
        return 3
    }

    # Fixa a mensagem do churrasco no chat e envia o arquivo .ics
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$pin&disable_notification=false"
    geraIcs "$lugar" "${data:6:4}${data:3:2}${data:0:2}" "${hora//h/:}"
    sendLocation "$lugar"
    notificaUsers
    lembrete "$pin" "$data" "$hora"

    # Cria o arquivo de presença para o churrasco
    touch C_${lugar// /_}_${data//\//}
}