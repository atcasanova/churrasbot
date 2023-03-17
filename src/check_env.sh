check_env() {
    if [ ! -f env.sh ]; then
        cat <<- EOF > env.sh
TOKEN=""
apiurl="https://api.telegram.org/bot\$TOKEN"
CHATID=""
ADMINS=("")
BOTNAME=""
DISTANCIA=150
EMAIL=no
ANTES=1
DEPOIS=2
EOF
        error "Arquivo env.sh não existe. Criei um modelo. Edite-o"
    else
        source env.sh

        for cmd in curl bc at; do
            command -v "$cmd" >/dev/null || error "$cmd não instalado"
        done

        mailEnabled && command -v mailx >/dev/null || error "mailx não instalado"

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