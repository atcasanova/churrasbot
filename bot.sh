#!/bin/bash
cd $(dirname $0)
source env.sh
DISTANCIA=150
curl -s $apiurl/getMe >/dev/null
envia() {
    id_msg=$(curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id=$CHATID | jq -r '.result.message_id')
}

offset(){
    echo $offset
    offset=$((offset+1))
    echo ${offset:-$offset} > offset
}

newchurras(){
    (( $# != 3 )) && return 2
    echo $*
    grep -qEo "^[0-9]{2}/[0-9]{2}/[0-9]{4}$" <<< "$1" || { echo "data invalida" ; return 3; }
    grep -qEo "^[0-9]{2}(:|h)[0-9]{2}$" <<< "$2" || { echo "hora invalida" ; return 3; }
    IFS='|' read lugar latitude longitude <<< "$(grep "^$3" localizacoes)"
    [[ -z "$lugar" ]] && { envia "$lugar nao sei onde é"; return 4; }
    echo "$lugar|$1|${2//h/:}" > CHURRAS
    echo "CHURRAS MARCADO $lugar|$1|${2//h/:}"
    envia "Churras marcado no dia $1. Checkin permitido até $2 na $lugar"
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg"

    touch C_${lugar// /_}_${1//\//}
}

newplace(){
    (( $# != 3 )) && return 2
    grep -qEo -- "-?[0-9]+\.[0-9]+" <<< $2 || { echo "latitude invalida"; return 3; }
    grep -qEo -- "-?[0-9]+\.[0-9]+" <<< $3 || { echo "longitude invalida"; return 3; }
    grep -iq "^$1|" localizacoes && { echo "ja existe $1"; return 3; }
    echo "${1^^}|$2|$3" >> localizacoes
    envia "${1^^} adicionado. lat: $2 long: $3"
}

qualchurras(){
    IFS='|' read loc dat hr < CHURRAS
    envia "O churrasco cadastrado é dia $dat, checkin válido até $hr, na $loc"
}

ranking(){
    local qtd=( C_* )
    local users=( $(cat C_* | cut -f1 -d: | sort -u) )
    envia "$(cut -f1 -d: C_* | sort | uniq -c | sort -nr | sed 's/^ \{1,\}//g')"
}

offset=$(cat offset)
while true; do 
    for linha in $(curl -s -X POST --data "offset=$offset&limit=1" "$apiurl/getUpdates" | \
    jq '.result[] | "\(.update_id)|\(.message.message_id)|\(.message.chat.id)|\(.message.from.username)|\(.message.date)|\(.message.location.latitude)|\(.message.location.longitude)|\(.message.location.live_period)|\(.message.text)"' -r| tr '\n' ' ' | sed 's/\\n//g' | sed 's/ /_/g'); do
        IFS='|' read offset messageId chatid username data latitude longitude live_period text <<< "$linha"
        echo "vrau linha: $linha text: $text offset: $offset"
        (( ${chatid//null/$CHATID} != CHATID )) && continue
        if [ "$live_period" != "null" ]; then
            offset
            envia "Usuário @$username enviou a localizacao $latitude,$longitude em $(date -d @$data)"
            IFS='|' read lugar data hora < CHURRAS
            alvo=$(grep -m1 "^$lugar|" localizacoes)
            IFS='|' read nome lat long <<< $alvo
            echo ./distance $lat $long $latitude $longitude
            distance=$(./distance $lat $long $latitude $longitude | cut -f1 -d.)
            envia "Usuário @$username está a $distance metros da $lugar. Checkin permitido até $data, $hora"
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
            if (( $distance <= $DISTANCIA && $(date +%s) <= $(date -d "$data $hora:59" +%s) )); then
                grep -q "^$username" C_${lugar// /_}_${data//\//} && { envia "checkin ja realizado"; } || {
                    envia "Checkin realizado."
                    echo "$username:$lugar:$(date +%s)" >> C_${lugar// /_}_${data//\//}
                }
            else
                offset
                envia "Checkin proibido"
            fi
        else
            offset
            if [ "$username" == "atc1235" ]; then
                comando="${text//_/ }"
                case "$comando" in
                    /newchurras*) newchurras ${comando//\/newchurras /}; break;;
                    /newplace*) newplace ${comando//\/newplace /}; break;;
                    /qualchurras*) qualchurras; break;;
                    /ranking*) ranking; break;;
                esac
                continue
            fi
                #grep -qE "^/newchurras " <<< "$comando" && newchurras ${comando//\/newchurras /};

            # criação de churras (arquivo CHURRAS)
            # listagem de presentes
            # ranking
            # etc
        fi
    done
done
