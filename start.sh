#bin/bash
#export DOCKER_BUILDKIT=1 # or configure in daemon.json
#export COMPOSE_DOCKER_CLI_BUILD=1
./clean
docker-compose build
docker-compose up