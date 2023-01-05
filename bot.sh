#!/bin/bash
cd $(dirname $0)
[ -x distance ] || gcc distance.c -lm -o distance 2>/dev/null
source env.sh
curl -s $apiurl/getMe >/dev/null
envia(){
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
    # apenas o admin pode cadastrar um novo churras
    [ "$username" == "$ADMIN" ] || return 6;
    (( $# != 3 )) && return 2
    local data="$1"
    local hora="$2"
    local place="$3"
    
    # verifica por regex o formato de data e hora informados
    # caso não dê match, retorna erro
    # TODO: melhorar a regex para não aceitar absurdos como
    # 99:99 e 82/12/9812
    [[ "$data" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]] || { 
        echo "data invalida";
        return 3;
    }
    [[ "$hora" =~ ^[0-9]{2}(:|h)[0-9]{2}$ ]] || {
        echo "hora invalida";
        return 3;
    }
    
    IFS='|' read lugar latitude longitude <<< "$(grep "^${place^^}|" localizacoes)"
    
    # caso o lugar não seja encontrado no arquivo de localizações
    # envia mensagem avisando.
    [[ -z "$lugar" ]] && {
        envia "Não sei onde é ${place^^}. Cadastre com /newplace";
        return 4;
    }

    # Caso nenhum erro seja encontrado, cadastra o churras
    echo "$lugar|$data|${hora//h/:}" > CHURRAS
    envia "Churras marcado no dia $data. Checkin permitido até ${hora//h/:} na $lugar"

    # pina a mensagem enviada marcando churrasco
    curl -s "$apiurl/pinChatMessage?chat_id=$CHATID&message_id=$id_msg"

    # cria o arquivo de presença pro churrasco
    touch C_${lugar// /_}_${1//\//}
}

newplace(){
    [ "$username" == "$ADMIN" ] || return 6;
    (( $# != 3 )) && return 2
    local venue="$1"
    local latitude="$2"
    local longitude="$3"

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
    envia "${venue^^} adicionado. lat: $latitude long: $longitude"
}

qualchurras(){
    IFS='|' read loc dat hr < CHURRAS
    envia "O último churrasco cadastrado é dia $dat, checkin válido até $hr, na $loc"
}

ranking(){
    local ranking="$(cut -f1 -d: C_* | sort | uniq -c | sort -nr | sed 's/^ \{1,\}//g')"
    [ -z $ranking ] && envia "Ranking ainda está vazio" || envia "$ranking"
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
            IFS='|' read lugar data hora < CHURRAS
            alvo=$(grep -m1 "^$lugar|" localizacoes)
            IFS='|' read nome lat long <<< "$alvo"

            # calcula distância do usuário até o ponto cadastrado
            distance=$(./distance $lat $long $latitude $longitude | cut -f1 -d.)
            envia "O @$username está a $distance metros da $lugar. Checkin permitido até $data, $hora"
            
            # deleta a mensagem de localização enviada para não poluir o grupo e compensa o offset
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset

            # calcula se a distância e horário são satisfatórios.
            # se por algum motivo o cálculo da distância falhar, a distância máxima aceitavel
            # é considerada.
            if (( ${distance:-$DISTANCIA} <= $DISTANCIA && $(date +%s) <= $(date -d "$data $hora:59" +%s) )); then
                
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
            curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
        else
            offset
            comando="${text//_/ }"
            case "$comando" in
                /newchurras*)   newchurras ${comando//\/newchurras /}; break;;
                /newplace*)     newplace ${comando//\/newplace /}; break;;
                /qualchurras*)  qualchurras; break;;
                /ranking*)      ranking; break;;
            esac
            continue
        fi
    done
done
