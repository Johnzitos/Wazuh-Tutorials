# Atualização Remota de Agentes Wazuh

<div align="center">

<img src="https://github.com/user-attachments/assets/709d0381-0ac0-42a2-9efc-2ae8af84576c" alt="Agentes listados com status Active" width="90%"/>
</div>

---

## 1. Contexto

Neste tutorial, será apresentado o procedimento para **atualização remota de agentes Wazuh** a partir do **Wazuh Manager**, utilizando o mecanismo oficial de pacotes **WPK (Wazuh Package)**.

O objetivo é guiar o analista durante todo o processo, explicando não apenas os comandos executados, mas também o motivo de cada etapa. O foco é garantir uma atualização controlada, previsível e com validações claras, reduzindo riscos operacionais em ambientes de SOC.

---

## 2. O que será feito

Ao longo deste procedimento, você irá validar o estado atual dos agentes conectados ao Manager, realizar a atualização inicial em um agente piloto e, após confirmação do sucesso, executar a atualização em massa dos demais agentes.

Ao final, serão feitas verificações para confirmar que todos os agentes estão atualizados, ativos e se comunicando corretamente com o Manager.

---

## 3. Premissas Técnicas Importantes

Antes de prosseguir, é fundamental compreender uma limitação importante do Wazuh relacionada ao versionamento.

O Wazuh **não permite que agentes estejam em uma versão superior à versão do Manager**. Isso significa que qualquer tentativa de atualização de agentes acima da versão do Manager resultará em falha.

De forma prática, a seguinte regra sempre deve ser respeitada:

* A versão do **Manager** deve ser maior ou igual à versão dos **Agentes**

Exemplo:

* Manager: 4.7.0
* Agentes permitidos: até 4.7.0

---

## 4. Pré-requisitos

Antes de iniciar a execução, confirme que o ambiente está em um estado previsível. Essa validação inicial reduz a chance de falhas durante o procedimento.

Garanta que você possui acesso administrativo ao Wazuh Manager, que os agentes estejam com status **Active** e que exista comunicação estável entre o Manager e os endpoints.

Em ambientes produtivos, confirme também que a atividade está sendo executada dentro de uma janela de mudança aprovada.

---

## 5. Ambiente de Referência

Este tutorial foi validado considerando o seguinte cenário:

* Wazuh Manager em ambiente Linux
* Agentes Wazuh previamente registrados e ativos
* Comunicação funcional entre Manager e agentes

Diferenças de versão ou topologia podem exigir ajustes pontuais no procedimento.

---

## 6. Procedimento Operacional

### 6.1 Verificação do estado atual dos agentes

O primeiro passo é entender quais agentes estão registrados no Manager, qual o status de cada um e quais versões estão atualmente instaladas. Essa verificação evita tentativas de atualização em agentes inativos ou já atualizados.

No Wazuh Manager, execute o comando abaixo:

```bash
/var/ossec/bin/agent_control -l
```

Analise a saída do comando e confirme o ID, hostname, versão e status dos agentes listados.


<div align="center">

<img src="https://github.com/user-attachments/assets/3a031a31-7680-48f8-8b61-d72e15aa6a56" alt="Agentes listados com status Active" width="90%"/>

</div>

---

### 6.2 Atualização de agente piloto

Antes de realizar qualquer atualização em massa, é recomendável selecionar um **agente piloto**. Esse agente deve representar um perfil comum do ambiente e serve como validação inicial do processo.

Execute o comando abaixo substituindo o ID pelo agente escolhido:

```bash
/var/ossec/bin/agent_upgrade -a <ID_DO_AGENTE>
```

Exemplo:

```bash
/var/ossec/bin/agent_upgrade -a 002
```

Durante a execução, o Wazuh irá validar a compatibilidade de versão, realizar o download do pacote WPK adequado, transferir o pacote de forma segura e reiniciar o serviço do agente automaticamente.

<div align="center">

<img src="https://github.com/user-attachments/assets/be08eef6-1ac6-4324-9848-82a0ca1eae8d" alt="Agentes listados com status Active" width="90%"/>

</div>


---

### 6.3 Validação pós-upgrade do agente piloto

Após a conclusão da atualização do agente piloto, é necessário confirmar que o agente voltou a se comunicar corretamente com o Manager e que a nova versão foi aplicada.

<div align="center">

<img src="https://github.com/user-attachments/assets/93d667b4-daa8-4850-914a-26a433a7c99d" alt="Agentes listados com status Active" width="90%"/>

</div>


---

### 6.4 Atualização em massa dos agentes

Com a validação do agente piloto concluída com sucesso, é possível prosseguir com a atualização dos demais agentes.

Execute o comando abaixo para iniciar a atualização em massa:

```bash
/var/ossec/bin/agent_upgrade --all-agents
```

Recomenda-se executar esta etapa fora de horários críticos e monitorar possíveis falhas durante o processo, especialmente em servidores sensíveis.

---

## 7. Validação Final

Após a conclusão do processo, valide se todos os agentes foram atualizados corretamente.

Confirme se:

* Todos os agentes exibem a versão esperada
* O status dos agentes está como **Active**
* Não há agentes em estado de falha ou desconectados

Quando aplicável, utilize o Wazuh Dashboard para validar visualmente as versões e o estado dos agentes.

---

## 8. Logs e Análise de Falhas

Caso seja necessário investigar problemas durante ou após a atualização, utilize os logs abaixo como referência:

* Manager: `/var/ossec/logs/ossec.log`

Ao analisar os logs, procure por mensagens relacionadas a `agent_upgrade`, `wpk` ou erros de download e instalação.


<div align="center">

<img src="https://github.com/user-attachments/assets/fad3b4df-3a0d-42f7-9be9-d9b3c9fb994c" alt="Agentes listados com status Active" width="90%"/>

</div>

---

## 9. Observações Operacionais

Após a execução deste procedimento, considere as seguintes boas práticas:

* Sempre atualizar o Manager antes dos agentes
* Manter consistência de versões reduz ruído operacional
* Registrar falhas e ações corretivas
* Utilizar este documento como runbook e evidência de mudança

---

## 11. Próximos Passos

Após a conclusão, recomenda-se:

* Monitorar os agentes nas horas seguintes à atualização
* Planejar atualizações futuras conforme o ciclo de versões do Wazuh
* Revisar este procedimento caso novas versões introduzam mudanças no processo

---
