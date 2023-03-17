# Função para verificar se um usuário é administrador
isAdmin(){
    # Percorre a lista de administradores
    for admin in ${ADMINS[@]}; do
        # Se o usuário atual for igual a um dos administradores, retorna sucesso (0)
        [ "$username" == "$admin" ] && return 0;
    done
    # Se o usuário não for encontrado na lista de administradores, retorna falha (1)
    return 1
}