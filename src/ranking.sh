#!/bin/bash
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
                ranking=$(echo "$ranking" | sed "s/$edit/$pontos $penalizado (-$debito)/g" | sort -k1,1nr -k2,2)
            }
        done
    }

    [ -z "$ranking" ] && envia "Ranking ainda está vazio" || { 
        envia "$ranking" 
      
        isAdmin $username && {
            # imagem considera apenas usuários com as 3 maiores pontuações
            local points="$(cut -f1 -d" " <<< "$ranking" | sort -nur| head -3|tr '\n' '|')"
            ranking=$(grep -E "^(${points::-1}) " <<< "$ranking")

            # geração string para gerar gráfico na API do quickchart
            local users pontos score name payload
            while read score name ; do
                users+="'$name',"
                pontos+="$score,"
            done <<< "$ranking"

            ## Define o topo do gráfico em 2 pts acima da maior pontuação
            max=$(( $(head -1 <<< $ranking | cut -f1 -d" ") + 2 ))
            options=",options:{scales:{xAxes:[{ticks:{beginAtZero:true,min:0,max:$max,stepSize:1}}]}}"

            ## gera a string com nomes, pontos e opções e faz urlencoding
            payload=$(echo -ne "{type:'horizontalBar',data:{labels:[${users::-1}],datasets:[{label:'Presenças',data:[${pontos::-1}],backgroundColor:'rgba(54, 162, 235, 0.2)',borderColor:'rgba(54, 162, 235, 1)',borderWidth:1}]}$options}" | perl -pe 's/\W/"%".unpack "H*",$&/gei' )

            ## verifica se esse gráfico já foi pedido antes
            ## caso já tenha, envia o mesmo. Caso contrário, gera um novo
            if [ ! -f payload_ranking ] || [ "$payload" != "$(cat payload_ranking)" ]; then
                echo "$payload" > payload_ranking
                curl -s "$QUICKCHART/chart?c=$payload" -o chart.png
            fi

            # envia a imagem
            local result=$(curl -s -X POST "$apiurl/sendPhoto"  \
            -F "chat_id=$CHATID" \
            -F "photo=@chart.png" \
            -F "caption=Ranking" | jq '.ok')
            [ "$result" == "true" ] && \
                echo "[+] RANKING imagem enviada" || \
                echo "[-] RANKING falha no envio da imagem"
        }
    }
}