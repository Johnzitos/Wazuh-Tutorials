<h1 align="center">Backup do Wazuh Server (Manager)</h1>

<div align="center">

<img width="90%" alt="backup" src="https://github.com/user-attachments/assets/66c82daa-1380-4e5b-b851-8d52e73b4404" />

</div>

  
## Contexto

Antes de qualquer atualização ou mudança estrutural no ambiente Wazuh, é obrigatório garantir que as configurações críticas e os dados operacionais estejam devidamente protegidos. O backup do **Wazuh Manager** permite uma recuperação rápida em caso de falhas durante upgrades, corrupção de arquivos ou erros operacionais.

Este tutorial descreve um procedimento simples, seguro e validável para realizar o backup manual dos principais componentes do Wazuh Manager em ambientes Linux, com foco em uso prático em SOC.

---

## O que será feito

Ao final deste procedimento, você terá:

* Uma cópia íntegra do arquivo de configuração principal do Manager
* Backup das regras e decoders personalizados
* Um diretório de backup identificado por data
* Evidências claras de que o backup foi realizado com sucesso

---

## Premissas técnicas importantes

Este backup cobre **configurações e customizações** do Wazuh Manager. Ele **não substitui** snapshots de VM, backups completos do sistema ou do Indexer.

O foco aqui é garantir a preservação dos elementos que normalmente são alterados manualmente por analistas e engenheiros de SOC.

---

## Pré-requisitos

Antes de iniciar, valide:

* Acesso administrativo ao servidor (`root` ou `sudo`)
* Espaço disponível em disco para armazenar o backup
* Serviço do Wazuh Manager em funcionamento

---

## Ambiente de referência

* Componente: Wazuh Server (Manager)
* Sistema operacional: Linux
* Caminho padrão de instalação: `/var/ossec`

---

## Procedimento de backup

### Criação do diretório de backup

O primeiro passo é criar um diretório dedicado para armazenar os arquivos de backup. O uso da data no nome facilita rastreabilidade e organização.

```bash
mkdir -p /tmp/wazuh_backup_$(date +%F)
```

Esse diretório será utilizado apenas para este backup específico.

---

### Backup do arquivo de configuração principal

O arquivo `ossec.conf` concentra as principais configurações do Manager, incluindo integrações, módulos e comunicação com outros componentes.

```bash
cp -p /var/ossec/etc/ossec.conf /tmp/wazuh_backup_$(date +%F)/
```

A opção `-p` garante que permissões e timestamps sejam preservados.

---

### Backup de regras personalizadas

Regras customizadas são frequentemente utilizadas para adequar o Wazuh ao contexto do ambiente monitorado. Essas regras **não podem ser perdidas**.

```bash
cp -r /var/ossec/etc/rules /tmp/wazuh_backup_$(date +%F)/
```

---

### Backup de decoders personalizados

Decoders personalizados são essenciais para correta interpretação de logs específicos. Faça o backup completo do diretório:

```bash
cp -r /var/ossec/etc/decoders /tmp/wazuh_backup_$(date +%F)/
```

---

## Backup automatizado (opcional)

Além do procedimento manual descrito neste tutorial, este repositório disponibiliza um **script de automação** para facilitar a execução do backup do Wazuh Manager em ambientes onde padronização e agilidade operacional são necessárias.

O script executa automaticamente as seguintes ações:

- Coleta dos arquivos de configuração críticos do Wazuh Manager
- Backup de regras e decoders personalizados
- Backup de integrações customizadas
- Backup das configurações do Indexer e do Dashboard (quando presentes)
- Compactação de todos os arquivos em um único arquivo `.tar.gz`, identificado por data e hora

O uso do script **não substitui o entendimento do processo**, mas reduz erros manuais e garante consistência na execução do backup.

---

## Utilizando o script de backup

O script está disponível no diretório `scripts/` deste repositório.

### Execução

```bash
chmod +x backup_wazuh.sh
./backup_wazuh.sh
```

---

## Validação do backup

Após copiar todos os arquivos, valide o conteúdo do diretório de backup:

```bash
ls -lh /tmp/wazuh_backup_$(date +%F)/
```

A saída deve exibir, no mínimo:

* `ossec.conf`
* Diretório `rules/`
* Diretório `decoders/`
<div align="center">
<img width="603" height="215" alt="backup1" src="https://github.com/user-attachments/assets/72373787-0cd6-45d5-99d3-90e1fafdbf54" />
</div>

---

## Observações operacionais

* Mantenha os backups até a conclusão bem-sucedida da atualização
* Para ambientes críticos, considere copiar o backup para um local externo
* Não edite arquivos diretamente no diretório de backup
* Este procedimento deve ser executado **antes** de qualquer upgrade do Wazuh Manager

---

## Próximos passos

Com o backup devidamente realizado e validado, o ambiente está pronto para prosseguir com o tutorial de **Atualização do Wazuh Server (Manager)**.

Este backup servirá como ponto de restauração caso qualquer inconsistência seja identificada durante ou após a atualização.
