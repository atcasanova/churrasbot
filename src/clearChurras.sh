clearChurras(){
    local p d t pin now churras_timestamp filename
    now=$(date +%s)
    [ ! -f CHURRAS ] && return
    while IFS='|' read p d t pin; do
        churras_timestamp=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) + 7200 ))
        (( churras_timestamp < now )) || continue
        [ ! -z "$p" ] && {
            filename="C_${p// /_}_${d//\//}"
            [ -e $filename -a ! -s $filename ] && rm $filename && echo "$filename vazio. Apagado";
        }
        echo "Churras $p em $d $t ja passou"
        sed -i "/|$pin$/d" CHURRAS
        curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
    done < CHURRAS
}
