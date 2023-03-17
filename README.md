# CHURRASBOT

O CHURRASBOT é um bot do Telegram criado para gerenciar a presença dos participantes nos churrascos da temporada. Desenvolvido em Shell Script (Bash), o bot utiliza a API do Telegram para realizar todas as ações. Acabou a conversa fiada, agora saberemos quem são os campeões!

## Pré-Requisitos
- O projeto depende dos binários `curl`, `bc` e `at`. Certifique-se de que essas dependências estejam disponíveis no `PATH` do sistema.
- Caso queira enviar notificações por email, o `mailx` também será necessário, bem como um `SMTP` configurado.

## Configuração

* Deve ser criado um arquivo chamado `env.sh` com o seguinte conteúdo:
```bash
TOKEN="token_do_seu_bot"
apiurl="https://api.telegram.org/bot$TOKEN"
CHATID="CHAT_ID do grupo"
ADMINS=( "username_admin1" "username_admin_n" )
BOTNAME="@nomeDoBot"
DISTANCIA=150 # Distância válida para check-in (metros)
EMAIL=no
ANTES=1     # Horas antes do evento para início do check-in
DEPOIS=2    # Horas após o evento para fim do check-in
```

## Funcionalidades
### Configuração do local do churrasco
Um administrador deve cadastrar previamente o local onde o churrasco será realizado, utilizando o comando:

```/newplace VENUE lat long endereço do local no google maps```

Onde:

- `VENUE` é o nome do local a ser utilizado no bot futuramente (sem espaços, por favor)
- `lat` e `long` são a latitude e longitude base do local

### Gerenciamento de churrascos
#### Criação de churrascos

Um administrador pode criar novos churrascos com o seguinte comando:

```/newchurras dd/mm/aaaa HH:MM VENUE```

Esse comando estabelece o dia e a hora do churrasco. O check-in será válido de 1 hora antes até 2 horas depois do horário definido. A mensagem confirmando o agendamento será "pinada" no grupo e um arquivo .ics será enviado para que os usuários possam salvar o evento nas agendas.

#### Deletar churrascos
Para deletar um churrasco, um administrador pode utilizar o comando:

```/delchurras dd/mm/aaaa HH:MM VENUE```

#### Notificações por e-mail
Usuários que desejarem ser notificados por e-mail sobre novos churrascos devem cadastrar o e-mail com o comando:

```/email endereco@email.com```

### Check-in

A validação do check-in ocorre exclusivamente através do envio de uma mensagem de **localização em tempo real** pelo Telegram. A localização comum é desconsiderada, pois o próprio Telegram permite a falsificação dessas informações.

Para contabilizar o check-in, a localização deve ser enviada dentro do intervalo estabelecido (1 hora antes até 2 horas após o horário marcado) e respeitar a distância configurada (atualmente, 150 metros do ponto registrado no arquivo `localizacoes`).

Mensagens com localização processadas pelo bot são automaticamente removidas do grupo a fim de evitar poluição visual (eventuais falhas nesse processo são possíveis).

Administradores podem cancelar check-ins fraudulentos, realizados com GPS falso:

```/fake nome_do_usuario```

Esse comando anula o check-in e subtrai um ponto adicional do usuário no ranking, além do ponto associado ao check-in fraudulento.

### Comandos adicionais
| Comando       | Função                                                              |
|---------------|---------------------------------------------------------------------|
| /ranking      | Exibe o ranking de presenças                                       |
| /qualchurras  | Mostra o próximo churrasco agendado, em resposta à mensagem marcada|
| /email        | Registra o e-mail do usuário para receber notificações de churrascos|
| /help         | Exibe instruções para realizar o check-in                          |

# TODO
- [x] Implementar horário mínimo para check-in
- [x] Converter cálculo de distância de C para bc
- [x] Estabelecer prazo mínimo para agendar churrascos
- [x] Verificar conflito de horários na marcação de churrascos
- [x] Enviar notificações de churrascos por e-mail
- [x] Enviar lembrete de início do check-in no Telegram
- [ ] Enviar lembrete de término do check-in no Telegram

# Problemas conhecidos
* ~~Em algumas situações, após o envio de um check-in, o bot pode falhar no processamento do offset e não processar algumas mensagens.~~ ✅

