#!/bin/bash
# função para notificar com @mention todos os usuários
# é feito por userId para continuar notificando se o usuário mudar o nick
notificaUsers(){
    local username msg="⚠️ ⚠️ Atenção ⚠️ ⚠️ "
    while read username; do
        # username=$(curl -s "$apiurl/getChatMember?chat_id=$CHATID&user_id=$id" | jq -r '.result.user.username')
        [ "$username" == "null" -o "@$username" = "$BOTNAME" ] && continue
        msg+="@$username "
    done < <(shuf members)
    msg=${msg::-1}
    msg+="! Tem churras marcado!"
    envia "$msg"
}