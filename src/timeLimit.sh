timeLimit(){
    local d=$1 t=$2 horas_limite now churras_timestamp diff
    horas_limite=18
    horas_limite=$(( $horas_limite * 60 * 60 )) # horas em segundos
    read d t 
    now=$(date +%s)
    churras_timestamp=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) )) 
    diff=$(( $churras_timestamp - $now ))
    (( diff > horas_limite )) || return 1
    return
}