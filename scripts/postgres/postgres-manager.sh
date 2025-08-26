#!/bin/bash

# PostgreSQL Manager Script
# Quản lý PostgreSQL với giao diện menu tương tác

set -e

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Thông tin kết nối PostgreSQL
POSTGRES_CONTAINER="postgres"
POSTGRES_USER="postgres"
POSTGRES_DB="postgres"
BACKUP_DIR="./postgres/backups"

# Tạo thư mục backup nếu chưa có
mkdir -p "$BACKUP_DIR"

# Hàm hiển thị header
show_header() {
    clear
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}           POSTGRES MANAGER v1.0               ${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

# Hàm hiển thị menu chính
show_menu() {
    echo -e "${GREEN}Chọn tính năng:${NC}"
    echo "1. Xem trạng thái PostgreSQL"
    echo "2. Tạo database mới"
    echo "3. Xóa database"
    echo "4. Liệt kê tất cả databases"
    echo "5. Backup database"
    echo "6. Restore database"
    echo "7. Tạo user mới"
    echo "8. Xóa user"
    echo "9. Liệt kê users"
    echo "10. Xem logs PostgreSQL"
    echo "11. Kết nối psql"
    echo "12. Thống kê database"
    echo "13. Tối ưu hóa database"
    echo "0. Thoát"
    echo ""
    echo -n "Nhập lựa chọn (0-13): "
}

# Hàm kiểm tra container PostgreSQL
check_postgres() {
    if ! docker ps | grep -q "$POSTGRES_CONTAINER"; then
        echo -e "${RED}Lỗi: Container PostgreSQL không chạy!${NC}"
        echo "Vui lòng khởi động PostgreSQL trước."
        return 1
    fi
    return 0
}

# 1. Xem trạng thái PostgreSQL
show_status() {
    echo -e "${YELLOW}Đang kiểm tra trạng thái PostgreSQL...${NC}"
    
    if docker ps | grep -q "$POSTGRES_CONTAINER"; then
        echo -e "${GREEN}✓ PostgreSQL đang chạy${NC}"
        
        # Hiển thị thông tin chi tiết
        echo ""
        echo "Thông tin container:"
        docker ps --filter "name=$POSTGRES_CONTAINER" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        echo ""
        echo "Phiên bản PostgreSQL:"
        docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "SELECT version();"
        
        echo ""
        echo "Dung lượng sử dụng:"
        docker exec "$POSTGRES_CONTAINER" du -sh /var/lib/postgresql/data
    else
        echo -e "${RED}✗ PostgreSQL không chạy${NC}"
    fi
}

# 2. Tạo database mới
create_database() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên database mới: "
    read db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}Tên database không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Đang tạo database '$db_name'...${NC}"
    
    if docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "CREATE DATABASE \"$db_name\";"; then
        echo -e "${GREEN}✓ Tạo database '$db_name' thành công!${NC}"
    else
        echo -e "${RED}✗ Lỗi khi tạo database '$db_name'${NC}"
    fi
}

# 3. Xóa database
drop_database() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên database cần xóa: "
    read db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}Tên database không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${RED}CẢNH BÁO: Bạn sắp xóa database '$db_name'${NC}"
    echo -n "Gõ 'YES' để xác nhận: "
    read confirm
    
    if [[ "$confirm" == "YES" ]]; then
        echo -e "${YELLOW}Đang xóa database '$db_name'...${NC}"
        
        if docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "DROP DATABASE \"$db_name\";"; then
            echo -e "${GREEN}✓ Xóa database '$db_name' thành công!${NC}"
        else
            echo -e "${RED}✗ Lỗi khi xóa database '$db_name'${NC}"
        fi
    else
        echo "Hủy bỏ thao tác xóa."
    fi
}

# 4. Liệt kê databases
list_databases() {
    if ! check_postgres; then return 1; fi
    
    echo -e "${YELLOW}Danh sách databases:${NC}"
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "\l"
}

# 5. Backup database
backup_database() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên database cần backup: "
    read db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}Tên database không được để trống!${NC}"
        return 1
    fi
    
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="${db_name}_${timestamp}.sql"
    backup_path="$BACKUP_DIR/$backup_file"
    
    echo -e "${YELLOW}Đang backup database '$db_name'...${NC}"
    
    if docker exec "$POSTGRES_CONTAINER" pg_dump -U "$POSTGRES_USER" "$db_name" > "$backup_path"; then
        echo -e "${GREEN}✓ Backup thành công!${NC}"
        echo "File backup: $backup_path"
        echo "Kích thước: $(du -h "$backup_path" | cut -f1)"
    else
        echo -e "${RED}✗ Lỗi khi backup database${NC}"
    fi
}

# 6. Restore database
restore_database() {
    if ! check_postgres; then return 1; fi
    
    echo "Danh sách file backup:"
    ls -la "$BACKUP_DIR"/*.sql 2>/dev/null || {
        echo -e "${RED}Không tìm thấy file backup nào!${NC}"
        return 1
    }
    
    echo ""
    echo -n "Nhập tên file backup (không cần đường dẫn): "
    read backup_file
    
    backup_path="$BACKUP_DIR/$backup_file"
    
    if [[ ! -f "$backup_path" ]]; then
        echo -e "${RED}File backup không tồn tại!${NC}"
        return 1
    fi
    
    echo -n "Nhập tên database đích: "
    read target_db
    
    if [[ -z "$target_db" ]]; then
        echo -e "${RED}Tên database không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Đang restore database '$target_db'...${NC}"
    
    # Tạo database nếu chưa có
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "CREATE DATABASE \"$target_db\";"
    
    if docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" "$target_db" < "$backup_path"; then
        echo -e "${GREEN}✓ Restore thành công!${NC}"
    else
        echo -e "${RED}✗ Lỗi khi restore database${NC}"
    fi
}

# 7. Tạo user mới
create_user() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên user mới: "
    read username
    
    if [[ -z "$username" ]]; then
        echo -e "${RED}Tên user không được để trống!${NC}"
        return 1
    fi
    
    echo -n "Nhập password: "
    read -s password
    echo ""
    
    if [[ -z "$password" ]]; then
        echo -e "${RED}Password không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Đang tạo user '$username'...${NC}"
    
    if docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "CREATE USER \"$username\" WITH PASSWORD '$password';"; then
        echo -e "${GREEN}✓ Tạo user '$username' thành công!${NC}"
        
        echo -n "Cấp quyền CREATEDB cho user này? (y/n): "
        read grant_createdb
        
        if [[ "$grant_createdb" == "y" ]]; then
            docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "ALTER USER \"$username\" CREATEDB;"
            echo -e "${GREEN}✓ Đã cấp quyền CREATEDB${NC}"
        fi
    else
        echo -e "${RED}✗ Lỗi khi tạo user${NC}"
    fi
}

# 8. Xóa user
drop_user() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên user cần xóa: "
    read username
    
    if [[ -z "$username" ]]; then
        echo -e "${RED}Tên user không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${RED}CẢNH BÁO: Bạn sắp xóa user '$username'${NC}"
    echo -n "Gõ 'YES' để xác nhận: "
    read confirm
    
    if [[ "$confirm" == "YES" ]]; then
        echo -e "${YELLOW}Đang xóa user '$username'...${NC}"
        
        if docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "DROP USER \"$username\";"; then
            echo -e "${GREEN}✓ Xóa user '$username' thành công!${NC}"
        else
            echo -e "${RED}✗ Lỗi khi xóa user${NC}"
        fi
    else
        echo "Hủy bỏ thao tác xóa."
    fi
}

# 9. Liệt kê users
list_users() {
    if ! check_postgres; then return 1; fi
    
    echo -e "${YELLOW}Danh sách users:${NC}"
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "\du"
}

# 10. Xem logs
show_logs() {
    echo -e "${YELLOW}Logs PostgreSQL (50 dòng cuối):${NC}"
    docker logs --tail 50 "$POSTGRES_CONTAINER"
    
    echo ""
    echo -n "Xem logs realtime? (y/n): "
    read follow_logs
    
    if [[ "$follow_logs" == "y" ]]; then
        echo "Nhấn Ctrl+C để thoát..."
        docker logs -f "$POSTGRES_CONTAINER"
    fi
}

# 11. Kết nối psql
connect_psql() {
    if ! check_postgres; then return 1; fi
    
    echo -e "${YELLOW}Kết nối đến PostgreSQL...${NC}"
    echo "Gõ \\q để thoát khỏi psql"
    echo ""
    
    docker exec -it "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER"
}

# 12. Thống kê database
show_stats() {
    if ! check_postgres; then return 1; fi
    
    echo -e "${YELLOW}Thống kê databases:${NC}"
    
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "
        SELECT 
            datname as \"Database\",
            pg_size_pretty(pg_database_size(datname)) as \"Size\",
            (SELECT count(*) FROM pg_stat_activity WHERE datname = pg_database.datname) as \"Connections\"
        FROM pg_database 
        WHERE datistemplate = false
        ORDER BY pg_database_size(datname) DESC;
    "
    
    echo ""
    echo -e "${YELLOW}Top 10 bảng lớn nhất:${NC}"
    
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables 
        WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC 
        LIMIT 10;
    "
}

# 13. Tối ưu hóa database
optimize_database() {
    if ! check_postgres; then return 1; fi
    
    echo -n "Nhập tên database cần tối ưu: "
    read db_name
    
    if [[ -z "$db_name" ]]; then
        echo -e "${RED}Tên database không được để trống!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Đang tối ưu hóa database '$db_name'...${NC}"
    
    # VACUUM ANALYZE
    echo "Chạy VACUUM ANALYZE..."
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" "$db_name" -c "VACUUM ANALYZE;"
    
    # REINDEX
    echo "Chạy REINDEX..."
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" "$db_name" -c "REINDEX DATABASE \"$db_name\";"
    
    echo -e "${GREEN}✓ Tối ưu hóa hoàn tất!${NC}"
}

# Hàm chờ người dùng nhấn Enter
wait_enter() {
    echo ""
    echo -n "Nhấn Enter để tiếp tục..."
    read
}

# Vòng lặp menu chính
while true; do
    show_header
    show_menu
    
    read choice
    
    case $choice in
        1)
            show_header
            show_status
            wait_enter
            ;;
        2)
            show_header
            create_database
            wait_enter
            ;;
        3)
            show_header
            drop_database
            wait_enter
            ;;
        4)
            show_header
            list_databases
            wait_enter
            ;;
        5)
            show_header
            backup_database
            wait_enter
            ;;
        6)
            show_header
            restore_database
            wait_enter
            ;;
        7)
            show_header
            create_user
            wait_enter
            ;;
        8)
            show_header
            drop_user
            wait_enter
            ;;
        9)
            show_header
            list_users
            wait_enter
            ;;
        10)
            show_header
            show_logs
            wait_enter
            ;;
        11)
            show_header
            connect_psql
            wait_enter
            ;;
        12)
            show_header
            show_stats
            wait_enter
            ;;
        13)
            show_header
            optimize_database
            wait_enter
            ;;
        0)
            echo -e "${GREEN}Tạm biệt!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Lựa chọn không hợp lệ! Vui lòng chọn từ 0-13.${NC}"
            wait_enter
            ;;
    esac
done