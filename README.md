# Automated Deployment Script Tutorial

## Quick Start Guide

### Prerequisites
- Linux terminal, Git Bash, or WSL
- SSH access to remote server
- Docker on remote server

### Configuration Files

#### `config.ini`
```ini
REPO_URL=https://github.com/yourusername/project.git
BRANCH=main
BUILD_COMMAND=npm run build
RUN_COMMAND=npm start
APPLICATION_PORT=3001  # Must match the port in your env file
```

#### `.env`
```ini
NEXT_PUBLIC_BASE_URL=https://yoursite.com
PORT=3001  # Must be the same as APPLICATION_PORT
```

### Deployment Command
```bash
./deploy.sh username@server_ip config_file env_file
```

#### Example
```bash
./deploy.sh root@103.191.179.241 ./config.ini ../.env
```

## Key Notes
- **Important**: `APPLICATION_PORT` must match the port your app runs on
- Only use Linux terminal, Git Bash, or WSL
- **Not compatible with Windows PowerShell**
- Both config files must end with an empty line

## What the Script Does
1. Transfer files to server
2. Clone repository
3. Build Docker image
4. Run container
5. Expose specified port

## Warnings
⚠️ Ensure:
- Correct file paths
- SSH access works
- Docker installed on server