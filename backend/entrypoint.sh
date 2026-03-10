#!/bin/bash
set -e

echo "⏳ Waiting for database..."
python -c "
import time, psycopg2, os
for i in range(30):
    try:
        psycopg2.connect(
            dbname=os.environ.get('DB_NAME','suraksha_db'),
            user=os.environ.get('DB_USER','suraksha'),
            password=os.environ.get('DB_PASSWORD','suraksha_dev_2024'),
            host=os.environ.get('DB_HOST','db'),
            port=os.environ.get('DB_PORT','5432'),
        )
        print('✅ Database ready')
        break
    except psycopg2.OperationalError:
        time.sleep(1)
else:
    print('❌ Database not available')
    exit(1)
"

echo "🔄 Creating migrations..."
python manage.py makemigrations accounts hazards emergency privacy routing --noinput

echo "🔄 Running migrations..."
python manage.py migrate --noinput

echo "📦 Collecting static files..."
python manage.py collectstatic --noinput 2>/dev/null || true

exec "$@"
