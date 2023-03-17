envia() {
    local reply=""
    if (( $# == 2 )); then
        reply="$1"
        shift
    fi

    local CURLOPTS=(-F "text=${*// /\ }" -F chat_id="$CHATID")

    if [[ ! -z "$reply" ]]; then
        CURLOPTS+=(-F "reply_to_message_id=$reply")
    fi

    id_msg=$(curl -s -X POST "$apiurl/sendMessage" "${CURLOPTS[@]}" | jq -r '.result.message_id')
    echo
}