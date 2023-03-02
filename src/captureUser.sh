# Função para capturar todo membro que envia mensagem no bot
# Captura o user Id
captureMembers(){
    local member="$1"
    grep -q "^member$" members || echo "$member" >> members
}