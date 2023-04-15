#!/bin/bash
# Função para apagar a mensagem de localização
deleteLocationMessage() {
    local messageId="$1"
    echo "[-] ERROR Mensagem de Localização apagada ($messageId)"
    curl -s "$apiurl/deleteMessage?chat_id=$CHATID&message_id=$messageId" && offset
}

# Função para informar que o checkin deve ser feito com Live Location
sendCheckinReminder() {
    local username="$1"
    envia "Ei, @$username! Checkin tem que ser feito com Live Location"
}

# Função principal para lidar com mensagens de localização
handleLocation() {
    local username="$1"

    # Apaga a mensagem de localização
    deleteLocationMessage "$messageId"

    # Se um churrasco estiver ativo, envia um aviso para usar Live Location
    if churrasAtivo; then
        sendCheckinReminder "$username"
    fi
}
