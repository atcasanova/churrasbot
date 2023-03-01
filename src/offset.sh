offset(){
    offset=$((offset+1))
    echo ${offset:-$offset} > offset
}