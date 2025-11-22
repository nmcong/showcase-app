# Hướng Dẫn Cài Đặt Lên VPS

Hướng dẫn chi tiết để cài đặt Keycloak và Showcase App lên VPS (Virtual Private Server).

## Yêu Cầu

- VPS với Ubuntu 22.04 hoặc mới hơn
- Tối thiểu 2GB RAM, 2 CPU cores, 20GB disk
- Domain name (ví dụ: showcase.yourdomain.com)
- Root access hoặc sudo privileges

## Thông Tin Cần Chuẩn Bị

```
VPS_HOST: your-vps-ip-address hoặc domain
VPS_USER: root hoặc ubuntu
VPS_PASSWORD: your-password (hoặc SSH key)

DB_NAME: showcase_db
DB_USER: showcase_user
DB_PASSWORD: create-a-strong-password

KEYCLOAK_ADMIN: admin
KEYCLOAK_ADMIN_PASSWORD: create-a-strong-password

APP_DOMAIN: showcase.yourdomain.com
KEYCLOAK_DOMAIN: auth.yourdomain.com
```

## Bước 1: Kết Nối VPS

### Sử Dụng SSH Key (Khuyến nghị)

```bash
# Tạo SSH key trên máy local (nếu chưa có)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key lên VPS
ssh-copy-id -i ~/.ssh/id_rsa.pub VPS_USER@VPS_HOST

# Kết nối SSH
ssh VPS_USER@VPS_HOST
```

### Sử Dụng Password

```bash
# Kết nối với password
ssh VPS_USER@VPS_HOST
# Nhập password khi được hỏi
```

### Trên Windows

**Sử dụng PuTTY:**
1. Tải PuTTY: https://www.putty.org/
2. Mở PuTTY
3. Host Name: `VPS_HOST`
4. Port: `22`
5. Connection type: `SSH`
6. Click `Open`
7. Nhập username và password

**Sử dụng Windows Terminal/PowerShell:**
```powershell
ssh VPS_USER@VPS_HOST
```

## Bước 2: Cập Nhật Hệ Thống

```bash
# Cập nhật packages
sudo apt update && sudo apt upgrade -y

# Cài đặt các tools cần thiết
sudo apt install -y curl wget git build-essential ufw
```

## Bước 3: Cài Đặt Node.js

```bash
# Cài đặt Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Kiểm tra version
node --version  # Phải >= v20.0.0
npm --version
```

## Bước 4: Cài Đặt PostgreSQL

```bash
# Cài đặt PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Khởi động PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Kiểm tra status
sudo systemctl status postgresql
```

### Cấu Hình Database

```bash
# Đăng nhập PostgreSQL
sudo -u postgres psql

# Trong PostgreSQL console, chạy các lệnh sau:
```

```sql
-- Tạo user
CREATE USER showcase_user WITH PASSWORD 'your-strong-password-here';

-- Tạo database
CREATE DATABASE showcase_db;

-- Cấp quyền
GRANT ALL PRIVILEGES ON DATABASE showcase_db TO showcase_user;

-- Thoát
\q
```

### Test Kết Nối Database

```bash
# Test connection
psql -h localhost -U showcase_user -d showcase_db
# Nhập password khi được hỏi
# Nếu kết nối thành công, gõ \q để thoát
```

## Bước 5: Cài Đặt Keycloak

### Option A: Cài Đặt Keycloak Standalone

```bash
# Tạo thư mục cho Keycloak
sudo mkdir -p /opt/keycloak
cd /opt/keycloak

# Tải Keycloak (version 26.4.5 - Latest)
sudo wget https://github.com/keycloak/keycloak/releases/download/26.4.5/keycloak-26.4.5.tar.gz

# Giải nén
sudo tar -xzf keycloak-26.4.5.tar.gz
sudo mv keycloak-26.4.5 keycloak

# Tạo user cho Keycloak
sudo useradd -r -s /bin/false keycloak
sudo chown -R keycloak:keycloak /opt/keycloak
```

### Cấu Hình Keycloak với PostgreSQL

```bash
# Tạo database cho Keycloak
sudo -u postgres psql
```

```sql
CREATE DATABASE keycloak_db;
CREATE USER keycloak_user WITH PASSWORD 'keycloak-strong-password';
GRANT ALL PRIVILEGES ON DATABASE keycloak_db TO keycloak_user;
\q
```

```bash
# Cấu hình Keycloak
sudo nano /opt/keycloak/keycloak/conf/keycloak.conf
```

Thêm nội dung:

```conf
# Database
db=postgres
db-username=keycloak_user
db-password=keycloak-strong-password
db-url=jdbc:postgresql://localhost:5432/keycloak_db

# HTTP
http-enabled=true
http-port=8080
http-host=0.0.0.0
hostname=auth.yourdomain.com
hostname-strict=false
hostname-strict-https=false

# Proxy
proxy=edge
proxy-headers=xforwarded

# Admin
https-port=8443

# Performance (optional)
cache=ispn
cache-stack=tcp

### Tạo Systemd Service cho Keycloak

```bash
sudo nano /etc/systemd/system/keycloak.service
```

Thêm nội dung:

```ini
[Unit]
Description=Keycloak Identity and Access Management
After=network.target postgresql.service

[Service]
Type=exec
User=keycloak
Group=keycloak
Environment="KEYCLOAK_ADMIN=admin"
Environment="KEYCLOAK_ADMIN_PASSWORD=your-admin-password"
ExecStart=/opt/keycloak/keycloak/bin/kc.sh start \
    --optimized \
    --http-enabled=true \
    --http-port=8080 \
    --http-host=0.0.0.0 \
    --hostname=auth.yourdomain.com \
    --hostname-strict=false \
    --proxy=edge
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### Khởi Động Keycloak

```bash
# Set environment variables cho build
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=your-admin-password

# Build Keycloak configuration
cd /opt/keycloak/keycloak
sudo -u keycloak -E bin/kc.sh build

# Enable và start service
sudo systemctl daemon-reload
sudo systemctl enable keycloak
sudo systemctl start keycloak

# Đợi Keycloak khởi động (khoảng 60 giây cho lần đầu)
echo "Waiting for Keycloak to start..."
sleep 60

# Kiểm tra status
sudo systemctl status keycloak

# Xem logs nếu có lỗi
sudo journalctl -u keycloak -n 100 --no-pager

# Theo dõi logs realtime
sudo journalctl -u keycloak -f
```

### Option B: Cài Đặt Keycloak với Docker (Đơn giản hơn)

```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Cài đặt Docker Compose
sudo apt install -y docker-compose

# Tạo thư mục cho Keycloak
mkdir -p ~/keycloak
cd ~/keycloak

# Tạo docker-compose.yml
nano docker-compose.yml
```

Thêm nội dung:

```yaml
version: '3.8'

services:
  keycloak-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak-db-password
    volumes:
      - keycloak-db-data:/var/lib/postgresql/data
    networks:
      - keycloak-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U keycloak"]
      interval: 10s
      timeout: 5s
      retries: 5

  keycloak:
    image: quay.io/keycloak/keycloak:26.4.5
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak-db-password
      KC_DB_SCHEMA: public
      KC_HOSTNAME: auth.yourdomain.com
      KC_HOSTNAME_STRICT: false
      KC_HOSTNAME_STRICT_HTTPS: false
      KC_HTTP_ENABLED: true
      KC_HTTP_HOST: 0.0.0.0
      KC_HTTP_PORT: 8080
      KC_PROXY: edge
      KC_PROXY_HEADERS: xforwarded
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: your-admin-password
      KC_HEALTH_ENABLED: true
      KC_METRICS_ENABLED: true
      KC_LOG_LEVEL: info
    ports:
      - "8080:8080"
    depends_on:
      keycloak-db:
        condition: service_healthy
    command: 
      - start
      - --optimized
    networks:
      - keycloak-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "exec 3<>/dev/tcp/127.0.0.1/8080 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 90s

volumes:
  keycloak-db-data:

networks:
  keycloak-network:
```

```bash
# Khởi động Keycloak
docker-compose up -d

# Xem logs
docker-compose logs -f keycloak

# Kiểm tra containers
docker-compose ps

# Kiểm tra health
docker-compose ps keycloak
# Đợi cho đến khi status là "healthy" (có thể mất 1-2 phút)

# Test Keycloak endpoint
curl -s http://localhost:8080/health/ready | jq
```

## Bước 6: Cài Đặt Showcase App

```bash
# Tạo thư mục cho app
sudo mkdir -p /var/www/showcase-app
cd /var/www/showcase-app

# Clone repository
sudo git clone <your-repo-url> .

# Hoặc upload code từ máy local
# rsync -avz -e ssh /path/to/local/showcase-app/ VPS_USER@VPS_HOST:/var/www/showcase-app/
```

### Cấu Hình Environment Variables

```bash
# Tạo .env.local
sudo nano .env.local
```

Thêm nội dung:

```env
# Database
DATABASE_URL="postgresql://showcase_user:your-db-password@localhost:5432/showcase_db?schema=public"

# Keycloak
NEXT_PUBLIC_KEYCLOAK_URL="https://auth.yourdomain.com"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="get-from-keycloak-later"

# Application
NEXT_PUBLIC_APP_URL="https://showcase.yourdomain.com"
NODE_ENV="production"
```

### Cài Đặt Dependencies và Build

```bash
# Cài đặt packages
sudo npm install

# Generate Prisma Client
sudo npx prisma generate

# Run migrations
sudo npx prisma migrate deploy

# Seed database (optional)
sudo npm run db:seed

# Build application
sudo npm run build

# Test build
sudo npm start
# Nếu chạy OK, nhấn Ctrl+C để dừng
```

## Bước 7: Cài Đặt PM2 (Process Manager)

```bash
# Cài đặt PM2
sudo npm install -g pm2

# Khởi động app với PM2
cd /var/www/showcase-app
pm2 start npm --name "showcase-app" -- start

# Lưu PM2 process list
pm2 save

# Cấu hình PM2 khởi động cùng hệ thống
pm2 startup
# Copy và chạy lệnh được hiển thị

# Kiểm tra status
pm2 status
pm2 logs showcase-app

# Một số lệnh PM2 hữu ích:
# pm2 restart showcase-app  # Restart app
# pm2 stop showcase-app     # Stop app
# pm2 delete showcase-app   # Delete app
# pm2 monit                 # Monitor app
```

## Bước 8: Cài Đặt Nginx

```bash
# Cài đặt Nginx
sudo apt install -y nginx

# Khởi động Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Cấu Hình Nginx cho Showcase App

```bash
# Tạo config file
sudo nano /etc/nginx/sites-available/showcase-app
```

Thêm nội dung:

```nginx
# Showcase App
server {
    listen 80;
    server_name showcase.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Increase upload size for 3D models
    client_max_body_size 100M;
}
```

### Cấu Hình Nginx cho Keycloak

```bash
sudo nano /etc/nginx/sites-available/keycloak
```

Thêm nội dung:

```nginx
# Keycloak
server {
    listen 80;
    server_name auth.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_cache_bypass $http_upgrade;
        
        # Buffer settings for Keycloak
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

### Enable Sites

```bash
# Enable sites
sudo ln -s /etc/nginx/sites-available/showcase-app /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## Bước 9: Cấu Hình SSL với Let's Encrypt

```bash
# Cài đặt Certbot
sudo apt install -y certbot python3-certbot-nginx

# Lấy SSL certificate cho Showcase App
sudo certbot --nginx -d showcase.yourdomain.com

# Lấy SSL certificate cho Keycloak
sudo certbot --nginx -d auth.yourdomain.com

# Certbot sẽ tự động cấu hình Nginx với HTTPS
```

### Cấu Hình Auto-renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Certbot tự động cài đặt cron job để renew
# Kiểm tra cron job
sudo systemctl status certbot.timer
```

## Bước 10: Cấu Hình Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (QUAN TRỌNG - làm trước khi enable UFW!)
sudo ufw allow 22/tcp

# Allow HTTP và HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Kiểm tra status
sudo ufw status verbose

# Nếu cần allow port khác:
# sudo ufw allow 8080/tcp  # Keycloak (nếu không dùng Nginx)
# sudo ufw allow 3000/tcp  # Next.js (nếu không dùng Nginx)
```

## Bước 11: Cấu Hình Keycloak

### Truy Cập Keycloak Admin Console

```
1. Mở browser: https://auth.yourdomain.com
2. Click "Administration Console"
3. Login:
   - Username: admin
   - Password: your-admin-password
```

### Tạo Realm

```
1. Click dropdown ở góc trên bên trái (Master)
2. Click "Create Realm"
3. Name: showcase-realm
4. Click "Create"
```

### Tạo Client

```
1. Trong showcase-realm, click "Clients" (sidebar)
2. Click "Create client"
3. Client ID: showcase-client
4. Click "Next"
5. Enable:
   - Standard flow: ON
   - Direct access grants: ON
6. Click "Next"
7. Configure:
   - Valid redirect URIs: https://showcase.yourdomain.com/*
   - Valid post logout redirect URIs: https://showcase.yourdomain.com/*
   - Web origins: https://showcase.yourdomain.com
8. Click "Save"
```

### Lấy Client Secret (nếu cần)

```
1. Vào client vừa tạo
2. Tab "Credentials"
3. Copy "Client Secret"
4. Update vào .env.local trên VPS
```

### Tạo Realm Roles

```
1. Click "Realm roles" (sidebar)
2. Click "Create role"
3. Name: admin
4. Description: Administrator role
5. Click "Save"

6. Tạo role khác:
   - Name: user
   - Description: Regular user
   - Click "Save"
```

### Tạo Admin User

```
1. Click "Users" (sidebar)
2. Click "Add user"
3. Fill:
   - Username: testadmin
   - Email: admin@yourdomain.com
   - First name: Admin
   - Last name: User
   - Email verified: ON
4. Click "Create"

5. Set password:
   - Tab "Credentials"
   - Click "Set password"
   - Password: create-strong-password
   - Temporary: OFF
   - Click "Save"

6. Assign admin role:
   - Tab "Role mapping"
   - Click "Assign role"
   - Filter: "Filter by realm roles"
   - Select "admin"
   - Click "Assign"
```

## Bước 12: Update Environment Variables

```bash
# Update .env.local với thông tin Keycloak đầy đủ
cd /var/www/showcase-app
sudo nano .env.local
```

Cập nhật:

```env
DATABASE_URL="postgresql://showcase_user:your-db-password@localhost:5432/showcase_db?schema=public"

NEXT_PUBLIC_KEYCLOAK_URL="https://auth.yourdomain.com"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-client-secret-from-keycloak"

NEXT_PUBLIC_APP_URL="https://showcase.yourdomain.com"
NODE_ENV="production"
```

```bash
# Restart app
pm2 restart showcase-app

# Check logs
pm2 logs showcase-app
```

## Bước 13: Kiểm Tra Hệ Thống

### Test Showcase App

```
1. Mở browser: https://showcase.yourdomain.com
2. Kiểm tra:
   - Page load OK
   - Models hiển thị
   - Filters hoạt động
   - 3D viewer chạy OK
```

### Test Authentication

```
1. Click "Login"
2. Redirect đến Keycloak
3. Login với testadmin/password
4. Redirect về app
5. Kiểm tra "Admin Panel" button hiển thị
6. Click vào Admin Panel
7. Tạo một model test
```

### Test Comment

```
1. Vào chi tiết một model
2. Submit comment
3. Vào Admin Panel > Comments
4. Approve comment
5. Check comment hiển thị
```

## Bước 14: Backup và Monitoring

### Cấu Hình Backup Database

```bash
# Tạo script backup
sudo nano /usr/local/bin/backup-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/showcase"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup showcase database
pg_dump -U showcase_user showcase_db | gzip > $BACKUP_DIR/showcase_db_$DATE.sql.gz

# Backup keycloak database
pg_dump -U keycloak_user keycloak_db | gzip > $BACKUP_DIR/keycloak_db_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/backup-db.sh

# Test backup
sudo /usr/local/bin/backup-db.sh

# Add to crontab (chạy mỗi ngày lúc 2 AM)
sudo crontab -e
```

Thêm dòng:

```
0 2 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

### Monitoring với PM2

```bash
# Install PM2 monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# View monitoring
pm2 monit
```

## Bước 15: Maintenance Scripts

### Update Application

```bash
# Tạo update script
sudo nano /var/www/showcase-app/update.sh
```

```bash
#!/bin/bash
cd /var/www/showcase-app

echo "Pulling latest code..."
git pull

echo "Installing dependencies..."
npm install

echo "Running migrations..."
npx prisma migrate deploy

echo "Building application..."
npm run build

echo "Restarting application..."
pm2 restart showcase-app

echo "Update completed!"
pm2 logs showcase-app --lines 50
```

```bash
sudo chmod +x /var/www/showcase-app/update.sh

# Sử dụng:
# cd /var/www/showcase-app
# ./update.sh
```

## Troubleshooting

### Kiểm Tra Logs

```bash
# App logs
pm2 logs showcase-app

# Keycloak logs (standalone)
sudo journalctl -u keycloak -f

# Keycloak logs (Docker)
cd ~/keycloak
docker-compose logs -f keycloak

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# System logs
sudo journalctl -xe
```

### Lỗi Database Connection

```bash
# Kiểm tra PostgreSQL
sudo systemctl status postgresql

# Kiểm tra kết nối
psql -h localhost -U showcase_user -d showcase_db

# Xem connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

### Lỗi Permission

```bash
# Fix ownership
sudo chown -R $USER:$USER /var/www/showcase-app

# Fix permissions
sudo chmod -R 755 /var/www/showcase-app
```

### App Không Start

```bash
# Kiểm tra port
sudo netstat -tulpn | grep :3000

# Kill process nếu cần
sudo kill -9 $(sudo lsof -t -i:3000)

# Restart PM2
pm2 restart showcase-app
```

## Bảo Mật Bổ Sung

### Thay Đổi SSH Port

```bash
sudo nano /etc/ssh/sshd_config
# Thay đổi Port 22 thành Port 2222

sudo systemctl restart sshd
sudo ufw allow 2222/tcp
```

### Disable Root Login

```bash
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no

sudo systemctl restart sshd
```

### Install Fail2Ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Thông Tin Truy Cập

Sau khi hoàn thành, bạn có thể truy cập:

```
Showcase App: https://showcase.yourdomain.com
Keycloak Admin: https://auth.yourdomain.com
PM2 Monitor: pm2 monit (on VPS)
Database: psql -h localhost -U showcase_user -d showcase_db

SSH: ssh VPS_USER@VPS_HOST
```

## Lưu Ý Quan Trọng

1. **Thay đổi tất cả passwords mặc định**
2. **Backup thường xuyên**
3. **Update system và packages định kỳ**
4. **Monitor logs và resources**
5. **Cấu hình firewall đúng cách**
6. **Sử dụng SSL/HTTPS cho mọi connections**

## Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra logs
2. Verify configurations
3. Test từng service riêng lẻ
4. Google error messages
5. Check GitHub issues

Chúc bạn deploy thành công! 🚀

