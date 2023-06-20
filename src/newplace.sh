#!/bin/bash
places(){
    local places=$(cut -f1 -d'|' localizacoes | sort)
    envia "$places"
}

newplace(){
    (( $# < 4 )) && return 2
    local venue="$1"
    local latitude="$2"
    local longitude="$3"
    shift 3
    local endereco="$*"

    # verifica porcamente por expressão regular o formato de latitude e longitude
    # caso não dê match retorna erro
    [[ "$latitude" =~ ^-?[0-9]+\.[0-9]+$ ]] || {
        echo "[-] ERROR newplace: latitude invalida";
        return 3;
    }
    [[ "$longitude" =~ ^-?[0-9]+\.[0-9]+$ ]] || {
        echo "[-] ERROR newplace: longitude invalida";
        return 3;
    }

    # pesquisa o nome informado na lista de localizações cadastradas
    # caso já exista, retorna erro.
    [ -f localizacoes ] && {
        grep -iq "^$venue|" localizacoes && {
            echo "[-] ERROR newplace: ja existe $venue";
            return 3;
        }
    }

    # caso nenhum erro seja retornado, cadastra a localização
    # e envia confirmação no grupo
    echo "${venue^^}|$latitude|$longitude" >> localizacoes
    echo "${venue^^}|$endereco" >> enderecos
    echo "[+] NEWPLACE: ${venue^^} cadastrado"
    envia "${venue^^} adicionado. lat: $latitude long: $longitude"
}
