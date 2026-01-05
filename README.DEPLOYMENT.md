# HR Portal Backend - Deployment Guide

## Prerequisites

- Docker and Docker Compose installed on the server
- SSH access to the server
- MongoDB running on the server (or accessible remotely)

## Server Setup

### 1. Install Docker on Ubuntu Server

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (optional, to run docker without sudo)
sudo usermod -aG docker $USER
```

### 2. Setup MongoDB (if not already installed)

```bash
# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

### 3. Deploy Backend Application

#### Option A: Manual Deployment

```bash
# SSH into your server
ssh root@97.77.20.150

# Clone or upload your project
cd /opt
mkdir -p hr-portal-backend
cd hr-portal-backend

# Copy your backend files here
# Then create .env.production file
nano .env.production
# Copy contents from .env.production.example and update values

# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh production
```

#### Option B: Using Docker Compose Directly

```bash
# Navigate to project directory
cd /opt/hr-portal-backend

# Create .env.production file
cp .env.production.example .env.production
nano .env.production  # Update with your values

# Start the service
docker-compose -f docker-compose.prod.yml up -d --build

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

### 4. Configure Environment Variables

Create `.env.production` file with the following:

```env
MONGODB_URI=mongodb://localhost:27017/hr_portal
NODE_ENV=production
PORT=3000
JWT_SECRET=your-very-secure-random-secret-key-here
JWT_EXPIRE=7d
CORS_ORIGIN=https://your-frontend-domain.com
```

**Important:** Generate a secure JWT_SECRET:
```bash
openssl rand -base64 32
```

### 5. Firewall Configuration

```bash
# Allow port 3000 (if needed)
sudo ufw allow 3000/tcp
sudo ufw reload
```

## CI/CD Setup (GitHub Actions)

### 1. Set up GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password/token
- `SERVER_HOST`: `97.77.20.150`
- `SERVER_USER`: `root`
- `SERVER_SSH_KEY`: Your private SSH key
- `SERVER_PORT`: `22` (default)

### 2. Generate SSH Key for Deployment

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_deploy

# Copy public key to server
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub root@97.77.20.150

# Add private key to GitHub Secrets as SERVER_SSH_KEY
cat ~/.ssh/github_actions_deploy
```

### 3. Push to Trigger Deployment

```bash
git add .
git commit -m "Setup CI/CD"
git push origin main
```

## Management Commands

### View Logs
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

### Restart Service
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Stop Service
```bash
docker-compose -f docker-compose.prod.yml down
```

### Update Application
```bash
cd /opt/hr-portal-backend
git pull  # or copy new files
docker-compose -f docker-compose.prod.yml up -d --build
```

### Check Container Status
```bash
docker ps | grep hr-portal-backend
```

### Health Check
```bash
curl http://localhost:3000/api/health
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs

# Check if MongoDB is accessible
docker exec hr-portal-backend-prod node -e "console.log(process.env.MONGODB_URI)"
```

### MongoDB connection issues
```bash
# Test MongoDB connection from server
mongo mongodb://localhost:27017/hr_portal

# Check MongoDB status
sudo systemctl status mongod
```

### Port already in use
```bash
# Find process using port 3000
sudo lsof -i :3000

# Kill the process or change PORT in .env.production
```

## Security Recommendations

1. **Change default secrets** - Never use default JWT_SECRET in production
2. **Use HTTPS** - Set up Nginx reverse proxy with SSL
3. **Firewall** - Only expose necessary ports
4. **Regular updates** - Keep Docker and system packages updated
5. **Backup** - Regular MongoDB backups
6. **Monitoring** - Set up monitoring and alerting

## Nginx Reverse Proxy (Optional)

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

