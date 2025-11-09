const express = require('express');
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');

puppeteer.use(StealthPlugin());

const app = express();
const API_KEY = process.env.API_KEY;

app.use(express.json());

// Authentication middleware
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Invalid authorization header' });
  }

  if (parts[1] !== API_KEY) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  next();
}

app.post('/puppeteer', authenticate, async (req, res) => {
  const { url, waitFor, script, timeout = 30000 } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'URL is required' });
  }

  let browser = null;
  try {
    browser = await puppeteer.launch({
      headless: 'new',
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium',
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--disable-gpu'
      ]
    });

    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    await page.goto(url, { timeout, waitUntil: 'domcontentloaded' });

    if (waitFor) {
      await page.waitForSelector(waitFor, { timeout: 10000 });
    }

    let result;
    if (script) {
      result = await page.evaluate(script);
    } else {
      result = await page.content();
    }

    await browser.close();

    res.json({
      success: true,
      data: result,
      url,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    if (browser) {
      await browser.close();
    }

    res.status(500).json({
      success: false,
      error: error.message,
      url
    });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'puppeteer' });
});

const PORT = process.env.PORT || 3002;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Puppeteer scraper listening on port ${PORT}`);
});