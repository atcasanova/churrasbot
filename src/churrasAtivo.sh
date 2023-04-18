#!/bin/bash
churrasAtivo(){
    clearChurras
    local p d t id now horario_minimo horario_maximo
    now=$(date +%s)
    while IFS='|' read p d t id; do
        tmpd=$(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s)
        horario_minimo=$(( $tmpd - ($ANTES*3600) ))
        horario_maximo=$(( $tmpd + ($DEPOIS*3600) ))
        if (( $now <= $horario_maximo && $now >= $horario_minimo )); then
            IFS='|' read lugar data hora pin <<< "$p|$d|$t|$id"
            echo "[+] CHURRAS $lugar $data $hora $pin ativo"
            return 0
        fi
    done < CHURRAS
    return 1
}
