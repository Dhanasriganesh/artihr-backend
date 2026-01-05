#!/bin/bash

# Deployment script for HR Portal Backend
# Usage: ./deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}
COMPOSE_FILE="docker-compose.prod.yml"
PROJECT_DIR="/opt/hr-portal-backend"

echo "🚀 Starting deployment for $ENVIRONMENT environment..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create project directory if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "📁 Creating project directory..."
    sudo mkdir -p $PROJECT_DIR
    sudo chown -R $USER:$USER $PROJECT_DIR
fi

# Copy files to project directory
echo "📦 Copying files..."
cp -r . $PROJECT_DIR/
cd $PROJECT_DIR

# Check if .env.production exists
if [ ! -f ".env.production" ]; then
    echo "⚠️  .env.production not found. Creating from template..."
    cp env.template .env.production
    echo "⚠️  Please update .env.production with your production values!"
    exit 1
fi

# Pull latest images
echo "📥 Pulling latest Docker images..."
docker-compose -f $COMPOSE_FILE pull

# Build and start containers
echo "🔨 Building and starting containers..."
docker-compose -f $COMPOSE_FILE up -d --build

# Wait for health check
echo "⏳ Waiting for service to be healthy..."
sleep 10

# Check if container is running
if docker ps | grep -q hr-portal-backend-prod; then
    echo "✅ Deployment successful!"
    echo "📊 Container status:"
    docker ps | grep hr-portal-backend-prod
    echo ""
    echo "📝 Logs:"
    docker-compose -f $COMPOSE_FILE logs --tail=50
else
    echo "❌ Deployment failed. Container is not running."
    echo "📝 Logs:"
    docker-compose -f $COMPOSE_FILE logs
    exit 1
fi

# Clean up old images
echo "🧹 Cleaning up old Docker images..."
docker system prune -f

echo "✨ Deployment completed!"

