#!/bin/bash

source set_variables.sh

docker-compose -p $DOCKER_COMPOSE_PROJECT -f docker/dev.yml down
