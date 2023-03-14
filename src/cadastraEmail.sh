cadastraEmail(){
    local email=${1,,}
    [[ "$email" =~ ^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$ ]] || {
        envia "Email inválido"
        return
    }

    [ ! -s EMAILS ] && {
        echo "$username:$email" >> EMAILS
        envia "Email $email cadastrado para $username"
        return
    }
    grep -q "^$username:" EMAILS && {
        sed -i "s/^$username:.*/$username:$email/g" EMAILS
        envia "Email de $username atualizado para $email"
    } || {
        echo "$username:$email" >> EMAILS
        envia "Email $email cadastrado para $username"
    }
}