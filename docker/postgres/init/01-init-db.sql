-- Script de inicialização do banco de dados
-- Executado automaticamente quando o container PostgreSQL é criado pela primeira vez

-- Conectar ao banco padrão
\c postgres;

-- Criar o banco de dados principal se não existir
SELECT 'CREATE DATABASE fluxxer_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'fluxxer_test')\gexec

-- Conectar ao banco criado
\c fluxxer_test;

-- Conceder privilégios ao usuário
GRANT ALL PRIVILEGES ON DATABASE fluxxer_test TO fluxxer_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fluxxer_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fluxxer_user;

-- Configurar privilégios para futuras tabelas
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fluxxer_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fluxxer_user;