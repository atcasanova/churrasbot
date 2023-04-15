#!/bin/bash
checkOverlap() {
    # Retorna se o arquivo CHURRAS não existir
    [ ! -f CHURRAS ] && return

    local data=$1 hora=$2 p d t pin start1 end1 start2 end2
    # Converte a data para o formato DD/MM/YYYY
    data="${data:3:2}/${data:0:2}/${data:6:4}"

    # Calcula os timestamps de início e fim do evento atual
    start1="$(date -d "$data $hora -03 -$ANTES hour" +%s)"
    end1="$(date -d "$data $hora -03 +$DEPOIS hours" +%s)"

    # Loop pelos eventos em CHURRAS
    while IFS='|' read p d t pin; do
        # Calcula os timestamps de início e fim do evento do arquivo CHURRAS
        start2=$(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t -03 -$ANTES hour" +%s)
        end2=$(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t -03 +$DEPOIS hour" +%s)

        # Se os eventos não se sobrepõem, continua o loop
        if [[ "$end1" < "$start2" ]] || [[ "$start1" > "$end2" ]]; then
            continue
        else
            # Se os eventos se sobrepõem, envia uma mensagem e retorna 2
            envia "$pin" "Já tem esse churras nesse horário"
            echo "[-] OVERLAP já existe churrasco nesse horario"
            return 2
        fi
    done < CHURRAS
}
