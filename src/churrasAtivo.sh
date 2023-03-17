churrasAtivo(){
    clearChurras
    local p d t id now
    now=$(date +%s)
    while IFS='|' read p d t id; do
        horario_minimo=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) - $(($ANTES*3600)) ))
        horario_maximo=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) + $(($DEPOIS*3600)) ))
        (( $now <= $horario_maximo && $now >= $horario_minimo )) && {
            IFS='|' read lugar data hora pin <<< "$p|$d|$t|$id"
            echo "$lugar $data $hora $pin ativo"
            return
        }
    done < CHURRAS
    return 1
}