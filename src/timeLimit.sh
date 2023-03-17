# Função para verificar se um churrasco foi marcado com pelo menos 18 horas de antecedência
timeLimit(){
    local d="$1" t="$2" horas_limite now churras_timestamp diff
    horas_limite=$(( ${ANTECEDENCIA:-18} * 60 * 60 )) # Converte horas em segundos

    now=$(date +%s) # Obtém o timestamp atual
    churras_timestamp=$(( $(date -d "${d:3:2}/${d:0:2}/${d:6:4} $t" +%s) )) # Obtém o timestamp do churrasco

    diff=$(( $churras_timestamp - $now )) # Calcula a diferença entre os dois timestamps

    # Se a diferença for menor que 18 horas, retorna erro
    (( diff > horas_limite )) || {
        envia "Churras deve ser marcado com no mínimo 18h de antecedência"
        return 1
    }

    # Caso contrário, retorna sucesso
    return
}