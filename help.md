**Check-in**

Quem quiser ser notificado por e-mail dos churrascos deve utilizar o comando 

```
/email seu@email
```

O checkin só é válido por meio de envio de mensagem **live location** pelo Telegram. **A localização normal é ignorada**, pois pode ser spoofada pelo próprio Telegram. 

Caso a localização seja enviada dentro do prazo (1h antes até 2h depois do horário marcado) e dentro da distância configurada (hoje em 150m do ponto cadastrado no arquivo `localizacoes`), o checkin será contabilizado.

Sempre que uma mensagem com localização for processada pelo bot, ela será deletada do grupo para evitar poluição (às vezes dá pau, mas paciência)

Um admin pode cancelar checkins de malandros usando fake GPS:

```
/fake nome_do_usuario
```

Esse comando retira o checkin de quem tentou roubar e retira um ponto do malandro no ranking (além de perder o ponto roubado, perde mais um)