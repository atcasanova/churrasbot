#!/bin/bash
clearChurras(){
    local place date time pin now churras_timestamp filename tmp_churras
    now=$(date +%s)

    [ ! -f CHURRAS ] && return

    tmp_churras=$(mktemp)

    while IFS='|' read -r place date time pin; do
        [ -z "$place$date$time$pin" ] && continue
        churras_timestamp=$(( $(date -d "${date:3:2}/${date:0:2}/${date:6:4} $time" +%s) + ( DEPOIS * 3600 ) ))

        if (( churras_timestamp < now )); then
            if [ ! -z "$place" ]; then
                filename="C_${place// /_}_${date//\//}"
                if [ -e "$filename" ] && [ ! -s "$filename" ]; then
                    rm "$filename"
                    echo "[+] CHURRAS $filename vazio. Apagado"
                fi
            fi

            echo "[+] CHURRAS Churras $place em $date $time já passou, tirando pin"
            local ok=$(curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin")
        else
            echo "$place|$date|$time|$pin" >> "$tmp_churras"
        fi
    done < CHURRAS

    mv "$tmp_churras" CHURRAS
}
