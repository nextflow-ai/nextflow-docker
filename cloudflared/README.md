# Cloudflare Tunnel Configuration

Thư mục này chứa các file cấu hình và credentials cho Cloudflare Tunnel.

## Cấu trúc thư mục

- `config/`: Chứa các file cấu hình cho các tunnel khác nhau
  - `cloudflared-config.yml`: Cấu hình cho tunnel chính (nextflow)
  - `cloudflared-monitoring-config.yml`: Cấu hình cho tunnel monitoring
  - `cloudflared-ai-config.yml`: Cấu hình cho tunnel AI
  - `cloudflared-messaging-config.yml`: Cấu hình cho tunnel messaging
  - `cloudflared-docs-config.yml`: Cấu hình cho tunnel docs
  - `cloudflared-analytics-config.yml`: Cấu hình cho tunnel analytics
  - `cloudflared-dev-config.yml`: Cấu hình cho tunnel dev
  - `cloudflared-storage-config.yml`: Cấu hình cho tunnel storage

- `credentials/`: Chứa các file credentials cho các tunnel
  - `credentials.json`: Credentials cho tunnel chính (nextflow)
      docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoiNTJjM2QxNTUzZDA3NDBiOWE4MDMzZmYxMzdjZTMyNmUiLCJ0IjoiYTY0ZDZiNjQtMjJmMC00ZTEzLWI4MzItMTMwMjY4NTNjNjU3IiwicyI6Ik1ERmhPRFUzTVdJdE56TXlaaTAwWmpObUxXSXhaalF0WXpjMk1ESXpOMlZrTWpWaiJ9
  - `credentials-monitoring.json`: Credentials cho tunnel monitoring
  - `credentials-ai.json`: Credentials cho tunnel AI
      docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token eyJhIjoiNTJjM2QxNTUzZDA3NDBiOWE4MDMzZmYxMzdjZTMyNmUiLCJ0IjoiNDQxZDFlMWMtMGQ1Zi00OTQxLTkwODUtYjkwMDk0MDVlNGI1IiwicyI6Ik5tWmxNVGcwTVRJdE16VTVOUzAwTUdWbExXRTVZVEF0TW1SaE9XRTNaVGc0TjJaaCJ9
  - `credentials-messaging.json`: Credentials cho tunnel messaging
  - `credentials-docs.json`: Credentials cho tunnel docs
  - `credentials-analytics.json`: Credentials cho tunnel analytics
  - `credentials-dev.json`: Credentials cho tunnel dev
  - `credentials-storage.json`: Credentials cho tunnel storage

  giải mã token: https://www.base64decode.org/
    echo "eyJhIjoiNTJjM2QxNTUzZDA3NDBiOWE4MDMzZmYxMzdjZTMyNmUiLCJ0IjoiNDQxZDFlMWMtMGQ1Zi00OTQxLTkwODUtYjkwMDk0MDVlNGI1IiwicyI6Ik5tWmxNVGcwTVRJdE16VTVOUzAwTUdWbExXRTVZVEF0TW1SaE9XRTNaVGc0TjJaaCJ9" | base64 -d
## Cách sử dụng

Các file cấu hình và credentials được sử dụng trong `docker-compose.yml` để cấu hình các service Cloudflare Tunnel.

### Ví dụ:

```yaml
cloudflare-tunnel:
  image: cloudflare/cloudflared:latest
  container_name: cloudflare-tunnel
  hostname: cloudflare-tunnel
  command: tunnel --config /etc/cloudflared/config.yml run
  volumes:
    - ./cloudflared/config/cloudflared-config.yml:/etc/cloudflared/config.yml
    - ./cloudflared/credentials/credentials.json:/etc/cloudflared/credentials.json
  environment:
    - TUNNEL_ORIGIN_CERT=/etc/cloudflared/credentials.json
    - NO_AUTOUPDATE=true
```

## Lưu ý

- Không chia sẻ các file credentials với người khác
- Các file credentials chứa thông tin nhạy cảm và nên được bảo vệ
- Các file cấu hình có thể được chỉnh sửa để thay đổi cấu hình tunnel
