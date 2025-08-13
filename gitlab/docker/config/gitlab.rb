# ============================================================================
# NEXTFLOW GITLAB CONFIGURATION
# ============================================================================
# Cấu hình GitLab CE cho NextFlow CRM-AI
# Tối ưu cho production với external PostgreSQL và Redis
# ============================================================================

# URL và cấu hình cơ bản
external_url ENV['GITLAB_EXTERNAL_URL'] || 'http://localhost:8088'
gitlab_kas['enable'] = false
gitlab_rails['initial_root_password'] = ENV['GITLAB_ROOT_PASSWORD'] || 'nextflow@2025'
gitlab_rails['time_zone'] = 'Asia/Ho_Chi_Minh'

# ============================================================================
# DATABASE - POSTGRESQL EXTERNAL
# ============================================================================
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = ENV['GITLAB_DB_HOST'] || 'postgres'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = ENV['GITLAB_DB_USER'] || 'nextflow'
gitlab_rails['db_password'] = ENV['GITLAB_DB_PASSWORD'] || 'nextflow@2025'
gitlab_rails['db_database'] = 'gitlabhq_production'

# ============================================================================
# CACHE - REDIS EXTERNAL
# ============================================================================
redis['enable'] = false
gitlab_rails['redis_host'] = ENV['GITLAB_REDIS_HOST'] || 'redis'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = ENV['GITLAB_REDIS_PASSWORD'] || 'nextflow@2025'

# ============================================================================
# CONTAINER REGISTRY
# ============================================================================
registry_external_url ENV['GITLAB_REGISTRY_URL'] || 'http://localhost:5050'
gitlab_rails['registry_enabled'] = true
registry_nginx['listen_port'] = 5050

# ============================================================================
# SSH CONFIGURATION
# ============================================================================
gitlab_rails['gitlab_shell_ssh_port'] = 2222

# ============================================================================
# EMAIL - STALWART MAIL INTEGRATION
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
# BACKUP CONFIGURATION
# ============================================================================
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_keep_time'] = ENV['GITLAB_BACKUP_KEEP_TIME'] || 604800

# ============================================================================
# PERFORMANCE TUNING
# ============================================================================
puma['worker_processes'] = ENV['GITLAB_PUMA_WORKERS'] || 4
puma['min_threads'] = ENV['GITLAB_PUMA_MIN_THREADS'] || 4
puma['max_threads'] = ENV['GITLAB_PUMA_MAX_THREADS'] || 16
sidekiq['max_concurrency'] = ENV['GITLAB_SIDEKIQ_CONCURRENCY'] || 10

# ============================================================================
# SECURITY & MONITORING
# ============================================================================
prometheus_monitoring['enable'] = false
nginx['redirect_http_to_https'] = false

# ============================================================================
# FEATURES & CI/CD
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
# USER MANAGEMENT
# ============================================================================
gitlab_rails['signup_enabled'] = ENV['GITLAB_SIGNUP_ENABLED'] || true
gitlab_rails['require_admin_approval_after_user_signup'] = false
gitlab_rails['send_user_confirmation_email'] = false

# ============================================================================
# LOGGING
# ============================================================================
logging['logrotate_frequency'] = "daily"
logging['logrotate_size'] = "200MB"
logging['logrotate_rotate'] = 30

# ============================================================================
# OPTIONAL FEATURES (DISABLED)
# ============================================================================
gitlab_pages['enable'] = false
mattermost['enable'] = false
