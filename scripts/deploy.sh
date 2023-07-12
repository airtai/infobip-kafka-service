#!/bin/bash


if test -z "$CI_REGISTRY_IMAGE"
then
	echo "INFO: CI_REGISTRY_IMAGE variable not set, setting it to 'ghcr.io/airtai/infobip-kafka-service'"
	export CI_REGISTRY_IMAGE="ghcr.io/airtai/infobip-kafka-service"
fi

if test -z "$TAG"
then
	echo "ERROR: TAG variable must be defined, exiting"
	exit -1
fi

if test -z "$CI_REGISTRY"
then
	echo "INFO: CI_REGISTRY variable not set, setting it to 'ghcr.io'"
	export CI_REGISTRY="ghcr.io"
fi

if test -z "$GITHUB_USERNAME"
then
	echo "ERROR: GITHUB_USERNAME variable must be defined, exiting"
	exit -1
fi

if test -z "$GITHUB_PASSWORD"
then
	echo "ERROR: GITHUB_PASSWORD variable must be defined, exiting"
	exit -1
fi


if test -z "$DOMAIN"
then
	echo "ERROR: DOMAIN variable must be defined, exiting"
	exit -1
fi


echo "INFO: stopping already running docker container"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "set -a && source .env && set +a && docker-compose -p airt-service -f docker/dependencies.yml -f docker/base-server.yml -f docker/server.yml down || echo 'No containers available to stop'"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "docker container prune -f || echo 'No stopped containers to delete'"

# echo "INFO: copying docker compose files to server"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "rm -rf /home/azureuser/docker"
# scp -o StrictHostKeyChecking=no -i key.pem -r ./docker azureuser@"$DOMAIN":/home/azureuser/docker

# echo "INFO: copying .env file to server"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "rm -rf /home/azureuser/.env"
# scp -o StrictHostKeyChecking=no -i key.pem .env azureuser@"$DOMAIN":/home/azureuser/.env

# echo "INFO: Creating storage directory if it doesn't exists"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "mkdir -p /home/azureuser/storage"

# echo "INFO: pulling docker images"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "echo $GITHUB_PASSWORD | docker login -u '$GITHUB_USERNAME' --password-stdin '$CI_REGISTRY'"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "docker pull '$CI_REGISTRY_IMAGE':'$TAG'"
# sleep 10

# echo "Deleting old images"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "docker system prune -f || echo 'No images to delete'"

# echo "INFO: starting docker containers using compose files"
# ssh -o StrictHostKeyChecking=no -i key.pem azureuser@"$DOMAIN" "set -a && source .env && set +a && docker-compose -p airt-service -f docker/dependencies.yml -f docker/base-server.yml -f docker/server.yml up -d --no-recreate"
