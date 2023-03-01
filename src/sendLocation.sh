sendLocation(){
    (( $# != 1 )) && return 3
    local venue address lat long
    IFS='|' read venue address <<< "$(grep "^$1|" enderecos)"
    [ -z "$venue" ] || {
        IFS='|' read venue lat long <<< "$(grep "^$1|" localizacoes)"
        curl -s $apiurl/sendVenue -F "chat_id=$CHATID" \
        -F "latitude=$lat" \
        -F "longitude=$long" \
        -F "title=${venue}" \
        -F "address=$address"
        echo
    }
}