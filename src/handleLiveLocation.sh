#!/bin/bash
handleLiveLocation(){
    # Verifica se o número de argumentos está correto
    (( $# != 4 )) && { envia "Falha no processamento da Live Location"; return 1; }

    local username="$1" latitude="$2" longitude="$3" userid="$4" lat long nome alvo
    offset

    # Verifica se há um churrasco ativo e pega os dados relevantes
    if churrasAtivo; then
        # Encontra a localização do churrasco
        alvo=$(grep -m1 "^$lugar|" localizacoes)
        IFS='|' read nome lat long <<< "$alvo"

        # Calcula a distância entre o usuário e a localização do churrasco
        distance $lat $long $latitude $longitude
        envia "O @$username está a $distance metros da $lugar."

        # Deleta a mensagem de localização enviada para evitar poluição no grupo
        local delete=$(curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" | jq '.result')
        [ "$delete" == "true" ] && echo "[+] CHECKIN Localização deletada"

        # Verifica se a distância é menor ou igual à distância permitida
        if (( ${distance:-$DISTANCIA} <= $DISTANCIA )); then
            local filename="C_${lugar// /_}_${data//\//}"
            
            # Verifica se o usuário já fez checkin neste churrasco antes
            if grep -q "^$username" $filename; then
                envia "Checkin ja realizado ☑"
                echo "[-] CHECKIN $username já fez esse checkin"
            else
                envia "Checkin realizado ✅"
                echo "$username:$lugar:$(date +%s)" >> $filename
                echo "[+] CHECKIN $username fez checkin em $lugar"
                getUsernameById "$userid"
            fi
        else
            envia "Checkin proibido! 🛑 Chora, @$username"
            echo "[-] CHECKIN checkin de $username não autorizado"
        fi
    else
         local delete=$(curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" | jq '.result')
         [ "$delete" == "true" ] && echo "[+] CHECKIN nenhum churras ativo, localização deletada"
    fi
}
