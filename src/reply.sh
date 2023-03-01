reply(){
    local reply_to="$1"
    shift
    curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id="$CHATID" \
    -F reply_to_message_id="$reply_to"
    echo
}