#!/bin/bash

# Generate secure API keys for scraper services
# Usage: ./generate-keys.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔐 Generating secure API keys...${NC}"
echo ""

# Generate two secure 32-byte base64 keys
API_KEY=$(openssl rand -base64 32 | tr -d '\n')
OPENMEMORY_KEY=$(openssl rand -base64 32 | tr -d '\n')

# Backup existing .env files if they exist
if [ -f ".env" ]; then
    echo -e "${YELLOW}📦 Backing up existing .env${NC}"
    cp .env ".env.backup.$(date +%Y%m%d_%H%M%S)"
fi

if [ -f ".env.openmemory" ]; then
    echo -e "${YELLOW}📦 Backing up existing .env.openmemory${NC}"
    cp .env.openmemory ".env.openmemory.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create new .env file
cat > .env << EOF
# API Key for authenticating requests to scrapers
# Generated: $(date)
API_KEY=${API_KEY}
EOF

# Create new .env.openmemory file
cat > .env.openmemory << EOF
# OpenMemory API Key for authentication
# Generated: $(date)
OPENMEMORY_API_KEY=${OPENMEMORY_KEY}
EOF

# Set proper permissions
chmod 600 .env
chmod 600 .env.openmemory

echo -e "${GREEN}✅ Generated secure API keys!${NC}"
echo ""
echo -e "${GREEN}API_KEY (for scrapers):${NC}"
echo "$API_KEY"
echo ""
echo -e "${GREEN}OPENMEMORY_API_KEY:${NC}"
echo "$OPENMEMORY_KEY"
echo ""
echo -e "${YELLOW}⚠️  Keys saved to .env and .env.openmemory${NC}"
echo -e "${YELLOW}⚠️  Old keys backed up with timestamp${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Restart services: docker-compose restart"
echo "2. Update your API clients with the new API_KEY"
echo "3. Keep these keys secure and never commit to Git"
echo ""
echo -e "${GREEN}🔒 File permissions set to 600 (owner read/write only)${NC}"