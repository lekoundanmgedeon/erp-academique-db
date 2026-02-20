#!/bin/bash
set -e

# Définit l'environnement par défaut si non fourni
ENV_TYPE=${ENV_TYPE:-dev}
echo "📦 Initialisation de la base pour l'environnement : $ENV_TYPE"

# Chemins des fichiers SQL de seed
SEED_FILE=""
case "$ENV_TYPE" in
    dev)
        SEED_FILE="/docker-entrypoint-initdb.d/seed_dev.sql"
        ;;
    iso)
        SEED_FILE="/docker-entrypoint-initdb.d/seed_iso.sql"
        ;;
    prod)
        SEED_FILE="/docker-entrypoint-initdb.d/seed_prod.sql"
        ;;
    *)
        echo "⚠️ Environnement inconnu : $ENV_TYPE. Utilisation de dev par défaut."
        SEED_FILE="/docker-entrypoint-initdb.d/seed_dev.sql"
        ;;
esac

# Exécution des scripts init fournis par l'image officielle PostgreSQL
# /docker-entrypoint-initdb.d/*.sql est déjà exécuté automatiquement
# On exécute ensuite le seed spécifique
if [ -f "$SEED_FILE" ]; then
    echo "🚀 Chargement du seed : $SEED_FILE"
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$SEED_FILE"
else
    echo "⚠️ Fichier de seed non trouvé : $SEED_FILE"
fi

# Passe le contrôle à l'entrypoint original de PostgreSQL
exec docker-entrypoint.sh postgres