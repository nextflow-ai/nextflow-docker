# 🚀 NextFlow Docker - Hệ thống AI & Automation Platform

## 📋 Tổng quan

NextFlow Docker là một hệ thống tích hợp hoàn chỉnh bao gồm các công cụ AI, automation, monitoring và quản lý dữ liệu được đóng gói trong Docker containers. Hệ thống đã được tối ưu hóa cho môi trường production với cấu hình bảo mật cao và hiệu suất tối ưu.

## 🏗️ Kiến trúc hệ thống

### Core Services
- **PostgreSQL**: Database chính cho tất cả services
- **Redis**: Cache và session storage
- **RabbitMQ**: Message queue system

### AI & Automation Services
- **Flowise**: Visual AI workflow builder (Port: 8001)
- **Open WebUI**: Chat interface cho AI models (Port: 8002)
- **n8n**: Automation platform (Port: 8003)
- **Langflow**: Low-code AI application builder (Port: 7860)
- **Qdrant**: Vector database cho AI embeddings (Port: 6333)

### Management & Monitoring
- **Grafana**: Monitoring dashboard (Port: 9001)
- **Prometheus**: Metrics collection (Port: 9090)
- **Loki**: Log aggregation (Port: 9002)
- **Jaeger**: Distributed tracing (Port: 9004)
- **Redis Commander**: Redis management (Port: 6001)
- **cAdvisor**: Container monitoring (Port: 9003)

### Authentication & Security
- **NextAuth.js**: Authentication được tích hợp trong ứng dụng Next.js

### Communication & Collaboration
- **Stalwart Mail Server**: Complete mail solution (Ports: 25, 587, 465, 143, 993, 110, 995, 8005)
- **GitLab**: Source code management (Ports: 8443, 8088, 2222, 5050)

### Content Management
- **WordPress**: Landing page và blog (Port: 8080)
- **MariaDB**: Database cho WordPress (Port: 3306)

## 🚀 Hướng dẫn triển khai

### 1. Yêu cầu hệ thống

**Minimum Requirements:**
- CPU: 4 cores
- RAM: 8GB
- Storage: 100GB SSD
- Docker Engine 20.10+
- Docker Compose 2.0+

**Recommended for Production:**
- CPU: 8+ cores
- RAM: 16GB+
- Storage: 500GB+ SSD
- Network: 1Gbps

### 2. Cài đặt Docker

```bash
# Windows (PowerShell as Administrator)
Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "DockerDesktopInstaller.exe"
Start-Process -FilePath "DockerDesktopInstaller.exe" -Wait

# Hoặc sử dụng Chocolatey
choco install docker-desktop
```

### 3. Cấu hình môi trường

```bash
# Clone repository
git clone <repository-url>
cd nextflow-docker

# Copy và cấu hình file environment
copy .env.example .env

# Chỉnh sửa file .env với các giá trị phù hợp
notepad .env
```

### 4. Khởi động hệ thống

```bash
# Khởi động tất cả services
docker-compose up -d

# Kiểm tra trạng thái
docker-compose ps

# Xem logs
docker-compose logs -f [service-name]
```

### 5. Khởi động theo profiles

```bash
# Chỉ khởi động core services
docker-compose --profile core up -d

# Khởi động AI services
docker-compose --profile ai up -d

# Khởi động monitoring services
docker-compose --profile monitoring up -d

# Khởi động mail services
docker-compose --profile mail up -d

# Khởi động development tools
docker-compose --profile development up -d
```

## 🔧 Cấu hình chi tiết

### Port Mapping (Đã tối ưu hóa)

| Service | Internal Port | External Port | Description |
|---------|---------------|---------------|-------------|
| **AI Services** |
| Flowise | 3000 | 8001 | AI Workflow Builder |
| Open WebUI | 8080 | 8002 | AI Chat Interface |
| n8n | 5678 | 8003 | Automation Platform |
| Langflow | 7860 | 7860 | AI App Builder |
| Qdrant | 6333 | 6333 | Vector Database |
| **Management** |
| Redis Commander | 8081 | 6001 | Redis Management |
| **Monitoring** |
| Grafana | 3000 | 9001 | Monitoring Dashboard |
| Prometheus | 9090 | 9090 | Metrics Collection |
| Loki | 3100 | 9002 | Log Aggregation |
| cAdvisor | 8080 | 9003 | Container Monitoring |
| Jaeger | 16686 | 9004 | Distributed Tracing |
| **Authentication** |
| NextAuth.js | - | - | Tích hợp trong ứng dụng Next.js |
| **Mail Services** |
| Stalwart Admin | 80 | 8005 | Mail Admin Interface |
| SMTP | 25 | 25 | Mail Transfer |
| Submission | 587 | 587 | Mail Submission |
| SMTPS | 465 | 465 | Secure SMTP |
| IMAP | 143 | 143 | Mail Access |
| IMAPS | 993 | 993 | Secure IMAP |
| POP3 | 110 | 110 | Mail Access |
| POP3S | 995 | 995 | Secure POP3 |

### Resource Limits (Đã tối ưu hóa)

| Service | CPU Limit | Memory Limit | Description |
|---------|-----------|--------------|-------------|
| Flowise | 1.0 | 1GB | AI Workflow |
| Open WebUI | 1.0 | 1GB | AI Chat |
| Qdrant | 1.0 | 1GB | Vector DB |
| Redis | 0.5 | 512MB | Cache |
| Redis Commander | 0.2 | 256MB | Management |
| n8n | 1.0 | 1GB | Automation |

## 🔐 Bảo mật

### Cấu hình bảo mật đã được tối ưu hóa:

1. **Open WebUI**:
   - Tắt tính năng export/share models
   - Tắt đăng ký user mới
   - Bật access logging
   - Định dạng log JSON

2. **n8n**:
   - Cấu hình logging ra console và file
   - Giới hạn kích thước log files
   - Rotation log files

3. **Qdrant**:
   - Tắt CORS
   - Bật API key authentication
   - Cho phép ghi dữ liệu

### Khuyến nghị bảo mật:

1. **Thay đổi tất cả mật khẩu mặc định**
2. **Sử dụng HTTPS cho tất cả services**
3. **Cấu hình firewall phù hợp**
4. **Backup định kỳ**
5. **Monitoring và alerting**
6. **Cập nhật security patches**

## 📊 Monitoring & Logging

### Grafana Dashboards
Truy cập: `http://localhost:9001`
- Username: `admin`
- Password: Xem trong file `.env`

### Prometheus Metrics
Truy cập: `http://localhost:9090`

### Loki Logs
Truy cập: `http://localhost:9002`

### Jaeger Tracing
Truy cập: `http://localhost:9004`

## 🔧 Troubleshooting

### Kiểm tra trạng thái services
```bash
# Xem tất cả containers
docker-compose ps

# Xem logs của service cụ thể
docker-compose logs -f [service-name]

# Restart service
docker-compose restart [service-name]

# Xem resource usage
docker stats
```

### Các lỗi thường gặp

1. **Port conflicts**:
   ```bash
   # Kiểm tra port đang sử dụng
   netstat -an | findstr :8001
   
   # Thay đổi port trong docker-compose.yml
   ```

2. **Memory issues**:
   ```bash
   # Tăng memory limit cho Docker Desktop
   # Settings > Resources > Memory
   ```

3. **Database connection issues**:
   ```bash
   # Kiểm tra PostgreSQL logs
   docker-compose logs postgres
   
   # Restart database
   docker-compose restart postgres
   ```

## 🔄 Backup & Recovery

### Backup tự động
Hệ thống đã cấu hình backup tự động cho PostgreSQL:
- Schedule: Hàng ngày lúc 2:00 AM
- Retention: 7 ngày
- Location: `./backups/`

### Manual backup
```bash
# Backup database
docker-compose exec postgres pg_dumpall -U nextflow > backup_$(date +%Y%m%d).sql

# Backup volumes
docker run --rm -v nextflow-docker_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_data_$(date +%Y%m%d).tar.gz /data
```

### Recovery
```bash
# Restore database
docker-compose exec -T postgres psql -U nextflow < backup_20250101.sql

# Restore volumes
docker run --rm -v nextflow-docker_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_data_20250101.tar.gz -C /
```

## 🚀 Performance Tuning

### Database optimization
```sql
-- PostgreSQL tuning (đã cấu hình trong docker-compose.yml)
max_connections = 200
shared_buffers = 512MB
effective_cache_size = 2GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

### Redis optimization
```
# Redis tuning (đã cấu hình)
maxmemory 1gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

## 📚 API Documentation

### Service Endpoints

| Service | Endpoint | Documentation |
|---------|----------|---------------|
| Flowise | `http://localhost:8001` | Built-in UI |
| Open WebUI | `http://localhost:8002` | Built-in UI |
| n8n | `http://localhost:8003` | Built-in UI |
| Grafana | `http://localhost:9001` | Built-in UI |
| Mail Admin | `http://localhost:8005` | Web Interface |

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

## 📞 Support

- **Documentation**: [Wiki](./wiki)
- **Issues**: [GitHub Issues](./issues)
- **Email**: support@nextflow.vn
- **Discord**: [NextFlow Community](./discord)

## 🔄 Updates

### Version 2.1 (Current)
- ✅ Tối ưu hóa port mapping
- ✅ Giảm resource usage
- ✅ Cải thiện bảo mật
- ✅ Cập nhật logging
- ✅ Thêm health checks
- ✅ Tối ưu hóa profiles

### Roadmap
- 🔄 Kubernetes deployment
- 🔄 Auto-scaling
- 🔄 Advanced monitoring
- 🔄 Multi-region support
- 🔄 CI/CD integration

---

**⚡ NextFlow Docker - Powering AI & Automation at Scale**