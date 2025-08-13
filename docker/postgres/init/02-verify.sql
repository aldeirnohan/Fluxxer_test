-- Script de verificação
-- Executado por último para confirmar que tudo foi configurado

-- Verificar bancos existentes
SELECT datname, pg_size_pretty(pg_database_size(datname)) as size 
FROM pg_database 
ORDER BY pg_database_size(datname) DESC;

-- Verificar usuários
SELECT usename, usesuper, usecreatedb 
FROM pg_user 
WHERE usename = 'fluxxer_user';

-- Verificar extensões instaladas
SELECT extname, extversion 
FROM pg_extension 
ORDER BY extname;

-- Verificar configurações
SELECT name, setting, unit 
FROM pg_settings 
WHERE name IN ('timezone', 'client_encoding', 'shared_buffers')
ORDER BY name;

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'PostgreSQL inicializado com sucesso!';
    RAISE NOTICE 'Banco: fluxxer_test';
    RAISE NOTICE 'Usuário: fluxxer_user';
    RAISE NOTICE 'Porta: 5432';
END $$;