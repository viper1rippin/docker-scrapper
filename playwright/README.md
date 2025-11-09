# Playwright Scraper Service

Modern browser automation service using Playwright with Chromium.

## Port
- **3001**

## API Endpoint
`POST /playwright`

## Request Body
```json
{
  "url": "https://example.com",
  "waitFor": "h1",
  "script": "document.querySelector('h1').textContent",
  "timeout": 30000
}
```

See full documentation in the root README.md file.