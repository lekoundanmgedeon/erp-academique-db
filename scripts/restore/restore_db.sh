#!/bin/bash
# scripts/restore/restore_db.sh
# Script pour restaurer la base PostgreSQL depuis un backup

set -e

# Variables
CONTAINER_NAME="${CONTAINER_NAME:-erp-db-dev}"  # Nom du conteneur Docker
DB_NAME="${DB_NAME:-erp_academique}"            # Nom de la DB
BACKUP_FILE="$1"                                # Chemin vers le fichier de backup à restaurer

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ Veuillez spécifier le fichier de backup à restaurer."
    echo "Usage: $0 path/to/backup_file.sql"
    exit 1
fi

echo "♻️  Restauration de la base '$DB_NAME' depuis le backup '$BACKUP_FILE'..."

# Supprimer la base existante et la recréer
docker exec -t "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"
docker exec -t "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -c "CREATE DATABASE $DB_NAME;"

# Restaurer le backup
docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$DB_NAME" < "$BACKUP_FILE"

echo "✅ Restauration terminée !"