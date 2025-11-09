#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Vultr Deployment${NC}"

# Change to deployment directory
cd "$(dirname "$0")/.."

# Backup current configuration
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}📦 Creating backup in ${BACKUP_DIR}${NC}"
mkdir -p "$BACKUP_DIR"
cp docker-compose.yml "$BACKUP_DIR/" 2>/dev/null || true
cp -r nginx "$BACKUP_DIR/" 2>/dev/null || true
cp .env "$BACKUP_DIR/" 2>/dev/null || true

# Create .env files if they don't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚙️  Creating .env file${NC}"
    cp .env.example .env
    echo -e "${RED}⚠️  IMPORTANT: Update .env with your secure API_KEY${NC}"
fi

if [ ! -f .env.openmemory ]; then
    echo -e "${YELLOW}⚙️  Creating .env.openmemory file${NC}"
    echo "OPENMEMORY_API_KEY=your_secure_openmemory_key_here" > .env.openmemory
    echo -e "${RED}⚠️  IMPORTANT: Update .env.openmemory with your secure API key${NC}"
fi

# Clone OpenMemory if not exists
if [ ! -d "openmemory-src" ]; then
    echo -e "${YELLOW}📦 Cloning OpenMemory from GitHub${NC}"
    git clone https://github.com/CaviraOSS/OpenMemory.git openmemory-src
    echo -e "${GREEN}✅ OpenMemory source cloned${NC}"
else
    echo -e "${GREEN}✅ OpenMemory source already exists${NC}"
    cd openmemory-src
    git pull origin main 2>/dev/null || echo -e "${YELLOW}⚠️  Could not update OpenMemory source${NC}"
    cd ..
fi

# Pull latest Docker images
echo -e "${GREEN}📥 Pulling latest Docker images${NC}"
docker-compose pull

# Rebuild and restart services
echo -e "${YELLOW}🔨 Building all services${NC}"
docker-compose up -d --build

# Wait for services to start
echo -e "${YELLOW}⏳ Waiting for services to be ready (30s)${NC}"
sleep 30

# Health checks
echo -e "${GREEN}🏥 Running health checks${NC}"

check_health() {
    local service=$1
    local url=$2
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service is healthy${NC}"
            return 0
        fi
        echo -e "${YELLOW}⏳ Waiting for $service (attempt $attempt/$max_attempts)${NC}"
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $service health check failed${NC}"
    return 1
}

# Check all services
HEALTH_CHECK_FAILED=0

check_health "Nginx" "http://localhost/health" || HEALTH_CHECK_FAILED=1
check_health "Playwright" "http://localhost/playwright/health" || HEALTH_CHECK_FAILED=1
check_health "Puppeteer" "http://localhost/puppeteer/health" || HEALTH_CHECK_FAILED=1
check_health "Selenium" "http://localhost/selenium/health" || HEALTH_CHECK_FAILED=1
check_health "Universal Sandbox" "http://localhost/universal/health" || HEALTH_CHECK_FAILED=1

if [ $HEALTH_CHECK_FAILED -eq 1 ]; then
    echo -e "${RED}❌ Some services failed health checks${NC}"
    echo -e "${YELLOW}🔄 Rolling back to previous version${NC}"
    
    # Restore from backup
    cp "$BACKUP_DIR/docker-compose.yml" docker-compose.yml 2>/dev/null || true
    cp -r "$BACKUP_DIR/nginx" nginx 2>/dev/null || true
    docker-compose up -d
    
    echo -e "${RED}❌ Deployment failed and rolled back${NC}"
    exit 1
fi

# Clean up old backups (keep last 5)
echo -e "${YELLOW}🧹 Cleaning up old backups${NC}"
cd backups
ls -t | tail -n +6 | xargs -r rm -rf
cd ..

# Show running services
echo -e "${GREEN}📊 Running services:${NC}"
docker-compose ps

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Services available at:${NC}"
echo -e "  - Nginx: http://localhost/"
echo -e "  - Playwright: http://localhost/playwright"
echo -e "  - Puppeteer: http://localhost/puppeteer"
echo -e "  - Selenium: http://localhost/selenium"
echo -e "  - Universal: http://localhost/universal"