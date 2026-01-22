# Proxy Support

## Overview

agent-browser supports routing traffic through proxy servers for testing geo-restricted content, corporate network access, or traffic inspection.

## Basic Proxy Usage

```bash
agent-browser --proxy "http://proxy.example.com:8080" open "https://example.com"
```

## Proxy Types

### HTTP Proxy

```bash
agent-browser --proxy "http://proxy:8080" open "https://example.com"
```

### HTTPS Proxy

```bash
agent-browser --proxy "https://proxy:8080" open "https://example.com"
```

### SOCKS5 Proxy

```bash
agent-browser --proxy "socks5://proxy:1080" open "https://example.com"
```

## Authenticated Proxies

### URL Authentication

```bash
agent-browser --proxy "http://user:pass@proxy:8080" open "https://example.com"
```

### Separate Credentials

```bash
agent-browser --proxy "http://proxy:8080" --proxy-user "username" --proxy-pass "password" open "https://example.com"
```

## Session-Specific Proxies

Each session can use a different proxy:

```bash
# US proxy
agent-browser --session us --proxy "http://us-proxy:8080" open "https://example.com"

# EU proxy
agent-browser --session eu --proxy "http://eu-proxy:8080" open "https://example.com"

# Compare results
agent-browser --session us screenshot --output us-view.png
agent-browser --session eu screenshot --output eu-view.png
```

## Use Cases

### Geo-Location Testing

Test how site appears from different regions:

```bash
# Test from different locations
for region in us eu asia; do
    agent-browser --session $region --proxy "http://$region-proxy:8080" \
        open "https://example.com"
    agent-browser --session $region screenshot --output "$region.png"
    agent-browser --session $region close
done
```

### Corporate Network Access

Access internal resources through corporate proxy:

```bash
agent-browser --proxy "http://corp-proxy.internal:8080" \
    open "https://internal.corp.example.com"
```

### Traffic Inspection

Route through inspection proxy for debugging:

```bash
# Start mitmproxy or similar
agent-browser --proxy "http://localhost:8080" open "https://example.com"

# Traffic visible in proxy tool
```

### Rate Limit Bypass

Rotate through proxy pool (use responsibly):

```bash
proxies=("proxy1:8080" "proxy2:8080" "proxy3:8080")

for i in "${!proxies[@]}"; do
    agent-browser --session "s$i" --proxy "http://${proxies[$i]}" \
        open "https://example.com/api"
done
```

## Proxy Bypass

Bypass proxy for specific hosts:

```bash
agent-browser --proxy "http://proxy:8080" \
    --proxy-bypass "localhost,*.internal.com" \
    open "https://example.com"
```

## Environment Variables

Set default proxy via environment:

```bash
export AGENT_BROWSER_PROXY="http://proxy:8080"
agent-browser open "https://example.com"  # Uses env proxy
```

Override with flag:

```bash
export AGENT_BROWSER_PROXY="http://default-proxy:8080"
agent-browser --proxy "http://other-proxy:8080" open "https://example.com"
```

## Proxy Configuration File

For complex setups, use a config file:

```json
{
  "proxy": {
    "server": "http://proxy:8080",
    "username": "user",
    "password": "pass",
    "bypass": ["localhost", "*.internal.com"]
  }
}
```

```bash
agent-browser --config proxy-config.json open "https://example.com"
```

## Troubleshooting

### Connection Refused
- Verify proxy server is running
- Check port number
- Confirm network access to proxy

### Authentication Failed
- Verify credentials
- Check for special characters in password (URL encode)
- Try separate `--proxy-user` and `--proxy-pass` flags

### SSL/Certificate Errors
- Proxy may intercept HTTPS
- Install proxy's CA certificate
- Use `--ignore-https-errors` for testing only

### Slow Performance
- Proxy may be overloaded
- Try different proxy server
- Check proxy logs for errors

## Security Notes

1. **Proxy sees all traffic** - Don't use untrusted proxies
2. **Credentials in URLs** - May appear in logs
3. **HTTPS inspection** - Proxy can read encrypted traffic
4. **Testing only** - Don't bypass security controls in production
