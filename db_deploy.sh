#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <database_engine> <port> <username> <password> [initial_database]"
    echo "Supported database engines: postgres, mysql"
    echo "Example: $0 postgres 5432 myuser mypassword mydb"
    echo "Or"
    echo "ssh Robi 'bash -s' < ./db_deploy.sh postgres 5454 dbuser letsrock community"
    echo "Optional database name can be added as the 5th argument"
    exit 1
}

# Check if correct number of arguments is provided (4-5 arguments)
if [ $# -lt 4 ] || [ $# -gt 5 ]; then
    usage
fi

# Parse arguments
DB_ENGINE=$1
PORT=$2
USERNAME=$3
PASSWORD=$4
INITIAL_DB=${5:-}  # Optional initial database name, defaults to empty string

# Validate database engine
if [[ "$DB_ENGINE" != "postgres" && "$DB_ENGINE" != "mysql" ]]; then
    echo "Error: Unsupported database engine. Choose 'postgres' or 'mysql'."
    usage
fi

# Validate port number
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a valid number."
    exit 1
fi

# Deploy PostgreSQL
if [ "$DB_ENGINE" == "postgres" ]; then
    echo "Deploying PostgreSQL..."
    
    # Create Docker volume for PostgreSQL data
    docker volume create postgres-data

    # Run PostgreSQL container
    docker run -d \
        --name postgres-db \
        -e POSTGRES_USER="$USERNAME" \
        -e POSTGRES_PASSWORD="$PASSWORD" \
        -p "$PORT":5432 \
        -v postgres-data:/var/lib/postgresql/data \
        postgres:latest

    # Wait for PostgreSQL to start
    sleep 10

    # Create initial database if specified
    if [ -n "$INITIAL_DB" ]; then
        echo "Creating initial database: $INITIAL_DB"
        docker exec postgres-db psql -U "$USERNAME" -c "CREATE DATABASE \"$INITIAL_DB\";"
        
        if [ $? -eq 0 ]; then
            echo "Database $INITIAL_DB created successfully"
        else
            echo "Error creating database $INITIAL_DB"
        fi
    fi
fi

# Deploy MySQL
if [ "$DB_ENGINE" == "mysql" ]; then
    echo "Deploying MySQL..."
    
    # Create Docker volume for MySQL data
    docker volume create mysql-data

    # Run MySQL container
    docker run -d \
        --name mysql-db \
        -e MYSQL_ROOT_PASSWORD="$PASSWORD" \
        -e MYSQL_USER="$USERNAME" \
        -e MYSQL_PASSWORD="$PASSWORD" \
        -p "$PORT":3306 \
        -v mysql-data:/var/lib/mysql \
        mysql:latest

    # Wait for MySQL to start
    sleep 10

    # Create initial database if specified
    if [ -n "$INITIAL_DB" ]; then
        echo "Creating initial database: $INITIAL_DB"
        docker exec mysql-db mysql -u root -p"$PASSWORD" -e "CREATE DATABASE \`$INITIAL_DB\`;"
        
        if [ $? -eq 0 ]; then
            echo "Database $INITIAL_DB created successfully"
        else
            echo "Error creating database $INITIAL_DB"
        fi
    fi
fi

# Check container status
docker ps | grep "$DB_ENGINE-db"

echo "Deployment complete!"