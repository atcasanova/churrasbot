clearChurras() {
    local place date time pin now churras_timestamp filename
    now=$(date +%s)

    [ ! -f CHURRAS ] && return

    while IFS='|' read -r place date time pin; do
        churras_timestamp=$(( $(date -d "${date:3:2}/${date:0:2}/${date:6:4} $time" +%s) + ( DEPOIS * 3600 ) ))

        if (( churras_timestamp < now )); then
            if [ ! -z "$place" ]; then
                filename="C_${place// /_}_${date//\//}"
                if [ -e "$filename" ] && [ ! -s "$filename" ]; then
                    rm "$filename"
                    echo "$filename vazio. Apagado"
                fi
            fi

            echo "Churras $place em $date $time já passou"
            sed -i "/|$pin$/d" CHURRAS
            curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
        fi
    done < CHURRAS
}
