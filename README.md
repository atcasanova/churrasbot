# CHURRASBOT

Esse é o CHURRASBOT, criado para validar a presença dos competidores nos churrascos da temporada. Acabou a conversa fiada, agora saberemos quem são os campeões

## Setup
* Os binários `bc` e `curl` devem estar disponíveis no `PATH`

* Deve ser criado um arquivo chamado `env.sh` com o seguinte conteúdo:
```bash
TOKEN="token_do_seu_bot"
apiurl="https://api.telegram.org/bot$TOKEN"
CHATID="CHAT_ID do seu grupo"
ADMINS=( "username_do_admin1" "username_do_admin_n" )
BOTNAME="@nomeDoBot"
DISTANCIA=150 # distância em metros do ponto cadastrado para o checkin ser aceito
```

## Funcionamento
Um admin deve cadastrar previamente o local onde o churrasco será realizado, com o seguinte comando:

```/newplace VENUE lat long endereço do local no google maps```

onde `VENUE` é o nome do local a ser utilizado no bot futuramente (sem espaços, por favor) e `lat` e `long` são a latitude e longitude base do lugar.

Um admin pode criar novos churrascos com o seguinte comando:

```/newchurras dd/mm/aaaa HH:MM VENUE```

Esse comando estabelece o dia e a hora do churrasco. O checkin será válido de 1 hora antes até 2 horas depois do horário definido. Também vai colocar a mensagem confirmando o agendamento como "pinada" no grupo, além de enviar um arquivo .ics para que seja possível salvar nas agendas.

## Check-in

O checkin só é válido por meio de envio de mensagem **live location** pelo Telegram. **A localização normal é ignorada**, pois pode ser spoofada pelo próprio Telegram. 

Caso a localização seja enviada dentro do prazo (1h antes até 2h depois do horário marcado) e dentro da distância configurada (hoje em 150m do ponto cadastrado no arquivo `localizacoes`), o checkin será contabilizado.

Sempre que uma mensagem com localização for processada pelo bot, ela será deletada do grupo para evitar poluição (às vezes dá pau, mas paciência)

Um admin pode cancelar checkins de malandros usando fake GPS:

```/fake nome_do_usuario```

Esse comando retira o checkin de quem tentou roubar e retira um ponto do malandro no ranking.

## Demais comandos
| comando      | função                                                               |
|--------------|----------------------------------------------------------------------|
| /ranking     | mostra o ranking de presenças                                        |
| /qualchurras | mostra o último churras marcado, respondendo a mensagem que o marcou |
| /help        | mostra instruções para o checkin                                     |

# TODO
- [x] Implementar horário mínimo para checkin 
- [x] Converter cálculo de distância de C para bc

# KNOWN BUGS
* ~~em algumas situações, após o envio de um checkin, o bot se perde no offset e não processa algumas mensagens.~~ ✅
