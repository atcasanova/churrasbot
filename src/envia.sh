envia(){
    (( $# == 2 )) && {
        local reply="$1"
        shift
    }
    CURLOPTS=( -F "text=${*// /\ }" -F chat_id=$CHATID )
    [ ! -z "$reply" ] && CURLOPTS+=( -F "reply_to_message_id=$reply" )
    
    id_msg=$(curl -s -X POST "$apiurl/sendMessage" "${CURLOPTS[@]}" | jq -r '.result.message_id')
    echo
}