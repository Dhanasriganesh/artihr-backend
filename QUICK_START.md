# Quick Start Guide - Deploy to Server

## Step 1: Initial Server Setup (One-time)

SSH into your server and run:

```bash
ssh root@97.77.20.150

# Upload setup-server.sh to server, then:
chmod +x setup-server.sh
./setup-server.sh
```

Or manually install Docker and MongoDB:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose-plugin -y

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

## Step 2: Deploy Backend

### Option A: Manual Deployment

```bash
# On your server
cd /opt
mkdir -p hr-portal-backend
cd hr-portal-backend

# Upload all backend files here (use scp, rsync, or git clone)

# Create production environment file
cp env.production.example .env.production
nano .env.production  # Edit with your values

# Important: Update MONGODB_URI to use server's MongoDB
# MONGODB_URI=mongodb://localhost:27017/hr_portal

# Make deploy script executable
chmod +x deploy.sh

# Deploy
./deploy.sh production
```

### Option B: Using Git

```bash
# On your server
cd /opt
git clone <your-repo-url> hr-portal-backend
cd hr-portal-backend/Backend

# Create .env.production
cp env.production.example .env.production
nano .env.production

# Deploy
chmod +x deploy.sh
./deploy.sh production
```

### Option C: Using Docker Compose Directly

```bash
cd /opt/hr-portal-backend/Backend

# Create .env.production
cp env.production.example .env.production
nano .env.production

# Build and run
docker-compose -f docker-compose.prod.yml up -d --build

# Check status
docker ps
docker-compose -f docker-compose.prod.yml logs -f
```

## Step 3: Verify Deployment

```bash
# Check if container is running
docker ps | grep hr-portal-backend

# Test health endpoint
curl http://localhost:3000/api/health

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## Step 4: Setup CI/CD (Optional)

1. Go to GitHub → Your Repo → Settings → Secrets → Actions
2. Add these secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub access token
   - `SERVER_HOST`: `97.77.20.150`
   - `SERVER_USER`: `root`
   - `SERVER_SSH_KEY`: Your private SSH key
   - `SERVER_PORT`: `22`

3. Push to main branch to trigger deployment

## Environment Variables (.env.production)

```env
# MongoDB (using server's MongoDB)
MONGODB_URI=mongodb://localhost:27017/hr_portal

# Server
NODE_ENV=production
PORT=3000

# Security (IMPORTANT: Generate secure secrets!)
JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRE=7d

# CORS (update with your frontend URL)
CORS_ORIGIN=http://localhost:5173
```

## Common Commands

```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart
docker-compose -f docker-compose.prod.yml restart

# Stop
docker-compose -f docker-compose.prod.yml down

# Update
cd /opt/hr-portal-backend/Backend
git pull  # or upload new files
docker-compose -f docker-compose.prod.yml up -d --build

# Check MongoDB
mongo mongodb://localhost:27017/hr_portal
```

## Troubleshooting

**Container won't start:**
```bash
docker-compose -f docker-compose.prod.yml logs
```

**MongoDB connection error:**
```bash
# Check MongoDB is running
sudo systemctl status mongod

# Test connection
mongo mongodb://localhost:27017/hr_portal
```

**Port already in use:**
```bash
# Find process
sudo lsof -i :3000

# Kill process or change PORT in .env.production
```

