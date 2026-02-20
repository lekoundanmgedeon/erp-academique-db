# erp-academique-db/docker/Dockerfile
FROM postgres:15

# Copie des scripts d'initialisation
COPY ../scripts/init /docker-entrypoint-initdb.d

# Définit l'encodage et locale
ENV POSTGRES_INITDB_ARGS="--encoding=UTF8 --locale=en_US.utf8"

# Expose le port PostgreSQL
EXPOSE 5432