check_env(){
    if [ ! -f env.sh ]; then
        echo -e 'TOKEN=""\napiurl="https://api.telegram.org/bot$TOKEN"\nCHATID=""\nADMINS=("")\nBOTNAME=""\nDISTANCIA=150' > env.sh
        error "Arquivo env.sh não existe. Criei um modelo. Edite-o"
    else
        source env.sh
        which curl >/dev/null || error "curl não instalado"
        which bc >/dev/null || error "bc não instalado"
        which at >/dev/null || error "at não instalado"
        mailEnabled && { which mailx >/dev/null || error "mailx não instalado"; }
        [ ! -d reminders ] && mkdir reminders
        [[ ! "$TOKEN" =~ [0-9]{9}:[a-zA-Z0-9_-]{35} ]] && error "Variável TOKEN inválida"
        [ -z "$CHATID" ] && error "Variável CHATID vazia"
        [[ ! "$(declare -p ADMINS)" =~ "declare -a" ]] && error "Variável ADMINS deve ser um array."
        (( ${#ADMINS[@]} < 1 )) && error "Array ADMINS sem elementos"
        (( ${#ADMINS[0]} < 1 )) && error "Array ADMINS deve ter ao menos um elemento"
        [ "${BOTNAME:0:1}" != "@" ] && error "Variável BOTNAME deve começar com @"
    fi
    curl -s $apiurl/getMe >/dev/null
}