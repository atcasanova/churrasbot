#!/bin/bash
# Função para verificar o ambiente antes de executar o script
check_env(){
    # Verifica se o arquivo env.sh existe, caso contrário, cria um modelo e exibe um erro
    if [ ! -f env.sh ]; then
        cat > env.sh <<- EOF
	TOKEN=""
	apiurl="https://api.telegram.org/bot\$TOKEN"
	QUICKCHART="https://quickchart.io"
	CHATID=""
	ADMINS=("")
	DISTANCIA=150
	EMAIL=no
	ANTES=1
	DEPOIS=2
	ANTECEDENCIA=18
	EOF
        error "Arquivo env.sh não existe. Criei um modelo. Edite-o"
    else
        local current_timestamp=$(stat -c %Y "env.sh")
        if [[ ! -v file_timestamps["env.sh"] ]] || (( ${file_timestamps["env.sh"]} != $current_timestamp )); then
            echo "[UPDT] file env.sh created or updated"
            source env.sh
            file_timestamps["env.sh"]=$current_timestamp
        
            # Verifica a existência das dependências necessárias em um loop
            for dep in curl bc at; do
                command -v $dep >/dev/null || error "$dep não instalado"
            done

            # Verifica se o mailx está instalado se o email estiver habilitado
            mailEnabled && { command -v mailx >/dev/null || error "mailx não instalado"; }

            # Cria o diretório 'reminders' se não existir
            [ ! -d reminders ] && mkdir reminders

            # Valida as variáveis do ambiente
            [[ ! "$TOKEN" =~ [0-9]{9}:[a-zA-Z0-9_-]{35} ]] && error "Variável TOKEN inválida"
            [ -z "$CHATID" ] && error "Variável CHATID vazia"
            [[ ! "$(declare -p ADMINS)" =~ "declare -a" ]] && error "Variável ADMINS deve ser um array."
            (( ${#ADMINS[@]} < 1 )) && error "Array ADMINS sem elementos"
            (( ${#ADMINS[0]} < 1 )) && error "Array ADMINS deve ter ao menos um elemento"
        
            # Preenche BOTNAME
            [ -z $BOTNAME ] && BOTNAME="@$(curl -s $apiurl/getMe | jq -r '.result.username')"
        fi
    fi
}
