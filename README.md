# Fluxxer - Stack de Desenvolvimento

Este projeto contém uma stack completa de desenvolvimento com Laravel, Vue.js, PostgreSQL, Redis e Horizon usando Docker Compose.

## 🚀 Serviços Incluídos

- **Laravel API** (Porta 8000) - Backend da aplicação
- **Vue.js Frontend** (Porta 3000) - Interface do usuário
- **PostgreSQL** (Porta 5432) - Banco de dados principal
- **Redis** (Porta 6379) - Cache e filas
- **Laravel Horizon** - Gerenciamento de filas
- **Nginx** - Servidor web para Laravel
- **pgAdmin** (Porta 5050) - Interface de administração do PostgreSQL

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Git

## 🛠️ Configuração Inicial

1. **Clone o repositório:**
   ```bash
   git clone <seu-repositorio>
   cd fluxxer_test
   ```

2. **Configure o ambiente Laravel:**
   ```bash
   # Copie o arquivo de exemplo
   cp backend/env.example backend/.env
   
   # Gere a chave da aplicação
   docker-compose run --rm app php artisan key:generate
   ```

3. **Inicie os serviços:**
   ```bash
   docker-compose up -d
   ```

4. **Execute as migrações:**
   ```bash
   docker-compose run --rm app php artisan migrate
   ```

5. **Instale as dependências do frontend:**
   ```bash
   docker-compose run --rm frontend npm install
   ```

## 🌐 Acessos

- **Laravel API:** http://localhost:8000
- **Vue.js Frontend:** http://localhost:3000
- **Laravel Horizon:** http://localhost:8000/horizon
- **pgAdmin:** http://localhost:5050
  - Email: admin@fluxxer.com
  - Senha: admin123

## 📁 Estrutura de Diretórios

```
fluxxer_test/
├── docker-compose.yml
├── .gitignore
├── .dockerignore
├── backend/
│   ├── Dockerfile
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── routes/
│   └── .env (criado a partir de env.example)
├── frontend/
│   ├── package.json
│   ├── src/
│   └── vite.config.js
├── docker/
│   └── nginx/
│       └── conf.d/
│           └── default.conf
└── README.md
```

## 🔧 Comandos Úteis

### Gerenciar Serviços
```bash
# Iniciar todos os serviços
docker-compose up -d

# Parar todos os serviços
docker-compose down

# Ver logs de um serviço específico
docker-compose logs app
docker-compose logs frontend
docker-compose logs postgres
docker-compose logs redis

# Reiniciar um serviço específico
docker-compose restart app
```

### Laravel
```bash
# Executar comandos Artisan
docker-compose run --rm app php artisan migrate
docker-compose run --rm app php artisan make:controller UserController
docker-compose run --rm app php artisan tinker

# Instalar dependências
docker-compose run --rm app composer install
docker-compose run --rm app composer update

# Criar migrations e models
docker-compose exec app php artisan make:migration create_tasks_table
docker-compose exec app php artisan make:model Task
```

### Frontend
```bash
# Executar comandos npm
docker-compose run --rm frontend npm run dev
docker-compose run --rm frontend npm run build
docker-compose run --rm frontend npm install package-name
```

### Banco de Dados PostgreSQL
```bash
# Acessar PostgreSQL
docker-compose exec postgres psql -U fluxxer_user -d fluxxer_db

# Criar banco de dados
docker-compose exec postgres createdb -U fluxxer_user fluxxer_db

# Backup do banco
docker-compose exec postgres pg_dump -U fluxxer_user fluxxer_db > backup.sql

# Ver logs do PostgreSQL
docker-compose logs postgres
```

### Redis
```bash
# Acessar CLI do Redis
docker-compose exec redis redis-cli -a fluxxer_redis_password

# Ver logs do Redis
docker-compose logs redis
```

## 🔒 Variáveis de Ambiente

### Laravel (.env)
```env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=fluxxer_db
DB_USERNAME=fluxxer_user
DB_PASSWORD=fluxxer_password

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=fluxxer_redis_password

QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
CACHE_DRIVER=redis
```

### Frontend
- `VITE_API_URL=http://localhost:8000`

## 🗄️ Configuração do Banco de Dados

### PostgreSQL
- **Host:** postgres (nome do container)
- **Porta:** 5432
- **Usuário:** fluxxer_user
- **Senha:** fluxxer_password
- **Banco:** fluxxer_db

### Redis
- **Host:** redis (nome do container)
- **Porta:** 6379
- **Senha:** fluxxer_redis_password

## 🚨 Solução de Problemas

### Porta já em uso
Se alguma porta estiver sendo usada, altere no `docker-compose.yml`:
```yaml
ports:
  - "8001:80"  # Mude de 8000 para 8001
```

### Permissões de arquivo
```bash
# Corrigir permissões do Laravel
docker-compose run --rm app chmod -R 755 storage bootstrap/cache
```

### Problemas de conexão com banco
```bash
# Verificar se PostgreSQL está rodando
docker-compose ps postgres

# Ver logs do PostgreSQL
docker-compose logs postgres

# Testar conexão
docker-compose exec app php artisan migrate:status
```

### Reconstruir containers
```bash
# Parar e remover containers
docker-compose down

# Reconstruir imagens
docker-compose build --no-cache

# Subir novamente
docker-compose up -d
```

### Limpar volumes
```bash
# Remover todos os dados (CUIDADO!)
docker-compose down -v
```

## 📝 Notas

- **PostgreSQL** é usado como banco de dados principal (não SQLite)
- O **Redis** está configurado com senha para maior segurança
- O **Horizon** está configurado para usar Redis como driver de filas
- Todos os serviços estão na mesma rede Docker para comunicação interna
- Os volumes são persistentes, então os dados não são perdidos ao parar os containers
- O **Laravel** está configurado para usar PostgreSQL por padrão

## 🚀 Desenvolvimento

### Criar nova migration
```bash
docker-compose exec app php artisan make:migration create_nome_tabela_table
```

### Criar novo model
```bash
docker-compose exec app php artisan make:model NomeModel
```

### Executar migrações
```bash
docker-compose exec app php artisan migrate
docker-compose exec app php artisan migrate:rollback
docker-compose exec app php artisan migrate:fresh
```

### Acessar Tinker
```bash
docker-compose exec app php artisan tinker
```

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request 