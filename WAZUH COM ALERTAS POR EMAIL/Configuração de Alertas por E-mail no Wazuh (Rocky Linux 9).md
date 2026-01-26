<h1 align="center">
  Configuração de Alertas por E-mail no Wazuh (Rocky Linux 9)
<h1>
<div align="center">
  <img width="2752" height="1536" alt="email - wallpaper email" src="https://github.com/user-attachments/assets/328063c8-2d85-4455-828b-f86abbeb0947" />
  <br>
  <img src="https://img.shields.io/badge/OS-Rocky%20Linux%209-green" alt="OS Badge">
  <img src="https://img.shields.io/badge/Wazuh-Manager-blue" alt="Wazuh Badge">
</div>

----

## Contexto

A monitoria de um ambiente seguro não pode depender de um analista observando o dashboard 24 horas por dia. Para garantir uma resposta rápida a incidentes críticos, é fundamental que o SIEM seja capaz de notificar a equipe de segurança ativamente.

Como o Wazuh não suporta nativamente a autenticação moderna (OAuth/App Passwords) exigida por provedores como o Gmail, este tutorial utiliza o **Postfix** como um *SMTP Relay* local. O Postfix atua como intermediário, recebendo os alertas do Wazuh internamente e realizando a autenticação segura para entrega externa.

> **Nota de Compatibilidade:**
> Este tutorial foi validado especificamente para **Rocky Linux 9**.
> Nesta versão, o pacote de envio de e-mail via terminal (`mailx`) foi substituído pelo `s-nail`.

---

## O que será feito

Ao final deste procedimento, você terá:

* Um servidor **Postfix** configurado como Relay SMTP seguro
* Autenticação via **Senha de App** do Google
* O **Wazuh Manager** configurado para enviar e-mails em alertas críticos
* Validação do fluxo de entrega utilizando a regra personalizada **100006**

---

## Pré-requisitos

* Acesso administrativo ao servidor Wazuh Manager (**Rocky Linux 9**)
* Conexão com a internet (**porta 587 liberada**)
* Conta Gmail válida

>  **Requisito Crítico – Autenticação Google**
> Para que esta integração funcione, o Google exige o uso de uma **Senha de App**.
> Essa opção só fica disponível se a conta tiver a **Verificação em Duas Etapas (2FA)** ativada.

### Etapas no Google

1. **Ative o 2FA**
   [Tutorial oficial do Google](https://support.google.com/accounts/answer/185839?hl=pt&co=GENIE.Platform%3DDesktop)

2. **Gere a Senha de App**
   Caminho: **Segurança → Como fazer login no Google → Senhas de App**
   Crie uma senha com o nome **Wazuh** e **guarde essa senha**.

---

## Instalação das dependências

```bash
dnf install postfix cyrus-sasl-plain s-nail -y
```

---

## Procedimento de configuração

### 1. Configuração de Credenciais SASL

Crie o arquivo de senhas do Postfix:

```bash
nano /etc/postfix/sasl_passwd
```

Insira o conteúdo abaixo:

> Use a **Senha de App de 16 dígitos**, não a senha normal do Gmail.

```plaintext
[smtp.gmail.com]:587 seu.email@gmail.com:sua_senha_de_app_aqui
```

Gere o mapa de hash e ajuste as permissões:

```bash
postmap /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
```
---

### 2. Configuração do Postfix Relay

Edite o arquivo principal do Postfix:

```bash
nano /etc/postfix/main.cf
```

Adicione ao final do arquivo:

```plaintext
# Configuração de Relay Gmail para Wazuh
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
```

Ative e reinicie o serviço:

```bash
systemctl enable postfix
systemctl restart postfix
```


<div align="center">
  <img width="1000" height="97" alt="Captura de tela de 2026-01-24 10-26-12" src="https://github.com/user-attachments/assets/76dac435-1549-478a-8fcc-de53f410f1ba" width="90%">
</div>

---

### 3. Teste de envio (Pré-Wazuh)

Valide o envio de e-mail antes de configurar o SIEM:

```bash
echo "Teste de conectividade SMTP Rocky Linux 9" | mail -s "Teste Postfix" seu.email@gmail.com
```

Verifique a caixa de entrada ou spam.



<div align="center">
  <img width="651" height="549" alt="Captura de tela de 2026-01-24 10-33-29" src="https://github.com/user-attachments/assets/d861de25-717a-421a-905b-ac99d05016ce" width="90%">
</div>

---

### 4. Configuração do Wazuh Manager

Edite o arquivo de configuração global:

```bash
nano /var/ossec/etc/ossec.conf
```

Ajuste os blocos `<global>` e `<alerts>`:

```xml
<global>
  <jsonout_output>yes</jsonout_output>
  <alerts_log>yes</alerts_log>
  <logall>no</logall>
  <logall_json>no</logall_json>

  <email_notification>yes</email_notification>
  <smtp_server>localhost</smtp_server>
  <email_from>wazuh@seuservidor.com</email_from>
  <email_to>seu.email@gmail.com</email_to>
  <email_maxperhour>12</email_maxperhour>
  <email_log_source>alerts.log</email_log_source>
</global>

<alerts>
  <log_alert_level>3</log_alert_level>
  <email_alert_level>10</email_alert_level>
</alerts>
```

---

### 5. Criação de Regra de Teste

Edite o arquivo de regras locais:

```bash
nano /var/ossec/etc/rules/local_rules.xml
```

Adicione ou valide a regra **100006**:

```xml
<group name="local,syslog,sshd,">
  <rule id="100006" level="10">
    <description>Alerta por Email</description>
    <match>WazuhMailTest</match>
    <group>custom_test,</group>
  </rule>
</group>
```

Reinicie o Wazuh Manager:

```bash
systemctl restart wazuh-manager
```
---

## Validação da integração

Gere um alerta simulado:

```bash
logger -t sshd "WazuhMailTest: Teste critico de envio de email"
```

Verifique o log do Wazuh:

```bash
grep "Mail" /var/ossec/logs/ossec.log
```

**Evidência 05 — Log e e-mail recebidos**

<div align="center">
  <img width="659" height="364" alt="image" src="https://github.com/user-attachments/assets/f165d227-ea39-449e-af02-c572b5fd7940" width="90%">
</div>

---

## Troubleshooting

### Erro de autenticação SMTP

Erro típico:

```plaintext
authentication failed: 535 5.7.8 Username and Password not accepted
```

**Solução:**

* Verifique se o **2FA** está ativo
* Confirme o uso de **Senha de App**
* Gere uma nova senha e atualize o `/etc/postfix/sasl_passwd`
* Execute novamente o `postmap`

---

### Alerta não aparece no `alerts.log`

Use o teste de regras:

```bash
/var/ossec/bin/wazuh-logtest
```

Cole:

```plaintext
Jan 23 10:00:00 localhost sshd: WazuhMailTest: teste
```

Se não aparecer **Rule id: 100006**, revise o **Passo 5**.

---

## Conclusão

Com o **Postfix** atuando como relay SMTP, o Wazuh passa a ter notificação ativa por e-mail, garantindo que alertas críticos cheguem imediatamente aos responsáveis e reduzindo o tempo de resposta a incidentes.

