.PHONY: help build up down restart logs clean test migrate seed fresh install-frontend install-backend

# Variáveis
COMPOSE_FILE = docker-compose.yml
APP_CONTAINER = fluxxer_app
FRONTEND_CONTAINER = fluxxer_frontend
POSTGRES_CONTAINER = fluxxer_postgres
REDIS_CONTAINER = fluxxer_redis

# Comando padrão
help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Docker Compose
build: ## Constrói as imagens Docker
	docker-compose -f $(COMPOSE_FILE) build

up: ## Inicia todos os serviços
	docker-compose -f $(COMPOSE_FILE) up -d

down: ## Para todos os serviços
	docker-compose -f $(COMPOSE_FILE) down

restart: ## Reinicia todos os serviços
	docker-compose -f $(COMPOSE_FILE) restart

logs: ## Mostra logs de todos os serviços
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-app: ## Mostra logs do Laravel
	docker-compose -f $(COMPOSE_FILE) logs -f $(APP_CONTAINER)

logs-frontend: ## Mostra logs do Vue.js
	docker-compose -f $(COMPOSE_FILE) logs -f $(FRONTEND_CONTAINER)

logs-db: ## Mostra logs do PostgreSQL
	docker-compose -f $(COMPOSE_FILE) logs -f $(POSTGRES_CONTAINER)

logs-redis: ## Mostra logs do Redis
	docker-compose -f $(COMPOSE_FILE) logs -f $(REDIS_CONTAINER)

# Laravel
migrate: ## Executa as migrações do banco
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan migrate

migrate-fresh: ## Recria o banco e executa migrações
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan migrate:fresh

seed: ## Executa os seeders
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan db:seed

fresh: ## Recria o banco, executa migrações e seeders
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan migrate:fresh --seed

tinker: ## Abre o Tinker do Laravel
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan tinker

artisan: ## Executa comando Artisan (uso: make artisan cmd="make:controller UserController")
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan $(cmd)

# Frontend
install-frontend: ## Instala dependências do frontend
	docker-compose -f $(COMPOSE_FILE) run --rm $(FRONTEND_CONTAINER) npm install

dev-frontend: ## Inicia o frontend em modo desenvolvimento
	docker-compose -f $(COMPOSE_FILE) run --rm $(FRONTEND_CONTAINER) npm run dev

build-frontend: ## Constrói o frontend para produção
	docker-compose -f $(COMPOSE_FILE) run --rm $(FRONTEND_CONTAINER) npm run build

# Backend
install-backend: ## Instala dependências do backend
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) composer install

update-backend: ## Atualiza dependências do backend
	docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) composer update

# Banco de dados
db-shell: ## Acessa o shell do PostgreSQL
	docker-compose -f $(COMPOSE_FILE) exec $(POSTGRES_CONTAINER) psql -U fluxxer_user -d fluxxer_db

db-backup: ## Faz backup do banco
	docker-compose -f $(COMPOSE_FILE) exec $(POSTGRES_CONTAINER) pg_dump -U fluxxer_user fluxxer_db > backup_$(shell date +%Y%m%d_%H%M%S).sql

redis-cli: ## Acessa o CLI do Redis
	docker-compose -f $(COMPOSE_FILE) exec $(REDIS_CONTAINER) redis-cli -a fluxxer_redis_password

# Limpeza
clean: ## Remove containers, imagens e volumes não utilizados
	docker-compose -f $(COMPOSE_FILE) down -v
	docker system prune -f
	docker volume prune -f

clean-all: ## Remove tudo (CUIDADO!)
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af
	docker volume prune -f

# Desenvolvimento
setup: ## Configuração inicial do projeto
	@echo "🚀 Configurando o projeto..."
	@if [ ! -f backend/.env ]; then \
		cp backend/env.example backend/.env; \
		echo "✅ Arquivo .env criado"; \
	else \
		echo "ℹ️  Arquivo .env já existe"; \
	fi
	@echo "🔑 Gerando chave da aplicação..."
	@docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan key:generate
	@echo "📁 Configurando permissões..."
	@docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) chmod -R 755 storage bootstrap/cache
	@echo "🗄️  Executando migrações..."
	@docker-compose -f $(COMPOSE_FILE) run --rm $(APP_CONTAINER) php artisan migrate
	@echo "✅ Configuração concluída!"

status: ## Mostra o status dos serviços
	docker-compose -f $(COMPOSE_FILE) ps

# Produção
deploy: ## Deploy para produção
	@echo "🚀 Iniciando deploy..."
	@docker-compose -f docker-compose.prod.yml down
	@git pull origin main
	@docker-compose -f docker-compose.prod.yml build --no-cache
	@docker-compose -f docker-compose.prod.yml up -d
	@docker-compose -f docker-compose.prod.yml exec -T app php artisan migrate --force
	@docker-compose -f docker-compose.prod.yml exec -T app php artisan config:cache
	@docker-compose -f docker-compose.prod.yml exec -T app php artisan route:cache
	@docker-compose -f docker-compose.prod.yml exec -T app php artisan view:cache
	@echo "✅ Deploy concluído!" 