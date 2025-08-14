# ============================================================================
# GITLAB CE TÙY CHỈNH CHO NEXTFLOW CRM-AI
# ============================================================================
# Mô tả: GitLab Community Edition được tùy chỉnh với scripts và cấu hình tối ưu
# Tính năng: Scripts NextFlow, múi giờ Việt Nam, cấu hình hiệu suất cao
# Phiên bản: 2.0.0 - Ổn định cho production
# ============================================================================

# Tham số xây dựng - Cố định phiên bản GitLab để đảm bảo ổn định
ARG GITLAB_VERSION=16.11.10-ce.0
ARG GITLAB_TIMEZONE=Asia/Ho_Chi_Minh

# Image gốc - Sử dụng GitLab CE chính thức với phiên bản cố định
FROM gitlab/gitlab-ce:${GITLAB_VERSION}

# Thông tin metadata cho Docker image
LABEL maintainer="NextFlow Team"
LABEL description="GitLab CE tùy chỉnh cho NextFlow CRM-AI"
LABEL version="2.0.0"
LABEL project="nextflow-crm-ai"

# Biến môi trường hệ thống
ENV GITLAB_TIMEZONE=${GITLAB_TIMEZONE}
ENV GITLAB_ROOT_PASSWORD="Nex!tFlow@2025!"

# Thiết lập múi giờ Việt Nam (Asia/Ho_Chi_Minh)
RUN ln -sf /usr/share/zoneinfo/${GITLAB_TIMEZONE} /etc/localtime \
    && echo "${GITLAB_TIMEZONE}" > /etc/timezone

# Cài đặt các gói phần mềm cần thiết (chỉ cài tối thiểu để giảm dung lượng)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Tạo thư mục lưu trữ scripts và cấu hình NextFlow
RUN mkdir -p /opt/nextflow/scripts \
    && mkdir -p /opt/nextflow/config

# Sao chép các scripts NextFlow vào container
COPY gitlab/docker/scripts/gitlab-init.sh /opt/nextflow/scripts/
COPY gitlab/docker/scripts/gitlab-backup.sh /opt/nextflow/scripts/
COPY gitlab/docker/scripts/docker-entrypoint.sh /opt/nextflow/scripts/

# Sao chép file cấu hình mẫu GitLab
COPY gitlab/docker/config/gitlab.rb /opt/nextflow/config/gitlab.rb.template

# Cấp quyền thực thi cho tất cả scripts
RUN chmod +x /opt/nextflow/scripts/*.sh

# Tạo liên kết tắt để dễ sử dụng scripts từ command line
RUN ln -sf /opt/nextflow/scripts/gitlab-backup.sh /usr/local/bin/nextflow-backup \
    && ln -sf /opt/nextflow/scripts/gitlab-init.sh /usr/local/bin/nextflow-init

# Kiểm tra sức khỏe container (Health Check) - Tối ưu cho production
# interval=60s: Kiểm tra mỗi 60 giây
# timeout=30s: Timeout sau 30 giây nếu không phản hồi
# start-period=300s: Đợi 5 phút sau khi start mới bắt đầu check
# retries=3: Thử lại 3 lần trước khi đánh dấu unhealthy
HEALTHCHECK --interval=60s --timeout=30s --start-period=300s --retries=3 \
    CMD /opt/gitlab/bin/gitlab-healthcheck --fail --max-time 10 || exit 1

# Mở các cổng kết nối cần thiết
EXPOSE 80 443 22 5050

# Định nghĩa các thư mục dữ liệu sẽ được mount từ host
VOLUME ["/etc/gitlab", "/var/log/gitlab", "/var/opt/gitlab"]

# Sao chép và cấp quyền cho entry point script tùy chỉnh
COPY gitlab/docker/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Nhãn để Docker Compose nhận diện
LABEL com.docker.compose.service="gitlab"
LABEL com.docker.compose.project="nextflow-crm-ai"

# Điểm khởi động container - Chạy script tùy chỉnh trước khi start GitLab
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/assets/wrapper"]
