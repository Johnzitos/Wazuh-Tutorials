# Atualização Remota de Agentes Wazuh

<img width="2816" height="1372" alt="capa" src="https://github.com/user-attachments/assets/54d90595-0c5e-4320-867e-f9c250b9ca60" />

## 1. Contexto

Este documento descreve o procedimento operacional para atualização remota de agentes **Wazuh** a partir do **Wazuh Manager**, utilizando o mecanismo oficial de pacotes **WPK (Wazuh Package)**.

O conteúdo foi estruturado para atender a um público técnico de **SOC / Blue Team / Engenharia de Segurança**, com foco em controle operacional, previsibilidade do processo e geração de evidências.

---

## 2. Premissa Técnica de Versionamento

O Wazuh **não permite** que agentes estejam em versão superior à do Manager.

Regra:

* Versão do Manager ≥ Versão dos Agentes

Exemplo:

* Manager: 4.7.0
* Agentes permitidos: até 4.7.0

Qualquer tentativa de upgrade acima da versão do Manager resultará em falha.

---

## 3. Pré-requisitos

Antes da execução do procedimento, valide:

* Acesso administrativo (root) ao servidor Wazuh Manager
* Agentes com status **Active**
* Comunicação estável entre Manager e agentes
* Acesso do Manager à internet ou a um repositório WPK interno
* Janela de mudança aprovada (quando aplicável)

<div align="center">
<img width="933" height="169" alt="Captura de tela de 2026-01-20 12-26-18" src="https://github.com/user-attachments/assets/dec44028-b344-41b9-880b-8b1e0861d864" />
</div>

---

## 4. Procedimento Operacional

### 4.1 Levantamento de Agentes e Versões

No Wazuh Manager, execute:

```bash
/var/ossec/bin/agent_control -l
```

Validar:

* ID do agente
* Hostname
* Versão instalada
* Status

<div align="center">
<img width="933" height="226" alt="Captura de tela de 2026-01-20 12-28-31" src="https://github.com/user-attachments/assets/2d6984da-bebb-4ed9-9827-45051dcab786" />
</div>

---

### 4.2 Atualização de Agente Piloto

Antes de qualquer atualização em massa, selecione um agente representativo (piloto).

```bash
/var/ossec/bin/agent_upgrade -a <ID_DO_AGENTE>
```

Exemplo:

```bash
/var/ossec/bin/agent_upgrade -a 002
```

A execução realiza automaticamente:

* Validação de versão
* Download do pacote WPK adequado
* Transferência segura
* Atualização do agente
* Reinício do serviço

<div align="center">
<img width="788" height="112" alt="Captura de tela de 2026-01-20 13-26-48" src="https://github.com/user-attachments/assets/4faf14f0-e64a-4a60-b7a6-76e7e44912e4" />
</div>

---

### 4.3 Validação Pós-Upgrade do Agente Piloto

Após a conclusão, validar o estado do agente:

```bash
/var/ossec/bin/agent_control -i <ID_DO_AGENTE>
```

Confirmar:

* Versão atualizada
* Status Active
* Comunicação com o Manager

<div align="center">
<img width="607" height="246" alt="Captura de tela de 2026-01-20 13-24-51" src="https://github.com/user-attachments/assets/f4e07b18-a933-4a55-8f50-1fa2e7d02b4d" />
</div>

---

### 4.4 Atualização em Massa

Após validação bem-sucedida do agente piloto, proceder com a atualização em lote:

```bash
/var/ossec/bin/agent_upgrade --all-agents
```

Considerações:

* Executar fora de horário crítico
* Avaliar impacto em servidores sensíveis
* Monitorar falhas durante a execução


---

## 5. Verificação Final

Após o término do processo:

* Verificar no Dashboard a versão de todos os agentes
* Confirmar status Active
* Identificar e tratar exceções

<div align="center">
<img width="1074" height="269" alt="Captura de tela de 2026-01-20 13-18-50" src="https://github.com/user-attachments/assets/c810f7b6-65b9-4f82-9c24-2903f9e09757" />
</div>

---

## 6. Logs e Análise de Falhas

### Manager

```bash
/var/ossec/logs/ossec.log
```

Analisar entradas relacionadas a:

* agent_upgrade
* wpk
* erros de download ou instalação

<div align="center">
<img width="788" height="112" alt="Captura de tela de 2026-01-20 13-26-48" src="https://github.com/user-attachments/assets/c0554bf8-730b-4ed8-8fc9-feb47fa4444f" />
</div>

---

## 7. Observações Operacionais

* O Manager deve ser atualizado antes dos agentes
* Manter consistência de versões reduz ruído operacional
* Registrar falhas e ações corretivas
* Utilizar este documento como runbook e evidência de mudança

