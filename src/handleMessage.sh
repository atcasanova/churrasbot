#!/bin/bash
# Função para processar e executar comandos do bot
handleCommand(){
    local comando="$1"

    case "$comando" in
        /newchurras\ *)   isAdmin && newchurras ${comando//\/newchurras /};;
        /delchurras\ *)   isAdmin && delchurras ${comando//\/delchurras /};;
        /newplace\ *)     isAdmin && newplace ${comando//\/newplace /};;
        /fake\ *)         isAdmin && fake ${comando//\/fake /};;
        /email\ *)        mailEnabled && cadastraEmail ${comando//\/email /};;
        /places)          isAdmin && places;;
        /qualchurras)     qualchurras;;
        /ranking)         ranking;;
        /ranking\ *)      ranking ${comando//\/ranking /};;
        /help)            ajuda;;
    esac
}

# Função principal para lidar com mensagens
handleMessage(){
    local comando="$(echo ${1//_/ }| sed -e 's/ \+$//g' | sed "s/$BOTNAME//g")"
    
    # Atualiza o offset
    offset

    # Processa e executa o comando
    handleCommand "$comando"
}