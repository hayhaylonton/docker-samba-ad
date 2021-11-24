#bin/bash
#export DOCKER_BUILDKIT=1 # or configure in daemon.json
#export COMPOSE_DOCKER_CLI_BUILD=1
docker-compose rm -fs
docker volume prune -f
docker network prune -f
docker-compose build
docker-compose up