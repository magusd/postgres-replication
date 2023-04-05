#!/bin/bash

docker compose down
rm -rf data/postgres-main/*
rm -rf data/postgres-replica/*
sleep 5
docker compose up -d

sleep 20


docker compose exec postgres psql -U postgres -c "CREATE ROLE replication WITH REPLICATION PASSWORD 'replication' LOGIN;"
echo "host    replication     all             all                 md5" >> ./data/postgres-main/pg_hba.conf:
docker compose restart postgres

sleep 3
docker compose exec replica bash -c "rm -rf /var/lib/postgresql/data/*"
docker compose exec replica pg_basebackup -h postgres -p 5432 -U replication -D /var/lib/postgresql/data -Fp -Xs -R

docker compose exec postgres psql -U postgres -c "SELECT client_addr, state FROM pg_stat_replication;"
