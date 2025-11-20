#!/bin/bash
geraIcs(){
    local nome="Churras @ $1"
    local base="${3//:}00"

    urlencode(){
        jq -sRr @uri <<< "$1"
    }
    
    # Início e fim do evento levando em conta as horas antes e depois
    local inicial=$(printf '%06d' $((10#$base - (ANTES * 10000))))
    local final=$(printf '%06d' $((10#$base + (DEPOIS * 10000))))
    local inicio="$2T$inicial"
    local fim="$2T$final"
    
    # Recupera o endereço do evento
    local endereco=$(grep "^$1|" enderecos | cut -f2 -d\|)
    local filename="$1_$fim.ics"
    local details="Checkin: De ${inicial:0:2}:${inicial:2:2} até ${final:0:2}:${final:2:2}"
    local googleLink="https://calendar.google.com/calendar/render?action=TEMPLATE"
    googleLink+="&text=$(urlencode "$nome")"
    googleLink+="&dates=${inicio}/${fim}"
    googleLink+="&details=$(urlencode "$details")"
    googleLink+="&location=$(urlencode "$endereco")"
    
    # Cria o arquivo ICS para o evento
    echo -e "BEGIN:VCALENDAR\nBEGIN:VEVENT\nDESCRIPTION:$nome\\\\nCheckin:\\\\nDe ${inicial:0:2}:${inicial:2:2}\\\\nAté ${final:0:2}:${final:2:2}\nSUMMARY:$nome\nSTATUS:CONFIRMED\nDTSTART;VALUE=DATE-TIME:$inicio\nDTEND;VALUE=DATE-TIME:$fim\nLOCATION:$endereco\nEND:VEVENT\nEND:VCALENDAR" > $filename

    # Envia o arquivo ICS para o chat
    local ok=$(curl -s -X POST "$apiurl/sendDocument" -F "chat_id=$CHATID" -F "document=@$filename" -F "caption=Agendamento do Churras, salve na agenda" | jq '.ok')
    envia "Link para adicionar ao Google Calendar: $googleLink"

    # Se o envio de email estiver habilitado, envia o arquivo ICS por email
    if mailEnabled; then
        if [ -s EMAILS ]; then
            local emails=$(cut -f2 -d: EMAILS | tr '\n' ',')
            emails=${emails::-1}
            echo "[+] MAIL enviando emails para $emails"
            printf "Checkin de ${inicial:0:2}:${inicial:2:2} até ${final:0:2}:${final:2:2}\nAdicionar no Google Calendar: %s" "$googleLink" | mailx -a "FROM:ChurrasBot <no-reply@bru.to>" -s "$nome ${2:6:2}/${2:4:2}/${2:0:4}" -A "$filename" "$emails"
        fi
    fi

    # Remove o arquivo ICS após o envio
    rm "$filename"
}
