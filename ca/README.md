# SSL Certificates Management

## 📁 Cấu trúc thư mục

Thư mục này chứa SSL certificates cho các services của vibytes.tech, được tổ chức theo subdomain:

```
ca/
├── auth/                                    # Certificates cho auth.vibytes.tech (Keycloak)
│   ├── private_key_auth-vibytes-tech.txt   # Private key
│   ├── rootca_auth-vibytes-tech.txt        # Root CA certificate
│   ├── certificate_auth-vibytes-tech.txt   # Domain certificate (optional)
│   └── README.md                           # Documentation
├── showcase/                                # Certificates cho showcase.vibytes.tech (nếu khác)
│   └── ...
└── README.md                               # This file
```

## 🎯 Subdomain Directories

### `/auth/` - Keycloak Authentication (auth.vibytes.tech)

SSL certificates cho Keycloak authentication server.

**Setup command:**
```bash
./scripts/setup-ssl-keycloak.sh
```

**Chi tiết:** Xem [auth/README.md](auth/README.md)

### `/showcase/` - Main Application (showcase.vibytes.tech)

*(Tạo thư mục này nếu cần SSL riêng cho main app, hoặc dùng chung với auth nếu là wildcard certificate)*

## 🚀 Quick Start

### Setup SSL cho Keycloak (auth.vibytes.tech)

1. **Đặt certificates vào thư mục `auth/`:**
   ```bash
   # Copy certificates của bạn
   cp your-private-key.txt ca/auth/private_key_auth-vibytes-tech.txt
   cp your-rootca.txt ca/auth/rootca_auth-vibytes-tech.txt
   cp your-certificate.txt ca/auth/certificate_auth-vibytes-tech.txt  # Optional
   ```

2. **Chạy script setup:**
   ```bash
   ./scripts/setup-ssl-keycloak.sh
   ```

3. **Truy cập:**
   ```
   https://auth.vibytes.tech
   ```

### Yêu cầu

- ✅ File `.env` đã được cấu hình đúng
- ✅ Keycloak đã được cài đặt trên VPS
- ✅ Nginx đã được cài đặt và cấu hình cơ bản
- ✅ Certificates đã được đặt trong `ca/auth/`

## 🔄 Naming Conventions

Script hỗ trợ nhiều naming patterns. Chọn một trong các cách đặt tên:

### Recommended (với subdomain prefix):
```
ca/auth/private_key_auth-vibytes-tech.txt
ca/auth/rootca_auth-vibytes-tech.txt
ca/auth/certificate_auth-vibytes-tech.txt
```

### Alternative (domain only):
```
ca/auth/private_key_vibytes-tech.txt
ca/auth/rootca_vibytes-tech.txt
ca/auth/certificate_vibytes-tech.txt
```

### Simple (generic names):
```
ca/auth/private_key.txt
ca/auth/rootca.txt
ca/auth/certificate.txt
```

> 💡 Script sẽ tự động detect file nào tồn tại và sử dụng.

### Kiểm tra SSL

```bash
# Trên VPS
ssh root@103.82.20.169

# Check Nginx SSL config
sudo nginx -t
sudo systemctl status nginx

# View certificates
sudo ls -la /etc/nginx/ssl/
openssl x509 -in /etc/nginx/ssl/vibytes-tech-fullchain.crt -text -noout

# Test SSL connection
curl -I https://auth.vibytes.tech

# Detailed SSL test
openssl s_client -connect auth.vibytes.tech:443 -servername auth.vibytes.tech

# Check Keycloak logs
sudo journalctl -u keycloak -f
```

### Troubleshooting

#### Lỗi: Certificate verification failed
- Kiểm tra xem domain certificate có tồn tại không
- Verify CA chain đúng
- Check DNS đã trỏ đúng chưa

#### Lỗi: Nginx fails to start
```bash
# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test configuration
sudo nginx -t

# Restore backup
sudo cp /etc/nginx/sites-available/keycloak.backup /etc/nginx/sites-available/keycloak
sudo systemctl reload nginx
```

#### Lỗi: Keycloak không start
```bash
# Check Keycloak logs
sudo journalctl -u keycloak -n 100

# Restore config backup
sudo cp /opt/keycloak/conf/keycloak.conf.backup /opt/keycloak/conf/keycloak.conf

# Restart Keycloak
sudo systemctl restart keycloak
```

### SSL Certificate Renewal

Nếu certificate hết hạn, bạn cần:

1. Lấy certificate mới từ nhà cung cấp SSL
2. Thay thế files trong thư mục `ca/`
3. Chạy lại script: `./scripts/setup-ssl-keycloak.sh`

### Security Best Practices

- **Private key**: Không bao giờ commit file này lên Git (đã có trong .gitignore)
- **Backup**: Backup private key ở nơi an toàn
- **Permissions**: Private key phải có permission 600 (chỉ root read)
- **Monitoring**: Theo dõi ngày hết hạn certificate

### Cấu trúc SSL trên VPS

```
/etc/nginx/ssl/
├── vibytes-tech.key              # Private key (600)
├── vibytes-tech.crt              # Domain certificate (644)
├── vibytes-tech-ca.crt           # CA bundle (644)
└── vibytes-tech-fullchain.crt    # Full chain: domain cert + CA (644)
```

### Files tham khảo

- Script setup: `/scripts/setup-ssl-keycloak.sh`
- Nginx config: `/etc/nginx/sites-available/keycloak`
- Keycloak config: `/opt/keycloak/conf/keycloak.conf`

