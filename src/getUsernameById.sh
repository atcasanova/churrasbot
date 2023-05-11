#!/bin/bash
getUsernameById(){
    local id="$1"
    local username=$(curl -s "$apiurl/getChatMember?chat_id=$CHATID&user_id=$id" | jq -r '.result.user.username')
    local str=$(grep "^$id:" members)
    if [ "${str:=null}" == "null" ]; then
        echo "[+] USER $id:$username cadastrado"
        echo "$id:$username" >> members
    elif [ "${str}" != "$id:$username" ]; then
        echo "[+] USER $id:$username alterado"
        sed -i "s/^$id:.*/$id:$username/g" members
    fi
}