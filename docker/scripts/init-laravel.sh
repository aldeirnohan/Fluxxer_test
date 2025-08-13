#!/bin/bash

# Script de inicialização do Laravel
# Executado quando o container app inicia

echo "🚀 Iniciando configuração do Laravel..."

# Aguardar PostgreSQL estar pronto
echo "⏳ Aguardando PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U fluxxer_user -d fluxxer_test; do
    echo "PostgreSQL não está pronto ainda, aguardando..."
    sleep 2
done

echo "✅ PostgreSQL está pronto!"

# Aguardar Redis estar pronto
echo "⏳ Aguardando Redis..."
until docker-compose exec -T redis redis-cli ping; do
    echo "Redis não está pronto ainda, aguardando..."
    sleep 2
done

echo "✅ Redis está pronto!"

# Verificar se o arquivo .env existe
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp .env.example .env
fi

# Gerar chave da aplicação se não existir
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Gerando chave da aplicação..."
    php artisan key:generate
fi

# Configurar permissões
echo "📁 Configurando permissões..."
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Executar migrations
echo "🗄️ Executando migrations..."
php artisan migrate --force

# Limpar caches
echo "🧹 Limpando caches..."
php artisan config:clear
php artisan route:clear
php artisan cache:clear

echo "✅ Laravel configurado com sucesso!"

# Manter o container rodando
exec php-fpm