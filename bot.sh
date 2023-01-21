#!/bin/bash
cd $(dirname $0)
touch penalidades
source env.sh
curl -s $apiurl/getMe >/dev/null

ajuda(){
    curl -s -X POST "$apiurl/sendMessage" \
    -F "chat_id=$CHATID" \
    -F "parse_mode=markdown" \
    -F text="$(cat help.md)" >/dev/null
}

isAdmin(){
    for admin in ${ADMINS[@]}; do
        [ "$username" == "$admin" ] && return 0;
    done
    reply $messageId "kkkk coitadinho do @$username"
    return 1
}

envia(){
    id_msg=$(curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id=$CHATID | jq -r '.result.message_id')
}

reply(){
    local reply_to="$1"
    shift
    curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id="$CHATID" \
    -F reply_to_message_id="$reply_to"
}

offset(){
    offset=$((offset+1))
    echo ${offset:-$offset} > offset
}

geraIcs(){
    local nome="Churras @ $1"
    local inicio="$2T100000"
    local fim="$2T${3//:}00"
    local endereco=$(grep "^$1|" enderecos | cut -f2 -d\|)

    filename="$1_$fim.ics"
    echo -e "BEGIN:VCALENDAR\nBEGIN:VEVENT\nDESCRIPTION:$nome\nSUMMARY:$nome\nSTATUS:CONFIRMED\nDTSTART;VALUE=DATE-TIME:$inicio\nDTEND;VALUE=DATE-TIME:$fim\nLOCATION:$endereco\nGEO:$4\nEND:VEVENT\nEND:VCALENDAR" > $filename
    curl -s -X POST "$apiurl/sendDocument"  \
    -F "chat_id=$CHATID" \
    -F "document=@$filename" \
    -F "caption=Agendamento do Churras, salve na agenda"
}

distance(){
    local lat1 lon1 lat2 lon2 a d r pi=3.14159265358979323846
    lat1=$(echo "scale=10; $1 * ($pi / 180)" | bc -l)
    lon1=$(echo "scale=10; $2 * ($pi / 180)" | bc -l)
    lat2=$(echo "scale=10; $3 * ($pi / 180)" | bc -l)
    lon2=$(echo "scale=10; $4 * ($pi / 180)" | bc -l)

    # Fórmula de Haversine
    a=$(echo "scale=10; s((($lat2 - $lat1) / 2))^2 + c($lat1) * c($lat2) * s(($lon2 - $lon1) / 2)^2" | bc -l)
    d=$(echo "scale=10; 2 * a(sqrt($a))" | bc -l)
    r=6378140 # Raio da Terra em km

    # Distância em km
    distance=$(echo "$r * $d " | bc)
    distance=${distance%\.*}
}

sendLocation(){
    (( $# != 1 )) && return 3
    local venue address lat long
    IFS='|' read venue address <<< "$(grep "^$1|" enderecos)"
    [ -z "$venue" ] || {
        IFS='|' read venue lat long <<< "$(grep "^$1|" localizacoes)"
        curl -s $apiurl/sendVenue -F "chat_id=$CHATID" \
        -F "latitude=$lat" \
        -F "longitude=$long" \
        -F "title=${venue}" \
        -F "address=$address"
    }
}

newchurras(){
    (( $# != 3 )) && return 2
    # pegar variáveis na posição correta
    # independente da ordem, por regex
    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")
    
    # se as variáveis não forem preenchidas
    # dropa erro
    [ -z "$data" ] && { 
        echo "data invalida";
        return 3;
    }
    [ -z "$hora" ] && {
        echo "hora invalida";
        return 3;
    }
    [ -z "$place" ] && {
        echo "local invalido";
        return 3;
    }
    
    IFS='|' read lugar latitude longitude <<< "$(grep "^${place^^}|" localizacoes)"
    
    # caso o lugar não seja encontrado no arquivo de localizações
    # envia mensagem avisando.
    [[ -z "$lugar" ]] && {
        envia "Não sei onde é ${place^^}. Cadastre com /newplace nome lat long endereço";
        return 4;
    }
    read pin pin pin pin < CHURRAS

    # Caso nenhum erro seja encontrado, cadastra o churras
    envia "Churras marcado no dia $data. Checkin permitido até ${hora//h/:} na $lugar"
    echo "$lugar|$data|${hora//h/:}|$id_msg" > CHURRAS
    
    # despina o churras antigo e pina a mensagem enviada marcando churrasco
    curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg"

    # envia o arquivo.ics
    geraIcs "$lugar" "${data:6:4}${data:3:2}${data:0:2}" "${hora//h/:}" "$latitude;$longitude"
    sendLocation "$lugar"

    # cria o arquivo de presença pro churrasco
    touch C_${lugar// /_}_${data//\//}
}

newplace(){
    (( $# < 4 )) && return 2
    local venue="$1"
    local latitude="$2"
    local longitude="$3"
    shift 3
    local endereco="$*"

    # verifica porcamente por expressão regular o formato de latitude e longitude
    # caso não dê match retorna erro
    [[ "$latitude" =~ ^-?[0-9]+\.[0-9]+$ ]] || {
        echo "latitude invalida";
        return 3;
    }
    [[ "$longitude" =~ ^-?[0-9]+\.[0-9]+$ ]] || {
        echo "longitude invalida";
        return 3;
    }

    # pesquisa o nome informado na lista de localizações cadastradas
    # caso já exista, retorna erro.
    grep -iq "^$venue|" localizacoes && {
        echo "ja existe $venue";
        return 3;
    }

    # caso nenhum erro seja retornado, cadastra a localização
    # e envia confirmação no grupo
    echo "${venue^^}|$latitude|$longitude" >> localizacoes
    echo "${venue^^}|$endereco" >> enderecos
    envia "${venue^^} adicionado. lat: $latitude long: $longitude"
}

qualchurras(){
    IFS='|' read loc dat hr pin < CHURRAS
    reply "$pin" "O último churrasco cadastrado é dia $dat, checkin válido até $hr, na $loc"
}

ranking(){
    local ranking="$(cut -f1 -d: C_* | sort | uniq -c | sort -nr | sed 's/^ \{1,\}//g')"
    for penalizado in $(sort -u penalidades); do
        edit=$(grep -E "[0-9] +$penalizado$" <<< "$ranking")
        [ -z "$edit" ] || {
            read pontos malandro <<< "$edit"
            debito=$(grep -c "^$malandro$" penalidades)
            pontos=$(( $pontos - $debito ))
            ranking=$(echo "$ranking" | sed "s/$edit/$pontos $penalizado (-$debito)/g" | sort -nr)
        }
    done
    [ -z "$ranking" ] && envia "Ranking ainda está vazio" || envia "$ranking"
}

fake(){
    (( $# != 1 )) && return 2;
    local loc dat hr pin
    IFS='|' read loc dat hr pin < CHURRAS
    filename=C_${loc// /_}_${dat//\//}
    local malandro="$1"
    grep -qi "^$malandro:" $filename && {
        sed -i "/^$malandro:$loc:/d" $filename && {
            envia "Checkin do $malandro removido"
            echo "$malandro" >> penalidades
            envia "Presenças:
$(cut -f1 -d: $filename)"
        }
    } || envia "$malandro não fez checkin nesse churras"
}

offset=$(cat offset)
while true; do 
    for linha in $(curl -s -X POST --data "offset=$offset&limit=1" "$apiurl/getUpdates" | \
    jq '.result[] | "\(.update_id)|\(.message.message_id)|\(.message.chat.id)|\(.message.from.username)|\(.message.date)|\(.message.location.latitude)|\(.message.location.longitude)|\(.message.location.live_period)|\(.message.text)"' -r| tr '\n' ' ' | sed 's/\\n//g' | sed 's/ /_/g' 2>/dev/null); do

        # atribuimos os campos filtrados do json à variáveis que usaremos daqui em diante
        IFS='|' read offset messageId chatid username data latitude longitude live_period text <<< "$linha"
        echo "$offset|$messageId|$chatid|$username|$data|$latitude|$live_period|$text"
        # se a origem da mensagem ($chatid) não for o $CHATID do grupo (cadastrado no arquivo env.sh)
        # ignoramos e vamos para a próxima
        # isso faz o bot ignorar mensagens enviadas no privado
        (( ${chatid//null/$CHATID} != $CHATID )) && { offset; continue; }

        # se a mensagem enviada for uma live location, o campo 'live_period' do JSON vem prenchido
        # então se ele não for nulo, tratamos a mensagem
        if [ "$live_period" != "null" ]; then
            offset

            # pegar data, hora e localização do churras atual
            IFS='|' read lugar data hora lixo < CHURRAS
            alvo=$(grep -m1 "^$lugar|" localizacoes)
            IFS='|' read nome lat long <<< "$alvo"

            # calcula distância do usuário até o ponto cadastrado
            distance $lat $long $latitude $longitude
            envia "O @$username está a $distance metros da $lugar. Checkin permitido de 11:00 até $data, $hora"
            
            # deleta a mensagem de localização enviada para não poluir o grupo e compensa o offset
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset

            # calcula se a distância e horário são satisfatórios.
            # se por algum motivo o cálculo da distância falhar, a distância máxima aceitavel
            # é considerada.
            data_convertida=${data:3:2}/${data:0:2}/${data:6:4}
            horario_maximo=$(date -d "$data_convertida $hora:59" +%s)
            horario_minimo=$(date -d "$data_convertida 11:00:00" +%s)
            agora=$(date +%s)
            echo "agora: $(date -d@$agora)"
            echo "minimo: $(date -d@$horario_minimo)"
            echo "maximo: $(date -d@$horario_maximo)"

            if (( ${distance:-$DISTANCIA} <= $DISTANCIA && $agora <= $horario_maximo && $agora >= $horario_minimo )); then
                
                # verifica se o usuário já fez checkin nesse churras antes
                # caso não tenha feito, checkin aceito
                grep -q "^$username" C_${lugar// /_}_${data//\//} && {
                    envia "checkin ja realizado";
                } || {
                    envia "Checkin realizado."
                    echo "$username:$lugar:$(date +%s)" >> C_${lugar// /_}_${data//\//}
                }
            else
                envia "Checkin proibido, ou tá longe ou passou da hora. Chora, @$username"
            fi
        
        # se for uma mensagem de localização normal (live_location vazio, mas longitude preenchida)
        # apaga a mensagem e compensa o offset
        elif [ "$longitude" != "null" ]; then
            echo "Mensagem de localização detectada vindo de @$username. Tentando apagar $messageId em $offset"
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
        else
            offset
            comando="$(echo ${text//_/ }| sed -e 's/ \+$//g' | sed "s/$BOTNAME//g")"
            echo ":$comando:"
            case "$comando" in
                /newchurras\ *)   isAdmin && newchurras ${comando//\/newchurras /}; break;;
                /newplace\ *)     isAdmin && newplace ${comando//\/newplace /}; break;;
                /fake\ *)         isAdmin && fake ${comando//\/fake /}; break;;
                /qualchurras)  qualchurras; break;;
                /ranking)         ranking; break;;
                /help)            ajuda; break;;
            esac
            continue
        fi
    done
done
