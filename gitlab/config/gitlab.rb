# ============================================================================
# NEXTFLOW GITLAB CONFIGURATION
# ============================================================================
# Cấu hình GitLab CE cho NextFlow CRM-AI
# Tối ưu cho production với external PostgreSQL và Redis
# ============================================================================

# URL : địa chỉ web và cấu hình cơ bản
external_url ENV['GITLAB_EXTERNAL_URL'] || 'http://localhost:8088'

# Nginx configuration : cấu hình máy chủ web Nginx
nginx['enable'] = true
nginx['listen_port'] = 80
nginx['listen_https'] = false

# Database configuration : cấu hình cơ sở dữ liệu (PostgreSQL bên ngoài)
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = ENV['POSTGRES_HOST'] || 'postgres'
gitlab_rails['db_port'] = ENV['POSTGRES_PORT'] || 5432
gitlab_rails['db_username'] = ENV['POSTGRES_USER_GITLAB'] || 'nextflow'
gitlab_rails['db_password'] = ENV['POSTGRES_PASSWORD_GITLAB'] || 'nextflow@2025'
gitlab_rails['db_database'] = ENV['GITLAB_DATABASE'] || 'nextflow_gitlab'

# Redis configuration : cấu hình bộ nhớ đệm Redis (bên ngoài)
redis['enable'] = false
gitlab_rails['redis_host'] = ENV['REDIS_HOST'] || 'redis'
gitlab_rails['redis_port'] = ENV['REDIS_PORT'] || 6379
gitlab_rails['redis_password'] = ENV['REDIS_PASSWORD'] || 'nextflow@2025'

# Performance settings : cài đặt hiệu suất
puma['worker_processes'] = ENV['GITLAB_PUMA_WORKERS'] || 4
puma['min_threads'] = ENV['GITLAB_PUMA_MIN_THREADS'] || 4
puma['max_threads'] = ENV['GITLAB_PUMA_MAX_THREADS'] || 16
sidekiq['concurrency'] = ENV['GITLAB_SIDEKIQ_CONCURRENCY'] || 10

# SSH configuration : cấu hình kết nối SSH
gitlab_rails['gitlab_shell_ssh_port'] = ENV['GITLAB_SSH_PORT'] || 2222

# Container Registry : kho lưu trữ Docker images
registry_external_url ENV['GITLAB_REGISTRY_URL'] || 'http://localhost:5050'
gitlab_rails['registry_enabled'] = true
registry['enable'] = true
registry_nginx['enable'] = true
registry_nginx['listen_port'] = ENV['GITLAB_REGISTRY_PORT'] || 5050

# Disable unused services : tắt các dịch vụ không sử dụng
prometheus_monitoring['enable'] = false
alertmanager['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_exporter['enable'] = false
grafana['enable'] = false

# Security and features : bảo mật và tính năng
gitlab_rails['signup_enabled'] = ENV['GITLAB_SIGNUP_ENABLED'] || true
gitlab_rails['backup_keep_time'] = ENV['GITLAB_BACKUP_KEEP_TIME'] || 604800

# Timezone : múi giờ
gitlab_rails['time_zone'] = 'Asia/Ho_Chi_Minh'

# Disable GitLab KAS : tắt GitLab Kubernetes Agent Server
gitlab_kas['enable'] = false
gitlab_rails['initial_root_password'] = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
gitlab_rails['time_zone'] = 'Asia/Ho_Chi_Minh'

# ============================================================================
# CƠ SỞ DỮ LIỆU - POSTGRESQL BÊN NGOÀI
# ============================================================================
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = ENV['GITLAB_DB_HOST'] || 'postgres'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = ENV['GITLAB_DB_USER'] || 'nextflow'
gitlab_rails['db_password'] = ENV['GITLAB_DB_PASSWORD'] || 'nextflow@2025'
gitlab_rails['db_database'] = 'nextflow_gitlab'

# ============================================================================
# BỘ NHỚ ĐỆM - REDIS BÊN NGOÀI
# ============================================================================
redis['enable'] = false
gitlab_rails['redis_host'] = ENV['GITLAB_REDIS_HOST'] || 'redis'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = ENV['GITLAB_REDIS_PASSWORD'] || 'nextflow@2025'

# ============================================================================
# KHO LƯU TRỮ CONTAINER : nơi lưu Docker images
# ============================================================================
registry_external_url ENV['GITLAB_REGISTRY_URL'] || 'http://localhost:5050'
gitlab_rails['registry_enabled'] = true
registry_nginx['listen_port'] = 5050

# ============================================================================
# CẤU HÌNH SSH : kết nối bảo mật qua SSH
# ============================================================================
gitlab_rails['gitlab_shell_ssh_port'] = 2222

# ============================================================================
# EMAIL - TÍCH HỢP STALWART MAIL : hệ thống gửi email
# ============================================================================
gitlab_rails['smtp_enable'] = ENV['GITLAB_SMTP_ENABLE'] || true
gitlab_rails['smtp_address'] = ENV['MAIL_SMTP_HOST'] || 'stalwart-mail'
gitlab_rails['smtp_port'] = ENV['MAIL_SMTP_PORT'] || 587
gitlab_rails['smtp_user_name'] = ENV['MAIL_SMTP_USER'] || 'gitlab@nextflow.local'
gitlab_rails['smtp_password'] = ENV['MAIL_SMTP_PASSWORD'] || 'changeme123'
gitlab_rails['smtp_domain'] = ENV['MAIL_DOMAIN'] || 'nextflow.local'
gitlab_rails['smtp_authentication'] = 'login'
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['gitlab_email_from'] = ENV['MAIL_FROM'] || 'gitlab@nextflow.local'
gitlab_rails['gitlab_email_display_name'] = 'GitLab NextFlow CRM-AI'
gitlab_rails['gitlab_email_reply_to'] = ENV['MAIL_REPLY_TO'] || 'noreply@nextflow.local'

# ============================================================================
# CẤU HÌNH SAO LƯU : thiết lập backup dữ liệu
# ============================================================================
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_keep_time'] = ENV['GITLAB_BACKUP_KEEP_TIME'] || 604800

# ============================================================================
# TỐI ƯU HIỆU SUẤT : cài đặt performance
# ============================================================================
puma['worker_processes'] = ENV['GITLAB_PUMA_WORKERS'] || 4
puma['min_threads'] = ENV['GITLAB_PUMA_MIN_THREADS'] || 4
puma['max_threads'] = ENV['GITLAB_PUMA_MAX_THREADS'] || 16
sidekiq['max_concurrency'] = ENV['GITLAB_SIDEKIQ_CONCURRENCY'] || 10

# ============================================================================
# BẢO MẬT & GIÁM SÁT : security và monitoring
# ============================================================================
prometheus_monitoring['enable'] = false
nginx['redirect_http_to_https'] = false

# ============================================================================
# TÍNH NĂNG & CI/CD : các chức năng và tự động hóa
# ============================================================================
gitlab_rails['gitlab_default_projects_features_issues'] = true
gitlab_rails['gitlab_default_projects_features_merge_requests'] = true
gitlab_rails['gitlab_default_projects_features_wiki'] = true
gitlab_rails['gitlab_default_projects_features_snippets'] = true
gitlab_rails['gitlab_default_projects_features_builds'] = true
gitlab_rails['gitlab_default_projects_features_container_registry'] = true
gitlab_rails['auto_devops_enabled'] = true
gitlab_rails['shared_runners_enabled'] = true

# ============================================================================
# QUẢN LÝ NGƯỜI DÙNG : user management
# ============================================================================
gitlab_rails['signup_enabled'] = ENV['GITLAB_SIGNUP_ENABLED'] || true
gitlab_rails['require_admin_approval_after_user_signup'] = false
gitlab_rails['send_user_confirmation_email'] = false

# ============================================================================
# GHI LOG : logging và lưu trữ nhật ký
# ============================================================================
logging['logrotate_frequency'] = "daily"
logging['logrotate_size'] = "200MB"
logging['logrotate_rotate'] = 30

# ============================================================================
# TÍNH NĂNG TÙY CHỌN (ĐÃ TẮT) : optional features disabled
# ============================================================================
gitlab_pages['enable'] = false


# Chính sách mật khẩu NextFlow - Đơn giản và thân thiện người dùng
gitlab_rails['password_authentication_enabled_for_web'] = true
gitlab_rails['password_authentication_enabled_for_git'] = true

# Tắt yêu cầu mật khẩu phức tạp
gitlab_rails['minimum_password_length'] = 8
gitlab_rails['password_complexity'] = false

# Cho phép mật khẩu đơn giản
gitlab_rails['password_blacklist_enabled'] = false
gitlab_rails['password_require_uppercase'] = false
gitlab_rails['password_require_lowercase'] = false
gitlab_rails['password_require_numbers'] = false
gitlab_rails['password_require_symbols'] = false