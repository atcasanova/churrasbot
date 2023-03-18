achaChurras(){
    local place data hora
    IFS='|' read -r data hora place <<< "$*"

    grep -m1 "$place|$data|${hora//h/:}" CHURRAS
}