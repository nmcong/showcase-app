#!/bin/bash

# ==========================================
# Script Cài Đặt VPS Tự Động
# Chạy script này TRÊN VPS
# ==========================================

set -e

echo "=========================================="
echo "  Script Cài Đặt VPS cho Frogs Project"
echo "=========================================="
echo ""

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then 
    print_error "Vui lòng chạy script với quyền root (sudo)"
    exit 1
fi

print_info "Bắt đầu cài đặt..."
echo ""

# 1. Update hệ thống
echo "1️⃣  Cập nhật hệ thống..."
apt update -qq
apt upgrade -y -qq
print_success "Đã cập nhật hệ thống"
echo ""

# 2. Cài đặt các packages cần thiết
echo "2️⃣  Cài đặt các packages cơ bản..."
apt install -y -qq curl wget git unzip nginx certbot python3-certbot-nginx
print_success "Đã cài đặt packages"
echo ""

# 3. Cấu hình Firewall
echo "3️⃣  Cấu hình Firewall..."
ufw --force enable
ufw allow OpenSSH
ufw allow 'Nginx Full'
print_success "Đã cấu hình firewall"
echo ""

# 4. Khởi động Nginx
echo "4️⃣  Khởi động Nginx..."
systemctl start nginx
systemctl enable nginx
print_success "Nginx đã được khởi động"
echo ""

# 5. Tạo thư mục cho website
echo "5️⃣  Tạo thư mục website..."
mkdir -p /var/www/frogs
chown -R www-data:www-data /var/www/frogs
chmod -R 755 /var/www/frogs
print_success "Đã tạo thư mục /var/www/frogs"
echo ""

# 6. Hỏi thông tin domain
echo "6️⃣  Cấu hình Nginx..."
read -p "Bạn có domain không? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Nhập domain của bạn (vd: frogs.noteflix.tech): " DOMAIN
    DOMAIN=${DOMAIN:-frogs.noteflix.tech}
    
    read -p "Có subdomain www không? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        SERVER_NAME="$DOMAIN www.$DOMAIN"
    else
        SERVER_NAME="$DOMAIN"
    fi
    
    # Tạo Nginx config với domain
    cat > /etc/nginx/sites-available/frogs << EOF
server {
    listen 80;
    listen [::]:80;
    
    server_name $SERVER_NAME;
    
    root /var/www/frogs;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF
    print_success "Đã tạo Nginx config với domain: $DOMAIN"
    
    # Hỏi về SSL
    echo ""
    echo "⚠️  Lưu ý: Trước khi cài SSL, đảm bảo DNS đã trỏ về VPS này!"
    echo "   Kiểm tra: ping $DOMAIN"
    echo ""
    read -p "Bạn có muốn cài SSL (HTTPS) ngay bây giờ không? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Nhập email của bạn: " EMAIL
        
        echo "🔐 Đang cài đặt SSL..."
        certbot --nginx -d $DOMAIN $(if [[ $SERVER_NAME == *"www"* ]]; then echo "-d www.$DOMAIN"; fi) --non-interactive --agree-tos -m $EMAIL
        
        print_success "Đã cài SSL thành công!"
    else
        print_warning "Bạn có thể cài SSL sau bằng lệnh:"
        echo "  sudo certbot --nginx -d $DOMAIN"
    fi
else
    # Lấy IP của VPS
    SERVER_IP=$(curl -s ifconfig.me)
    
    # Tạo Nginx config với IP
    cat > /etc/nginx/sites-available/frogs << EOF
server {
    listen 80;
    listen [::]:80;
    
    server_name $SERVER_IP;
    
    root /var/www/frogs;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF
    print_success "Đã tạo Nginx config với IP: $SERVER_IP"
fi

# 7. Kích hoạt site
echo ""
echo "7️⃣  Kích hoạt website..."
ln -sf /etc/nginx/sites-available/frogs /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
print_success "Website đã được kích hoạt"
echo ""

# Hoàn thành
echo "============================================"
print_success "CÀI ĐẶT HOÀN TẤT! 🎉"
echo "============================================"
echo ""
echo "Các bước tiếp theo:"
echo ""
echo "1. Upload code lên VPS:"
echo "   - Dùng git clone"
echo "   - Hoặc dùng scp/rsync từ máy local"
echo "   - Hoặc chạy script deploy.sh từ máy local"
echo ""
echo "2. Files cần upload vào: /var/www/frogs"
echo ""

if [[ -n "$DOMAIN" ]]; then
    echo "3. Truy cập website tại: http://$DOMAIN"
    if command -v certbot &> /dev/null && certbot certificates 2>/dev/null | grep -q "$DOMAIN"; then
        echo "   hoặc https://$DOMAIN (đã có SSL)"
    fi
else
    echo "3. Truy cập website tại: http://$SERVER_IP"
fi

echo ""
print_info "Tham khảo file DEPLOYMENT_GUIDE.md để biết thêm chi tiết"
echo ""

