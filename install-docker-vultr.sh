#!/bin/bash

# Install Docker and Docker Compose on Vultr Ubuntu server
# Usage: sudo ./install-docker-vultr.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐋 Installing Docker and Docker Compose on Vultr${NC}"

# Update system
echo -e "${YELLOW}📦 Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# Install prerequisites
echo -e "${YELLOW}📦 Installing prerequisites...${NC}"
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo -e "${YELLOW}🔑 Adding Docker GPG key...${NC}"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo -e "${YELLOW}📦 Setting up Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
echo -e "${YELLOW}🐋 Installing Docker Engine...${NC}"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
echo -e "${YELLOW}🚀 Starting Docker...${NC}"
systemctl start docker
systemctl enable docker

# Verify installation
echo -e "${GREEN}✅ Docker installed successfully!${NC}"
docker --version
docker compose version

echo ""
echo -e "${GREEN}📊 Docker status:${NC}"
systemctl status docker --no-pager

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Deploy your services: ./scripts/deploy.sh"
echo "2. Check logs: docker compose logs -f"
echo "3. Monitor: docker stats"