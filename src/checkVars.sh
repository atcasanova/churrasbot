checkVars(){
    local data="$1"
    local hora="$2"
    local lugar="$3"

    [ -z "$data" ] && {
        echo "data invalida";
        return 1;
    }
    [ -z "$hora" ] && {
        echo "hora invalida";
        return 2;
    }
    [ -z "$lugar" ] && {
        echo "local invalido";
        return 3;
    }
    echo "Variáveis OK"
}