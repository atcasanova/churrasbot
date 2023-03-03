handleLocation(){
    echo "Mensagem de localização detectada vindo de @$username. Tentando apagar $messageId em $offset"
    curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
    churrasAtivo && {
        envia "Ei, @$username! Checkin tem que ser feito com Live Location"
    }
}