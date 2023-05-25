FROM postgres as ton_migration

COPY --from=ton_builder /ton/medium-client/create_db.sql ./docker-entrypoint-initdb.d/init.sql
