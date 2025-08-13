# Guia de Deploy

Este documento contém instruções para fazer deploy da aplicação em produção.

## 🚀 Deploy com Docker Compose

### 1. Preparação do Servidor

```bash
# Instalar Docker e Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Configuração de Produção

Crie um arquivo `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_HOST=postgres
      - REDIS_HOST=redis
    volumes:
      - ./backend:/var/www
      - ./backend/storage:/var/www/storage

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./backend:/var/www
      - ./docker/nginx/prod:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${DB_DATABASE}
      - POSTGRES_USER=${DB_USERNAME}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - fluxxer_network

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - fluxxer_network

volumes:
  postgres_data:
  redis_data:

networks:
  fluxxer_network:
    driver: bridge
```

### 3. Variáveis de Ambiente de Produção

Crie um arquivo `.env.production`:

```bash
APP_NAME=Fluxxer
APP_ENV=production
APP_KEY=base64:sua_chave_aqui
APP_DEBUG=false
APP_URL=https://seudominio.com

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=fluxxer_prod
DB_USERNAME=fluxxer_prod_user
DB_PASSWORD=senha_super_segura_aqui

REDIS_HOST=redis
REDIS_PASSWORD=senha_redis_segura
REDIS_PORT=6379

QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
CACHE_DRIVER=redis

MAIL_MAILER=smtp
MAIL_HOST=seu_smtp.com
MAIL_PORT=587
MAIL_USERNAME=seu_email@dominio.com
MAIL_PASSWORD=sua_senha_smtp
MAIL_ENCRYPTION=tls
```

### 4. Script de Deploy

Crie um script `deploy.sh`:

```bash
#!/bin/bash

echo "🚀 Iniciando deploy..."

# Parar containers existentes
docker-compose -f docker-compose.prod.yml down

# Fazer pull das últimas mudanças
git pull origin main

# Construir novas imagens
docker-compose -f docker-compose.prod.yml build --no-cache

# Iniciar serviços
docker-compose -f docker-compose.prod.yml up -d

# Executar migrações
docker-compose -f docker-compose.prod.yml exec app php artisan migrate --force

# Limpar cache
docker-compose -f docker-compose.prod.yml exec app php artisan config:cache
docker-compose -f docker-compose.prod.yml exec app php artisan route:cache
docker-compose -f docker-compose.prod.yml exec app php artisan view:cache

# Verificar status
docker-compose -f docker-compose.prod.yml ps

echo "✅ Deploy concluído!"
```

### 5. Configuração de SSL

Para HTTPS, configure o Nginx com SSL:

```nginx
server {
    listen 443 ssl http2;
    server_name seudominio.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # Configurações SSL recomendadas
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}

# Redirecionar HTTP para HTTPS
server {
    listen 80;
    server_name seudominio.com;
    return 301 https://$server_name$request_uri;
}
```

## 🔧 Comandos de Manutenção

```bash
# Ver logs em produção
docker-compose -f docker-compose.prod.yml logs -f app

# Backup do banco
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U $DB_USERNAME $DB_DATABASE > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U $DB_USERNAME $DB_DATABASE < backup.sql

# Atualizar apenas um serviço
docker-compose -f docker-compose.prod.yml up -d --no-deps --build app

# Verificar uso de recursos
docker stats
```

## 📊 Monitoramento

### Health Checks

Adicione health checks aos serviços:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Logs Centralizados

Para produção, considere usar um sistema de logs centralizado como ELK Stack ou Graylog.

## 🚨 Segurança

1. **Altere todas as senhas padrão**
2. **Use variáveis de ambiente para credenciais**
3. **Configure firewall para permitir apenas portas necessárias**
4. **Mantenha imagens Docker atualizadas**
5. **Use secrets do Docker para credenciais sensíveis**

## 📝 Checklist de Deploy

- [ ] Servidor configurado com Docker
- [ ] Variáveis de ambiente configuradas
- [ ] SSL configurado (se necessário)
- [ ] Banco de dados configurado
- [ ] Migrações executadas
- [ ] Cache limpo
- [ ] Health checks funcionando
- [ ] Logs sendo gerados
- [ ] Backup configurado
- [ ] Monitoramento configurado 