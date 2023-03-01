handleLiveLocation(){
    offset
    # pegar data, hora e localização do churras atual
    churrasAtivo && {
        alvo=$(grep -m1 "^$lugar|" localizacoes)
        IFS='|' read nome lat long <<< "$alvo"

        # calcula distância do usuário até o ponto cadastrado
        distance $lat $long $latitude $longitude
        envia "O @$username está a $distance metros da $lugar."

        # deleta a mensagem de localização enviada para não poluir o grupo
        curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" 

        if (( ${distance:-$DISTANCIA} <= $DISTANCIA )); then
            local filename="C_${lugar// /_}_${data//\//}"
            # verifica se o usuário já fez checkin nesse churras antes
            # caso não tenha feito, checkin aceito
            grep -q "^$username" $filename && {
                envia "Checkin ja realizado ☑";
            } || {
                envia "Checkin realizado ✅"
                echo "$username:$lugar:$(date +%s)" >> $filename
            }
        else
            envia "Checkin proibido! 🛑 Chora, @$username"
        fi
    } || curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" 
}