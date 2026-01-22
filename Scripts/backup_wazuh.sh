cat << 'EOF' > backup_wazuh.sh
#!/bin/bash
# Script de Backup Wazuh - Salva Configuracoes, Chaves e Integracoes

# Define variaveis de data e destino
DATA_ATUAL=$(date +'%Y-%m-%d_%H-%M')
NOME_ARQUIVO="wazuh_backup_$DATA_ATUAL.tar.gz"
DESTINO="/root"

echo "[INFO] Iniciando backup do Wazuh Master..."

# Cria diretorio temporario
mkdir -p /tmp/wazuh_backup_temp

echo "[INFO] Copiando configuracoes do Manager..."
# Recria estrutura de diretorios
mkdir -p /tmp/wazuh_backup_temp/var/ossec/etc/
mkdir -p /tmp/wazuh_backup_temp/var/ossec/integrations/
mkdir -p /tmp/wazuh_backup_temp/etc/wazuh-indexer/
mkdir -p /tmp/wazuh_backup_temp/etc/wazuh-dashboard/

# Copia arquivos criticos (Chaves, Configuracoes, Regras)
cp /var/ossec/etc/client.keys /tmp/wazuh_backup_temp/var/ossec/etc/ 2>/dev/null
cp /var/ossec/etc/ossec.conf /tmp/wazuh_backup_temp/var/ossec/etc/
cp /var/ossec/etc/local_internal_options.conf /tmp/wazuh_backup_temp/var/ossec/etc/ 2>/dev/null
cp -r /var/ossec/etc/rules /tmp/wazuh_backup_temp/var/ossec/etc/
cp -r /var/ossec/etc/decoders /tmp/wazuh_backup_temp/var/ossec/etc/

# Copia Integracoes (Scripts customizados)
cp -r /var/ossec/integrations/* /tmp/wazuh_backup_temp/var/ossec/integrations/ 2>/dev/null

echo "[INFO] Copiando configuracoes do Indexer e Dashboard..."
cp -r /etc/wazuh-indexer/* /tmp/wazuh_backup_temp/etc/wazuh-indexer/ 2>/dev/null
cp -r /etc/wazuh-dashboard/* /tmp/wazuh_backup_temp/etc/wazuh-dashboard/ 2>/dev/null

echo "[INFO] Compactando arquivos..."
cd /tmp/wazuh_backup_temp
tar -czvf $DESTINO/$NOME_ARQUIVO .

echo "[INFO] Limpando arquivos temporarios..."
rm -rf /tmp/wazuh_backup_temp

echo "[OK] Backup concluido com sucesso."
echo "Arquivo salvo em: $DESTINO/$NOME_ARQUIVO"
EOF
chmod +x backup_wazuh.sh
