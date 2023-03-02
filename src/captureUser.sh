# Função para capturar todo membro que envia mensagem no bot
# Captura o user Id
captureUser(){
    local member="$1"
    grep -q "^member$" members || echo "$member" >> members
}