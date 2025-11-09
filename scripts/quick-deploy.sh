#!/bin/bash

# Quick deployment script for scraper infrastructure
# Usage: ./quick-deploy.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting quick deployment...${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from example...${NC}"
    cp .env.example .env
    echo -e "${RED}⚠️  IMPORTANT: Update .env with your secure API key!${NC}"
fi

# Check if .env.openmemory exists
if [ ! -f ".env.openmemory" ]; then
    echo -e "${YELLOW}⚠️  .env.openmemory file not found. Creating from example...${NC}"
    cp .env.example .env.openmemory
    echo -e "${RED}⚠️  IMPORTANT: Update .env.openmemory with your secure API key!${NC}"
fi

# Clone OpenMemory if not exists
if [ ! -d "openmemory-src" ]; then
    echo -e "${YELLOW}📦 Cloning OpenMemory from GitHub...${NC}"
    git clone https://github.com/CaviraOSS/OpenMemory.git openmemory-src
    echo -e "${GREEN}✅ OpenMemory source cloned${NC}"
else
    echo -e "${GREEN}✅ OpenMemory source already exists${NC}"
fi

# Build all services
echo -e "${YELLOW}🔨 Building Docker services...${NC}"
docker-compose build

# Start services
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker-compose up -d

# Wait for services to start
echo -e "${YELLOW}⏳ Waiting 30 seconds for services to start...${NC}"
sleep 30

# Check status
echo ""
echo -e "${GREEN}📊 Service Status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Check service health: docker-compose ps"
echo "2. View logs: docker-compose logs -f"
echo "3. Test endpoints with curl (see DEPLOYMENT.md)"
echo ""
echo -e "${YELLOW}🔗 Service URLs:${NC}"
echo "   Nginx: http://localhost/"
echo "   Playwright: http://localhost/playwright"
echo "   Puppeteer: http://localhost/puppeteer"
echo "   Selenium: http://localhost/selenium"
echo "   Universal: http://localhost/universal"
echo "   OpenMemory: http://localhost:8001"