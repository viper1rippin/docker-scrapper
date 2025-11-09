# Deployment Guide

## Quick Start

1. Upload this entire folder to your server:
   ```bash
   scp -r vultr-deployment root@YOUR_SERVER_IP:/opt/scrapers
   ```

2. SSH into your server:
   ```bash
   ssh root@YOUR_SERVER_IP
   cd /opt/scrapers
   ```

3. Install Docker (if not already installed):
   ```bash
   chmod +x install-docker-vultr.sh
   ./install-docker-vultr.sh
   ```

4. Deploy all services:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/deploy.sh
   ```

5. Test your deployment:
   ```bash
   curl http://localhost/health
   curl http://localhost/playwright/health
   ```

## Pre-Generated API Keys

**⚠️ CRITICAL: Change these immediately in production!**

- **Scraper Services API Key**: k7mQ9vR3nX2pL6fJ8tY4wB5cZ1dA0eN7mK9sT6uV2xA=
- **OpenMemory API Key**: p3hR7nT9kL2mY5wX8qF4vZ1jC6bN0sA9uD2eG5tM8xB=

Generate new keys:
```bash
./scripts/generate-keys.sh
docker-compose restart
```

## Services Included

### 1. Playwright (Port 3001)
Modern browser automation for SPAs and dynamic content.
```bash
curl -X POST http://YOUR_SERVER/playwright \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","waitFor":"h1"}'
```

### 2. Puppeteer (Port 3002)
Stealth mode scraping with anti-bot detection bypass.
```bash
curl -X POST http://YOUR_SERVER/puppeteer \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}'
```

### 3. Selenium (Port 4444)
Python-based browser automation.
```bash
curl -X POST http://YOUR_SERVER/selenium \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}'
```

### 4. Universal Sandbox (Port 8000)
Multi-runtime execution for GitHub repos (Node.js, Python, Deno, Go, Ruby).
```bash
curl -X POST http://YOUR_SERVER/universal \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"repoUrl":"https://github.com/yourusername/scraper-repo"}'
```

### 5. Nginx (Port 80)
Reverse proxy with rate limiting (10 req/s per IP).

### 6. OpenMemory (Port 8001)
Pluggable memory layer for scraper state management.

## Requirements

- Ubuntu 20.04+ or Debian 11+
- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommended)
- 20GB disk space

## Monitoring

```bash
# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Monitor resources
docker stats
```

## Troubleshooting

If services fail to start:
```bash
# Check logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose up -d --build
```

## Security Checklist

- [ ] Changed default API keys
- [ ] Configured firewall (UFW or Vultr firewall)
- [ ] Set up SSH keys (disabled password auth)
- [ ] Enabled SSL/HTTPS (optional but recommended)
- [ ] Configured rate limiting in nginx
- [ ] Set up monitoring and alerts

## Support

For issues or questions, refer to the individual service README files in each service folder.
