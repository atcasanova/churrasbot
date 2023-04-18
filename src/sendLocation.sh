#!/bin/bash
sendLocation() {
    # Verifica se o argumento foi fornecido
    (( $# != 1 )) && return 3

    local venue address lat long
    local searchString="$1"

    # Busca as informações do local no arquivo de endereços
    IFS='|' read venue address <<< "$(grep "^${searchString}|" enderecos)"

    # Verifica se o local foi encontrado
    if [ -n "$venue" ]; then
        # Busca as informações de latitude e longitude do local no arquivo de localizações
        IFS='|' read venue lat long <<< "$(grep "^${searchString}|" localizacoes)"

        # Envia a localização do local para o chat
        local ok=$(curl -s $apiurl/sendVenue \
            -F "chat_id=$CHATID" \
            -F "latitude=$lat" \
            -F "longitude=$long" \
            -F "title=${venue}" \
            -F "address=$address" | jq '.ok')
        echo
    fi
}