# CHURRASBOT

Esse é o CHURRASBOT, criado para validar a presença dos competidores nos churrascos da temporada. Acabou a conversa fiada, agora saberemos quem são os campeões

## Funcionamento
O arquivo `distance.c` deve ser compilado novamente para evitar problemas de glib

```gcc distance.c -lm -o distance```

O admin (eu) deve cadastrar previamente o local onde o churrasco será realizado, com o seguinte comando:

```/newplace VENUE lat long```

onde `VENUE` é o nome do local a ser utilizado no bot futuramente (sem espaços, por favor) e `lat` e `long` são a latitude e longitude base do lugar.

O admin (eu) pode criar novos churrascos com o seguinte comando:

```/newchurras dd/mm/aaaa HH:MM VENUE```

Esse comando estabelece o dia e a hora limite para o checkin no churrasco, que só é válido por meio de envio de mensagem *live location* pelo telegram. A localização normal não funciona.

## Demais comandos
* `/ranking` mostra o ranking de presenças
* `/qualchurras` mostra o próximo churrasco marcado
