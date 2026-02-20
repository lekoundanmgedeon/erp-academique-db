#!/bin/bash
# scripts/backup/backup_db.sh
# Script pour sauvegarder la base PostgreSQL

set -e

# Variables (modifiables si nécessaire)
CONTAINER_NAME="${CONTAINER_NAME:-erp-db-dev}"  # Nom du conteneur Docker
DB_NAME="${DB_NAME:-erp_academique}"            # Nom de la DB
BACKUP_DIR="${BACKUP_DIR:-$(pwd)/backups}"      # Dossier où stocker les backups
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

# Création du dossier backup si nécessaire
mkdir -p "$BACKUP_DIR"

echo "📦 Sauvegarde de la base '$DB_NAME' depuis le conteneur '$CONTAINER_NAME'..."
docker exec -t "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" "$DB_NAME" > "$BACKUP_FILE"

echo "✅ Backup terminé : $BACKUP_FILE"