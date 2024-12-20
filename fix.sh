#!/bin/bash

set -e

echo "Choose an option to resolve the SQLite issue:"
echo "1. Upgrade SQLite"
echo "2. Switch to PostgreSQL"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" -eq 1 ]; then
    # Upgrade SQLite
    echo "Upgrading SQLite to the latest version..."
    
    # Remove the old SQLite version
    sudo yum remove -y sqlite

    # Download and compile a new version of SQLite
    SQLITE_VERSION="3430000" # Update with the latest version
    cd /usr/local/src
    sudo wget https://www.sqlite.org/2023/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
    sudo tar -xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
    cd sqlite-autoconf-${SQLITE_VERSION}
    sudo ./configure
    sudo make
    sudo make install

    # Verify the version
    sqlite3 --version

    echo "SQLite upgrade completed. Restart your Django server."
elif [ "$choice" -eq 2 ]; then
    # Install and configure PostgreSQL
    echo "Installing and configuring PostgreSQL for Django..."
    
    # Install PostgreSQL
    sudo yum install -y postgresql postgresql-server postgresql-devel
    sudo postgresql-setup initdb
    sudo systemctl start postgresql
    sudo systemctl enable postgresql

    # Create PostgreSQL database and user
    read -p "Enter database name: " DB_NAME
    read -p "Enter database user: " DB_USER
    read -sp "Enter password for the database user: " DB_PASS
    echo

    sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\q
EOF

    # Update Django settings.py
    echo "Updating Django settings for PostgreSQL..."
    SETTINGS_FILE="settings.py" # Change this to the path of your settings.py file
    if [ -f "$SETTINGS_FILE" ]; then
        cat <<EOT >> "$SETTINGS_FILE"

# PostgreSQL Database Configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '$DB_NAME',
        'USER': '$DB_USER',
        'PASSWORD': '$DB_PASS',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
EOT
        echo "Django settings updated. Apply migrations with 'python3 manage.py migrate'."
    else
        echo "settings.py not found. Update your DATABASES setting manually."
    fi
else
    echo "Invalid choice. Exiting."
    exit 1
fi
