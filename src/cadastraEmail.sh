# Função para cadastrar ou atualizar o email de um usuário
cadastraEmail() {
    # Verifica se há exatamente um argumento
    (( $# != 1 )) && return

    # Converte o email para minúsculas
    local email="${1,,}"

    # Verifica se o email é válido
    [[ "$email" =~ ^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$ ]] || {
        envia "Email inválido"
        return
    }

    # Se o arquivo EMAILS não existe ou está vazio, cadastra o email
    [ ! -s EMAILS ] && {
        echo "$username:$email" >> EMAILS
        envia "Email $email cadastrado para $username"
        return
    }

    # Se o usuário já está cadastrado, atualiza o email, caso contrário, adiciona um novo registro
    grep -q "^$username:" EMAILS && {
        sed -i "s/^$username:.*/$username:$email/g" EMAILS
        envia "Email de $username atualizado para $email"
    } || {
        echo "$username:$email" >> EMAILS
        envia "Email $email cadastrado para $username"
    }
}