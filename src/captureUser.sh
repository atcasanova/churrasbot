# Função para capturar o userId de cada membro que envia uma mensagem ao bot
captureUser() {
    local userId="$1"

    # Verifica se o userId já está no arquivo 'members'
    if ! grep -q "^$userId$" members; then
        # Se o userId não estiver no arquivo, adiciona-o
        echo "$userId" >> members
        echo "[+] USERS Novo Usuário no grupo: $userId"
    fi
}
