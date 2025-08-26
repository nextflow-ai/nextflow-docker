# 🦊 GITLAB SCRIPTS - HƯỚNG DẪN TỔNG HỢP

## 📋 **MỤC LỤC**

1. [Tổng quan về GitLab Scripts](#1-tổng-quan-về-gitlab-scripts)
2. [Hướng dẫn sử dụng gitlab-manager.sh](#2-hướng-dẫn-sử-dụng-gitlab-managersh)
3. [Quy trình Backup/Restore](#3-quy-trình-backuprestore)
4. [Database Management](#4-database-management)
5. [User Management](#5-user-management)
6. [Integration với Docker Compose](#6-integration-với-docker-compose)
7. [Troubleshooting Guide](#7-troubleshooting-guide)
8. [Best Practices & Security](#8-best-practices--security)

---

## 1. **TỔNG QUAN VỀ GITLAB SCRIPTS**

### 🎯 **Mục đích**

GitLab Scripts trong NextFlow Docker được thiết kế để quản lý toàn diện GitLab Community Edition, bao gồm:

- **Triển khai tự động**: Cài đặt và cấu hình GitLab
- **Quản lý dữ liệu**: Backup/restore hoàn chỉnh
- **Bảo trì hệ thống**: Database management và troubleshooting
- **Quản lý người dùng**: User creation và authentication
- **Tích hợp**: Seamless integration với NextFlow ecosystem

### 📁 **Cấu trúc Thư mục**

```
scripts/gitlab/
├── gitlab-manager.sh          # Script quản lý chính (2024 dòng)
└── README.md                   # Tài liệu này

gitlab/
├── config/
│   ├── gitlab.rb              # Cấu hình GitLab chính
│   └── trusted-certs/          # Chứng chỉ tin cậy
├── docker/
│   ├── Dockerfile              # Custom GitLab image
│   ├── config/                 # Template cấu hình
│   └── scripts/                # Scripts khởi tạo
└── scripts/
    ├── check_root_user.rb      # Kiểm tra root user
    ├── create_root_user.rb     # Tạo root user
    ├── gitlab_status.rb        # Kiểm tra trạng thái
    └── reset_root_password.rb  # Reset password
```

### 🔧 **Tính năng Chính**

- **16 chức năng quản lý**: Từ cài đặt đến troubleshooting
- **Backup theo chuẩn GitLab**: Bao gồm data, secrets, config
- **Database management**: Migration, reset, troubleshooting
- **User management**: Root user creation và password management
- **Error handling**: Comprehensive error handling và recovery
- **Interactive menu**: Giao diện thân thiện cho người dùng

---

## 2. **HƯỚNG DẪN SỬ DỤNG GITLAB-MANAGER.SH**

### 🚀 **Cách sử dụng cơ bản**

```bash
# Menu tương tác
./scripts/gitlab/gitlab-manager.sh

# Command line interface
./scripts/gitlab/gitlab-manager.sh [command] [options]
```

### 📋 **16 Chức năng Chính**

#### **A. QUẢN LÝ IMAGES VÀ CÀI ĐẶT**

##### **1. check / images - Kiểm tra GitLab Images**
```bash
./scripts/gitlab/gitlab-manager.sh check
```
**Mục đích**: Kiểm tra custom image và official images
**Output**: Danh sách images với version và status

##### **2. build - Build Custom Image**
```bash
./scripts/gitlab/gitlab-manager.sh build
```
**Mục đích**: Build custom GitLab image với NextFlow optimizations
**Image tag**: `nextflow/gitlab-ce:16.11.10-ce.0`

##### **3. install - Cài đặt GitLab Hoàn chỉnh**
```bash
./scripts/gitlab/gitlab-manager.sh install
```
**Quy trình**:
1. Kiểm tra dependencies (PostgreSQL, Redis)
2. Tạo database `nextflow_gitlab`
3. Khởi động GitLab container
4. Health check và readiness validation
5. Database migration (nếu cần)

#### **B. QUẢN LÝ DATABASE**

##### **4. check-db - Kiểm tra và Migration Database**
```bash
./scripts/gitlab/gitlab-manager.sh check-db
```
**Chức năng**:
- Kiểm tra GitLab readiness (timeout: 10 phút)
- Validate database schema
- Tự động chạy migrations nếu cần
- Health check và verification

##### **5. migrate - Force Migration Database**
```bash
./scripts/gitlab/gitlab-manager.sh migrate
```
**Quy trình an toàn**:
1. Stop GitLab services
2. Database setup (`db:setup`)
3. Database migrate (`db:migrate`)
4. Verification (đếm tables và migrations)
5. Restart services

##### **6. reset-db - Reset Database (XÓA TOÀN BỘ)**
```bash
./scripts/gitlab/gitlab-manager.sh reset-db
```
**⚠️ CẢNH BÁO**: Xóa toàn bộ dữ liệu GitLab!
**Quy trình**:
1. Confirmation prompt
2. Force terminate connections
3. Drop và recreate database
4. Schema load
5. Verification

#### **C. QUẢN LÝ NGƯỜI DÙNG**

##### **7. create-root - Tạo/Quản lý Root User**
```bash
./scripts/gitlab/gitlab-manager.sh create-root
```
**Dual approach**:
- **Rails runner**: Bypass validation
- **Database seeding**: Fallback method
**User config**: ID=1, admin=true, confirmed=true

##### **8. reset-root - Reset Password Root User**
```bash
./scripts/gitlab/gitlab-manager.sh reset-root
```
**Interactive process**:
1. Nhập password mới (hoặc dùng mặc định)
2. Confirmation
3. Rails runner update
4. Verification

#### **D. BACKUP VÀ RESTORE**

##### **9. backup - Backup Hoàn chỉnh**
```bash
./scripts/gitlab/gitlab-manager.sh backup
```
**8 bước backup theo chuẩn GitLab**:
1. GitLab Data (`gitlab-backup create`)
2. GitLab Secrets (`gitlab-secrets.json`) - QUAN TRỌNG NHẤT
3. Configuration (`gitlab.rb`)
4. SSH Host Keys
5. TLS Certificates
6. Trusted Certificates
7. Backup Info (metadata)
8. Restore Script (auto-generated)

##### **10. restore-full - Restore Hoàn chỉnh**
```bash
./scripts/gitlab/gitlab-manager.sh restore-full /path/to/backup
```
**12 bước restore an toàn**:
1. Validation (backup directory và metadata)
2. Stop Services (Puma, Sidekiq)
3. Restore Secrets (gitlab-secrets.json TRƯỚC)
4. Restore Config (gitlab.rb)
5. Restore SSH Keys
6. Restore Certificates
7. Reconfigure GitLab
8. Data Restore
9. Post-Reconfigure
10. Start Services
11. Verification (health check, secrets)
12. Summary

#### **E. TROUBLESHOOTING**

##### **11. fix-422 - Fix Lỗi 422**
```bash
./scripts/gitlab/gitlab-manager.sh fix-422
```
**5 bước fix "The change you requested was rejected"**:
1. Restart Services (Puma, Sidekiq)
2. Clear Cache (GitLab cache, tmp)
3. Reconfigure GitLab
4. User Verification (check và fix root user)
5. Reset Sessions

##### **12. check-ready - Kiểm tra Readiness**
```bash
./scripts/gitlab/gitlab-manager.sh check-ready
```
**Validation checks**:
- Container status
- Health status
- Services check
- Rails environment

#### **F. CẤU HÌNH VÀ QUẢN LÝ**

##### **13. config - Cấu hình Password Policy**
```bash
./scripts/gitlab/gitlab-manager.sh config
```
**Simple policy**:
- Minimum length: 8 ký tự
- Disable complexity requirements
- Allow simple passwords
- User-friendly approach

##### **14. reconfigure - Reconfigure GitLab**
```bash
./scripts/gitlab/gitlab-manager.sh reconfigure
```
**Quy trình**:
1. Status check
2. `gitlab-ctl reconfigure`
3. `gitlab-ctl restart`
4. Verification

##### **15. info - Thông tin Truy cập**
```bash
./scripts/gitlab/gitlab-manager.sh info
```
**Hiển thị**:
- URL: Web interface và registry
- Credentials: Username, password, email
- SSH: Git SSH access
- Container status

##### **16. Menu System - Giao diện Tương tác**
```bash
./scripts/gitlab/gitlab-manager.sh
```
**Features**:
- 16 options với mô tả rõ ràng
- Input validation
- Error handling
- Help system

### 💡 **Ví dụ Sử dụng Thực tế**

#### **Scenario 1: Cài đặt GitLab lần đầu**
```bash
# 1. Kiểm tra images
./scripts/gitlab/gitlab-manager.sh check

# 2. Build custom image (nếu cần)
./scripts/gitlab/gitlab-manager.sh build

# 3. Cài đặt GitLab
./scripts/gitlab/gitlab-manager.sh install

# 4. Tạo root user
./scripts/gitlab/gitlab-manager.sh create-root

# 5. Xem thông tin truy cập
./scripts/gitlab/gitlab-manager.sh info
```

#### **Scenario 2: Backup và Restore**
```bash
# Tạo backup hoàn chỉnh
./scripts/gitlab/gitlab-manager.sh backup

# Restore từ backup
./scripts/gitlab/gitlab-manager.sh restore-full /path/to/backup/gitlab_backup_20250119_143000
```

#### **Scenario 3: Troubleshooting**
```bash
# Kiểm tra readiness
./scripts/gitlab/gitlab-manager.sh check-ready

# Fix lỗi 422
./scripts/gitlab/gitlab-manager.sh fix-422

# Reset password
./scripts/gitlab/gitlab-manager.sh reset-root
```

---

## 3. **QUY TRÌNH BACKUP/RESTORE**

### 🗄️ **Backup Strategy**

#### **Backup Components**

1. **GitLab Data** (`gitlab-backup create`)
   - Repositories (Git data)
   - Database (PostgreSQL)
   - Uploads (files, images)
   - CI artifacts
   - LFS objects

2. **GitLab Secrets** (`gitlab-secrets.json`) - **QUAN TRỌNG NHẤT**
   - Encryption keys
   - Database encryption key
   - Secret tokens
   - OTP secrets

3. **Configuration Files**
   - `gitlab.rb` - Main configuration
   - SSH host keys
   - TLS/SSL certificates
   - Trusted certificates

#### **Backup Structure**
```
backups/gitlab_backup_YYYYMMDD_HHMMSS/
├── data/
│   └── TIMESTAMP_gitlab_backup.tar    # GitLab data backup
├── secrets/
│   └── gitlab-secrets.json            # Encryption secrets
├── config/
│   ├── gitlab.rb                      # Main config
│   ├── ssh_host_keys/                 # SSH keys
│   ├── ssl/                           # TLS certificates
│   └── trusted-certs/                 # Trusted certificates
├── backup_info.txt                    # Metadata
└── restore.sh                         # Auto-generated restore script
```

### 🔄 **Restore Process**

#### **Pre-Restore Checklist**
- ✅ GitLab container đang chạy
- ✅ Backup directory tồn tại và hợp lệ
- ✅ Có `backup_info.txt` và metadata
- ✅ Đã backup dữ liệu hiện tại (nếu cần)

#### **Restore Order (QUAN TRỌNG)**
1. **Secrets FIRST** - Phải restore trước tất cả
2. **Configuration** - gitlab.rb và settings
3. **Certificates** - SSH keys, TLS certs
4. **Reconfigure** - Apply configuration
5. **Data** - Repositories và database
6. **Verification** - Health check

#### **Common Restore Issues**

**Issue**: "Secrets verification failed"
```bash
# Solution: Kiểm tra gitlab-secrets.json
ls -la /path/to/backup/secrets/
docker exec gitlab ls -la /etc/gitlab/gitlab-secrets.json
```

**Issue**: "Database restore failed"
```bash
# Solution: Reset database trước
./scripts/gitlab/gitlab-manager.sh reset-db
./scripts/gitlab/gitlab-manager.sh restore-full /path/to/backup
```

### 📅 **Backup Schedule Recommendations**

#### **Production Environment**
- **Daily**: Automated backup (cron job)
- **Weekly**: Full verification backup
- **Monthly**: Archive backup (long-term storage)
- **Before updates**: Manual backup

#### **Development Environment**
- **Weekly**: Regular backup
- **Before major changes**: Manual backup

#### **Cron Job Example**
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/nextflow-docker/scripts/gitlab/gitlab-manager.sh backup

# Weekly cleanup (keep 4 weeks)
0 3 * * 0 find /path/to/backups -name "gitlab_backup_*" -mtime +28 -delete
```

---

## 4. **DATABASE MANAGEMENT**

### 🗄️ **Database Architecture**

#### **Database Setup**
- **Engine**: PostgreSQL 13+
- **Database**: `nextflow_gitlab`
- **User**: `nextflow`
- **Host**: `postgres` (Docker service)
- **Port**: 5432

#### **Key Tables**
- `users` - User accounts
- `projects` - Git repositories
- `issues` - Issue tracking
- `merge_requests` - Code review
- `ci_builds` - CI/CD jobs
- `schema_migrations` - Migration tracking

### 🔧 **Migration Management**

#### **Migration States**

1. **Fresh Install**
   ```bash
   # Tự động chạy khi install
   ./scripts/gitlab/gitlab-manager.sh install
   ```

2. **Pending Migrations**
   ```bash
   # Kiểm tra và chạy migrations
   ./scripts/gitlab/gitlab-manager.sh check-db
   ```

3. **Failed Migrations**
   ```bash
   # Force migrate
   ./scripts/gitlab/gitlab-manager.sh migrate
   ```

4. **Corrupted Database**
   ```bash
   # Reset hoàn toàn
   ./scripts/gitlab/gitlab-manager.sh reset-db
   ```

#### **Migration Troubleshooting**

**Issue**: "Migration timeout"
```bash
# Solution: Tăng timeout và retry
docker exec gitlab gitlab-rake db:migrate RAILS_ENV=production
```

**Issue**: "Table already exists"
```bash
# Solution: Skip problematic migration
docker exec gitlab gitlab-rails runner "ActiveRecord::Migration.verbose = false; ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_paths, TARGET_VERSION)"
```

**Issue**: "Database connection failed"
```bash
# Solution: Kiểm tra PostgreSQL
docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT 1;"
```

### 📊 **Database Monitoring**

#### **Health Checks**
```bash
# Kiểm tra kết nối
docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.active?"

# Kiểm tra tables
docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.tables.count"

# Kiểm tra migrations
docker exec gitlab gitlab-rake db:migrate:status
```

#### **Performance Monitoring**
```bash
# Database size
docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT pg_size_pretty(pg_database_size('nextflow_gitlab'));"

# Table sizes
docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT schemaname,tablename,pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size FROM pg_tables WHERE schemaname='public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;"

# Active connections
docker exec postgres psql -U nextflow -c "SELECT count(*) FROM pg_stat_activity WHERE datname='nextflow_gitlab';"
```

### 🛠️ **Database Maintenance**

#### **Regular Maintenance Tasks**

1. **Vacuum và Analyze**
   ```bash
   docker exec postgres psql -U nextflow -d nextflow_gitlab -c "VACUUM ANALYZE;"
   ```

2. **Reindex**
   ```bash
   docker exec postgres psql -U nextflow -d nextflow_gitlab -c "REINDEX DATABASE nextflow_gitlab;"
   ```

3. **Update Statistics**
   ```bash
   docker exec gitlab gitlab-rake db:analyze
   ```

#### **Cleanup Tasks**

1. **Old CI Artifacts**
   ```bash
   docker exec gitlab gitlab-rake gitlab:cleanup:project_uploads
   ```

2. **Orphaned Files**
   ```bash
   docker exec gitlab gitlab-rake gitlab:cleanup:orphan_job_artifact_files
   ```

3. **Old Traces**
   ```bash
   docker exec gitlab gitlab-rake gitlab:cleanup:remote_upload_files
   ```

---

## 5. **USER MANAGEMENT**

### 👤 **Root User Management**

#### **Root User Creation**

**Method 1: Rails Runner (Recommended)**
```bash
./scripts/gitlab/gitlab-manager.sh create-root
```

**Method 2: Manual Rails Console**
```bash
docker exec -it gitlab gitlab-rails console

# Trong Rails console:
user = User.new(
  id: 1,
  username: 'root',
  email: 'nextflow.vn@gmail.com',
  name: 'Administrator',
  password: 'Nextflow@2025',
  password_confirmation: 'Nextflow@2025',
  admin: true,
  confirmed_at: Time.current,
  state: 'active'
)
user.skip_confirmation!
user.save(validate: false)
```

#### **Root User Configuration**

**Default Settings**:
- **Username**: `root`
- **Password**: `Nextflow@2025` (từ ENV: `GITLAB_ROOT_PASSWORD`)
- **Email**: `nextflow.vn@gmail.com` (từ ENV: `GITLAB_ROOT_EMAIL`)
- **Name**: `Administrator`
- **Admin**: `true`
- **State**: `active`
- **Confirmed**: `true`

### 🔐 **Password Management**

#### **Password Policy Configuration**

**Simple Policy (User-Friendly)**:
```ruby
# Trong gitlab.rb
gitlab_rails['minimum_password_length'] = 8
gitlab_rails['password_complexity'] = false
gitlab_rails['password_blacklist_enabled'] = false
gitlab_rails['password_require_uppercase'] = false
gitlab_rails['password_require_lowercase'] = false
gitlab_rails['password_require_numbers'] = false
gitlab_rails['password_require_symbols'] = false
```

**Apply Policy**:
```bash
./scripts/gitlab/gitlab-manager.sh config
```

#### **Password Reset**

**Interactive Reset**:
```bash
./scripts/gitlab/gitlab-manager.sh reset-root
```

**Manual Reset**:
```bash
docker exec gitlab gitlab-rails runner "
user = User.find_by(username: 'root')
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save(validate: false)
"
```

### 👥 **Additional User Management**

#### **Create Regular User**
```bash
docker exec gitlab gitlab-rails runner "
user = User.create!(
  username: 'developer',
  email: 'dev@nextflow.vn',
  name: 'Developer',
  password: 'password123',
  password_confirmation: 'password123',
  confirmed_at: Time.current,
  state: 'active'
)
user.skip_confirmation!
user.save(validate: false)
"
```

#### **User Operations**

**List Users**:
```bash
docker exec gitlab gitlab-rails runner "User.all.each { |u| puts \"#{u.id}: #{u.username} (#{u.email}) - #{u.state}\" }"
```

**Activate User**:
```bash
docker exec gitlab gitlab-rails runner "User.find_by(username: 'username').activate"
```

**Block User**:
```bash
docker exec gitlab gitlab-rails runner "User.find_by(username: 'username').block"
```

**Delete User**:
```bash
docker exec gitlab gitlab-rails runner "User.find_by(username: 'username').destroy"
```

### 🔑 **Authentication Troubleshooting**

#### **Common Issues**

**Issue**: "422 - The change you requested was rejected"
```bash
# Solution: Fix CSRF và sessions
./scripts/gitlab/gitlab-manager.sh fix-422
```

**Issue**: "Invalid username or password"
```bash
# Solution: Reset password
./scripts/gitlab/gitlab-manager.sh reset-root
```

**Issue**: "Account locked"
```bash
# Solution: Unlock account
docker exec gitlab gitlab-rails runner "User.find_by(username: 'root').unlock_access!"
```

**Issue**: "Email not confirmed"
```bash
# Solution: Confirm email
docker exec gitlab gitlab-rails runner "User.find_by(username: 'root').confirm"
```

---

## 6. **INTEGRATION VỚI DOCKER COMPOSE**

### 🐳 **Docker Compose Configuration**

#### **GitLab Service Definition**
```yaml
# Trong docker-compose.yml
gitlab:
  image: nextflow/gitlab-ce:16.11.10-ce.0
  container_name: gitlab
  hostname: gitlab.nextflow.local
  restart: unless-stopped
  environment:
    GITLAB_EXTERNAL_URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}
    GITLAB_ROOT_PASSWORD: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}
    GITLAB_ROOT_EMAIL: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}
    # Database configuration
    GITLAB_DB_HOST: postgres
    GITLAB_DB_USER: ${POSTGRES_USER}
    GITLAB_DB_PASSWORD: ${POSTGRES_PASSWORD}
    GITLAB_DB_DATABASE: nextflow_gitlab
    # Redis configuration
    GITLAB_REDIS_HOST: redis
    GITLAB_REDIS_PASSWORD: ${REDIS_PASSWORD}
  ports:
    - "8088:80"      # HTTP
    - "8443:443"     # HTTPS
    - "2222:22"      # SSH
    - "5050:5050"    # Registry
  volumes:
    - ./gitlab/config:/etc/gitlab
    - ./gitlab/logs:/var/log/gitlab
    - ./gitlab/data:/var/opt/gitlab
    - ./gitlab/backups:/var/opt/gitlab/backups
  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy
  networks:
    - demo
  healthcheck:
    test: ["CMD", "/opt/gitlab/bin/gitlab-healthcheck", "--fail", "--max-time", "10"]
    interval: 60s
    timeout: 30s
    start_period: 300s
    retries: 3
```

#### **Dependencies**

**PostgreSQL Service**:
```yaml
postgres:
  image: postgres:13
  container_name: postgres
  environment:
    POSTGRES_DB: ${POSTGRES_DB:-nextflow}
    POSTGRES_USER: ${POSTGRES_USER:-nextflow}
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-nextflow@2025}
  volumes:
    - postgres_storage:/var/lib/postgresql/data
    - ./postgres/init:/docker-entrypoint-initdb.d
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-nextflow}"]
    interval: 10s
    timeout: 5s
    retries: 5
```

**Redis Service**:
```yaml
redis:
  image: redis:7-alpine
  container_name: redis
  command: redis-server --requirepass ${REDIS_PASSWORD:-nextflow@2025}
  volumes:
    - redis_data:/data
  healthcheck:
    test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
    interval: 10s
    timeout: 3s
    retries: 5
```

### 🔧 **Environment Variables**

#### **GitLab Configuration**
```bash
# Trong .env file

# GitLab Basic Settings
GITLAB_EXTERNAL_URL=http://localhost:8088
GITLAB_ROOT_PASSWORD=Nextflow@2025
GITLAB_ROOT_EMAIL=nextflow.vn@gmail.com
GITLAB_ROOT_NAME="NextFlow Administrator"

# GitLab Ports
GITLAB_HTTP_PORT=8088
GITLAB_HTTPS_PORT=8443
GITLAB_SSH_PORT=2222
GITLAB_REGISTRY_PORT=5050

# GitLab Registry
GITLAB_REGISTRY_URL=http://localhost:5050
GITLAB_REGISTRY_ENABLED=true

# GitLab Database
GITLAB_DB_HOST=postgres
GITLAB_DB_PORT=5432
GITLAB_DB_USER=nextflow
GITLAB_DB_PASSWORD=nextflow@2025
GITLAB_DB_DATABASE=nextflow_gitlab

# GitLab Redis
GITLAB_REDIS_HOST=redis
GITLAB_REDIS_PORT=6379
GITLAB_REDIS_PASSWORD=nextflow@2025

# GitLab Performance
GITLAB_PUMA_WORKERS=4
GITLAB_PUMA_MIN_THREADS=4
GITLAB_PUMA_MAX_THREADS=16
GITLAB_SIDEKIQ_CONCURRENCY=10

# GitLab Features
GITLAB_SIGNUP_ENABLED=true
GITLAB_BACKUP_KEEP_TIME=604800

# GitLab SMTP (với Stalwart Mail)
GITLAB_SMTP_ENABLE=true
GITLAB_SMTP_HOST=stalwart-mail
GITLAB_SMTP_PORT=587
GITLAB_SMTP_USER=gitlab@nextflow.local
GITLAB_SMTP_PASSWORD=changeme123
GITLAB_SMTP_DOMAIN=nextflow.local
```

### 🚀 **Deployment Integration**

#### **Với Deploy Manager**
```bash
# Triển khai GitLab profile
./scripts/deploy_manager.sh --profile gitlab

# Triển khai multiple profiles
./scripts/deploy_manager.sh --profiles basic,gitlab,monitoring
```

#### **Với Backup Manager**
```bash
# Backup GitLab trong tổng thể
./scripts/backup_manager.sh --full

# Backup chỉ GitLab
./scripts/backup_manager.sh --service gitlab
```

### 🌐 **Network Configuration**

#### **Internal Network**
```yaml
networks:
  demo:
    driver: bridge
    name: nextflow_network
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
```

#### **Service Discovery**
- **GitLab**: `http://gitlab:80` (internal)
- **PostgreSQL**: `postgres:5432`
- **Redis**: `redis:6379`
- **Registry**: `gitlab:5050`

### 🔗 **External Access**

#### **Port Mapping**
- **HTTP**: `localhost:8088` → `gitlab:80`
- **HTTPS**: `localhost:8443` → `gitlab:443`
- **SSH**: `localhost:2222` → `gitlab:22`
- **Registry**: `localhost:5050` → `gitlab:5050`

#### **Cloudflare Tunnel Integration**
```bash
# Setup tunnel cho GitLab
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn

# URLs:
# - https://gitlab.nextflow.vn (GitLab web)
# - https://registry.nextflow.vn (Container registry)
```

---

## 7. **TROUBLESHOOTING GUIDE**

### 🚨 **Common Issues và Solutions**

#### **A. INSTALLATION ISSUES**

##### **Issue 1: "GitLab container fails to start"**

**Symptoms**:
- Container exits immediately
- "Exited (1)" status
- No logs in `docker logs gitlab`

**Diagnosis**:
```bash
# Kiểm tra container status
docker ps -a | grep gitlab

# Xem logs chi tiết
docker logs gitlab --tail 50

# Kiểm tra resources
docker stats gitlab
```

**Solutions**:
```bash
# 1. Kiểm tra memory (GitLab cần ít nhất 3GB)
free -h

# 2. Kiểm tra disk space
df -h

# 3. Reset container
docker stop gitlab
docker rm gitlab
./scripts/gitlab/gitlab-manager.sh install

# 4. Kiểm tra dependencies
docker ps | grep -E "postgres|redis"
```

##### **Issue 2: "Database connection failed"**

**Symptoms**:
- GitLab logs show database errors
- "PG::ConnectionBad" errors
- GitLab web interface không accessible

**Diagnosis**:
```bash
# Kiểm tra PostgreSQL
docker exec postgres psql -U nextflow -c "SELECT 1;"

# Kiểm tra database tồn tại
docker exec postgres psql -U nextflow -l | grep gitlab

# Kiểm tra network connectivity
docker exec gitlab ping postgres
```

**Solutions**:
```bash
# 1. Tạo database nếu chưa có
docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;"

# 2. Reset database connection
./scripts/gitlab/gitlab-manager.sh reconfigure

# 3. Force database setup
./scripts/gitlab/gitlab-manager.sh migrate
```

#### **B. AUTHENTICATION ISSUES**

##### **Issue 3: "422 - The change you requested was rejected"**

**Symptoms**:
- Không thể login
- Form submissions bị reject
- CSRF token errors

**Diagnosis**:
```bash
# Kiểm tra GitLab services
docker exec gitlab gitlab-ctl status

# Kiểm tra logs
docker exec gitlab gitlab-ctl tail gitlab-rails
```

**Solutions**:
```bash
# Automated fix
./scripts/gitlab/gitlab-manager.sh fix-422

# Manual steps:
# 1. Clear browser cache và cookies
# 2. Thử incognito mode
# 3. Restart Puma
docker exec gitlab gitlab-ctl restart puma
```

##### **Issue 4: "Invalid username or password"**

**Symptoms**:
- Root user không thể login
- Password không work
- Account locked

**Diagnosis**:
```bash
# Kiểm tra root user
docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root')&.state"

# Kiểm tra password hash
docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root')&.encrypted_password[0..20]"
```

**Solutions**:
```bash
# 1. Reset password
./scripts/gitlab/gitlab-manager.sh reset-root

# 2. Recreate root user
./scripts/gitlab/gitlab-manager.sh create-root

# 3. Unlock account
docker exec gitlab gitlab-rails runner "User.find_by(username: 'root').unlock_access!"
```

#### **C. PERFORMANCE ISSUES**

##### **Issue 5: "GitLab is very slow"**

**Symptoms**:
- Pages load slowly
- Timeouts
- High CPU/Memory usage

**Diagnosis**:
```bash
# Kiểm tra resources
docker stats gitlab postgres redis

# Kiểm tra GitLab performance
docker exec gitlab gitlab-rake gitlab:check

# Kiểm tra database performance
docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT count(*) FROM pg_stat_activity;"
```

**Solutions**:
```bash
# 1. Tăng resources trong docker-compose.yml
# 2. Optimize database
docker exec postgres psql -U nextflow -d nextflow_gitlab -c "VACUUM ANALYZE;"

# 3. Clear GitLab cache
docker exec gitlab gitlab-rake cache:clear

# 4. Restart services
docker exec gitlab gitlab-ctl restart
```

##### **Issue 6: "Out of disk space"**

**Symptoms**:
- "No space left on device"
- GitLab stops working
- Backup fails

**Diagnosis**:
```bash
# Kiểm tra disk usage
df -h
du -sh /var/lib/docker

# Kiểm tra GitLab data
docker exec gitlab du -sh /var/opt/gitlab
```

**Solutions**:
```bash
# 1. Clean Docker
docker system prune -a

# 2. Clean GitLab artifacts
docker exec gitlab gitlab-rake gitlab:cleanup:project_uploads
docker exec gitlab gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# 3. Move data to larger disk
# 4. Setup log rotation
```

#### **D. BACKUP/RESTORE ISSUES**

##### **Issue 7: "Backup fails"**

**Symptoms**:
- `gitlab-backup create` fails
- Permission denied errors
- Incomplete backup files

**Diagnosis**:
```bash
# Kiểm tra backup directory
ls -la gitlab/backups/

# Kiểm tra permissions
docker exec gitlab ls -la /var/opt/gitlab/backups/

# Kiểm tra disk space
df -h
```

**Solutions**:
```bash
# 1. Fix permissions
docker exec gitlab chown -R git:git /var/opt/gitlab/backups

# 2. Clean old backups
find gitlab/backups/ -name "*_gitlab_backup.tar" -mtime +7 -delete

# 3. Manual backup
docker exec gitlab gitlab-backup create BACKUP=manual_$(date +%Y%m%d)
```

##### **Issue 8: "Restore fails"**

**Symptoms**:
- "Backup file not found"
- "Secrets verification failed"
- Data corruption after restore

**Diagnosis**:
```bash
# Kiểm tra backup file
tar -tf backup_file.tar | head -10

# Kiểm tra secrets
ls -la backup_directory/secrets/

# Kiểm tra GitLab version compatibility
```

**Solutions**:
```bash
# 1. Verify backup integrity
tar -tf backup_file.tar > /dev/null

# 2. Restore secrets first
docker cp backup/secrets/gitlab-secrets.json gitlab:/etc/gitlab/

# 3. Reset database before restore
./scripts/gitlab/gitlab-manager.sh reset-db
./scripts/gitlab/gitlab-manager.sh restore-full /path/to/backup
```

### 🔍 **Diagnostic Commands**

#### **System Health Check**
```bash
# GitLab comprehensive check
docker exec gitlab gitlab-rake gitlab:check SANITIZE=true

# GitLab environment info
docker exec gitlab gitlab-rake gitlab:env:info

# Database check
docker exec gitlab gitlab-rake gitlab:doctor:secrets
```

#### **Log Analysis**
```bash
# GitLab application logs
docker exec gitlab gitlab-ctl tail gitlab-rails

# GitLab service logs
docker exec gitlab gitlab-ctl tail

# Container logs
docker logs gitlab --tail 100 -f

# System logs (if needed)
journalctl -u docker -f
```

#### **Performance Monitoring**
```bash
# Resource usage
docker stats gitlab postgres redis

# GitLab process status
docker exec gitlab gitlab-ctl status

# Database connections
docker exec postgres psql -U nextflow -c "SELECT count(*) FROM pg_stat_activity WHERE datname='nextflow_gitlab';"

# Redis info
docker exec redis redis-cli info
```

### 📞 **Getting Help**

#### **Internal Resources**
1. **Script help**: `./scripts/gitlab/gitlab-manager.sh --help`
2. **Interactive menu**: `./scripts/gitlab/gitlab-manager.sh`
3. **Logs**: `docker logs gitlab`
4. **GitLab check**: `docker exec gitlab gitlab-rake gitlab:check`

#### **External Resources**
1. **GitLab Docs**: https://docs.gitlab.com/
2. **GitLab Troubleshooting**: https://docs.gitlab.com/ee/administration/troubleshooting/
3. **Docker Docs**: https://docs.docker.com/
4. **NextFlow Community**: Internal support channels

---

## 8. **BEST PRACTICES & SECURITY**

### 🛡️ **Security Best Practices**

#### **A. AUTHENTICATION & AUTHORIZATION**

##### **Strong Password Policy**
```bash
# Cấu hình password policy mạnh cho production
docker exec gitlab gitlab-rails runner "
ApplicationSetting.current.update!(
  minimum_password_length: 12,
  password_complexity: true,
  password_require_uppercase: true,
  password_require_lowercase: true,
  password_require_numbers: true,
  password_require_symbols: true
)
"
```

##### **Two-Factor Authentication (2FA)**
```bash
# Bật 2FA cho admin users
docker exec gitlab gitlab-rails runner "
User.admins.each do |admin|
  admin.update!(require_two_factor_authentication: true)
end
"
```

##### **Session Security**
```ruby
# Trong gitlab.rb
gitlab_rails['session_expire_delay'] = 10080  # 7 days
gitlab_rails['session_store_secure'] = true   # HTTPS only
gitlab_rails['session_store_httponly'] = true # No JS access
```

#### **B. NETWORK SECURITY**

##### **HTTPS Configuration**
```ruby
# Trong gitlab.rb
external_url 'https://gitlab.nextflow.vn'
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.key"
nginx['ssl_protocols'] = "TLSv1.2 TLSv1.3"
nginx['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256"
```

##### **SSH Security**
```ruby
# Trong gitlab.rb
gitlab_rails['gitlab_shell_ssh_port'] = 2222
gitlab_shell['auth_file'] = "/var/opt/gitlab/.ssh/authorized_keys"

# Disable SSH password authentication
# Chỉ cho phép key-based authentication
```

##### **IP Whitelisting**
```ruby
# Trong gitlab.rb
nginx['custom_gitlab_server_config'] = "
  location /admin {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
  }
"
```

#### **C. DATA PROTECTION**

##### **Encryption at Rest**
```ruby
# Trong gitlab.rb
gitlab_rails['db_encryption_key_base'] = 'your-secret-key-base'
gitlab_rails['secret_key_base'] = 'your-secret-key-base'
gitlab_rails['otp_key_base'] = 'your-otp-key-base'
```

##### **Backup Encryption**
```bash
# Encrypt backup files
tar -czf - backup_directory/ | gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output backup_encrypted.tar.gz.gpg

# Decrypt backup files
gpg --decrypt backup_encrypted.tar.gz.gpg | tar -xzf -
```

##### **Secrets Management**
```bash
# Secure gitlab-secrets.json
chmod 600 /etc/gitlab/gitlab-secrets.json
chown root:root /etc/gitlab/gitlab-secrets.json

# Backup secrets securely
cp /etc/gitlab/gitlab-secrets.json /secure/backup/location/
```

### 🚀 **Performance Best Practices**

#### **A. RESOURCE OPTIMIZATION**

##### **Memory Configuration**
```ruby
# Trong gitlab.rb
# Optimize cho 8GB RAM server
puma['worker_processes'] = 4
puma['min_threads'] = 4
puma['max_threads'] = 16
puma['worker_memory_limit_mb'] = 1024

sidekiq['max_concurrency'] = 10
sidekiq['memory_killer_max_memory'] = 1000

postgresql['shared_buffers'] = "1GB"
postgresql['effective_cache_size'] = "4GB"
```

##### **Database Optimization**
```sql
-- Trong PostgreSQL
-- Optimize cho GitLab workload
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '4GB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
SELECT pg_reload_conf();
```

##### **Redis Optimization**
```ruby
# Trong gitlab.rb
redis['maxmemory'] = "1gb"
redis['maxmemory_policy'] = "allkeys-lru"
redis['save'] = "900 1 300 10 60 10000"
```

#### **B. MONITORING & ALERTING**

##### **Health Monitoring**
```bash
# Setup health check script
cat > /usr/local/bin/gitlab-health-check.sh << 'EOF'
#!/bin/bash

# Check GitLab health
if ! docker exec gitlab gitlab-ctl status > /dev/null 2>&1; then
    echo "CRITICAL: GitLab services down"
    exit 2
fi

# Check database connection
if ! docker exec gitlab gitlab-rails runner "ActiveRecord::Base.connection.active?" > /dev/null 2>&1; then
    echo "CRITICAL: Database connection failed"
    exit 2
fi

# Check disk space
USAGE=$(df /var/lib/docker | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $USAGE -gt 90 ]; then
    echo "WARNING: Disk usage ${USAGE}%"
    exit 1
fi

echo "OK: GitLab healthy"
exit 0
EOF

chmod +x /usr/local/bin/gitlab-health-check.sh
```

##### **Log Monitoring**
```bash
# Setup log rotation
cat > /etc/logrotate.d/gitlab << 'EOF'
/var/log/gitlab/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 git git
    postrotate
        docker exec gitlab gitlab-ctl reopen-logs
    endscript
}
EOF
```

### 🔄 **Operational Best Practices**

#### **A. BACKUP STRATEGY**

##### **3-2-1 Backup Rule**
- **3 copies**: Original + 2 backups
- **2 different media**: Local + Cloud/Remote
- **1 offsite**: Geographic separation

##### **Automated Backup Script**
```bash
#!/bin/bash
# /usr/local/bin/gitlab-backup-automated.sh

BACKUP_DIR="/backups/gitlab"
S3_BUCKET="s3://your-backup-bucket/gitlab"
RETENTION_DAYS=30

# Create backup
/path/to/nextflow-docker/scripts/gitlab/gitlab-manager.sh backup

# Find latest backup
LATEST_BACKUP=$(find $BACKUP_DIR -name "gitlab_backup_*" -type d | sort -r | head -1)

if [ -n "$LATEST_BACKUP" ]; then
    # Compress backup
    tar -czf "${LATEST_BACKUP}.tar.gz" -C "$(dirname $LATEST_BACKUP)" "$(basename $LATEST_BACKUP)"
    
    # Upload to S3 (if configured)
    if command -v aws >/dev/null 2>&1; then
        aws s3 cp "${LATEST_BACKUP}.tar.gz" "$S3_BUCKET/"
    fi
    
    # Cleanup old backups
    find $BACKUP_DIR -name "gitlab_backup_*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;
    
    echo "Backup completed: $(basename $LATEST_BACKUP)"
else
    echo "ERROR: No backup created"
    exit 1
fi
```

##### **Backup Verification**
```bash
#!/bin/bash
# Verify backup integrity

BACKUP_PATH="$1"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "ERROR: Backup path not found"
    exit 1
fi

# Check required files
REQUIRED_FILES=(
    "secrets/gitlab-secrets.json"
    "config/gitlab.rb"
    "backup_info.txt"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$BACKUP_PATH/$file" ]; then
        echo "ERROR: Missing required file: $file"
        exit 1
    fi
done

# Check data backup
DATA_BACKUP=$(find "$BACKUP_PATH/data" -name "*_gitlab_backup.tar" | head -1)
if [ ! -f "$DATA_BACKUP" ]; then
    echo "ERROR: No data backup found"
    exit 1
fi

# Verify tar file
if ! tar -tf "$DATA_BACKUP" >/dev/null 2>&1; then
    echo "ERROR: Data backup file corrupted"
    exit 1
fi

echo "OK: Backup verification passed"
```

#### **B. UPDATE STRATEGY**

##### **GitLab Update Process**
```bash
#!/bin/bash
# GitLab update script

CURRENT_VERSION=$(docker exec gitlab cat /opt/gitlab/version-manifest.txt | head -1)
echo "Current version: $CURRENT_VERSION"

# 1. Create backup before update
echo "Creating backup before update..."
./scripts/gitlab/gitlab-manager.sh backup

# 2. Stop GitLab
echo "Stopping GitLab..."
docker stop gitlab

# 3. Update image
echo "Pulling new GitLab image..."
docker pull gitlab/gitlab-ce:latest

# 4. Update docker-compose.yml if needed
# 5. Start GitLab
echo "Starting GitLab..."
docker-compose up -d gitlab

# 6. Wait for GitLab to be ready
echo "Waiting for GitLab to be ready..."
sleep 60

# 7. Run migrations
echo "Running database migrations..."
docker exec gitlab gitlab-rake db:migrate

# 8. Verify update
echo "Verifying update..."
NEW_VERSION=$(docker exec gitlab cat /opt/gitlab/version-manifest.txt | head -1)
echo "New version: $NEW_VERSION"

if docker exec gitlab gitlab-rake gitlab:check >/dev/null 2>&1; then
    echo "✅ Update successful!"
else
    echo "❌ Update verification failed!"
    echo "Consider rolling back..."
fi
```

#### **C. DISASTER RECOVERY**

##### **Recovery Plan**

**RTO (Recovery Time Objective)**: 4 hours
**RPO (Recovery Point Objective)**: 24 hours

**Recovery Steps**:
1. **Assess damage** (15 minutes)
2. **Prepare new environment** (30 minutes)
3. **Restore from backup** (2-3 hours)
4. **Verify and test** (30 minutes)

##### **Recovery Script**
```bash
#!/bin/bash
# Disaster recovery script

BACKUP_PATH="$1"
NEW_HOST="$2"

if [ -z "$BACKUP_PATH" ] || [ -z "$NEW_HOST" ]; then
    echo "Usage: $0 <backup_path> <new_host>"
    exit 1
fi

echo "🚨 Starting GitLab disaster recovery..."
echo "Backup: $BACKUP_PATH"
echo "Target: $NEW_HOST"

# 1. Setup new environment
echo "📋 Setting up new environment..."
scp -r nextflow-docker/ $NEW_HOST:/opt/
ssh $NEW_HOST "cd /opt/nextflow-docker && docker-compose up -d postgres redis"

# 2. Wait for dependencies
echo "⏳ Waiting for dependencies..."
sleep 30

# 3. Transfer backup
echo "📦 Transferring backup..."
scp -r $BACKUP_PATH $NEW_HOST:/opt/nextflow-docker/

# 4. Start GitLab
echo "🚀 Starting GitLab..."
ssh $NEW_HOST "cd /opt/nextflow-docker && docker-compose up -d gitlab"

# 5. Restore from backup
echo "🔄 Restoring from backup..."
ssh $NEW_HOST "cd /opt/nextflow-docker && ./scripts/gitlab/gitlab-manager.sh restore-full $(basename $BACKUP_PATH)"

# 6. Verify recovery
echo "✅ Verifying recovery..."
if ssh $NEW_HOST "docker exec gitlab gitlab-rake gitlab:check" >/dev/null 2>&1; then
    echo "🎉 Disaster recovery completed successfully!"
    echo "GitLab is now available at: http://$NEW_HOST:8088"
else
    echo "❌ Recovery verification failed!"
    exit 1
fi
```

### 📊 **Compliance & Auditing**

#### **Audit Logging**
```ruby
# Trong gitlab.rb
gitlab_rails['audit_events_enabled'] = true
gitlab_rails['audit_events_retention_days'] = 365

# Log all admin actions
gitlab_rails['log_level'] = 'info'
gitlab_rails['audit_log_enabled'] = true
```

#### **Access Control**
```bash
# Regular access review script
#!/bin/bash

echo "=== GitLab Access Review ==="
echo "Date: $(date)"
echo

echo "Admin Users:"
docker exec gitlab gitlab-rails runner "User.admins.each { |u| puts \"#{u.username} - #{u.email} - Last seen: #{u.last_activity_on}\" }"

echo
echo "Active Users (last 30 days):"
docker exec gitlab gitlab-rails runner "User.active.where('last_activity_on > ?', 30.days.ago).each { |u| puts \"#{u.username} - #{u.email} - #{u.last_activity_on}\" }"

echo
echo "Inactive Users (>90 days):"
docker exec gitlab gitlab-rails runner "User.where('last_activity_on < ? OR last_activity_on IS NULL', 90.days.ago).each { |u| puts \"#{u.username} - #{u.email} - #{u.last_activity_on || 'Never'}\" }"
```

---

## 🎯 **KẾT LUẬN**

Tài liệu này cung cấp hướng dẫn toàn diện để quản lý GitLab trong môi trường NextFlow Docker. Với 16 chức năng chính của `gitlab-manager.sh` và các best practices được trình bày, bạn có thể:

✅ **Triển khai GitLab** một cách an toàn và hiệu quả
✅ **Quản lý backup/restore** theo chuẩn GitLab Official
✅ **Troubleshoot** các vấn đề thường gặp
✅ **Bảo mật** hệ thống theo best practices
✅ **Tối ưu performance** cho môi trường production
✅ **Tích hợp** seamlessly với NextFlow ecosystem

### 📞 **Hỗ trợ**

Nếu gặp vấn đề, hãy:
1. Kiểm tra [Troubleshooting Guide](#7-troubleshooting-guide)
2. Chạy `./scripts/gitlab/gitlab-manager.sh` để sử dụng interactive menu
3. Xem logs: `docker logs gitlab --tail 100`
4. Liên hệ NextFlow support team

### 🔄 **Cập nhật**

Tài liệu này được cập nhật thường xuyên. Phiên bản hiện tại: **v2.0.0**

---

**© 2025 NextFlow Team - GitLab Scripts Documentation**