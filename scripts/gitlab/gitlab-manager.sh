#!/bin/bash
# ============================================================================
# GITLAB MANAGER - ENHANCED VERSION
# ============================================================================
# Mô tả: Script quản lý GitLab hoàn chỉnh với backup/restore đầy đủ
# Tác giả: NextFlow Team
# ============================================================================
set -e
# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cấu hình
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"
GITLAB_CONTAINER="gitlab"
BACKUP_DIR="$PROJECT_DIR/gitlab/backups"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Hàm log đơn giản
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Kiểm tra Docker
check_docker() {
    if ! command -v docker > /dev/null 2>&1; then
        log_error "Docker không được cài đặt"
        log_info "Vui lòng cài đặt Docker Desktop và khởi động"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon không chạy"
        log_info "Vui lòng khởi động Docker Desktop"
        exit 1
    fi

    log_info "Docker đã sẵn sàng"
}

# Cấu hình GitLab password policy đơn giản
configure_password_policy() {
    log_info "Cấu hình GitLab password policy đơn giản..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        return 1
    fi

    # Backup gitlab.rb hiện tại
    docker exec "$GITLAB_CONTAINER" cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.backup 2>/dev/null || true

    # Thêm cấu hình password policy vào gitlab.rb
    docker exec "$GITLAB_CONTAINER" bash -c "
    # Xóa cấu hình password cũ nếu có
    sed -i '/# NextFlow Password Policy/,/# End NextFlow Password Policy/d' /etc/gitlab/gitlab.rb

    # Thêm cấu hình mới
    cat >> /etc/gitlab/gitlab.rb << 'EOF'

# NextFlow Password Policy - Simple & User Friendly
gitlab_rails['password_authentication_enabled_for_web'] = true
gitlab_rails['password_authentication_enabled_for_git'] = true

# Disable strict password requirements
gitlab_rails['minimum_password_length'] = 8
gitlab_rails['password_complexity'] = false

# Allow simple passwords
gitlab_rails['password_blacklist_enabled'] = false
gitlab_rails['password_require_uppercase'] = false
gitlab_rails['password_require_lowercase'] = false
gitlab_rails['password_require_numbers'] = false
gitlab_rails['password_require_symbols'] = false

# End NextFlow Password Policy
EOF
    "

    log_info "Áp dụng cấu hình GitLab..."
    if docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure; then
        log_success "Cấu hình password policy thành công!"
        log_info "GitLab hiện cho phép password đơn giản"
    else
        log_error "Lỗi cấu hình GitLab"
        return 1
    fi
}

# [RECONFIGURE] Reconfigure GitLab
reconfigure_gitlab() {
    log_info "Reconfigure GitLab..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    log_info "Kiểm tra trạng thái GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl status

    log_info "Bắt đầu reconfigure GitLab..."
    if docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure; then
        log_success "✅ GitLab reconfigure thành công!"

        log_info "Restart các services..."
        if docker exec "$GITLAB_CONTAINER" gitlab-ctl restart; then
            log_success "✅ GitLab services đã được restart!"
        else
            log_warning "⚠️ Một số services có thể chưa restart hoàn toàn"
        fi

        log_info "Kiểm tra trạng thái sau reconfigure..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl status

        log_success "GitLab reconfigure hoàn tất!"
        log_info "Thông tin truy cập:"
        echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        echo "  👤 Username: root"
        echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
        echo "  📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    else
        log_error "Lỗi reconfigure GitLab"
        log_info "Kiểm tra logs:"
        echo "  docker exec gitlab gitlab-ctl tail"
        exit 1
    fi
}

# [CHECK] Kiểm tra GitLab images
check_images() {
    log_info "Kiểm tra GitLab images..."

    echo "=== GITLAB IMAGES ==="

    # Kiểm tra Docker trước
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon không chạy - không thể kiểm tra images"
        return 1
    fi

    # Kiểm tra custom image
    if docker images | grep -q "nextflow/gitlab-ce.*16.11.10-ce.0"; then
        log_success "Custom image tồn tại:"
        docker images | grep "nextflow/gitlab-ce.*16.11.10-ce.0"
    else
        log_warning "Custom image chưa được build (cần phiên bản 16.11.10-ce.0)"
    fi

    echo ""

    # Kiểm tra official image
    if docker images | grep -q "gitlab/gitlab-ce"; then
        log_info "Official images:"
        docker images | grep "gitlab/gitlab-ce"
    else
        log_warning "Chưa có official GitLab image"
    fi

    echo ""
    log_info "Để build custom image: ./scripts/gitlab-manager.sh build"
    echo ""
}

# [BUILD] Build GitLab custom image
build_image() {
    log_info "Building GitLab custom image..."
    
    if [ ! -f "$PROJECT_DIR/gitlab/docker/Dockerfile" ]; then
        log_error "Dockerfile không tồn tại: $PROJECT_DIR/gitlab/docker/Dockerfile"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    log_info "Đang build image..."
    if docker build -f gitlab/docker/Dockerfile -t nextflow/gitlab-ce:16.11.10-ce.0 .; then
        log_success "Build image thành công!"
        log_info "Image được tag: nextflow/gitlab-ce:16.11.10-ce.0"
    else
        log_error "Build image thất bại"
        exit 1
    fi
}

# [INSTALL] Cài đặt GitLab với kiểm tra và migrate database
install_gitlab() {
    log_info "Cài đặt GitLab..."

    # Kiểm tra custom image
    if ! docker images | grep -q "nextflow/gitlab-ce.*16.11.10-ce.0"; then
        log_warning "Custom image phiên bản 16.11.10-ce.0 chưa tồn tại, đang build..."
        build_image
    fi

    # Tạo thư mục cần thiết
    mkdir -p "$PROJECT_DIR/gitlab/config"
    mkdir -p "$PROJECT_DIR/gitlab/logs"
    mkdir -p "$PROJECT_DIR/gitlab/data"
    mkdir -p "$BACKUP_DIR"

    cd "$PROJECT_DIR"

    # Khởi động dependencies trước
    log_info "Khởi động PostgreSQL và Redis..."
    docker-compose up -d postgres redis

    # Đợi PostgreSQL sẵn sàng
    log_info "Đợi PostgreSQL sẵn sàng..."
    sleep 10

    # Tạo database cho GitLab
    log_info "Tạo database GitLab..."
    docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;" 2>/dev/null || true

    # Khởi động GitLab
    log_info "Khởi động GitLab..."
    docker-compose up -d gitlab

    # Đợi GitLab container khởi động
    log_info "Đợi GitLab container khởi động..."
    local max_wait=60
    local wait_count=0

    while [ $wait_count -lt $max_wait ]; do
        if docker ps | grep -q "$GITLAB_CONTAINER.*healthy\|$GITLAB_CONTAINER.*Up"; then
            log_success "GitLab container đã khởi động"
            break
        fi

        if [ $((wait_count % 10)) -eq 0 ]; then
            log_info "Đợi GitLab container... ($wait_count/${max_wait}s)"
        fi

        sleep 1
        wait_count=$((wait_count + 1))
    done

    if [ $wait_count -ge $max_wait ]; then
        log_warning "GitLab container mất nhiều thời gian để khởi động"
        log_info "Tiếp tục kiểm tra database..."
    fi

    # Đợi GitLab services sẵn sàng
    log_info "Đợi GitLab services sẵn sàng..."
    sleep 30

    # Kiểm tra GitLab đã sẵn sàng chưa (với timeout ngắn)
    log_info "🔍 Kiểm tra GitLab readiness..."

    # Quick check với timeout ngắn
    local quick_check=0
    if timeout 10 docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts User.count" >/dev/null 2>&1; then
        quick_check=1
    fi

    if [ $quick_check -eq 1 ]; then
        log_success "✅ GitLab đã sẵn sàng và database hoạt động tốt"
        log_info "💡 Bỏ qua database check vì GitLab đang hoạt động bình thường"
    else
        # Kiểm tra container có healthy không
        local container_health=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null)
        if [ "$container_health" = "healthy" ]; then
            log_info "⏳ Container healthy nhưng Rails chưa sẵn sàng, đợi thêm..."
            sleep 30

            # Thử lại lần cuối
            if timeout 15 docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts 'OK'" >/dev/null 2>&1; then
                log_success "✅ GitLab đã sẵn sàng sau khi đợi"
            else
                log_warning "⚠️  GitLab mất nhiều thời gian, có thể cần kiểm tra database"
                log_info "💡 Sử dụng: ./scripts/gitlab-manager.sh check-db để kiểm tra riêng"
            fi
        else
            log_info "⚠️  GitLab chưa sẵn sàng, tiến hành kiểm tra database..."
            # Kiểm tra và migrate database chỉ khi cần thiết
            check_and_migrate_database
        fi
    fi

    log_success "GitLab đã được cài đặt!"
    log_info "📋 Thông tin quan trọng:"
    echo "   🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "   👤 Username: root"
    echo "   🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
    echo ""
    log_info "⏳ GitLab sẽ sẵn sàng hoàn toàn trong 5-10 phút"
    log_info "💡 Kiểm tra trạng thái: docker logs gitlab"
    log_info "💡 Tạo root user: ./scripts/gitlab-manager.sh create-root"
}

# [READINESS] Kiểm tra GitLab readiness với tolerance cao hơn
check_gitlab_readiness() {
    # Kiểm tra container đang chạy
    if ! docker ps | grep -q "$GITLAB_CONTAINER.*Up"; then
        return 1
    fi

    # Kiểm tra container health (nếu có)
    local container_health=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null)
    if [ "$container_health" = "unhealthy" ]; then
        return 1
    fi

    # Thử kiểm tra GitLab services (với timeout ngắn)
    local services_check=$(timeout 5 docker exec "$GITLAB_CONTAINER" gitlab-ctl status 2>/dev/null)
    if [ $? -ne 0 ]; then
        # Container chưa sẵn sàng cho exec commands
        return 1
    fi

    # Nếu có services fail thì chưa sẵn sàng
    if echo "$services_check" | grep -q "fail:"; then
        return 1
    fi

    # Kiểm tra Rails environment (timeout ngắn)
    if timeout 8 docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts 'OK'" 2>/dev/null | grep -q "OK"; then
        return 0
    else
        return 1
    fi
}

# [DATABASE] Kiểm tra và migrate database GitLab
check_and_migrate_database() {
    log_info "🔍 Kiểm tra trạng thái database GitLab..."

    # Kiểm tra GitLab readiness với patience cao hơn
    log_info "⏳ Đợi GitLab sẵn sàng..."
    local readiness_attempts=60  # Tăng từ 30 lên 60 (10 phút)
    local readiness_count=1
    local last_container_id=""

    while [ $readiness_count -le $readiness_attempts ]; do
        # Kiểm tra container có bị restart không
        local current_container_id=$(docker ps -q -f name="$GITLAB_CONTAINER")
        if [ -n "$last_container_id" ] && [ "$current_container_id" != "$last_container_id" ]; then
            log_warning "⚠️  GitLab container đã restart, reset counter..."
            readiness_count=1
        fi
        last_container_id="$current_container_id"

        # Kiểm tra container đang chạy
        if ! docker ps | grep -q "$GITLAB_CONTAINER.*Up"; then
            log_warning "⚠️  GitLab container không chạy, đợi khởi động..."
            sleep 15
            readiness_count=$((readiness_count + 1))
            continue
        fi

        # Kiểm tra readiness
        if check_gitlab_readiness >/dev/null 2>&1; then
            log_success "✅ GitLab đã sẵn sàng cho database check"
            break
        fi

        # Log progress mỗi 5 lần
        if [ $((readiness_count % 5)) -eq 0 ]; then
            log_info "Đợi GitLab readiness... ($readiness_count/$readiness_attempts)"

            # Hiển thị thông tin debug mỗi 10 lần
            if [ $((readiness_count % 10)) -eq 0 ]; then
                local container_status=$(docker ps --format "table {{.Status}}" -f name="$GITLAB_CONTAINER" | tail -1)
                log_info "📊 Container status: $container_status"
            fi
        fi

        sleep 10
        readiness_count=$((readiness_count + 1))
    done

    if [ $readiness_count -gt $readiness_attempts ]; then
        log_warning "⚠️  GitLab mất quá nhiều thời gian để sẵn sàng ($(($readiness_attempts * 10 / 60)) phút)"
        log_info "💡 Thử kiểm tra database với limited functionality..."

        # Kiểm tra container có đang chạy không
        if ! docker ps | grep -q "$GITLAB_CONTAINER.*Up"; then
            log_error "❌ GitLab container không chạy, không thể kiểm tra database"
            return 1
        fi
    fi

    # Kiểm tra xem GitLab có đang reconfigure không
    log_info "🔄 Kiểm tra trạng thái GitLab reconfigure..."
    if docker exec "$GITLAB_CONTAINER" ps aux | grep -q "cinc-client\|chef-client" && ! docker exec "$GITLAB_CONTAINER" ps aux | grep -q "gitlab-rails"; then
        log_info "⏳ GitLab đang trong quá trình reconfigure, đợi hoàn tất..."

        local reconfigure_wait=0
        local max_reconfigure_wait=300  # 5 phút

        while [ $reconfigure_wait -lt $max_reconfigure_wait ]; do
            if ! docker exec "$GITLAB_CONTAINER" ps aux | grep -q "cinc-client\|chef-client"; then
                log_success "✅ GitLab reconfigure hoàn tất!"
                break
            fi

            if [ $((reconfigure_wait % 30)) -eq 0 ]; then
                log_info "Đợi reconfigure... ($reconfigure_wait/${max_reconfigure_wait}s)"
            fi

            sleep 10
            reconfigure_wait=$((reconfigure_wait + 10))
        done

        if [ $reconfigure_wait -ge $max_reconfigure_wait ]; then
            log_warning "⚠️  Reconfigure mất quá nhiều thời gian, tiếp tục kiểm tra..."
        fi

        # Đợi thêm để GitLab services khởi động
        log_info "⏳ Đợi GitLab services khởi động sau reconfigure..."
        sleep 30
    fi

    # Kiểm tra database connection
    log_info "📡 Kiểm tra kết nối database..."
    local db_check_attempts=3
    local db_check_count=1

    while [ $db_check_count -le $db_check_attempts ]; do
        if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts 'Database connection: OK'" 2>/dev/null | grep -q "Database connection: OK"; then
            log_success "✅ Database connection OK"
            break
        else
            log_warning "⚠️  Database connection attempt $db_check_count/$db_check_attempts failed"

            if [ $db_check_count -eq $db_check_attempts ]; then
                log_warning "🔧 Thử reconfigure GitLab để fix database connection..."
                docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure >/dev/null 2>&1 &
                log_info "⏳ Reconfigure đang chạy background, tiếp tục kiểm tra..."
                sleep 60
            else
                sleep 20
            fi
        fi

        db_check_count=$((db_check_count + 1))
    done

    # Kiểm tra database schema
    log_info "🗄️  Kiểm tra database schema..."

    # Đợi Rails environment sẵn sàng
    log_info "⏳ Đợi Rails environment sẵn sàng..."
    local rails_wait=0
    local max_rails_wait=120

    while [ $rails_wait -lt $max_rails_wait ]; do
        if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts 'Rails ready'" 2>/dev/null | grep -q "Rails ready"; then
            log_success "✅ Rails environment sẵn sàng"
            break
        fi

        if [ $((rails_wait % 20)) -eq 0 ]; then
            log_info "Đợi Rails... ($rails_wait/${max_rails_wait}s)"
        fi

        sleep 10
        rails_wait=$((rails_wait + 10))
    done

    if [ $rails_wait -ge $max_rails_wait ]; then
        log_warning "⚠️  Rails environment mất nhiều thời gian, thử kiểm tra database..."
    fi

    # Kiểm tra bảng quan trọng có tồn tại không
    local tables_check=$(docker exec "$GITLAB_CONTAINER" timeout 30 gitlab-rails runner "
        begin
            puts 'Users table: ' + (ActiveRecord::Base.connection.table_exists?('users') ? 'EXISTS' : 'MISSING')
            puts 'Projects table: ' + (ActiveRecord::Base.connection.table_exists?('projects') ? 'EXISTS' : 'MISSING')
            puts 'Issues table: ' + (ActiveRecord::Base.connection.table_exists?('issues') ? 'EXISTS' : 'MISSING')
        rescue => e
            puts 'ERROR: ' + e.message
        end
    " 2>/dev/null)

    if [ -z "$tables_check" ] || echo "$tables_check" | grep -q "ERROR"; then
        log_warning "⚠️  Không thể kiểm tra database schema (GitLab có thể chưa sẵn sàng)"
        echo "$tables_check"
        echo ""
        log_info "🔧 Thử setup database cơ bản..."

        # Thử setup database nếu Rails chưa sẵn sàng
        if docker exec "$GITLAB_CONTAINER" timeout 60 gitlab-rake db:create db:schema:load 2>/dev/null; then
            log_success "✅ Database setup cơ bản thành công!"
        else
            log_warning "⚠️  Database setup có vấn đề, GitLab sẽ tự động setup khi sẵn sàng"
        fi

    elif echo "$tables_check" | grep -q "MISSING"; then
        log_warning "⚠️  Database schema chưa đầy đủ!"
        echo "$tables_check"
        echo ""

        # Kiểm tra migration status
        log_info "📋 Kiểm tra migration status..."
        local migration_status=$(docker exec "$GITLAB_CONTAINER" gitlab-rake db:migrate:status 2>/dev/null | head -20)

        if echo "$migration_status" | grep -q "down"; then
            log_warning "🔄 Phát hiện migrations chưa chạy!"
            echo ""
            log_info "🚀 Bắt đầu database migration..."

            # Chạy database migrations
            if docker exec "$GITLAB_CONTAINER" gitlab-rake db:migrate; then
                log_success "✅ Database migration thành công!"

                # Verify lại sau migration
                log_info "🔍 Verify database sau migration..."
                local verify_result=$(docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
                    puts 'Users table: ' + (User.table_exists? ? 'OK' : 'ERROR')
                    puts 'Projects table: ' + (Project.table_exists? ? 'OK' : 'ERROR')
                    puts 'Total users: ' + User.count.to_s
                " 2>/dev/null)

                if echo "$verify_result" | grep -q "ERROR"; then
                    log_error "❌ Database verification thất bại sau migration!"
                    echo "$verify_result"
                else
                    log_success "✅ Database verification thành công!"
                    echo "$verify_result"
                fi

            else
                log_error "❌ Database migration thất bại!"
                log_info "💡 Thử các bước sau:"
                echo "   1. docker exec gitlab gitlab-ctl reconfigure"
                echo "   2. docker exec gitlab gitlab-rake db:setup"
                echo "   3. docker restart gitlab"
                return 1
            fi

        else
            log_info "ℹ️  Migrations đã được chạy, thử setup database..."

            # Thử setup database
            if docker exec "$GITLAB_CONTAINER" gitlab-rake db:setup; then
                log_success "✅ Database setup thành công!"
            else
                log_warning "⚠️  Database setup có vấn đề, nhưng có thể vẫn hoạt động"
            fi
        fi

    else
        log_success "✅ Database schema đầy đủ!"
        echo "$tables_check"

        # Hiển thị thống kê database
        log_info "📊 Thống kê database:"
        local stats=$(docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
            puts 'Total users: ' + User.count.to_s
            puts 'Total projects: ' + Project.count.to_s
            puts 'Total issues: ' + Issue.count.to_s
        " 2>/dev/null)
        echo "$stats"
    fi

    # Kiểm tra GitLab health
    log_info "🏥 Kiểm tra GitLab health..."
    if docker exec "$GITLAB_CONTAINER" gitlab-rake gitlab:check SANITIZE=true >/dev/null 2>&1; then
        log_success "✅ GitLab health check passed!"
    else
        log_warning "⚠️  GitLab health check có warnings (có thể bình thường lúc mới cài đặt)"
    fi

    log_success "🎉 Database check và migration hoàn tất!"
}

# [MIGRATE] Force migrate database GitLab
migrate_gitlab_database() {
    log_info "🚀 Force migrate GitLab database..."

    # Kiểm tra container đang chạy
    if ! docker ps | grep -q "$GITLAB_CONTAINER.*Up"; then
        log_error "❌ GitLab container không chạy"
        return 1
    fi

    # Kiểm tra database connection
    log_info "📡 Kiểm tra database connection..."
    if ! docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT 1;" >/dev/null 2>&1; then
        log_error "❌ Không thể kết nối database"
        return 1
    fi

    log_success "✅ Database connection OK"

    # Hiển thị current database status
    log_info "📊 Current database status:"
    local table_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "\dt" 2>/dev/null | grep -c "table" || echo "0")
    echo "   Tables: $table_count"

    local migration_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT COUNT(*) FROM schema_migrations;" 2>/dev/null | grep -o "[0-9]*" | head -1 || echo "0")
    echo "   Migrations: $migration_count"

    if [ "$table_count" -lt 10 ]; then
        log_warning "⚠️  Database thiếu tables chính - cần migrate!"
    fi

    # Dừng GitLab để migrate an toàn
    log_info "🛑 Dừng GitLab services để migrate an toàn..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop >/dev/null 2>&1 || true

    # Đợi services dừng
    sleep 10

    # Chạy database setup và migrate
    log_info "🔧 Chạy database setup và migrate..."

    # Thử db:setup trước (tạo schema cơ bản)
    log_info "📋 Step 1: Database setup..."
    if docker exec "$GITLAB_CONTAINER" timeout 300 gitlab-rake db:setup RAILS_ENV=production; then
        log_success "✅ Database setup thành công!"
    else
        log_warning "⚠️  Database setup có vấn đề, thử migrate..."

        # Fallback: chạy migrate
        log_info "🔄 Step 2: Database migrate..."
        if docker exec "$GITLAB_CONTAINER" timeout 300 gitlab-rake db:migrate RAILS_ENV=production; then
            log_success "✅ Database migrate thành công!"
        else
            log_error "❌ Database migrate thất bại!"
            log_info "🔧 Thử force migrate..."
            docker exec "$GITLAB_CONTAINER" timeout 300 gitlab-rake db:schema:load RAILS_ENV=production
        fi
    fi

    # Verify migration results
    log_info "🔍 Verify migration results..."
    local new_table_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "\dt" 2>/dev/null | grep -c "table" || echo "0")
    local new_migration_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT COUNT(*) FROM schema_migrations;" 2>/dev/null | grep -o "[0-9]*" | head -1 || echo "0")

    echo "📊 Migration results:"
    echo "   Tables: $table_count → $new_table_count"
    echo "   Migrations: $migration_count → $new_migration_count"

    if [ "$new_table_count" -gt 50 ]; then
        log_success "✅ Database migration thành công! ($new_table_count tables)"
    else
        log_warning "⚠️  Database migration chưa hoàn chỉnh ($new_table_count tables)"
    fi

    # Khởi động lại GitLab
    log_info "🚀 Khởi động lại GitLab..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl start

    log_success "🎉 Database migration hoàn tất!"
    log_info "💡 GitLab sẽ sẵn sàng trong 2-3 phút"
}

# [RESET-DB] Reset và recreate database GitLab
reset_gitlab_database() {
    log_info "🔄 Reset và recreate GitLab database..."

    # Xác nhận từ user
    log_warning "⚠️  CẢNH BÁO: Thao tác này sẽ XÓA TOÀN BỘ dữ liệu GitLab!"
    echo "   - Tất cả repositories sẽ bị mất"
    echo "   - Tất cả users, projects, issues sẽ bị mất"
    echo "   - Không thể khôi phục sau khi xóa"
    echo ""
    read -p "Bạn có chắc chắn muốn reset database? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Hủy reset database"
        return 0
    fi

    # Dừng GitLab
    log_info "🛑 Dừng GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop >/dev/null 2>&1 || true
    sleep 5

    # Force terminate database connections
    log_info "🔌 Terminate database connections..."
    docker exec postgres psql -U nextflow -c "
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = 'nextflow_gitlab' AND pid <> pg_backend_pid();
    " >/dev/null 2>&1 || true

    sleep 2

    # Drop và recreate database
    log_info "🗑️  Drop database cũ..."
    docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS nextflow_gitlab;"

    log_info "🆕 Tạo database mới..."
    docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;"

    # Verify database mới
    local new_table_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "\dt" 2>/dev/null | grep -c "table" || echo "0")
    log_success "✅ Database mới đã được tạo (tables: $new_table_count)"

    # Setup database schema
    log_info "📋 Setup database schema..."
    if docker exec "$GITLAB_CONTAINER" timeout 300 gitlab-rake db:schema:load RAILS_ENV=production; then
        log_success "✅ Database schema load thành công!"
    else
        log_error "❌ Database schema load thất bại!"
        return 1
    fi

    # Verify kết quả
    local final_table_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "\dt" 2>/dev/null | grep -c "table" || echo "0")
    local migration_count=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -c "SELECT COUNT(*) FROM schema_migrations;" 2>/dev/null | grep -o "[0-9]*" | head -1 || echo "0")

    echo "📊 Database reset results:"
    echo "   Tables: $final_table_count"
    echo "   Migrations: $migration_count"

    if [ "$final_table_count" -gt 50 ]; then
        log_success "✅ Database reset thành công!"
    else
        log_warning "⚠️  Database reset chưa hoàn chỉnh"
    fi

    # Khởi động GitLab
    log_info "🚀 Khởi động GitLab..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl start

    log_success "🎉 Database reset hoàn tất!"
    log_info "💡 GitLab sẽ sẵn sàng trong 2-3 phút"
    log_info "💡 Cần tạo root user: ./scripts/gitlab-manager.sh create-root"
}

# [FIX-422] Fix lỗi 422 "The change you requested was rejected"
fix_422_error() {
    log_info "🔧 Fix lỗi 422 'The change you requested was rejected'..."

    # Kiểm tra GitLab đang chạy
    if ! docker ps | grep -q "$GITLAB_CONTAINER.*Up"; then
        log_error "❌ GitLab container không chạy"
        return 1
    fi

    log_info "📋 Các nguyên nhân và cách fix lỗi 422:"
    echo ""
    echo "🔍 NGUYÊN NHÂN THƯỜNG GẶP:"
    echo "   1. GitLab chưa hoàn tất khởi động"
    echo "   2. CSRF token không hợp lệ"
    echo "   3. Browser cache cũ"
    echo "   4. Root user chưa được activate"
    echo "   5. Session timeout"
    echo ""

    # Fix 1: Restart GitLab services
    log_info "🔄 Fix 1: Restart GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl restart puma
    docker exec "$GITLAB_CONTAINER" gitlab-ctl restart sidekiq
    sleep 10

    # Fix 2: Clear cache
    log_info "🧹 Fix 2: Clear GitLab cache..."
    docker exec "$GITLAB_CONTAINER" gitlab-rake cache:clear >/dev/null 2>&1 || true
    docker exec "$GITLAB_CONTAINER" gitlab-rake tmp:clear >/dev/null 2>&1 || true

    # Fix 3: Reconfigure GitLab
    log_info "⚙️  Fix 3: Reconfigure GitLab..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure >/dev/null 2>&1 &

    # Fix 4: Verify và recreate root user
    log_info "👤 Fix 4: Verify và recreate root user..."

    # Kiểm tra root user
    local root_check=$(docker exec "$GITLAB_CONTAINER" timeout 30 gitlab-rails runner "
        begin
            user = User.find_by(username: 'root')
            if user
                puts 'EXISTS:' + user.active?.to_s + ':' + user.confirmed?.to_s
            else
                puts 'NOT_EXISTS'
            end
        rescue => e
            puts 'ERROR:' + e.message
        end
    " 2>/dev/null)

    if echo "$root_check" | grep -q "NOT_EXISTS\|ERROR"; then
        log_warning "⚠️  Root user có vấn đề, recreate..."
        create_root_user
    elif echo "$root_check" | grep -q "EXISTS:false\|EXISTS:true:false"; then
        log_warning "⚠️  Root user chưa active/confirmed, fix..."

        # Activate và confirm root user
        docker exec "$GITLAB_CONTAINER" timeout 30 gitlab-rails runner "
            user = User.find_by(username: 'root')
            if user
                user.activate
                user.confirm
                user.save!
                puts 'Root user activated and confirmed'
            end
        " 2>/dev/null || true
    else
        log_success "✅ Root user OK"
    fi

    # Fix 5: Reset sessions
    log_info "🔐 Fix 5: Reset user sessions..."
    docker exec "$GITLAB_CONTAINER" timeout 30 gitlab-rails runner "
        ActiveRecord::SessionStore::Session.delete_all
        puts 'All sessions cleared'
    " 2>/dev/null || true

    echo ""
    log_success "🎉 Hoàn tất fix lỗi 422!"
    echo ""
    log_info "💡 CÁCH KHẮC PHỤC THÊM:"
    echo "   1. Xóa browser cache và cookies"
    echo "   2. Thử trình duyệt ẩn danh (incognito)"
    echo "   3. Đợi 2-3 phút để GitLab hoàn tất restart"
    echo "   4. Truy cập: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "   5. Username: root"
    echo "   6. Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
    echo ""
    log_info "🔍 Nếu vẫn lỗi, kiểm tra logs:"
    echo "        docker logs gitlab --tail 50"
    echo "        docker exec gitlab gitlab-ctl tail gitlab-rails"
}

# [INFO] Xem thông tin truy cập
show_info() {
    echo "=== THÔNG TIN TRUY CẬP GITLAB ==="
    echo ""
    echo "🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "👤 Username: root"
    echo "🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
    echo "📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    echo ""
    echo "🐳 Container Registry: ${GITLAB_REGISTRY_URL:-http://localhost:5050}"
    echo "🔗 SSH Git: ssh://git@localhost:${GITLAB_SSH_PORT:-2222}"
    echo ""

    # Kiểm tra trạng thái container (chỉ khi Docker chạy)
    if docker info > /dev/null 2>&1; then
        if docker ps | grep -q "$GITLAB_CONTAINER"; then
            log_success "GitLab container đang chạy"
        else
            log_warning "GitLab container không chạy"
        fi
    else
        log_warning "Docker daemon không chạy - không thể kiểm tra container"
    fi
}



# [BACKUP] Sao lưu GitLab hoàn chỉnh theo chuẩn GitLab Official
backup_gitlab() {
    log_info "Tạo backup GitLab hoàn chỉnh..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Tạo thư mục backup với timestamp
    local backup_timestamp=$(date +"%Y%m%d_%H%M%S")
    local full_backup_dir="$BACKUP_DIR/gitlab_backup_$backup_timestamp"
    mkdir -p "$full_backup_dir"
    mkdir -p "$full_backup_dir/config"
    mkdir -p "$full_backup_dir/secrets"
    mkdir -p "$full_backup_dir/data"

    log_info "📁 Backup directory: $full_backup_dir"

    # Kiểm tra trạng thái GitLab trước khi backup
    log_info "Kiểm tra trạng thái GitLab..."
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_warning "Một số GitLab services có thể chưa sẵn sàng"
    fi

    # ========================================
    # BƯỚC 1: Backup GitLab Data (repositories, database, uploads, etc.)
    # ========================================
    log_info "🗄️  BƯỚC 1: Backup GitLab data..."
    if docker exec "$GITLAB_CONTAINER" gitlab-backup create; then
        log_success "✅ GitLab data backup thành công!"

        # Copy backup file ra host
        latest_backup=$(docker exec "$GITLAB_CONTAINER" sh -c "find /var/opt/gitlab/backups/ -name '*.tar' | sort -r | head -1")
        if [ -n "$latest_backup" ]; then
            backup_filename=$(basename "$latest_backup")
            log_info "Copy backup file: $backup_filename"
            docker cp "$GITLAB_CONTAINER:$latest_backup" "$full_backup_dir/data/"
            log_success "✅ Data backup copied to: $full_backup_dir/data/$backup_filename"
        fi
    else
        log_error "❌ GitLab data backup thất bại!"
        return 1
    fi

    # ========================================
    # BƯỚC 2: Backup GitLab Secrets (QUAN TRỌNG NHẤT!)
    # ========================================
    log_info "🔐 BƯỚC 2: Backup GitLab secrets..."
    if docker exec "$GITLAB_CONTAINER" test -f "/etc/gitlab/gitlab-secrets.json"; then
        docker cp "$GITLAB_CONTAINER:/etc/gitlab/gitlab-secrets.json" "$full_backup_dir/secrets/"
        log_success "✅ gitlab-secrets.json backed up"
    else
        log_error "❌ CẢNH BÁO: gitlab-secrets.json không tồn tại!"
        log_warning "⚠️  Restore sẽ không thể decrypt dữ liệu!"
    fi

    # ========================================
    # BƯỚC 3: Backup GitLab Configuration
    # ========================================
    log_info "⚙️  BƯỚC 3: Backup GitLab configuration..."
    if docker exec "$GITLAB_CONTAINER" test -f "/etc/gitlab/gitlab.rb"; then
        docker cp "$GITLAB_CONTAINER:/etc/gitlab/gitlab.rb" "$full_backup_dir/config/"
        log_success "✅ gitlab.rb backed up"
    else
        log_warning "⚠️  gitlab.rb không tồn tại (có thể dùng ENV variables)"
    fi

    # ========================================
    # BƯỚC 4: Backup SSH Host Keys
    # ========================================
    log_info "🔑 BƯỚC 4: Backup SSH host keys..."
    if docker exec "$GITLAB_CONTAINER" test -d "/etc/gitlab/ssh_host_keys"; then
        docker cp "$GITLAB_CONTAINER:/etc/gitlab/ssh_host_keys" "$full_backup_dir/config/"
        log_success "✅ SSH host keys backed up"
    else
        log_info "ℹ️  SSH host keys không tồn tại (sẽ được tạo lại)"
    fi

    # ========================================
    # BƯỚC 5: Backup TLS/SSL Certificates
    # ========================================
    log_info "🔒 BƯỚC 5: Backup TLS certificates..."
    if docker exec "$GITLAB_CONTAINER" test -d "/etc/gitlab/ssl"; then
        docker cp "$GITLAB_CONTAINER:/etc/gitlab/ssl" "$full_backup_dir/config/"
        log_success "✅ TLS certificates backed up"
    else
        log_info "ℹ️  TLS certificates không tồn tại"
    fi

    # ========================================
    # BƯỚC 6: Backup Trusted Certificates
    # ========================================
    log_info "📜 BƯỚC 6: Backup trusted certificates..."
    if docker exec "$GITLAB_CONTAINER" test -d "/etc/gitlab/trusted-certs"; then
        docker cp "$GITLAB_CONTAINER:/etc/gitlab/trusted-certs" "$full_backup_dir/config/"
        log_success "✅ Trusted certificates backed up"
    else
        log_info "ℹ️  Trusted certificates không tồn tại"
    fi

    # ========================================
    # BƯỚC 7: Tạo backup info file
    # ========================================
    log_info "📋 BƯỚC 7: Tạo backup information file..."
    cat > "$full_backup_dir/backup_info.txt" << EOF
# GitLab Backup Information
# Generated: $(date)
# ========================================

BACKUP_TIMESTAMP=$backup_timestamp
GITLAB_VERSION=$(docker exec "$GITLAB_CONTAINER" cat /opt/gitlab/version-manifest.txt | head -1 2>/dev/null || echo "Unknown")
BACKUP_TYPE=FULL_BACKUP
GITLAB_CONTAINER=$GITLAB_CONTAINER

# Files included:
# - Data backup: data/$backup_filename
# - Secrets: secrets/gitlab-secrets.json
# - Config: config/gitlab.rb
# - SSH keys: config/ssh_host_keys/
# - TLS certs: config/ssl/
# - Trusted certs: config/trusted-certs/

# Restore command:
# ./scripts/gitlab-manager.sh restore-full $full_backup_dir

EOF

    # ========================================
    # BƯỚC 8: Tạo restore script
    # ========================================
    log_info "📝 BƯỚC 8: Tạo restore script..."
    cat > "$full_backup_dir/restore.sh" << 'EOF'
#!/bin/bash
# GitLab Full Restore Script
# Auto-generated by gitlab-manager.sh

BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)"
GITLAB_CONTAINER="gitlab"

echo "🔄 Restoring GitLab from: $BACKUP_DIR"

# 1. Stop GitLab services
echo "⏹️  Stopping GitLab services..."
docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma
docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq

# 2. Restore secrets FIRST (quan trọng nhất!)
if [ -f "$BACKUP_DIR/secrets/gitlab-secrets.json" ]; then
    echo "🔐 Restoring GitLab secrets..."
    docker cp "$BACKUP_DIR/secrets/gitlab-secrets.json" "$GITLAB_CONTAINER:/etc/gitlab/"
    docker exec "$GITLAB_CONTAINER" chown root:root /etc/gitlab/gitlab-secrets.json
    docker exec "$GITLAB_CONTAINER" chmod 600 /etc/gitlab/gitlab-secrets.json
    echo "✅ Secrets restored"
else
    echo "❌ WARNING: No secrets file found!"
fi

# 3. Restore configuration
if [ -f "$BACKUP_DIR/config/gitlab.rb" ]; then
    echo "⚙️  Restoring GitLab configuration..."
    docker cp "$BACKUP_DIR/config/gitlab.rb" "$GITLAB_CONTAINER:/etc/gitlab/"
    echo "✅ Configuration restored"
fi

# 4. Restore SSH keys
if [ -d "$BACKUP_DIR/config/ssh_host_keys" ]; then
    echo "🔑 Restoring SSH host keys..."
    docker cp "$BACKUP_DIR/config/ssh_host_keys" "$GITLAB_CONTAINER:/etc/gitlab/"
    echo "✅ SSH keys restored"
fi

# 5. Restore TLS certificates
if [ -d "$BACKUP_DIR/config/ssl" ]; then
    echo "🔒 Restoring TLS certificates..."
    docker cp "$BACKUP_DIR/config/ssl" "$GITLAB_CONTAINER:/etc/gitlab/"
    echo "✅ TLS certificates restored"
fi

# 6. Restore trusted certificates
if [ -d "$BACKUP_DIR/config/trusted-certs" ]; then
    echo "📜 Restoring trusted certificates..."
    docker cp "$BACKUP_DIR/config/trusted-certs" "$GITLAB_CONTAINER:/etc/gitlab/"
    echo "✅ Trusted certificates restored"
fi

# 7. Reconfigure GitLab
echo "🔧 Reconfiguring GitLab..."
docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure

# 8. Restore data backup
DATA_BACKUP=$(find "$BACKUP_DIR/data" -name "*_gitlab_backup.tar" | head -1)
if [ -f "$DATA_BACKUP" ]; then
    BACKUP_NAME=$(basename "$DATA_BACKUP" | sed 's/_gitlab_backup.tar$//')
    echo "🗄️  Restoring data backup: $BACKUP_NAME"

    # Copy backup file to container
    docker cp "$DATA_BACKUP" "$GITLAB_CONTAINER:/var/opt/gitlab/backups/"
    docker exec "$GITLAB_CONTAINER" chown git:git "/var/opt/gitlab/backups/$(basename "$DATA_BACKUP")"

    # Restore backup
    docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$BACKUP_NAME" GITLAB_ASSUME_YES=1
    echo "✅ Data backup restored"
else
    echo "❌ No data backup found!"
fi

# 9. Start GitLab services
echo "▶️  Starting GitLab services..."
docker exec "$GITLAB_CONTAINER" gitlab-ctl start

echo "✅ GitLab restore completed!"
echo "🌐 GitLab should be available at: http://localhost:8088"
EOF

    chmod +x "$full_backup_dir/restore.sh"

    # ========================================
    # BƯỚC 9: Hiển thị kết quả
    # ========================================
    echo ""
    log_success "🎉 BACKUP HOÀN TẤT!"
    echo ""
    echo "📁 Backup location: $full_backup_dir"
    echo "📊 Backup contents:"
    echo "   🗄️  Data: $(ls -la "$full_backup_dir/data/" 2>/dev/null | wc -l) files"
    echo "   🔐 Secrets: $(ls -la "$full_backup_dir/secrets/" 2>/dev/null | wc -l) files"
    echo "   ⚙️  Config: $(ls -la "$full_backup_dir/config/" 2>/dev/null | wc -l) files"
    echo ""
    echo "📝 Restore options:"
    echo "   1. Auto restore: $full_backup_dir/restore.sh"
    echo "   2. Manual restore: ./scripts/gitlab-manager.sh restore-full $full_backup_dir"
    echo ""
    echo "💾 Backup size: $(du -sh "$full_backup_dir" | cut -f1)"
    echo "📅 Created: $(date)"
    echo ""
    log_info "💡 Lưu ý: Backup này bao gồm TẤT CẢ dữ liệu cần thiết để restore hoàn toàn GitLab!"
}



# [RESTORE-FULL] Khôi phục GitLab hoàn chỉnh từ full backup
restore_full_gitlab() {
    local backup_path="$1"

    if [ -z "$backup_path" ]; then
        log_error "Vui lòng cung cấp đường dẫn backup directory"
        echo "Sử dụng: $0 restore-full /path/to/backup/directory"
        exit 1
    fi

    if [ ! -d "$backup_path" ]; then
        log_error "Backup directory không tồn tại: $backup_path"
        exit 1
    fi

    if [ ! -f "$backup_path/backup_info.txt" ]; then
        log_error "Không phải backup directory hợp lệ (thiếu backup_info.txt)"
        exit 1
    fi

    log_info "🔄 Khôi phục GitLab từ full backup..."
    log_info "📁 Backup path: $backup_path"

    # Đọc thông tin backup
    source "$backup_path/backup_info.txt"
    log_info "📅 Backup timestamp: $BACKUP_TIMESTAMP"
    log_info "🏷️  GitLab version: $GITLAB_VERSION"

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Xác nhận restore
    echo ""
    log_warning "⚠️  CẢNH BÁO: Restore sẽ GHI ĐÈ tất cả dữ liệu GitLab hiện tại!"
    log_warning "Bao gồm: repositories, users, issues, merge requests, settings, secrets"
    echo ""
    read -p "Bạn có chắc chắn muốn restore? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Hủy restore"
        exit 0
    fi

    # ========================================
    # BƯỚC 1: Dừng GitLab services
    # ========================================
    log_info "⏹️  BƯỚC 1: Dừng GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq 2>/dev/null || true

    # ========================================
    # BƯỚC 2: Restore GitLab Secrets (QUAN TRỌNG NHẤT!)
    # ========================================
    log_info "🔐 BƯỚC 2: Restore GitLab secrets..."
    if [ -f "$backup_path/secrets/gitlab-secrets.json" ]; then
        docker cp "$backup_path/secrets/gitlab-secrets.json" "$GITLAB_CONTAINER:/etc/gitlab/"
        docker exec "$GITLAB_CONTAINER" chown root:root /etc/gitlab/gitlab-secrets.json
        docker exec "$GITLAB_CONTAINER" chmod 600 /etc/gitlab/gitlab-secrets.json
        log_success "✅ GitLab secrets restored"
    else
        log_error "❌ CẢNH BÁO: Không tìm thấy gitlab-secrets.json!"
        log_warning "⚠️  Restore có thể thành công nhưng dữ liệu encrypted sẽ không thể decrypt!"
        echo ""
        read -p "Tiếp tục restore? (yes/no): " continue_without_secrets

        if [ "$continue_without_secrets" != "yes" ]; then
            log_info "Hủy restore"
            exit 0
        fi
    fi

    # ========================================
    # BƯỚC 3: Restore GitLab Configuration
    # ========================================
    log_info "⚙️  BƯỚC 3: Restore GitLab configuration..."
    if [ -f "$backup_path/config/gitlab.rb" ]; then
        docker cp "$backup_path/config/gitlab.rb" "$GITLAB_CONTAINER:/etc/gitlab/"
        docker exec "$GITLAB_CONTAINER" chown root:root /etc/gitlab/gitlab.rb
        docker exec "$GITLAB_CONTAINER" chmod 600 /etc/gitlab/gitlab.rb
        log_success "✅ GitLab configuration restored"
    else
        log_info "ℹ️  Không có gitlab.rb (có thể dùng ENV variables)"
    fi

    # ========================================
    # BƯỚC 4: Restore SSH Host Keys
    # ========================================
    log_info "🔑 BƯỚC 4: Restore SSH host keys..."
    if [ -d "$backup_path/config/ssh_host_keys" ]; then
        docker cp "$backup_path/config/ssh_host_keys" "$GITLAB_CONTAINER:/etc/gitlab/"
        docker exec "$GITLAB_CONTAINER" chown -R root:root /etc/gitlab/ssh_host_keys
        docker exec "$GITLAB_CONTAINER" chmod 600 /etc/gitlab/ssh_host_keys/*
        log_success "✅ SSH host keys restored"
    else
        log_info "ℹ️  Không có SSH host keys (sẽ được tạo lại)"
    fi

    # ========================================
    # BƯỚC 5: Restore TLS/SSL Certificates
    # ========================================
    log_info "🔒 BƯỚC 5: Restore TLS certificates..."
    if [ -d "$backup_path/config/ssl" ]; then
        docker cp "$backup_path/config/ssl" "$GITLAB_CONTAINER:/etc/gitlab/"
        docker exec "$GITLAB_CONTAINER" chown -R root:root /etc/gitlab/ssl
        docker exec "$GITLAB_CONTAINER" chmod 600 /etc/gitlab/ssl/*
        log_success "✅ TLS certificates restored"
    else
        log_info "ℹ️  Không có TLS certificates"
    fi

    # ========================================
    # BƯỚC 6: Restore Trusted Certificates
    # ========================================
    log_info "📜 BƯỚC 6: Restore trusted certificates..."
    if [ -d "$backup_path/config/trusted-certs" ]; then
        docker cp "$backup_path/config/trusted-certs" "$GITLAB_CONTAINER:/etc/gitlab/"
        docker exec "$GITLAB_CONTAINER" chown -R root:root /etc/gitlab/trusted-certs
        log_success "✅ Trusted certificates restored"
    else
        log_info "ℹ️  Không có trusted certificates"
    fi

    # ========================================
    # BƯỚC 7: Reconfigure GitLab
    # ========================================
    log_info "🔧 BƯỚC 7: Reconfigure GitLab..."
    if docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure; then
        log_success "✅ GitLab reconfigure thành công"
    else
        log_error "❌ GitLab reconfigure thất bại"
        return 1
    fi

    # ========================================
    # BƯỚC 8: Restore Data Backup
    # ========================================
    log_info "🗄️  BƯỚC 8: Restore data backup..."

    # Tìm data backup file
    data_backup=$(find "$backup_path/data" -name "*_gitlab_backup.tar" | head -1)
    if [ ! -f "$data_backup" ]; then
        log_error "❌ Không tìm thấy data backup file!"
        return 1
    fi

    backup_filename=$(basename "$data_backup")
    backup_name=$(echo "$backup_filename" | sed 's/_gitlab_backup.tar$//')

    log_info "📄 Data backup file: $backup_filename"
    log_info "🏷️  Backup ID: $backup_name"

    # Copy backup file vào container
    log_info "📋 Copy backup file vào container..."
    docker cp "$data_backup" "$GITLAB_CONTAINER:/var/opt/gitlab/backups/"
    docker exec "$GITLAB_CONTAINER" chown git:git "/var/opt/gitlab/backups/$backup_filename"

    # Dừng Puma và Sidekiq trước khi restore data
    log_info "⏹️  Dừng Puma và Sidekiq..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq

    # Verify services đã dừng
    log_info "✅ Verify services đã dừng..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl status

    # Thực hiện restore data
    log_info "🔄 Bắt đầu restore data (có thể mất vài phút)..."
    if docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$backup_name" GITLAB_ASSUME_YES=1; then
        log_success "✅ Data restore thành công!"
    else
        log_error "❌ Data restore thất bại!"
        log_info "💡 Thử khởi động services và kiểm tra lại..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl start
        return 1
    fi

    # ========================================
    # BƯỚC 9: Reconfigure lại sau restore
    # ========================================
    log_info "🔧 BƯỚC 9: Reconfigure GitLab sau restore..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure

    # ========================================
    # BƯỚC 10: Khởi động tất cả services
    # ========================================
    log_info "▶️  BƯỚC 10: Khởi động tất cả GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl start

    # ========================================
    # BƯỚC 11: Verify restore
    # ========================================
    log_info "🔍 BƯỚC 11: Verify restore..."
    sleep 15

    # Check GitLab
    log_info "Kiểm tra GitLab health..."
    if docker exec "$GITLAB_CONTAINER" gitlab-rake gitlab:check SANITIZE=true; then
        log_success "✅ GitLab health check passed!"
    else
        log_warning "⚠️  GitLab health check có warnings (có thể bình thường)"
    fi

    # Verify secrets
    log_info "Kiểm tra GitLab secrets..."
    if docker exec "$GITLAB_CONTAINER" gitlab-rake gitlab:doctor:secrets; then
        log_success "✅ GitLab secrets verification passed!"
    else
        log_warning "⚠️  GitLab secrets có vấn đề"
    fi

    # ========================================
    # BƯỚC 12: Hiển thị kết quả
    # ========================================
    echo ""
    log_success "🎉 RESTORE HOÀN TẤT!"
    echo ""
    echo "🌐 GitLab URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "👤 Username: root"
    echo "🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
    echo "📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    echo ""
    echo "📊 Restored from backup:"
    echo "   📅 Backup date: $BACKUP_TIMESTAMP"
    echo "   🏷️  GitLab version: $GITLAB_VERSION"
    echo "   📁 Backup path: $backup_path"
    echo ""
    log_info "⏳ GitLab sẽ sẵn sàng hoàn toàn trong 2-3 phút"
    log_info "💡 Nếu có vấn đề, kiểm tra logs: docker logs gitlab"
}

# [RESTORE] Khôi phục GitLab từ backup (LEGACY - sử dụng restore-full thay thế)
restore_gitlab_legacy() {
    log_info "Khôi phục GitLab từ backup..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Kiểm tra GitLab đã sẵn sàng chưa
    log_info "Kiểm tra trạng thái GitLab..."
    local max_attempts=10
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
            log_success "GitLab đã sẵn sàng"
            break
        fi

        log_warning "Đợi GitLab sẵn sàng... ($attempt/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done

    if [ $attempt -gt $max_attempts ]; then
        log_error "GitLab không sẵn sàng sau $max_attempts lần thử"
        exit 1
    fi
    
    # Liệt kê backup files
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        log_error "Không tìm thấy backup files trong $BACKUP_DIR"
        exit 1
    fi
    
    echo "=== BACKUP FILES ==="
    ls -la "$BACKUP_DIR"
    echo ""
    
    read -p "Nhập tên backup file (không cần đường dẫn): " backup_file

    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        log_error "Backup file không tồn tại: $backup_file"
        exit 1
    fi

    # Kiểm tra format backup file
    if [[ ! "$backup_file" =~ ^[0-9]{10}_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}\.[0-9]{2}\.[0-9]{2}_gitlab_backup\.tar$ ]]; then
        log_error "Format backup file không đúng. Ví dụ: 1755165834_2025_08_14_16.11.10_gitlab_backup.tar"
        exit 1
    fi

    # Kiểm tra backup file có thể đọc được
    if ! tar -tf "$BACKUP_DIR/$backup_file" >/dev/null 2>&1; then
        log_error "Backup file bị lỗi hoặc không thể đọc được"
        exit 1
    fi

    # Kiểm tra nội dung backup file
    log_info "Kiểm tra nội dung backup file..."
    if tar -tf "$BACKUP_DIR/$backup_file" | grep -q "backup_information.yml"; then
        log_success "Backup file hợp lệ"
    else
        log_error "Backup file không chứa thông tin cần thiết"
        exit 1
    fi
    
    # Hiển thị thông tin backup
    echo ""
    echo "=== THÔNG TIN BACKUP ==="
    echo "File: $backup_file"
    echo "Kích thước: $(du -h "$BACKUP_DIR/$backup_file" | cut -f1)"
    echo "Ngày tạo: $(stat -c %y "$BACKUP_DIR/$backup_file" 2>/dev/null || stat -f %Sm "$BACKUP_DIR/$backup_file" 2>/dev/null || echo "Không xác định")"
    echo ""

    # Xác nhận restore
    log_warning "CẢNH BÁO: Restore sẽ ghi đè tất cả dữ liệu GitLab hiện tại!"
    log_warning "Bao gồm: repositories, users, issues, merge requests, settings"
    echo ""
    read -p "Bạn có chắc chắn muốn restore? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Hủy restore"
        exit 0
    fi
    
    # Thực hiện restore
    backup_timestamp=$(echo "$backup_file" | grep -o '[0-9]\{10\}_[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}_[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}')

    log_info "Đang restore backup: $backup_timestamp"

    # Dừng các service GitLab trước khi restore
    log_info "Dừng Puma và Sidekiq..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq 2>/dev/null || true

    # Bước 1: Kiểm tra backup file trong container và đảm bảo ownership đúng
    log_info "Kiểm tra backup file trong container..."
    if docker exec "$GITLAB_CONTAINER" test -f "/var/opt/gitlab/backups/$backup_file"; then
        log_info "Backup file đã có trong container"
    else
        log_info "Copy backup file từ host vào container..."
        docker cp "$BACKUP_DIR/$backup_file" "$GITLAB_CONTAINER:/var/opt/gitlab/backups/"
    fi

    # Đảm bảo ownership đúng (chạy trong container để tránh path conversion issues)
    log_info "Đảm bảo ownership đúng..."
    docker exec "$GITLAB_CONTAINER" sh -c "chown git:git /var/opt/gitlab/backups/$backup_file"

    # Bước 2: Kiểm tra GitLab secrets (quan trọng!)
    log_info "Kiểm tra GitLab secrets..."
    if docker exec "$GITLAB_CONTAINER" test -f "/etc/gitlab/gitlab-secrets.json"; then
        log_success "GitLab secrets tồn tại"
    else
        log_warning "Thiếu file gitlab-secrets.json!"
        log_warning "Restore có thể thành công nhưng một số tính năng sẽ không hoạt động"
        log_warning "Ví dụ: 2FA, CI/CD variables, encrypted data"
        echo ""
        read -p "Tiếp tục restore? (yes/no): " continue_without_secrets

        if [ "$continue_without_secrets" != "yes" ]; then
            log_info "Hủy restore. Hãy restore gitlab-secrets.json trước"
            exit 0
        fi

        log_info "Tạo gitlab-secrets.json tạm thời..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure
    fi

    # Bước 3: Reconfigure GitLab trước khi restore (theo tài liệu chính thức)
    log_info "Reconfigure GitLab trước khi restore..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure

    # Bước 4: Dừng các service kết nối database (theo tài liệu chính thức)
    log_info "Dừng Puma và Sidekiq (giữ các service khác chạy)..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq

    # Verify services đã dừng
    log_info "Verify services đã dừng..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl status

    # Bước 5: Thực hiện restore với đúng tham số (không dùng echo "yes")
    log_info "Bắt đầu quá trình restore (có thể mất vài phút)..."
    if docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$backup_timestamp" GITLAB_ASSUME_YES=1; then
        log_success "Restore dữ liệu thành công!"

        # Bước 6: Reconfigure sau restore (bắt buộc theo tài liệu)
        log_info "Reconfigure GitLab sau restore..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure

        # Bước 7: Start tất cả services
        log_info "Khởi động tất cả GitLab services..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl start

        # Verify restore
        log_info "Kiểm tra kết quả restore..."
        sleep 10

        if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts 'Users: ' + User.count.to_s; puts 'Projects: ' + Project.count.to_s" 2>/dev/null; then
            log_success "Restore hoàn thành và đã verify thành công!"
        else
            log_warning "Restore hoàn thành nhưng chưa thể verify ngay"
        fi

        echo ""
        echo "=== THÔNG TIN TRUY CẬP ==="
        echo "URL: http://localhost:8088"
        echo "Username: root"
        echo "Password: Nex!tFlow@2025!"
        echo ""
        log_info "GitLab sẽ sẵn sàng hoàn toàn trong 2-3 phút"

        # Bước 8: Verify restore và check GitLab
        log_info "Verify GitLab sau restore..."
        docker exec "$GITLAB_CONTAINER" gitlab-rake gitlab:check SANITIZE=true

        # Bước 9: Verify database values có thể decrypt
        log_info "Verify database secrets..."
        docker exec "$GITLAB_CONTAINER" gitlab-rake gitlab:doctor:secrets

    else
        log_error "Restore thất bại!"
        log_info "Khởi động lại services để phục hồi trạng thái..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl start

        log_info "Kiểm tra logs để debug:"
        log_info "docker exec gitlab tail -f /var/log/gitlab/gitlab-rails/production.log"
        exit 1
    fi
}

# [CREATE-ROOT] Tạo/quản lý root user
create_root_user() {
    log_info "Tạo/quản lý root user..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Kiểm tra GitLab có sẵn sàng không
    log_info "Kiểm tra trạng thái GitLab..."
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_warning "GitLab services chưa sẵn sàng"
        log_info "Vui lòng đợi GitLab hoàn tất khởi động (5-10 phút)"
        return 1
    fi

    log_info "Kiểm tra root user hiện tại..."

    # Kiểm tra user đơn giản
    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "exit(User.where(username: 'root').exists? ? 0 : 1)" 2>/dev/null; then
        log_success "Root user đã tồn tại"

        # Hiển thị thông tin user
        log_info "Thông tin root user:"
        docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
        user = User.find_by(username: 'root')
        puts \"  👤 Username: #{user.username}\"
        puts \"  📧 Email: #{user.email}\"
        puts \"  🔑 Admin: #{user.admin}\"
        puts \"  ✅ State: #{user.state}\"
        " 2>/dev/null

        echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
        echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    else
        log_warning "Root user chưa tồn tại, đang tạo bằng Rails runner..."

        # Sử dụng Rails runner trực tiếp (đã test thành công)
        log_info "Tạo/fix root user bằng Rails runner..."
        if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
        puts 'Kiểm tra và tạo/fix root user...'

        # Xóa tất cả root users cũ để tránh duplicate
        old_users = User.where(username: 'root')
        if old_users.exists?
          puts \"Tìm thấy #{old_users.count} root user(s) cũ, đang xóa...\"
          old_users.destroy_all
          puts 'Đã xóa root users cũ'
        end

        # Tạo root user mới với ID = 1
        puts 'Tạo root user mới...'
        user = User.new(
          id: 1,
          username: 'root',
          email: '${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}',
          name: 'Administrator',
          password: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}',
          password_confirmation: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}',
          admin: true,
          confirmed_at: Time.current,
          state: 'active',
          projects_limit: 100000,
          can_create_group: true,
          external: false
        )

        # Skip confirmation và save với bypass validation
        user.skip_confirmation!

        if user.save(validate: false)
          puts '✅ Root user được tạo thành công!'
          puts \"   ID: #{user.id}\"
          puts \"   Username: #{user.username}\"
          puts \"   Email: #{user.email}\"
          puts \"   Admin: #{user.admin}\"
          puts \"   State: #{user.state}\"
          puts \"   Confirmed: #{user.confirmed?}\"
          puts \"   External: #{user.external}\"
          puts \"   Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}\"
        else
          puts '✗ Lỗi tạo root user!'
          puts \"Errors: #{user.errors.full_messages}\"
          exit 1
        end
        "; then
            log_success "✅ Root user được tạo/kiểm tra thành công!"
            log_info "Thông tin truy cập:"
            echo "  👤 Username: root"
            echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
            echo "  📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
            echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        else
            log_warning "⚠️ Rails runner có vấn đề - thử GitLab seed..."

            # Fallback: Cấu hình password policy và dùng seed
            log_info "Cấu hình password policy..."
            configure_password_policy

            log_info "Thử GitLab database seeding..."
            if docker exec "$GITLAB_CONTAINER" gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD=\"${GITLAB_ROOT_PASSWORD:-Nextflow@2025}\" GITLAB_ROOT_EMAIL=\"${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}\"; then
                log_success "Database seeding thành công!"
                log_info "Thông tin truy cập:"
                echo "  👤 Username: root"
                echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
                echo "  📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
                echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
            else
                log_error "Không thể tạo root user bằng cả 2 phương pháp"
                log_info "Vui lòng thử tạo manual qua GitLab console:"
                echo "  docker exec -it gitlab gitlab-rails console"
                echo "  user = User.create!(username: 'root', email: 'nextflow.vn@gmail.com', name: 'Administrator', password: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}', password_confirmation: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}', admin: true, confirmed_at: Time.current, state: 'active')"
                echo "  user.skip_confirmation!"
                echo "  user.save(validate: false)"
            fi
        fi
    fi
}

# [RESET-ROOT] Reset password root user
reset_root_password() {
    log_info "Reset password root user..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Kiểm tra GitLab có sẵn sàng không
    log_info "Kiểm tra trạng thái GitLab..."
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_warning "GitLab services chưa sẵn sàng"
        log_info "Vui lòng đợi GitLab hoàn tất khởi động"
        return 1
    fi

    # Kiểm tra root user có tồn tại không
    log_info "Kiểm tra root user..."
    user_count=$(docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts User.where(username: 'root').count" 2>/dev/null || echo "0")

    if [ "$user_count" -eq 0 ]; then
        log_error "Root user không tồn tại!"
        log_info "Vui lòng tạo root user trước: ./scripts/gitlab-manager.sh create-root"
        return 1
    fi

    # Nhập password mới
    echo ""
    read -s -p "Nhập password mới cho root (Enter để dùng mặc định): " new_password
    echo ""

    if [ -z "$new_password" ]; then
        new_password="${GITLAB_ROOT_PASSWORD:-Nextflow@2025@dev}"
        log_info "Sử dụng password mặc định"
    fi

    # Xác nhận reset
    echo ""
    log_warning "Bạn có chắc chắn muốn reset password cho root user?"
    read -p "Nhập 'yes' để xác nhận: " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Hủy reset password"
        return 0
    fi

    # Tạo seed file để reset password
    log_info "Tạo password reset seed..."
    docker exec "$GITLAB_CONTAINER" bash -c "mkdir -p /opt/gitlab/embedded/service/gitlab-rails/db/fixtures/production"

    docker exec "$GITLAB_CONTAINER" bash -c "cat > /opt/gitlab/embedded/service/gitlab-rails/db/fixtures/production/002_reset_root_password.rb << 'EOF'
# GitLab Root Password Reset Seed
puts 'Resetting root user password...'

# Find root user
root_user = User.find_by(username: 'root')
unless root_user
  puts '✗ Root user không tồn tại!'
  exit 1
end

puts \"Đang reset password cho user: #{root_user.email}\"

begin
  # Update password using proper GitLab methods
  root_user.password = '$new_password'
  root_user.password_confirmation = '$new_password'
  root_user.password_automatically_set = false
  root_user.password_expires_at = nil

  # Save with validation
  if root_user.save!
    puts \"✅ Password đã được reset thành công!\"
    puts \"   Username: #{root_user.username}\"
    puts \"   Email: #{root_user.email}\"
    puts \"   New password: $new_password\"
    puts \"   Admin: #{root_user.admin}\"
    puts \"   State: #{root_user.state}\"
  else
    puts \"✗ Lỗi validation: #{root_user.errors.full_messages.join(', ')}\"
    exit 1
  end

rescue => e
  puts \"✗ Lỗi reset password: #{e.message}\"
  puts \"   Backtrace: #{e.backtrace.first(3).join(', ')}\"
  exit 1
end
EOF"

    # Sử dụng rails runner trực tiếp (đã test thành công)
    log_info "Thực hiện reset password bằng Rails runner..."
    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
    user = User.find_by(username: 'root')
    unless user
      puts '✗ Root user không tồn tại!'
      exit 1
    end

    puts \"Đang reset password cho user: #{user.email}\"

    # Update password với bypass validation
    user.password = '$new_password'
    user.password_confirmation = '$new_password'
    user.password_automatically_set = false

    if user.save(validate: false)
      puts '✅ Password đã được reset thành công!'
      puts \"   Username: #{user.username}\"
      puts \"   Email: #{user.email}\"
      puts \"   New password: $new_password\"
      puts \"   Password hash updated: #{user.reload.encrypted_password[0..20]}...\"
    else
      puts '✗ Lỗi reset password!'
      exit 1
    end
    "; then
        log_success "✅ Reset password thành công!"
        log_info "Thông tin truy cập mới:"
        echo "  👤 Username: root"
        echo "  🔑 New Password: $new_password"
        echo "  📧 Email: nextflow.vn@gmail.com"
        echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    else
        log_warning "⚠️ Rails runner có vấn đề - thử GitLab rake task..."

        # Fallback: Thử GitLab rake task (có thể cần manual input)
        log_info "Thử reset bằng GitLab rake task..."
        log_warning "Lưu ý: Task này có thể yêu cầu nhập password manual"

        if echo "$new_password" | docker exec -i "$GITLAB_CONTAINER" gitlab-rake "gitlab:password:reset[root]"; then
            log_success "Password được reset bằng GitLab rake!"
            log_info "Thông tin truy cập mới:"
            echo "  👤 Username: root"
            echo "  🔑 New Password: $new_password"
            echo "  📧 Email: nextflow.vn@gmail.com"
            echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        else
            log_error "Không thể reset password bằng cả 2 phương pháp"
            log_info "Vui lòng thử reset manual qua GitLab console:"
            echo "  docker exec -it gitlab gitlab-rails console"
            echo "  user = User.find_by(username: 'root')"
            echo "  user.password = '$new_password'"
            echo "  user.password_confirmation = '$new_password'"
            echo "  user.save(validate: false)"
        fi
    fi
}

# Menu chính
show_menu() {
    echo ""
    echo "=== GITLAB MANAGER - ENHANCED VERSION ==="
    echo ""
    echo "1. [CHECK] Kiểm tra GitLab images"
    echo "2. [BUILD] Build GitLab custom image"
    echo "3. [INSTALL] Cài đặt GitLab"
    echo "4. [INFO] Xem thông tin truy cập"
    echo "5. [BACKUP] Sao lưu GitLab hoàn chỉnh"
    echo "6. [RESTORE-FULL] Khôi phục GitLab từ full backup"
    echo "7. [CREATE-ROOT] Tạo/quản lý root user"
    echo "8. [RESET-ROOT] Reset password root user"
    echo "9. [CONFIG] Cấu hình password policy đơn giản"
    echo "10. [RECONFIGURE] Reconfigure GitLab"
    echo "11. [CHECK-DB] Kiểm tra và migrate database"
    echo "12. [MIGRATE] Force migrate database"
    echo "13. [RESET-DB] Reset database (XÓA TOÀN BỘ DỮ LIỆU)"
    echo "14. [CHECK-READY] Kiểm tra GitLab readiness"
    echo "15. [FIX-422] Fix lỗi 422 'The change you requested was rejected'"
    echo "16. Thoát"
    echo ""
    echo "💡 Backup bao gồm: data + secrets + config + certificates"
    echo "⚠️  Database functions: Sử dụng khi GitLab có vấn đề"
    echo "🔧 Fix functions: Sử dụng khi gặp lỗi đăng nhập"
    echo ""
}

# Xử lý tham số command line
case "${1:-}" in
    "check"|"images")
        check_docker
        check_images
        ;;
    "build")
        check_docker
        build_image
        ;;
    "install")
        check_docker
        install_gitlab
        ;;
    "info")
        show_info
        ;;
    "backup")
        check_docker
        backup_gitlab
        ;;
    "restore-full")
        check_docker
        restore_full_gitlab "$2"
        ;;
    "restore")
        check_docker
        log_warning "⚠️  Command 'restore' is deprecated!"
        log_info "💡 Please use 'restore-full' for complete restore with secrets and config"
        echo ""
        echo "Usage: $0 restore-full /path/to/backup/directory"
        echo ""
        exit 1
        ;;
    "create-root")
        check_docker
        create_root_user
        ;;
    "reset-root")
        check_docker
        reset_root_password
        ;;
    "config")
        check_docker
        configure_password_policy
        ;;
    "reconfigure")
        check_docker
        reconfigure_gitlab
        ;;
    "check-db")
        check_docker
        check_and_migrate_database
        ;;
    "check-ready")
        check_docker
        if check_gitlab_readiness; then
            log_success "🎉 GitLab sẵn sàng!"
        else
            log_warning "⚠️  GitLab chưa sẵn sàng"
            exit 1
        fi
        ;;
    "migrate")
        check_docker
        migrate_gitlab_database
        ;;
    "reset-db")
        check_docker
        reset_gitlab_database
        ;;
    "fix-422")
        check_docker
        fix_422_error
        ;;
    "")
        # Menu tương tác
        while true; do
            show_menu
            read -p "Chọn chức năng (1-16): " choice

            case $choice in
                1)
                    check_docker
                    check_images
                    ;;
                2)
                    check_docker
                    build_image
                    ;;
                3)
                    check_docker
                    install_gitlab
                    ;;
                4)
                    show_info
                    ;;
                5)
                    check_docker
                    backup_gitlab
                    ;;
                6)
                    check_docker
                    echo ""
                    read -p "Nhập đường dẫn backup directory: " backup_path
                    restore_full_gitlab "$backup_path"
                    ;;
                7)
                    check_docker
                    create_root_user
                    ;;
                8)
                    check_docker
                    reset_root_password
                    ;;
                9)
                    check_docker
                    configure_password_policy
                    ;;
                10)
                    check_docker
                    reconfigure_gitlab
                    ;;
                11)
                    check_docker
                    check_and_migrate_database
                    ;;
                12)
                    check_docker
                    migrate_gitlab_database
                    ;;
                13)
                    check_docker
                    reset_gitlab_database
                    ;;
                14)
                    check_docker
                    if check_gitlab_readiness; then
                        log_success "🎉 GitLab sẵn sàng!"
                    else
                        log_warning "⚠️  GitLab chưa sẵn sàng"
                    fi
                    ;;
                15)
                    check_docker
                    fix_422_error
                    ;;
                16)
                    log_info "Thoát chương trình"
                    exit 0
                    ;;
                *)
                    log_error "Lựa chọn không hợp lệ"
                    ;;
            esac
            
            echo ""
            read -p "Nhấn Enter để tiếp tục..."
        done
        ;;
    *)
        echo "Sử dụng: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  check                    - Kiểm tra GitLab images"
        echo "  build                    - Build GitLab custom image"
        echo "  install                  - Cài đặt GitLab"
        echo "  info                     - Xem thông tin truy cập"
        echo "  backup                   - Sao lưu GitLab hoàn chỉnh"
        echo "  restore-full <path>      - Khôi phục GitLab từ full backup"
        echo "  create-root              - Tạo/quản lý root user"
        echo "  reset-root               - Reset password root user"
        echo "  config                   - Cấu hình password policy"
        echo "  reconfigure              - Reconfigure GitLab"
        echo "  check-db                 - Kiểm tra và migrate database"
        echo "  migrate                  - Force migrate database"
        echo "  reset-db                 - Reset database (XÓA TOÀN BỘ)"
        echo "  check-ready              - Kiểm tra GitLab readiness"
        echo "  fix-422                  - Fix lỗi 422 'The change you requested was rejected'"
        echo ""
        echo "Examples:"
        echo "  $0                                    # Menu tương tác"
        echo "  $0 backup                            # Tạo full backup"
        echo "  $0 restore-full /path/to/backup      # Restore từ full backup"
        echo ""
        exit 1
        ;;
esac
