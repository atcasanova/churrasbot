#!/bin/bash
cd DIR_PLACEHOLDER
. env.sh
for i in src/*.sh; do
        . $i;
done

id="ID_PLACEHOLDER"
msg="⚠️ ⚠️ Atenção ⚠️ ⚠️ "

while read username; do
  # username=$(curl -s "$apiurl/getChatMember?chat_id=$CHATID&user_id=$id" | jq -r '.result.user.username')
  [ "$username" == "null" -o "@$username" = "$BOTNAME" ] && continue
  msg+="@$username "
done < <(shuf members)
msg=${msg::-1}

msg+="! O horário de checkin desse churras está começando!"

envia "$id" "$msg"