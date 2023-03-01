qualchurras(){
    clearChurras
    churrasAtivo && {
        reply "$pin" "Tá rolando esse aqui agora!"
        return
    }
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