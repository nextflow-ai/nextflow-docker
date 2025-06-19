# 🦊 GITLAB ROOT ACCOUNT CONFIGURATION - NEXTFLOW DOCKER

## 📋 Tổng quan

Tài liệu này mô tả cấu hình tài khoản root GitLab đã được tối ưu hóa và chuẩn hóa trong hệ thống NextFlow Docker.

**Ngày cập nhật:** 2025-06-16  
**Phiên bản:** 2.1 - GitLab Root Account Optimized  
**Trạng thái:** ✅ Hoàn thành và đã kiểm tra

---

## 👤 1. THÔNG TIN TÀI KHOẢN ROOT

### 1.1 Thông tin cơ bản

| Thuộc tính | Giá trị | Nguồn |
|------------|---------|-------|
| **Username** | `root` | Mặc định GitLab (không thể thay đổi) |
| **Password** | `nextflow@2025` | Environment variable |
| **Email** | `nextflow.vn@gmail.com` | Environment variable |
| **Full Name** | `NextFlow Administrator` | Environment variable |
| **Role** | Administrator | Mặc định cho root user |

### 1.2 Environment Variables

**Trong file `.env`:**
```bash
# === CẤU HÌNH GITLAB ===
GITLAB_ROOT_USERNAME=root
GITLAB_ROOT_PASSWORD=nextflow@2025
GITLAB_ROOT_EMAIL=nextflow.vn@gmail.com
GITLAB_ROOT_NAME=NextFlow Administrator
```

---

## 🔧 2. CẤU HÌNH TRONG DOCKER-COMPOSE.YML

### 2.1 GitLab Omnibus Configuration

```yaml
environment:
  GITLAB_OMNIBUS_CONFIG: |
    # === CẤU HÌNH TÀI KHOẢN ROOT - SỬ DỤNG ENVIRONMENT VARIABLES ===
    gitlab_rails['initial_root_password'] = "${GITLAB_ROOT_PASSWORD:-nextflow@2025}";
    gitlab_rails['initial_root_email'] = "${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}";
    # Lưu ý: Username root luôn là 'root' và không thể thay đổi trong GitLab
```

### 2.2 Email Configuration

```yaml
# Email configuration sử dụng root email
gitlab_rails['gitlab_email_from'] = "${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}";
gitlab_rails['gitlab_email_reply_to'] = "${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}";
```

---

## 🌐 3. THÔNG TIN TRUY CẬP

### 3.1 Web Interface

- **URL Local:** http://localhost:8088
- **URL External:** https://gitlab.nextflow.vn
- **Username:** root
- **Password:** nextflow@2025
- **Email:** nextflow.vn@gmail.com

### 3.2 Git Access

**SSH Access:**
```bash
# Clone repository qua SSH
git clone ssh://git@localhost:2222/root/repository-name.git

# Add remote SSH
git remote add origin ssh://git@localhost:2222/root/repository-name.git
```

**HTTPS Access:**
```bash
# Clone repository qua HTTPS
git clone http://localhost:8088/root/repository-name.git

# Add remote HTTPS
git remote add origin http://localhost:8088/root/repository-name.git
```

### 3.3 Container Registry

```bash
# Login to GitLab Container Registry
docker login localhost:5050
# Username: root
# Password: nextflow@2025

# Push image to registry
docker tag my-image:latest localhost:5050/root/my-project/my-image:latest
docker push localhost:5050/root/my-project/my-image:latest
```

---

## 🛠️ 4. SCRIPTS VÀ TOOLS SUPPORT

### 4.1 Deployment Scripts

**Tất cả scripts đã được cập nhật để sử dụng environment variables:**

- `scripts/profiles/gitlab.sh`
- `scripts/test-gitlab-deployment.sh`
- `scripts/check-gitlab-database.sh`
- `scripts/validate-gitlab-optimization.sh`

### 4.2 Hiển thị thông tin trong scripts

**Banner deployment:**
```bash
echo "  👤 Root Username: ${GITLAB_ROOT_USERNAME}"
echo "  🔐 Root Password: ${GITLAB_ROOT_PASSWORD}"
echo "  📧 Root Email: ${GITLAB_ROOT_EMAIL}"
echo "  👨‍💼 Root Name: ${GITLAB_ROOT_NAME}"
```

**Access information:**
```bash
echo "🌐 GitLab Web Interface:"
echo "  • URL: http://localhost:${GITLAB_HTTP_PORT}"
echo "  • Username: ${GITLAB_ROOT_USERNAME}"
echo "  • Password: ${GITLAB_ROOT_PASSWORD}"
echo "  • Email: ${GITLAB_ROOT_EMAIL}"
echo "  • Full Name: ${GITLAB_ROOT_NAME}"
```

---

## 🔐 5. BẢO MẬT VÀ BEST PRACTICES

### 5.1 Password Security

**Mật khẩu hiện tại:** `nextflow@2025`
- ✅ Đủ độ phức tạp cho development
- ✅ Dễ nhớ và nhập
- ✅ Consistent với các services khác

**Khuyến nghị cho production:**
```bash
# Thay đổi mật khẩu mạnh hơn
GITLAB_ROOT_PASSWORD=YourStrongPassword123!@#

# Hoặc generate random password
GITLAB_ROOT_PASSWORD=$(openssl rand -base64 32)
```

### 5.2 Email Configuration

**Email hiện tại:** `nextflow.vn@gmail.com`
- ✅ Email thực tế của dự án
- ✅ Có thể nhận notifications
- ✅ Consistent với SMTP configuration

### 5.3 Access Control

**Sau khi deploy:**
1. **Đăng nhập lần đầu** với tài khoản root
2. **Tạo user accounts** cho team members
3. **Thiết lập groups** và permissions
4. **Cấu hình SSH keys** cho secure access
5. **Enable 2FA** cho tài khoản quan trọng

---

## 📊 6. MONITORING VÀ VALIDATION

### 6.1 Kiểm tra tài khoản root

```bash
# Kiểm tra database user
./scripts/check-gitlab-database.sh

# Test deployment với root account
./scripts/test-gitlab-deployment.sh

# Validate configuration
./scripts/validate-gitlab-optimization.sh
```

### 6.2 Troubleshooting

**Nếu không thể đăng nhập:**

1. **Kiểm tra container status:**
   ```bash
   docker ps | grep gitlab
   docker logs gitlab --tail 50
   ```

2. **Reset root password:**
   ```bash
   docker exec -it gitlab gitlab-rails console
   # Trong Rails console:
   user = User.find_by(username: 'root')
   user.password = 'nextflow@2025'
   user.password_confirmation = 'nextflow@2025'
   user.save!
   ```

3. **Kiểm tra database:**
   ```bash
   docker exec postgres psql -U nextflow -d gitlabhq_production -c "SELECT username, email FROM users WHERE username = 'root';"
   ```

---

## 🚀 7. DEPLOYMENT WORKFLOW

### 7.1 Deploy GitLab với Root Account

```bash
# Deploy GitLab profile
./scripts/deploy.sh --profile gitlab

# Hoặc interactive mode
./scripts/deploy.sh
# Chọn option: GitLab
```

### 7.2 First Login Process

1. **Truy cập GitLab:** http://localhost:8088
2. **Đăng nhập với:**
   - Username: `root`
   - Password: `nextflow@2025`
3. **Thiết lập profile:**
   - Cập nhật thông tin cá nhân
   - Thiết lập SSH keys
   - Cấu hình notifications

### 7.3 Post-deployment Setup

```bash
# Tạo first project
curl -X POST "http://localhost:8088/api/v4/projects" \
  -H "Private-Token: YOUR_ACCESS_TOKEN" \
  -d "name=nextflow-demo&visibility=private"

# Clone project
git clone http://localhost:8088/root/nextflow-demo.git
```

---

## 📋 8. CHECKLIST

### 8.1 Pre-deployment

- [ ] Environment variables đã được set trong `.env`
- [ ] Docker containers đã sẵn sàng
- [ ] Port 8088, 2222, 5050 available
- [ ] PostgreSQL và Redis đang chạy

### 8.2 Post-deployment

- [ ] GitLab web interface accessible
- [ ] Root login thành công
- [ ] SSH access hoạt động
- [ ] Container Registry accessible
- [ ] Database tables đã được tạo
- [ ] Email configuration hoạt động

### 8.3 Security

- [ ] Đổi mật khẩu root (nếu cần)
- [ ] Thiết lập SSH keys
- [ ] Tạo user accounts cho team
- [ ] Cấu hình groups và permissions
- [ ] Enable 2FA cho admin accounts

---

## 🎯 9. KẾT LUẬN

### 9.1 Thành tựu đạt được

✅ **Root Account Configuration hoàn thành:**
- Environment variables standardized
- Secure password management
- Consistent email configuration
- Full integration với deployment scripts

✅ **Enhanced User Experience:**
- Clear account information display
- Comprehensive troubleshooting guides
- Automated validation scripts
- Detailed documentation

### 9.2 GitLab Root Account sẵn sàng

🚀 **Tài khoản root GitLab đã được cấu hình hoàn toàn:**
- **Username:** root
- **Password:** nextflow@2025
- **Email:** nextflow.vn@gmail.com
- **Full Name:** NextFlow Administrator
- **Access:** http://localhost:8088

**🎉 GitLab với tài khoản root đã sẵn sàng cho development và production!**

---

**📝 Lưu ý:** Tất cả thông tin tài khoản đã được tích hợp vào deployment scripts và có thể được thay đổi thông qua environment variables trong file `.env`.
