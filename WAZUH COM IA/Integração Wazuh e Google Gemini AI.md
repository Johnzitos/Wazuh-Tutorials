<h1 <p align="center">
 Integração Wazuh e Google Gemini AI
</h1>

<p <p align="center">
  <img width="2752" height="1366" alt="wallpaper" src="https://github.com/user-attachments/assets/8903d394-403b-46ac-b0ac-12c7b49d0a34" 
 width="90%">  
</p>

---

## Contexto

A operação de um SOC (Security Operations Center) moderno exige agilidade na análise e resposta a incidentes. A integração do Wazuh com a Inteligência Artificial do Google Gemini permite o enriquecimento automático dos alertas, fornecendo explicação contextualizada, sugestões de mitigação e avaliação de risco diretamente nos logs.

Este tutorial descreve a configuração passo a passo desta integração, com foco em validação técnica e geração de evidências.

---

## O que será feito

Ao final deste procedimento, você terá:

* Um script Python configurado para comunicação com a API do Google Gemini
* O Wazuh Manager enviando alertas de alta severidade para a IA
* Uma regra de teste funcional para validação do fluxo
* Tratamento de erros comuns em ambientes de laboratório

---

## Pré-requisitos

* Acesso administrativo ao servidor Wazuh Manager
* Conexão com a internet
* Python 3 instalado
* Biblioteca `requests`
* API Key válida do Google Gemini (Google AI Studio)

Instalação da dependência:

```bash
pip3 install requests
```

---

## Procedimento de configuração

### 1. Criação do script de integração

Crie o arquivo de integração no diretório padrão do Wazuh:

```bash
nano /var/ossec/integrations/custom-gemini.py
```

Insira o conteúdo abaixo e substitua `SUA_API_KEY_AQUI` pela sua chave real:

```python
#!/usr/bin/env python3
import sys
import json
import requests
import time

API_KEY = "SUA_API_KEY_AQUI"
LOG_FILE = "/var/ossec/logs/integrations.log"

def log_output(message):
    with open(LOG_FILE, "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Gemini AI: {message}\n")

def query_gemini(alert_json):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={API_KEY}"

    description = alert_json.get("rule", {}).get("description", "Alerta sem descrição")
    full_log = alert_json.get("full_log", "Sem log bruto")

    prompt = f"""
Atue como um analista de segurança sênior.
Analise o seguinte log de segurança:

Descrição: {description}
Log Bruto: {full_log}

Forneça:
1. Resumo do ocorrido
2. Nível de risco real
3. Ações de mitigação recomendadas
Seja objetivo e técnico.
"""

    payload = {"contents": [{"parts": [{"text": prompt}]}]}
    headers = {"Content-Type": "application/json"}

    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200:
            data = response.json()
            return data["candidates"][0]["content"]["parts"][0]["text"].replace("\n", " ")
        elif response.status_code == 429:
            return "Erro: cota da API excedida (rate limit)."
        else:
            return f"Erro API: {response.status_code} - {response.text}"
    except Exception as e:
        return f"Erro de conexão: {str(e)}"

try:
    alert_file = sys.argv[1]
    with open(alert_file) as f:
        alert_data = json.load(f)

    analysis = query_gemini(alert_data)
    log_output(analysis)

except Exception as e:
    log_output(f"Falha na execução do script: {str(e)}")
```
---

### 2. Ajuste de permissões

```bash
chmod 750 /var/ossec/integrations/custom-gemini.py
chown root:wazuh /var/ossec/integrations/custom-gemini.py
touch /var/ossec/logs/integrations.log
chown wazuh:wazuh /var/ossec/logs/integrations.log
chmod 664 /var/ossec/logs/integrations.log
```
---

### 3. Configuração do Wazuh Manager

Edite o arquivo de configuração:

```bash
nano /var/ossec/etc/ossec.conf
```

Adicione o bloco abaixo dentro da tag `<ossec_config>`:

```xml
<integration>
  <name>custom-gemini.py</name>
  <level>10</level>
  <group>custom_test,web,authentication</group>
  <alert_format>json</alert_format>
</integration>
```

<p <p align="center">
<img width="652" height="336" alt="red ossec config" src="https://github.com/user-attachments/assets/78e33af6-e861-4693-b5a4-36fecdfe40db" width="90%"/>
</p>
---

### 4. Criação de regra de teste

```bash
cat << 'EOF' > /var/ossec/etc/rules/local_rules.xml
<group name="local,syslog,sshd,">
  <rule id="100005" level="10">
    <description>Teste de Integração Wazuh e Gemini AI</description>
    <match>WazuhGeminiTest</match>
    <group>custom_test,</group>
  </rule>
</group>
EOF
```

---

### 5. Reinício do serviço

```bash
systemctl restart wazuh-manager
```

---

## Validação da integração

Monitore o log da integração:

```bash
tail -f /var/ossec/logs/integrations.log
```

Gere um alerta de teste:

```bash
logger -t sshd "WazuhGeminiTest: Simulando incidente critico para analise de IA"
```
<p <p align="center">
<img width="925" height="143" alt="image" src="https://github.com/user-attachments/assets/32f7c947-eefa-410f-972c-9898539eb6f6" width="90%"/>
</p>

---

## Troubleshooting

### Dashboard sem eventos / erro de SSL

Erro comum:

```text
remote error: tls: unknown certificate
```

#### Solução (ambiente de laboratório)

Edite `/etc/filebeat/filebeat.yml`:

```yaml
ssl.verification_mode: none
```

Edite `/etc/wazuh-indexer/opensearch.yml`:

```yaml
plugins.security.ssl.http.clientauth_mode: none
```

Reinicie os serviços:

```bash
systemctl restart wazuh-indexer
systemctl restart filebeat
```
<p <p align="center">
<img width="498" height="454" alt="red dashboard" src="https://github.com/user-attachments/assets/e73c0cc1-ef67-46ad-9687-2f46720d15e9" width="90%"/>
</p>
  
---

## Conclusão

Esta integração adiciona uma camada de inteligência contextual aos alertas do Wazuh, reduzindo o tempo de análise e apoiando analistas na tomada de decisão.

---

## Próximos passos

* Refinar o prompt enviado à IA
* Criar decoders para ingestão da resposta no Dashboard
* Ajustar filtros de nível e grupo para controle de custo da API
