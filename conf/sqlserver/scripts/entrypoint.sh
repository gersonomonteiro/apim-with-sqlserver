#!/bin/bash

# Inicia o SQL Server em background
/opt/mssql/bin/sqlservr &

# Função para aguardar o SQL Server estar pronto
echo "Aguardando o SQL Server iniciar..."
for i in {1..50}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Wso2@Sql2026!' -C -Q "SELECT 1" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server está pronto!"
        break
    fi
    echo "Tentativa $i: SQL ainda indisponível, aguardando..."
    sleep 2
done

# 1. Cria bancos, usuários e permissões
echo "Executando init-db.sql..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Wso2@Sql2026!' -C -i /u01/init-db.sql

# 2. Executa script SHARED
echo "Configurando WSO2_SHARED_DB..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Wso2@Sql2026!' -C -d WSO2_SHARED_DB -i /opt/wso2-scripts/mssql.sql

# 3. Executa script APIM
echo "Configurando WSO2AM_DB..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Wso2@Sql2026!' -C -d WSO2AM_DB -i /opt/wso2-scripts/mssql_apimgt.sql

echo "Bancos de dados do WSO2 configurados com sucesso!"

# Mantém o processo do SQL Server em primeiro plano para o container não fechar
wait