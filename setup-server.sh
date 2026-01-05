#!/bin/bash

# Server setup script for HR Portal Backend
# Run this script on your Ubuntu server to install prerequisites

set -e

echo "🚀 Setting up HR Portal Backend server..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker is already installed"
fi

# Install MongoDB (if not installed)
if ! command -v mongod &> /dev/null; then
    echo "🍃 Installing MongoDB..."
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
    
    # Start and enable MongoDB
    sudo systemctl start mongod
    sudo systemctl enable mongod
    echo "✅ MongoDB installed and started"
else
    echo "✅ MongoDB is already installed"
    # Ensure MongoDB is running
    sudo systemctl start mongod || true
fi

# Create project directory
PROJECT_DIR="/opt/hr-portal-backend"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "📁 Creating project directory..."
    sudo mkdir -p $PROJECT_DIR
    sudo chown -R $USER:$USER $PROJECT_DIR
fi

# Setup firewall (optional)
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp || true  # SSH
sudo ufw allow 3000/tcp || true  # Backend API
sudo ufw --force enable || true

echo ""
echo "✨ Server setup completed!"
echo ""
echo "Next steps:"
echo "1. Copy your backend files to $PROJECT_DIR"
echo "2. Create .env.production file: cp env.production.example .env.production"
echo "3. Update .env.production with your values"
echo "4. Run: ./deploy.sh production"
echo ""
echo "Note: You may need to log out and log back in for Docker group changes to take effect."

