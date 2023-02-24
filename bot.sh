#!/bin/bash
cd $(dirname $0)
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
    return 1
}

envia(){
    id_msg=$(curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id=$CHATID | jq -r '.result.message_id')
    echo
}

reply(){
    local reply_to="$1"
    shift
    curl -s -X POST "$apiurl/sendMessage" \
    -F text="$*" \
    -F chat_id="$CHATID" \
    -F reply_to_message_id="$reply_to"
    echo
}

offset(){
    offset=$((offset+1))
    echo ${offset:-$offset} > offset
}

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
    -F "caption=Agendamento do Churras, salve na agenda"
    rm "$filename"
}

distance(){
    local lat1 lon1 lat2 lon2 a d r=6378140 pi=3.14159265358979323846
    lat1=$(echo "scale=20; $1 * ($pi / 180)" | bc -l)
    lon1=$(echo "scale=20; $2 * ($pi / 180)" | bc -l)
    lat2=$(echo "scale=20; $3 * ($pi / 180)" | bc -l)
    lon2=$(echo "scale=20; $4 * ($pi / 180)" | bc -l)

    # Fórmula de Haversine
    a=$(echo "scale=20; s((($lat2 - $lat1) / 2))^2 + c($lat1) * c($lat2) * s(($lon2 - $lon1) / 2)^2" | bc -l)
    d=$(echo "scale=20; 2 * a(sqrt($a))" | bc -l)

    # Distância em metros, sem casas decimais
    distance=$(echo "scale=6; $r * $d " | bc)
    echo "distancia calculada: ${distance}"
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
        echo
    }
}

clearChurras(){
    local p d t pin now churras_timestamp
    now=$(date +%s)
    while IFS='|' read p d t pin; do
        churras_timestamp=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) + 7200 ))
        (( churras_timestamp < now )) || continue
        [ ! -z "$p" ] && {
            [ -e C_${p// /_}_${d//\//} -a ! -s C_${p// /_}_${d//\//} ] && rm C_${p// /_}_${d//\//} && echo "C_${p// /_}_${d//\//} vazio. Apagado";
        }
        echo "Churras $p em $d $t ja passou"
        sed -i "/$pin$/d" CHURRAS
        curl -s "$apiurl/unpinChatMessage?chat_id=$CHATID&message_id=$pin"
    done < CHURRAS
}

newchurras(){
    (( $# != 3 )) && return 2
    # pegar variáveis na posição correta
    # independente da ordem, por regex
    local data=$(grep -Eo "\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)[0-9]{2}\b" <<< "$*")
    local hora=$(grep -Eo "\b(0[0-9]|1[0-9]|2[0-3])(:|h)[0-5][0-9]\b" <<< "$*")
    local place=$(grep -Eo "\b[A-Z]+\b" <<< "${*^^}")
    local lugar latitude longitude
    # se as variáveis não forem preenchidas
    # dropa erro
    [ -z "$data" ] && { 
        echo "data invalida";
        return 1;
    }
    [ -z "$hora" ] && {
        echo "hora invalida";
        return 2;
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
    
    # chama a função de limpar churras já passados
    clearChurras

    # Caso nenhum erro seja encontrado, cadastra o churras
    envia "Churras marcado no dia $data, às ${hora//h/:} na $lugar. Checkin válido de 1h antes até 2h depois do horário."
    echo "$lugar|$data|${hora//h/:}|$id_msg" >> CHURRAS
    
    # despina o churras antigo e pina a mensagem enviada marcando churrasco
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg&disable_notification=false"

    # envia o arquivo.ics
    geraIcs "$lugar" "${data:6:4}${data:3:2}${data:0:2}" "${hora//h/:}"
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
    clearChurras
    local p d t pin now churras_timestamp ordem lugar data hora msg
    now=$(date +%s)
    while IFS='|' read p d t pin; do
        # fazer conta pra saber se tá rolando agora
        churras_timestamp=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) + 7200 ))
        (( churras_timestamp > now )) || continue
        ordem+="$churras_timestamp|$p|$d|$t|$pin\n"
    done < CHURRAS
    ordem=${ordem::-1}
    IFS='|' read churras_timestamp lugar data hora pin <<< "$(echo -e "$ordem" | sort -n | head -1)"
    (( ${churras_timestamp:-0} > now )) && \
    msg="O próximo churrasco será na $lugar, dia $data às $hora!" || \
    msg="Tá precisando cadastrar um churras novo! Tem nada chegando!"
    reply "$pin" "$msg"
}

ranking(){
    local ranking="$(cut -f1 -d: C_* | sort | uniq -c | sort -k1nr -k2| sed 's/^ \{1,\}//g')"

    # edita o ranking antes e enviar considerando penalidades cadastradas
    [ -f penalidades ] && {
        for penalizado in $(sort -u penalidades); do
            edit=$(grep -E "[0-9] +$penalizado$" <<< "$ranking")
            [ -z "$edit" ] || {
                read pontos malandro <<< "$edit"
                debito=$(grep -c "^$malandro$" penalidades)
                pontos=$(( $pontos - $debito ))
                ranking=$(echo "$ranking" | sed "s/$edit/$pontos $penalizado (-$debito)/g" | sort -nr)
            }
        done
    }

    [ -z "$ranking" ] && envia "Ranking ainda está vazio" || { 
        envia "$ranking" 
      
        isAdmin $username && {
            # geração string para gerar gráfico na API do quickchart
            local users pontos score name payload
            while read score name ; do
                users+="'$name',"
                pontos+="$score,"
            done <<< "$ranking"

            ## Define o topo do gráfico em 2 pts acima da maior pontuação
            max=$(( $(head -1 <<< $ranking | cut -f1 -d" ") + 2 ))
            options=",options:{scales:{yAxes:[{ticks:{min:0,max:$max,stepSize:1}}]}}"

            ## gera a string com nomes, pontos e opções e faz urlencoding
            payload=$(echo -ne "{type:'bar',data:{labels:[${users::-1}],datasets:[{label:'Presenças',data:[${pontos::-1}]}]}$options}" | perl -pe 's/\W/"%".unpack "H*",$&/gei' )

            ## verifica se esse gráfico já foi pedido antes
            ## caso já tenha, envia o mesmo. Caso contrário, gera um novo
            if [ ! -f payload_ranking -o "$payload" != "$(cat payload_ranking)" ]; then
                echo "$payload" > payload_ranking
                curl -s "https://quickchart.io/chart?bkg=black&c=$payload" -o chart.png
            fi

            # envia a imagem
            curl -s -X POST "$apiurl/sendPhoto"  \
            -F "chat_id=$CHATID" \
            -F "photo=@chart.png" \
            -F "caption=Ranking"
            echo
        }
    }
}

fake(){
    (( $# != 1 )) && return 2;
    churrasAtivo && {
        filename=C_${lugar// /_}_${data//\//}
        local malandro="$1"
        grep -qi "^$malandro:" $filename && {
            sed -i "/^$malandro:/d" $filename && {
                envia "Checkin do $malandro removido"
                echo "$malandro" >> penalidades
                envia "$(cut -f1 -d: $filename)"
            }
        }
    }
}

churrasAtivo(){
    clearChurras
    local p d t pin now
    now=$(date +%s)
    while IFS='|' read p d t pin; do
        horario_minimo=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) - 1800 ))
        horario_maximo=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) + 7200 ))
        (( $now <= $horario_maximo && $now >= $horario_minimo )) && {
            IFS='|' read lugar data hora pin <<< "$p|$d|$t|$pin"
            echo "$lugar $data $hora $pin ativo"
            return 0
        }
    done < CHURRAS
    return 1
}

handleLiveLocation(){
    offset
    # pegar data, hora e localização do churras atual
    churrasAtivo && {
        alvo=$(grep -m1 "^$lugar|" localizacoes)
        IFS='|' read nome lat long <<< "$alvo"

        # calcula distância do usuário até o ponto cadastrado
        distance $lat $long $latitude $longitude
        envia "O @$username está a $distance metros da $lugar."

        # deleta a mensagem de localização enviada para não poluir o grupo e compensa o offset
        curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" 

        # calcula se a distância e horário são satisfatórios.
        # se por algum motivo o cálculo da distância falhar, a distância máxima aceitavel
        # é considerada.
        echo "distancia: $distance"
        echo "$latitude $longitude"

        if (( ${distance:-$DISTANCIA} <= $DISTANCIA )); then
                        
            # verifica se o usuário já fez checkin nesse churras antes
            # caso não tenha feito, checkin aceito
            grep -q "^$username" C_${lugar// /_}_${data//\//} && {
                envia "Checkin ja realizado ☑";
            } || {
                envia "Checkin realizado ✅"
                echo "$username:$lugar:$(date +%s)" >> C_${lugar// /_}_${data//\//}
            }
        else
            envia "Checkin proibido! 🛑 Chora, @$username"
        fi
    } || curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" 
}

handleMessage(){
    offset
    comando="$(echo ${text//_/ }| sed -e 's/ \+$//g' | sed "s/$BOTNAME//g")"
    echo ":$comando:"
    case "$comando" in
        /newchurras\ *)   isAdmin && newchurras ${comando//\/newchurras /};;
        /newplace\ *)     isAdmin && newplace ${comando//\/newplace /};;
        /fake\ *)         isAdmin && fake ${comando//\/fake /};;
        /qualchurras)     qualchurras;;
        /ranking)         ranking;;
        /help)            ajuda;;
    esac
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
            handleLiveLocation
        # se for uma mensagem de localização normal (live_location vazio, mas longitude preenchida)
        # apaga a mensagem e compensa o offset
        elif [ "$longitude" != "null" ]; then
            echo "Mensagem de localização detectada vindo de @$username. Tentando apagar $messageId em $offset"
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
        else
            handleMessage
        fi
    done
done
