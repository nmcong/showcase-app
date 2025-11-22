#!/bin/bash

# ==========================================
# Script Deploy Tự Động
# ==========================================

set -e  # Dừng ngay khi có lỗi

echo "🚀 Bắt đầu deploy..."
echo ""

# Màu sắc cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hàm hiển thị
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Kiểm tra xem đã có thông tin VPS chưa
if [ ! -f ".deploy-config" ]; then
    echo "Chưa có file cấu hình. Hãy nhập thông tin VPS:"
    echo ""
    read -p "IP VPS: " VPS_IP
    read -p "SSH Username (mặc định: root): " SSH_USER
    SSH_USER=${SSH_USER:-root}
    read -p "SSH Port (mặc định: 22): " SSH_PORT
    SSH_PORT=${SSH_PORT:-22}
    read -p "Đường dẫn deploy trên VPS (mặc định: /var/www/frogs): " DEPLOY_PATH
    DEPLOY_PATH=${DEPLOY_PATH:-/var/www/frogs}
    
    # Lưu config
    cat > .deploy-config << EOF
VPS_IP=$VPS_IP
SSH_USER=$SSH_USER
SSH_PORT=$SSH_PORT
DEPLOY_PATH=$DEPLOY_PATH
EOF
    
    print_success "Đã lưu cấu hình vào file .deploy-config"
    echo ""
else
    # Load config
    source .deploy-config
    print_success "Đã load cấu hình từ .deploy-config"
    echo "  - VPS IP: $VPS_IP"
    echo "  - SSH User: $SSH_USER"
    echo "  - SSH Port: $SSH_PORT"
    echo "  - Deploy Path: $DEPLOY_PATH"
    echo ""
fi

# Hỏi xác nhận
read -p "Tiếp tục deploy? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Deploy bị hủy"
    exit 1
fi

# Kiểm tra kết nối SSH
echo ""
echo "📡 Kiểm tra kết nối SSH..."
if ssh -p $SSH_PORT -o ConnectTimeout=10 -o BatchMode=yes $SSH_USER@$VPS_IP exit 2>/dev/null; then
    print_success "Kết nối SSH thành công"
else
    print_error "Không thể kết nối SSH. Vui lòng kiểm tra:"
    echo "  - IP VPS có đúng không?"
    echo "  - SSH key đã được thêm vào VPS chưa?"
    echo "  - Firewall có chặn SSH không?"
    exit 1
fi

# Tạo thư mục trên VPS nếu chưa có
echo ""
echo "📁 Tạo thư mục deploy trên VPS..."
ssh -p $SSH_PORT $SSH_USER@$VPS_IP "mkdir -p $DEPLOY_PATH" 2>/dev/null || {
    print_warning "Không thể tạo thư mục. Có thể cần quyền sudo."
}

# Upload files
echo ""
echo "📤 Upload files lên VPS..."
rsync -avz --progress \
    --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.DS_Store' \
    --exclude '.deploy-config' \
    --exclude 'deploy.sh' \
    --exclude 'DEPLOYMENT_GUIDE.md' \
    -e "ssh -p $SSH_PORT" \
    ./ $SSH_USER@$VPS_IP:$DEPLOY_PATH/ || {
    print_error "Upload thất bại!"
    exit 1
}

print_success "Upload thành công!"

# Phân quyền
echo ""
echo "🔐 Phân quyền files..."
ssh -p $SSH_PORT $SSH_USER@$VPS_IP "
    sudo chown -R www-data:www-data $DEPLOY_PATH 2>/dev/null || chown -R $SSH_USER:$SSH_USER $DEPLOY_PATH
    sudo chmod -R 755 $DEPLOY_PATH
" && print_success "Phân quyền thành công" || print_warning "Không thể phân quyền (có thể cần chạy manual)"

# Reload Nginx
echo ""
echo "🔄 Reload Nginx..."
ssh -p $SSH_PORT $SSH_USER@$VPS_IP "
    sudo nginx -t && sudo systemctl reload nginx
" && print_success "Nginx đã được reload" || print_warning "Không thể reload Nginx (có thể chưa cài đặt)"

# Hoàn thành
echo ""
echo "============================================"
print_success "DEPLOY HOÀN TẤT! 🎉"
echo "============================================"
echo ""
echo "Truy cập website tại:"
echo "  → http://$VPS_IP"
echo ""
echo "Nếu đã cấu hình domain, truy cập:"
echo "  → http://yourdomain.com"
echo ""

