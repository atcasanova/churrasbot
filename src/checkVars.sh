checkVars(){
    local data="$1"
    local hora="$2"
    local lugar="$3"

    [ -z "$data" ] && {
        echo "[-] ERRO data invalida";
        return 1;
    }
    [ -z "$hora" ] && {
        echo "[-] ERRO hora invalida";
        return 2;
    }
    [ -z "$lugar" ] && {
        echo "[-] ERRO local invalido";
        return 3;
    }
}
