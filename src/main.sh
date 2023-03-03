main(){
    for linha in $(curl -s -X POST --data "offset=$offset&limit=1" "$apiurl/getUpdates" | \
    jq '.result[] | "\(.update_id)|\(.message.message_id)|\(.message.chat.id)|\(.message.from.username)|\(.message.from.id)|\(.message.date)|\(.message.location.latitude)|\(.message.location.longitude)|\(.message.location.live_period)|\(.message.text)"' -r| tr '\n' ' ' | sed 's/\\n//g' | sed 's/ /_/g' 2>/dev/null); do
        # atribuimos os campos filtrados do json à variáveis que usaremos daqui em diante
        IFS='|' read offset messageId chatid username userid data latitude longitude live_period text <<< "$linha"
        echo "$offset|$messageId|$chatid|$userid|$username|$data|$latitude|$live_period|$text"
        captureUser "$username"
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
            handleLocation
        else
            handleMessage
        fi
    done
}