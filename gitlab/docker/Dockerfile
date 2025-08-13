# ============================================================================
# GITLAB CE CUSTOM BUILD FOR NEXTFLOW CRM-AI
# ============================================================================
# Mô tả: GitLab CE tùy chỉnh với scripts và cấu hình tối ưu
# Tính năng: NextFlow scripts, Vietnamese timezone, optimized config
# ============================================================================

# Build arguments - Cố định GitLab version 16.11.10
ARG GITLAB_VERSION=16.11.10-ce.0
ARG GITLAB_TIMEZONE=Asia/Ho_Chi_Minh

# Base image - Cố định version để đảm bảo tính ổn định
FROM gitlab/gitlab-ce:16.11.10-ce.0

# Metadata
LABEL maintainer="NextFlow Team"
LABEL description="Custom GitLab CE for NextFlow CRM-AI"
LABEL version="2.0.0"
LABEL project="nextflow-crm-ai"

# Environment variables
ENV GITLAB_TIMEZONE=${GITLAB_TIMEZONE}
ENV GITLAB_ROOT_PASSWORD="nextflow@2025"

# Thiết lập timezone Việt Nam
RUN ln -sf /usr/share/zoneinfo/${GITLAB_TIMEZONE} /etc/localtime \
    && echo "${GITLAB_TIMEZONE}" > /etc/timezone

# Cài đặt packages cần thiết (tối thiểu)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Tạo thư mục cho NextFlow scripts
RUN mkdir -p /opt/nextflow/scripts \
    && mkdir -p /opt/nextflow/config

# Copy NextFlow scripts
COPY scripts/gitlab-init.sh /opt/nextflow/scripts/
COPY scripts/gitlab-backup.sh /opt/nextflow/scripts/
COPY scripts/docker-entrypoint.sh /opt/nextflow/scripts/

# Copy cấu hình template
COPY config/gitlab.rb /opt/nextflow/config/gitlab.rb.template

# Phân quyền cho scripts
RUN chmod +x /opt/nextflow/scripts/*.sh

# Tạo symbolic links để dễ truy cập
RUN ln -sf /opt/nextflow/scripts/gitlab-backup.sh /usr/local/bin/nextflow-backup \
    && ln -sf /opt/nextflow/scripts/gitlab-init.sh /usr/local/bin/nextflow-init

# Health check tối ưu
HEALTHCHECK --interval=60s --timeout=30s --start-period=300s --retries=3 \
    CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10 || exit 1

# Expose ports cần thiết
EXPOSE 80 443 22 5050

# Volume mounts
VOLUME ["/etc/gitlab", "/var/log/gitlab", "/var/opt/gitlab"]

# Entry point tùy chỉnh
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Labels cho Docker Compose
LABEL com.docker.compose.service="gitlab"
LABEL com.docker.compose.project="nextflow-crm-ai"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/assets/wrapper"]
