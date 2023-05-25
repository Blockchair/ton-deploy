#! /bin/bash

mkdir -p logs
mkdir -p template

export $(xargs < ton.env)

echo "Generating files from env"
envsubst < docker-compose.yaml.template > docker-compose.yaml
envsubst < ton.Dockerfile.template > ton.Dockerfile
envsubst < api.Dockerfile.template > api.Dockerfile
envsubst < indexer.Dockerfile.template > indexer.Dockerfile
envsubst < local_config.cfg.template > local_config.cfg

echo "Creating docker volumes \"tondata\" and \"parse_data\" and running builder container"
(docker volume create tondata && docker volume create parse_data_test) 1> /dev/null

echo "Building container from ton git"
docker build -c="6" --memory="8g" --file="builder.Dockerfile" -t ton_builder . >> ./logs/building.logs

echo "Starting docker compose with ton node"
docker-compose -f "ton-compose.yaml" up --build -d >> ./logs/ton_compose.logs

echo "Starting builder container, copying scripts and deleting it"

echo "Starting docker compose with all other services"
docker-compose -f "docker-compose.yaml" up --build --scale api=5 -d >> ./logs/services_compose.logs

echo "Moving template files to template directory"
mv api.Dockerfile.template ./template
mv docker-compose.yaml.template ./template
mv indexer.Dockerfile.template ./template
mv local_config.cfg.template ./template
mv ton.Dockerfile.template ./template
mv ton_example.env ./template

