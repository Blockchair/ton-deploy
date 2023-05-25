docker-compose -f "ton-compose.yaml" down && \
docker-compose -f "docker-compose.yaml" down

docker volume rm parse_data_test tondata
docker rmi -f  ton_api nginx postgres ton_indexer ton_builder ton_node

rm docker-compose.yaml