checkOverlap(){
    local data=$1 hora=$2 p d t pin start1 end1 start2 end2
    data="${data:3:2}/${data:0:2}/${data:6:4}"
    start1="$(date -d "$data $hora -03 -1 hour" +%s)"
    end1="$(date -d "$data $hora -03 +2 hours" +%s)"
    
    while IFS='|' read p d t pin; do
        start2=$( date -d "${d:3:2}/${d:0:2}/${d:6:4} $t -03 -1 hour" +%s )
        end2=$( date -d "${d:3:2}/${d:0:2}/${d:6:4} $t -03 +2 hour" +%s )
        if [[ "$end1" < "$start2" ]] || [[ "$start1" > "$end2" ]]; then
            continue
        else
            echo "$pin" "Já tem esse churras nesse horário"
            return 2
        fi
    done < CHURRAS
}