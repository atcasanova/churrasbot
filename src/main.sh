main(){
    response=$(curl -s -X POST --data "offset=$offset&limit=1" "$apiurl/getUpdates" | \
        jq '.result[] | "\(.update_id)|\(.message.message_id)|\(.message.chat.id)|\(.message.from.username)|\(.message.from.id)|\(.message.date)|\(.message.location.latitude)|\(.message.location.longitude)|\(.message.location.live_period)|\(.message.text)"' -r)

    [ -z "$response" ] && { sleep 1; return; }
    IFS='|' read offset messageId chatid username userid data latitude longitude live_period text <<< "$response"
    echo "$offset|$messageId|$chatid|$userid|$username|$data|$latitude|$live_period|$text"
    captureUser "$username"
    
    # Ignorar mensagens que não são do grupo $CHATID
    (( ${chatid//null/$CHATID} != $CHATID )) && { offset; return; }

    # Tratar live location
    if [ "$live_period" != "null" ]; then
        handleLiveLocation "$username" "$latitude" "$longitude"
    # Tratar localização normal e apagar a mensagem
    elif [ "$longitude" != "null" ]; then
        handleLocation "$username"
    # Tratar mensagem de texto
    else
        handleMessage "$text"
    fi
    sleep 1
}