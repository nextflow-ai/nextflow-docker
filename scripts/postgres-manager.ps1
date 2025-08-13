# PostgreSQL Manager Script for Windows
# Quản lý PostgreSQL với giao diện menu tương tác

# Màu sắc cho output
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Blue"
$CYAN = "Cyan"

# Thông tin kết nối PostgreSQL
$POSTGRES_CONTAINER = "postgres"
$POSTGRES_USER = "postgres"
$POSTGRES_DB = "postgres"
$BACKUP_DIR = "./postgres/backups"

# Tạo thư mục backup nếu chưa có
if (!(Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# Hàm hiển thị header
function Show-Header {
    Clear-Host
    Write-Host "================================================" -ForegroundColor $BLUE
    Write-Host "           POSTGRES MANAGER v1.0               " -ForegroundColor $BLUE
    Write-Host "================================================" -ForegroundColor $BLUE
    Write-Host ""
}

# Hàm hiển thị menu chính
function Show-Menu {
    Write-Host "Chọn tính năng:" -ForegroundColor $GREEN
    Write-Host "1. Xem trạng thái PostgreSQL"
    Write-Host "2. Tạo database mới"
    Write-Host "3. Xóa database"
    Write-Host "4. Liệt kê tất cả databases"
    Write-Host "5. Backup database"
    Write-Host "6. Restore database"
    Write-Host "7. Tạo user mới"
    Write-Host "8. Xóa user"
    Write-Host "9. Liệt kê users"
    Write-Host "10. Xem logs PostgreSQL"
    Write-Host "11. Kết nối psql"
    Write-Host "12. Thống kê database"
    Write-Host "13. Tối ưu hóa database"
    Write-Host "0. Thoát"
    Write-Host ""
    $choice = Read-Host "Nhập lựa chọn (0-13)"
    return $choice
}

# Hàm kiểm tra container PostgreSQL
function Test-PostgresContainer {
    try {
        $containers = docker ps --format "{{.Names}}" | Where-Object { $_ -eq $POSTGRES_CONTAINER }
        if ($containers) {
            return $true
        } else {
            Write-Host "Lỗi: Container PostgreSQL không chạy!" -ForegroundColor $RED
            Write-Host "Vui lòng khởi động PostgreSQL trước."
            return $false
        }
    } catch {
        Write-Host "Lỗi: Không thể kết nối Docker!" -ForegroundColor $RED
        return $false
    }
}

# 1. Xem trạng thái PostgreSQL
function Show-PostgresStatus {
    Write-Host "Đang kiểm tra trạng thái PostgreSQL..." -ForegroundColor $YELLOW
    
    if (Test-PostgresContainer) {
        Write-Host "✓ PostgreSQL đang chạy" -ForegroundColor $GREEN
        
        # Hiển thị thông tin chi tiết
        Write-Host ""
        Write-Host "Thông tin container:"
        docker ps --filter "name=$POSTGRES_CONTAINER" --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"
        
        Write-Host ""
        Write-Host "Phiên bản PostgreSQL:"
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "SELECT version();"
        
        Write-Host ""
        Write-Host "Dung lượng sử dụng:"
        docker exec $POSTGRES_CONTAINER du -sh /var/lib/postgresql/data
    } else {
        Write-Host "✗ PostgreSQL không chạy" -ForegroundColor $RED
    }
}

# 2. Tạo database mới
function New-Database {
    if (!(Test-PostgresContainer)) { return }
    
    $dbName = Read-Host "Nhập tên database mới"
    
    if ([string]::IsNullOrWhiteSpace($dbName)) {
        Write-Host "Tên database không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "Đang tạo database '$dbName'..." -ForegroundColor $YELLOW
    
    try {
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "CREATE DATABASE `"$dbName`";"
        Write-Host "✓ Tạo database '$dbName' thành công!" -ForegroundColor $GREEN
    } catch {
        Write-Host "✗ Lỗi khi tạo database '$dbName'" -ForegroundColor $RED
        Write-Host $_.Exception.Message
    }
}

# 3. Xóa database
function Remove-Database {
    if (!(Test-PostgresContainer)) { return }
    
    $dbName = Read-Host "Nhập tên database cần xóa"
    
    if ([string]::IsNullOrWhiteSpace($dbName)) {
        Write-Host "Tên database không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "CẢNH BÁO: Bạn sắp xóa database '$dbName'" -ForegroundColor $RED
    $confirm = Read-Host "Gõ 'YES' để xác nhận"
    
    if ($confirm -eq "YES") {
        Write-Host "Đang xóa database '$dbName'..." -ForegroundColor $YELLOW
        
        try {
            docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "DROP DATABASE `"$dbName`";"
            Write-Host "✓ Xóa database '$dbName' thành công!" -ForegroundColor $GREEN
        } catch {
            Write-Host "✗ Lỗi khi xóa database '$dbName'" -ForegroundColor $RED
            Write-Host $_.Exception.Message
        }
    } else {
        Write-Host "Hủy bỏ thao tác xóa."
    }
}

# 4. Liệt kê databases
function Get-DatabaseList {
    if (!(Test-PostgresContainer)) { return }
    
    Write-Host "Danh sách databases:" -ForegroundColor $YELLOW
    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "\l"
}

# 5. Backup database
function Backup-Database {
    if (!(Test-PostgresContainer)) { return }
    
    $dbName = Read-Host "Nhập tên database cần backup"
    
    if ([string]::IsNullOrWhiteSpace($dbName)) {
        Write-Host "Tên database không được để trống!" -ForegroundColor $RED
        return
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "${dbName}_${timestamp}.sql"
    $backupPath = Join-Path $BACKUP_DIR $backupFile
    
    Write-Host "Đang backup database '$dbName'..." -ForegroundColor $YELLOW
    
    try {
        docker exec $POSTGRES_CONTAINER pg_dump -U $POSTGRES_USER $dbName | Out-File -FilePath $backupPath -Encoding UTF8
        Write-Host "✓ Backup thành công!" -ForegroundColor $GREEN
        Write-Host "File backup: $backupPath"
        $size = (Get-Item $backupPath).Length / 1MB
        Write-Host "Kích thước: $([math]::Round($size, 2)) MB"
    } catch {
        Write-Host "✗ Lỗi khi backup database" -ForegroundColor $RED
        Write-Host $_.Exception.Message
    }
}

# 6. Restore database
function Restore-Database {
    if (!(Test-PostgresContainer)) { return }
    
    Write-Host "Danh sách file backup:"
    $backupFiles = Get-ChildItem -Path $BACKUP_DIR -Filter "*.sql" -ErrorAction SilentlyContinue
    
    if (!$backupFiles) {
        Write-Host "Không tìm thấy file backup nào!" -ForegroundColor $RED
        return
    }
    
    $backupFiles | ForEach-Object { Write-Host $_.Name }
    
    Write-Host ""
    $backupFile = Read-Host "Nhập tên file backup (không cần đường dẫn)"
    $backupPath = Join-Path $BACKUP_DIR $backupFile
    
    if (!(Test-Path $backupPath)) {
        Write-Host "File backup không tồn tại!" -ForegroundColor $RED
        return
    }
    
    $targetDb = Read-Host "Nhập tên database đích"
    
    if ([string]::IsNullOrWhiteSpace($targetDb)) {
        Write-Host "Tên database không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "Đang restore database '$targetDb'..." -ForegroundColor $YELLOW
    
    try {
        # Tạo database nếu chưa có
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "CREATE DATABASE `"$targetDb`";"
        
        # Restore từ file
        Get-Content $backupPath | docker exec -i $POSTGRES_CONTAINER psql -U $POSTGRES_USER $targetDb
        Write-Host "✓ Restore thành công!" -ForegroundColor $GREEN
    } catch {
        Write-Host "✗ Lỗi khi restore database" -ForegroundColor $RED
        Write-Host $_.Exception.Message
    }
}

# 7. Tạo user mới
function New-PostgresUser {
    if (!(Test-PostgresContainer)) { return }
    
    $username = Read-Host "Nhập tên user mới"
    
    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Tên user không được để trống!" -ForegroundColor $RED
        return
    }
    
    $password = Read-Host "Nhập password" -AsSecureString
    $passwordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    if ([string]::IsNullOrWhiteSpace($passwordText)) {
        Write-Host "Password không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "Đang tạo user '$username'..." -ForegroundColor $YELLOW
    
    try {
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "CREATE USER `"$username`" WITH PASSWORD '$passwordText';"
        Write-Host "✓ Tạo user '$username' thành công!" -ForegroundColor $GREEN
        
        $grantCreatedb = Read-Host "Cấp quyền CREATEDB cho user này? (y/n)"
        
        if ($grantCreatedb -eq "y") {
            docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "ALTER USER `"$username`" CREATEDB;"
            Write-Host "✓ Đã cấp quyền CREATEDB" -ForegroundColor $GREEN
        }
    } catch {
        Write-Host "✗ Lỗi khi tạo user" -ForegroundColor $RED
        Write-Host $_.Exception.Message
    }
}

# 8. Xóa user
function Remove-PostgresUser {
    if (!(Test-PostgresContainer)) { return }
    
    $username = Read-Host "Nhập tên user cần xóa"
    
    if ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Tên user không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "CẢNH BÁO: Bạn sắp xóa user '$username'" -ForegroundColor $RED
    $confirm = Read-Host "Gõ 'YES' để xác nhận"
    
    if ($confirm -eq "YES") {
        Write-Host "Đang xóa user '$username'..." -ForegroundColor $YELLOW
        
        try {
            docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "DROP USER `"$username`";"
            Write-Host "✓ Xóa user '$username' thành công!" -ForegroundColor $GREEN
        } catch {
            Write-Host "✗ Lỗi khi xóa user" -ForegroundColor $RED
            Write-Host $_.Exception.Message
        }
    } else {
        Write-Host "Hủy bỏ thao tác xóa."
    }
}

# 9. Liệt kê users
function Get-PostgresUsers {
    if (!(Test-PostgresContainer)) { return }
    
    Write-Host "Danh sách users:" -ForegroundColor $YELLOW
    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c "\du"
}

# 10. Xem logs
function Show-PostgresLogs {
    Write-Host "Logs PostgreSQL (50 dòng cuối):" -ForegroundColor $YELLOW
    docker logs --tail 50 $POSTGRES_CONTAINER
    
    Write-Host ""
    $followLogs = Read-Host "Xem logs realtime? (y/n)"
    
    if ($followLogs -eq "y") {
        Write-Host "Nhấn Ctrl+C để thoát..."
        docker logs -f $POSTGRES_CONTAINER
    }
}

# 11. Kết nối psql
function Connect-Psql {
    if (!(Test-PostgresContainer)) { return }
    
    Write-Host "Kết nối đến PostgreSQL..." -ForegroundColor $YELLOW
    Write-Host "Gõ \q để thoát khỏi psql"
    Write-Host ""
    
    docker exec -it $POSTGRES_CONTAINER psql -U $POSTGRES_USER
}

# 12. Thống kê database
function Show-DatabaseStats {
    if (!(Test-PostgresContainer)) { return }
    
    Write-Host "Thống kê databases:" -ForegroundColor $YELLOW
    
    $query1 = @"
SELECT 
    datname as "Database",
    pg_size_pretty(pg_database_size(datname)) as "Size",
    (SELECT count(*) FROM pg_stat_activity WHERE datname = pg_database.datname) as "Connections"
FROM pg_database 
WHERE datistemplate = false
ORDER BY pg_database_size(datname) DESC;
"@
    
    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c $query1
    
    Write-Host ""
    Write-Host "Top 10 bảng lớn nhất:" -ForegroundColor $YELLOW
    
    $query2 = @"
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC 
LIMIT 10;
"@
    
    docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -c $query2
}

# 13. Tối ưu hóa database
function Optimize-Database {
    if (!(Test-PostgresContainer)) { return }
    
    $dbName = Read-Host "Nhập tên database cần tối ưu"
    
    if ([string]::IsNullOrWhiteSpace($dbName)) {
        Write-Host "Tên database không được để trống!" -ForegroundColor $RED
        return
    }
    
    Write-Host "Đang tối ưu hóa database '$dbName'..." -ForegroundColor $YELLOW
    
    try {
        # VACUUM ANALYZE
        Write-Host "Chạy VACUUM ANALYZE..."
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER $dbName -c "VACUUM ANALYZE;"
        
        # REINDEX
        Write-Host "Chạy REINDEX..."
        docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER $dbName -c "REINDEX DATABASE `"$dbName`";"
        
        Write-Host "✓ Tối ưu hóa hoàn tất!" -ForegroundColor $GREEN
    } catch {
        Write-Host "✗ Lỗi khi tối ưu hóa database" -ForegroundColor $RED
        Write-Host $_.Exception.Message
    }
}

# Hàm chờ người dùng nhấn Enter
function Wait-Enter {
    Write-Host ""
    Read-Host "Nhấn Enter để tiếp tục"
}

# Vòng lặp menu chính
while ($true) {
    Show-Header
    $choice = Show-Menu
    
    switch ($choice) {
        "1" {
            Show-Header
            Show-PostgresStatus
            Wait-Enter
        }
        "2" {
            Show-Header
            New-Database
            Wait-Enter
        }
        "3" {
            Show-Header
            Remove-Database
            Wait-Enter
        }
        "4" {
            Show-Header
            Get-DatabaseList
            Wait-Enter
        }
        "5" {
            Show-Header
            Backup-Database
            Wait-Enter
        }
        "6" {
            Show-Header
            Restore-Database
            Wait-Enter
        }
        "7" {
            Show-Header
            New-PostgresUser
            Wait-Enter
        }
        "8" {
            Show-Header
            Remove-PostgresUser
            Wait-Enter
        }
        "9" {
            Show-Header
            Get-PostgresUsers
            Wait-Enter
        }
        "10" {
            Show-Header
            Show-PostgresLogs
            Wait-Enter
        }
        "11" {
            Show-Header
            Connect-Psql
            Wait-Enter
        }
        "12" {
            Show-Header
            Show-DatabaseStats
            Wait-Enter
        }
        "13" {
            Show-Header
            Optimize-Database
            Wait-Enter
        }
        "0" {
            Write-Host "Tạm biệt!" -ForegroundColor $GREEN
            exit 0
        }
        default {
            Write-Host "Lựa chọn không hợp lệ! Vui lòng chọn từ 0-13." -ForegroundColor $RED
            Wait-Enter
        }
    }
}