# função para notificar com @mention todos os usuários
# é feito por userId para continuar notificando se o usuário mudar o nick
notificaUsers(){
    local id username msg="Atenção! "
    while read id; do
        username=$(curl -s "$apiurl/getChatMember?chat_id=$CHATID&user_id=$id" | jq -r '.result.user.username')
        [ "$username" == "null" ] && continue
        msg+="@$username "
    done < members
    msg=${msg::-1}
    msg+="! Tem churras marcado!"
}