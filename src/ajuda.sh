ajuda(){
    curl -s -X POST "$apiurl/sendMessage" \
    -F "chat_id=$CHATID" \
    -F "parse_mode=markdown" \
    -F text="$(cat help.md)" >/dev/null
}