FROM node:20-slim

# Install Playwright dependencies
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Playwright and Chromium
RUN npm install -g playwright@latest \
    && npx playwright install chromium \
    && npx playwright install-deps chromium

# Copy application files
COPY package*.json ./
RUN npm install

COPY server.js ./

ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

EXPOSE 3001

CMD ["node", "server.js"]