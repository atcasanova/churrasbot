# CHURRASBOT

Esse é o CHURRASBOT, criado para validar a presença dos competidores nos churrascos da temporada. Acabou a conversa fiada, agora saberemos quem são os campeões

## Setup
* O arquivo `distance.c` deve ser compilado novamente para evitar problemas de glib

```gcc distance.c -lm -o distance```

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
O admin (eu) deve cadastrar previamente o local onde o churrasco será realizado, com o seguinte comando:

```/newplace VENUE lat long endereço do local no google maps```

onde `VENUE` é o nome do local a ser utilizado no bot futuramente (sem espaços, por favor) e `lat` e `long` são a latitude e longitude base do lugar.

O admin (eu) pode criar novos churrascos com o seguinte comando:

```/newchurras dd/mm/aaaa HH:MM VENUE```

Esse comando estabelece o dia e a hora limite para o checkin no churrasco. Também vai colocar a mensagem confirmando o agendamento como "pinada" no grupo, além de enviar um arquivo .ics para que seja possível salvar nas agendas.

## Check-in

O checkin só é válido por meio de envio de mensagem **live location** pelo Telegram. A localização normal é ignorada, pois pode ser spoofada pelo próprio Telegram. Caso a localização seja enviada dentro do prazo cadastrado e dentro da distância configurada (hoje em 150m do ponto cadastrado no arquivo `localizacoes`), o checkin será contabilizado.

Sempre que uma mensagem com localização for processada pelo bot, ela será deletada do grupo para evitar poluição (às vezes dá pau, mas paciência)

O admin (eu) pode cancelar checkins de malandros usando fake GPS:

```/fake nome_do_usuario```

Esse comando retira o checkin de quem tentou roubar e retira um ponto do malandro no ranking.

## Demais comandos
* `/ranking` mostra o ranking de presenças
* `/qualchurras` mostra o próximo churrasco marcado

# TODO
- [x] Implementar horário mínimo para checkin 

