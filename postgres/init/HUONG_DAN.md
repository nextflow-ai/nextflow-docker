# Vào container
docker exec -it postgres sh

# Cài đặt dos2unix nếu chưa có
apk add --no-cache dos2unix

# Chuyển đổi line endings
dos2unix /tmp/create-multiple-databases.sh

# Cấp quyền thực thi
chmod +x /tmp/create-multiple-databases.sh

# Copy file đã sửa vào container:
docker cp D:\NEXTFLOW-PRODUCT\nextflow-docker\postgres\init\create-multiple-databases.sh postgres:/tmp/

# Chạy script:
sh /tmp/create-multiple-databases.sh
