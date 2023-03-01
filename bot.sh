#!/bin/bash
cd $(dirname $0)

load_functions(){
    for function in src/*.sh; do
        source $function
    done
}
load_functions

check_env

offset=$(cat offset)
while true; do
    load_functions
    for linha in $(curl -s -X POST --data "offset=$offset&limit=1" "$apiurl/getUpdates" | \
    jq '.result[] | "\(.update_id)|\(.message.message_id)|\(.message.chat.id)|\(.message.from.username)|\(.message.date)|\(.message.location.latitude)|\(.message.location.longitude)|\(.message.location.live_period)|\(.message.text)"' -r| tr '\n' ' ' | sed 's/\\n//g' | sed 's/ /_/g' 2>/dev/null); do

        # atribuimos os campos filtrados do json à variáveis que usaremos daqui em diante
        IFS='|' read offset messageId chatid username data latitude longitude live_period text <<< "$linha"
        echo "$offset|$messageId|$chatid|$username|$data|$latitude|$live_period|$text"
        # se a origem da mensagem ($chatid) não for o $CHATID do grupo (cadastrado no arquivo env.sh)
        # ignoramos e vamos para a próxima
        # isso faz o bot ignorar mensagens enviadas no privado
        (( ${chatid//null/$CHATID} != $CHATID )) && { offset; continue; }

        # se a mensagem enviada for uma live location, o campo 'live_period' do JSON vem prenchido
        # então se ele não for nulo, tratamos a mensagem
        if [ "$live_period" != "null" ]; then
            handleLiveLocation
        # se for uma mensagem de localização normal (live_location vazio, mas longitude preenchida)
        # apaga a mensagem e compensa o offset
        elif [ "$longitude" != "null" ]; then
            echo "Mensagem de localização detectada vindo de @$username. Tentando apagar $messageId em $offset"
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
        else
            handleMessage
        fi
    done
done