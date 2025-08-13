# PostgreSQL Manager Script

Script quản lý PostgreSQL với giao diện menu tương tác dễ sử dụng.

## Tính năng

### 🔍 **Giám sát & Thống kê**
- Xem trạng thái PostgreSQL container
- Thống kê database (kích thước, kết nối)
- Xem logs realtime
- Top 10 bảng lớn nhất

### 🗄️ **Quản lý Database**
- Tạo database mới
- Xóa database (có xác nhận)
- Liệt kê tất cả databases
- Tối ưu hóa database (VACUUM, REINDEX)

### 💾 **Backup & Restore**
- Backup database với timestamp
- Restore từ file backup
- Quản lý file backup tự động

### 👥 **Quản lý User**
- Tạo user mới với password
- Xóa user (có xác nhận)
- Liệt kê users và quyền
- Cấp quyền CREATEDB

### 🔧 **Công cụ**
- Kết nối psql interactive
- Chạy lệnh SQL trực tiếp

## Cách sử dụng

### Windows (PowerShell)
```powershell
# Chạy script
.\scripts\postgres-manager.ps1

# Hoặc từ thư mục scripts
cd scripts
.\postgres-manager.ps1
```

### Linux/macOS (Bash)
```bash
# Cấp quyền thực thi
chmod +x scripts/postgres-manager.sh

# Chạy script
./scripts/postgres-manager.sh

# Hoặc từ thư mục scripts
cd scripts
./postgres-manager.sh
```

## Giao diện Menu

```
================================================
           POSTGRES MANAGER v1.0               
================================================

Chọn tính năng:
1. Xem trạng thái PostgreSQL
2. Tạo database mới
3. Xóa database
4. Liệt kê tất cả databases
5. Backup database
6. Restore database
7. Tạo user mới
8. Xóa user
9. Liệt kê users
10. Xem logs PostgreSQL
11. Kết nối psql
12. Thống kê database
13. Tối ưu hóa database
0. Thoát

Nhập lựa chọn (0-13):
```

## Yêu cầu hệ thống

- Docker đã cài đặt và chạy
- Container PostgreSQL với tên `postgres`
- PowerShell 5.0+ (Windows) hoặc Bash (Linux/macOS)

## Cấu hình

Các biến có thể tùy chỉnh trong script:

```powershell
# Windows PowerShell
$POSTGRES_CONTAINER = "postgres"     # Tên container
$POSTGRES_USER = "postgres"          # User PostgreSQL
$BACKUP_DIR = "./postgres/backups"   # Thư mục backup
```

```bash
# Linux/macOS Bash
POSTGRES_CONTAINER="postgres"        # Tên container
POSTGRES_USER="postgres"             # User PostgreSQL
BACKUP_DIR="./postgres/backups"      # Thư mục backup
```

## Ví dụ sử dụng

### 1. Tạo database mới
```
Chọn: 2
Nhập tên database mới: my_app_db
✓ Tạo database 'my_app_db' thành công!
```

### 2. Backup database
```
Chọn: 5
Nhập tên database cần backup: my_app_db
✓ Backup thành công!
File backup: ./postgres/backups/my_app_db_20241201_143022.sql
Kích thước: 2.5 MB
```

### 3. Tạo user mới
```
Chọn: 7
Nhập tên user mới: app_user
Nhập password: ********
✓ Tạo user 'app_user' thành công!
Cấp quyền CREATEDB cho user này? (y/n): y
✓ Đã cấp quyền CREATEDB
```

### 4. Xem thống kê
```
Chọn: 12
Thống kê databases:
 Database  |    Size    | Connections
-----------+------------+------------
 my_app_db | 15 MB      |     3
 postgres  | 8049 kB    |     1

Top 10 bảng lớn nhất:
 schemaname | tablename | size
------------+-----------+-------
 public     | users     | 5 MB
 public     | orders    | 3 MB
```

## Tính năng bảo mật

- ✅ Xác nhận trước khi xóa database/user
- ✅ Nhập password ẩn (secure input)
- ✅ Kiểm tra container trước mọi thao tác
- ✅ Xử lý lỗi và thông báo rõ ràng
- ✅ Backup tự động với timestamp

## Troubleshooting

### Container không chạy
```
Lỗi: Container PostgreSQL không chạy!
Vui lòng khởi động PostgreSQL trước.
```
**Giải pháp:** Chạy `docker-compose up -d postgres`

### Không thể kết nối Docker
```
Lỗi: Không thể kết nối Docker!
```
**Giải pháp:** Kiểm tra Docker Desktop đã chạy

### File backup không tồn tại
```
File backup không tồn tại!
```
**Giải pháp:** Kiểm tra tên file trong thư mục `./postgres/backups`

## Mở rộng

Script có thể mở rộng thêm:
- Quản lý schema
- Import/Export CSV
- Scheduled backup
- Monitoring alerts
- Multi-database operations

## Liên hệ

Nếu có vấn đề hoặc đề xuất cải tiến, vui lòng tạo issue trong repository.