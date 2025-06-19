#!/bin/bash
# ============================================================================
# SCRIPT: create-multiple-databases.sh
# MÔ TẢ: Script để tạo nhiều database trong PostgreSQL khi khởi tạo container
# NGƯỜI TẠO: NextFlow Team
# NGÀY TẠO: 03/06/2025
# ============================================================================

# Dừng ngay nếu có lỗi xảy ra
set -e

# ============================================================================
# CẤU HÌNH MẶC ĐỊNH
# ============================================================================
# Đặt giá trị mặc định nếu không được cung cấp qua biến môi trường
: ${POSTGRES_USER:=nextflow}                     # Tên người dùng PostgreSQL mặc định
: ${POSTGRES_PASSWORD:=nextflow@2025}           # Mật khẩu mặc định
: ${POSTGRES_DB:=nextflow}                      # Database chính mặc định
: ${POSTGRES_MULTIPLE_DATABASES:=nextflow_n8n,keycloak,gitlabhq_production}  # Danh sách database cần tạo

# Xuất biến môi trường PGPASSWORD để sử dụng với lệnh psql
export PGPASSWORD="$POSTGRES_PASSWORD"

# ============================================================================
# HIỂN THỊ THÔNG TIN KHỞI TẠO
# ============================================================================
echo "========================================"
echo "BẮT ĐẦU KHỞI TẠO DATABASE"
echo "Thời gian: $(date)"
echo "----------------------------------------"
echo "Người dùng: $POSTGRES_USER"
echo "Database chính: $POSTGRES_DB"
echo "Danh sách database bổ sung: ${POSTGRES_MULTIPLE_DATABASES:-Không có}"
echo "========================================"

# ============================================================================
# HÀM TẠO DATABASE VÀ CẤP QUYỀN
# ============================================================================
create_database() {
    local dbname="$1"
    local username="$2"
    
    echo "Đang tạo database: $dbname..."
    
    # Tạo database nếu chưa tồn tại
    psql -v ON_ERROR_STOP=1 --username "$username" --dbname "$POSTGRES_DB" <<-EOSQL
        -- Tạo database nếu chưa tồn tại
        CREATE DATABASE "$dbname" WITH OWNER = "$username" ENCODING = 'UTF8';
        
        -- Kết nối đến database mới tạo
        \c "$dbname"
        
        -- Tạo extension phổ biến
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS "pgcrypto";
        
        -- Cấp tất cả quyền cho người dùng
        GRANT ALL PRIVILEGES ON DATABASE "$dbname" TO "$username";
        
        -- Cấp quyền cho schema public
        GRANT ALL ON SCHEMA public TO "$username";
        
        -- Cấp quyền mặc định cho các bảng tương lai
        ALTER DEFAULT PRIVILEGES IN SCHEMA public 
        GRANT ALL ON TABLES TO "$username";
        
        -- Cấp quyền cho các sequence
        ALTER DEFAULT PRIVILEGES IN SCHEMA public 
        GRANT ALL ON SEQUENCES TO "$username";
        
        -- Cấp quyền cho các function
        ALTER DEFAULT PRIVILEGES IN SCHEMA public 
        GRANT ALL ON FUNCTIONS TO "$username";
        
        -- Cập nhật collation version để tránh cảnh báo
        ALTER DATABASE "$dbname" REFRESH COLLATION VERSION;
        
        -- Thông báo hoàn thành
        \echo "Đã tạo và cấu hình database: $dbname"
EOSQL
}

# ============================================================================
# CHỜ POSTGRESQL SẴN SÀNG
# ============================================================================
# Kiểm tra kết nối đến PostgreSQL trong vòng 60 giây
MAX_RETRIES=60
COUNTER=0

echo "Đang kiểm tra kết nối đến PostgreSQL..."

while ! psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1" >/dev/null 2>&1; do
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -ge $MAX_RETRIES ]; then
        echo "LỖI: Không thể kết nối đến PostgreSQL sau $MAX_RETRIES lần thử"
        exit 1
    fi
    
    echo "Đợi PostgreSQL khởi động... ($COUNTER/$MAX_RETRIES)"
    sleep 1
done

echo "Kết nối thành công đến PostgreSQL!"

# ============================================================================
# TẠO CÁC DATABASE BỔ SUNG
# ============================================================================
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "ĐANG TẠO CÁC DATABASE BỔ SUNG..."
    
    # Tách danh sách database bằng dấu phẩy và tạo từng cái
    IFS=',' read -ra databases <<< "$POSTGRES_MULTIPLE_DATABASES"
    
    # Tạo từng database trong danh sách
    for db in "${databases[@]}"; do
        # Xóa khoảng trắng thừa
        db=$(echo "$db" | xargs)
        
        # Chỉ tạo database nếu tên không rỗng
        if [ -n "$db" ]; then
            create_database "$db" "$POSTGRES_USER"
        fi
    done
    
    echo "✅ ĐÃ TẠO THÀNH CÔNG TẤT CẢ DATABASE"
else
    echo "ℹ️ Không có database bổ sung nào cần tạo (POSTGRES_MULTIPLE_DATABASES trống)"
fi

# ============================================================================
# KIỂM TRA LẠI TẤT CẢ DATABASE ĐÃ TẠO
# ============================================================================
echo "\n🔍 DANH SÁCH DATABASE HIỆN CÓ:"
psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\l"

# ============================================================================
# KẾT THÚC
# ============================================================================
echo "\n✅ KHỞI TẠO DATABASE HOÀN TẤT VÀO LÚC: $(date)"
echo "========================================"

# Thoát với mã thành công
exit 0
