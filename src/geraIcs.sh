geraIcs(){
    local nome="Churras @ $1"
    local base="${3//:}00"
    local inicial=$( printf '%06d' $((10#$base-10000)) ) # inicio 1h antes
    local final=$( printf '%06d' $((10#$base+20000)) ) # final 2h depois
    local inicio="$2T$inicial"
    local fim="$2T$final"
    local endereco=$(grep "^$1|" enderecos | cut -f2 -d\|)

    filename="$1_$fim.ics"
    echo -e "BEGIN:VCALENDAR\nBEGIN:VEVENT\nDESCRIPTION:$nome\\\\nCheckin:\\\\nDe ${inicial:0:2}:${inicial:2:2}\\\\nAté ${final:0:2}:${final:2:2}\nSUMMARY:$nome\nSTATUS:CONFIRMED\nDTSTART;VALUE=DATE-TIME:$inicio\nDTEND;VALUE=DATE-TIME:$fim\nLOCATION:$endereco\nEND:VEVENT\nEND:VCALENDAR" > $filename
    curl -s -X POST "$apiurl/sendDocument"  \
    -F "chat_id=$CHATID" \
    -F "document=@$filename" \
    -F "caption=Agendamento do Churras, salve na agenda" | jq '.ok'

    mailEnabled && {
        [ -s EMAILS ] && {
            local emails=$(cut -f2 -d: EMAILS | tr '\n' ',')
            emails=${emails::-1}
            echo enviando emails para $emails
            echo "Checkin de ${inicial:0:2}:${inicial:2:2} até ${final:0:2}:${final:2:2}" | mailx -a "FROM:ChurrasBot <no-reply@bru.to>" -s "$nome ${2:6:2}/${2:4:2}/${2:0:4}" -A $filename $emails
        }
    }

    rm "$filename"
}