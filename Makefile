WP_DATA = ~/inception/data/wordpress
DB_DATA = ~/inception/data/mariadb

all: up

up: build
	@mkdir -p $(WP_DATA);
	@mkdir -p $(DB_DATA);
	docker-compose -f ./srcs/docker-compose.yml up -d

down:
	docker-compose -f ./srcs/docker-compose.yml down

stop:
	docker-compose -f ./srcs/docker-compose.yml stop

start:
	docker-compose -f ./srcs/docker-compose.yml start

build:
	docker-compose -f ./srcs/docker-compose.yml build

clean:
	@docker stop $$(docker ps -qa) || true
	@docker rm $$(docker ps -qa) || true
	@docker rmi -f $$(docker images -qa) || true
	@docker volume rm $$(docker volume ls -q) || true
	@docker network rm $$(docker network ls -q) || true
	@rm -rf $(WP_DATA) 2>/dev/null || true
	@rm -rf $(DB_DATA) 2>/dev/null || true
 
re: clean up

prune: clean
	@docker system prune -a --volumes -f