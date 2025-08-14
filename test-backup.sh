#!/bin/bash

echo "Testing GitLab backup functionality..."

# Kiểm tra GitLab container
if docker ps | grep -q "gitlab"; then
    echo "✓ GitLab container is running"
else
    echo "✗ GitLab container is not running"
    exit 1
fi

# Tạo thư mục backup
mkdir -p gitlab/backups

# Tạo backup
echo "Creating backup..."
timestamp=$(date +%Y%m%d_%H%M%S)
echo "Timestamp: $timestamp"

# Chạy backup command
docker exec gitlab gitlab-backup create BACKUP="$timestamp" STRATEGY=copy

echo "Backup completed!"
echo "Check backup files:"
docker exec gitlab ls -la /var/opt/gitlab/backups/

echo "Local backup directory:"
ls -la gitlab/backups/
