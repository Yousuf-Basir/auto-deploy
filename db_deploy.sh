#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 <database_engine> <port> <username> <password>"
    echo "Supported database engines: postgres, mysql"
    echo "Example: $0 postgres 5432 myuser mypassword"
    exit 1
}

# Check if correct number of arguments is provided
if [ $# -ne 4 ]; then
    usage
fi

# Parse arguments
DB_ENGINE=$1
PORT=$2
USERNAME=$3
PASSWORD=$4

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
    docker run -d \
        --restart=always \
        --name postgres-db \
        -e POSTGRES_USER="$USERNAME" \
        -e POSTGRES_PASSWORD="$PASSWORD" \
        -p "$PORT":5432 \
        postgres:latest
    
    echo "PostgreSQL deployed successfully on port $PORT"
fi

# Deploy MySQL
if [ "$DB_ENGINE" == "mysql" ]; then
    echo "Deploying MySQL..."
    docker run -d \
        --restart=always \
        --name mysql-db \
        -e MYSQL_ROOT_PASSWORD="$PASSWORD" \
        -e MYSQL_USER="$USERNAME" \
        -e MYSQL_PASSWORD="$PASSWORD" \
        -p "$PORT":3306 \
        mysql:latest
    
    echo "MySQL deployed successfully on port $PORT"
fi

# Wait a moment to ensure container is up
sleep 5

# Check container status
docker ps | grep "$DB_ENGINE-db"
