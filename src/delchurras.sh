delchurras(){
    if (( $# != 3 )); then
        return 2
    fi

    local data hora place argValido churrasco
    argValido=$(validaArgumentos "$*")
    
    IFS='|' read -r data hora place <<< "$argValido"
    
    checkVars "$data" "$hora" "$place" || return 3

    churrasco=$(achaChurras "$argValido")
    echo "deletaChurras \"$churrasco\""
    deletaChurras "$churasco"
}

deletaChurras(){
    local p d t pin
    IFS='|' read -r p d t pin <<< "$*"

    if [[ ! -z "$pin" ]]; then
        filename="C_${p// /_}_${d//\//}"
        if [[ -e $filename && ! -s $filename ]]; then
            rm $filename
            echo "$filename vazio. Apagado"
        fi
        
        envia "$pin" "Esse churrasco foi cancelado!"
        curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
        job=$(grep "#job " reminders/run_$pin.sh | cut -f2 -d" ")
        rm reminders/run_$pin.sh reminders/$pin.sh
        atrm $job
        sed -i "/|$pin$/d" CHURRAS
    else
        envia "Nem sei de que churrasco você está falando"
    fi
}