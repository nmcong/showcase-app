# 📚 Tài Liệu Dự Án - 3D Models Showcase

Chào mừng đến với tài liệu dự án 3D Models Showcase. Tất cả tài liệu đã được tổ chức theo thứ tự logic từ cơ bản đến nâng cao.

## 📖 Hướng Dẫn Đọc

### 🚀 Bắt Đầu (Getting Started)

#### 00. [Environment Files Guide](./00-ENV-FILES-GUIDE.md)
- Hiểu về `.env.local` vs `.env.deploy`
- Cấu hình môi trường development và production
- **Đọc đầu tiên để hiểu cấu trúc config**

#### 01. [Quick Start](./01-QUICKSTART.md) ⭐
- Hướng dẫn cài đặt và chạy trong 5 phút
- Thiết lập local development
- **Bắt đầu từ đây nếu là lần đầu**

#### 02. [No Docker Deployment Strategy](./02-NO_DOCKER_DEPLOYMENT.md)
- Tại sao không dùng Docker cho VPS 4GB RAM
- Kiến trúc deployment tối ưu
- Memory optimization
- **Quan trọng để hiểu chiến lược deployment**

---

### 🔧 Deployment (Triển Khai)

#### 03. [VPS Deployment Guide](./03-VPS_DEPLOYMENT_GUIDE.md)
- Hướng dẫn chi tiết deploy manual từng bước
- Setup VPS Ubuntu từ đầu
- Troubleshooting deployment
- **Đọc nếu muốn hiểu chi tiết từng bước**

#### 04. [Deployment Scripts Reference](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md)
- Automated deployment scripts
- One-command deployment
- Scripts usage và configuration
- **Đọc để deploy tự động**

#### 05. [Complete Deployment Guide](./05-DEPLOYMENT-COMPLETE-GUIDE.md) ⭐
- Tổng hợp đầy đủ nhất về deployment
- Tích hợp tất cả các fixes
- Best practices và optimization
- **Hướng dẫn chính thức cho production deployment**

---

### 🔐 Authentication (Xác Thực)

#### 06. [Keycloak Setup](./06-KEYCLOAK_SETUP.md)
- Cài đặt và cấu hình Keycloak cơ bản
- Tạo realm và client
- User management
- **Bắt đầu với Keycloak tại đây**

#### 07. [Keycloak 26 Migration](./07-KEYCLOAK_26_MIGRATION.md)
- Chi tiết về Keycloak 26.4.5
- Migration từ version cũ
- Advanced configuration
- Performance tuning

---

### 🔒 SSL & Security

#### 08. [SSL Keycloak Setup](./08-SSL_KEYCLOAK_SETUP.md)
- Cài đặt SSL cho Keycloak
- HTTPS configuration
- Certificate management

#### 09. [SSL Certificates Guide](./09-SSL-CERTIFICATES-GUIDE.md)
- Quản lý SSL certificates
- Cấu trúc thư mục `ca/`
- Certificate renewal

#### 10. [SSL Auth Setup](./10-SSL-AUTH-SETUP.md)
- Chi tiết về SSL cho auth.vibytes.tech
- Certificate verification
- Troubleshooting SSL

---

### 🎨 Content & Resources

#### 11. [3D Models Guide](./11-3D_MODELS_GUIDE.md)
- Chuẩn bị và tối ưu 3D models
- GLB/GLTF formats
- Model optimization
- Best practices
- **Đọc khi làm việc với 3D models**

#### 12. [Version Compatibility](./12-VERSION_COMPATIBILITY.md)
- Keycloak versions (server vs client)
- Dependencies versions
- Compatibility matrix
- Update guidelines

---

### 🐛 Maintenance & Support

#### 13. [Troubleshooting Guide](./13-TROUBLESHOOTING.md)
- Common errors và solutions
- Debugging techniques
- Performance issues
- **Đọc khi gặp lỗi**

#### 14. [Changelog](./14-CHANGELOG.md)
- Version history
- New features
- Breaking changes
- Migration guides

#### 15. [Updates Summary](./15-UPDATES_SUMMARY.md)
- Recent updates
- Latest improvements
- Quick reference

---

## 🎯 Đọc Theo Mục Đích

### Tôi muốn...

**...bắt đầu local development**
1. → [00-ENV-FILES-GUIDE.md](./00-ENV-FILES-GUIDE.md)
2. → [01-QUICKSTART.md](./01-QUICKSTART.md)

**...deploy lên VPS (tự động - recommended)**
1. → [00-ENV-FILES-GUIDE.md](./00-ENV-FILES-GUIDE.md)
2. → [02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md)
3. → [04-DEPLOYMENT-SCRIPTS-REFERENCE.md](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md)
4. → [05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md)

**...deploy lên VPS (manual chi tiết)**
1. → [03-VPS_DEPLOYMENT_GUIDE.md](./03-VPS_DEPLOYMENT_GUIDE.md)
2. → [05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md)

**...setup Keycloak authentication**
1. → [06-KEYCLOAK_SETUP.md](./06-KEYCLOAK_SETUP.md)
2. → [07-KEYCLOAK_26_MIGRATION.md](./07-KEYCLOAK_26_MIGRATION.md) (nâng cao)

**...setup SSL/HTTPS**
1. → [08-SSL_KEYCLOAK_SETUP.md](./08-SSL_KEYCLOAK_SETUP.md)
2. → [09-SSL-CERTIFICATES-GUIDE.md](./09-SSL-CERTIFICATES-GUIDE.md)

**...làm việc với 3D models**
→ [11-3D_MODELS_GUIDE.md](./11-3D_MODELS_GUIDE.md)

**...troubleshoot lỗi**
→ [13-TROUBLESHOOTING.md](./13-TROUBLESHOOTING.md)

---

## 📂 Cấu Trúc Tài Liệu

```
docs/
├── 00-ENV-FILES-GUIDE.md                  # ⚙️  Environment configuration
├── 01-QUICKSTART.md                       # ⭐ Quick start guide
├── 02-NO_DOCKER_DEPLOYMENT.md            # 📦 Deployment strategy
│
├── 03-VPS_DEPLOYMENT_GUIDE.md            # 🔧 Manual deployment
├── 04-DEPLOYMENT-SCRIPTS-REFERENCE.md    # 🤖 Automated deployment
├── 05-DEPLOYMENT-COMPLETE-GUIDE.md       # ⭐ Complete deployment guide
│
├── 06-KEYCLOAK_SETUP.md                  # 🔐 Keycloak basics
├── 07-KEYCLOAK_26_MIGRATION.md           # 🔄 Keycloak advanced
│
├── 08-SSL_KEYCLOAK_SETUP.md              # 🔒 SSL setup
├── 09-SSL-CERTIFICATES-GUIDE.md          # 📜 SSL certificates
├── 10-SSL-AUTH-SETUP.md                  # 🔐 SSL auth details
│
├── 11-3D_MODELS_GUIDE.md                 # 🎨 3D models
├── 12-VERSION_COMPATIBILITY.md           # 📊 Versions
│
├── 13-TROUBLESHOOTING.md                 # 🐛 Troubleshooting
├── 14-CHANGELOG.md                       # 📝 Version history
├── 15-UPDATES_SUMMARY.md                 # 🔄 Recent updates
│
└── README.md                             # 📚 This file
```

---

## 🎓 Learning Path

### 👶 Beginner (Mới bắt đầu)
1. Đọc [00-ENV-FILES-GUIDE.md](./00-ENV-FILES-GUIDE.md)
2. Đọc [01-QUICKSTART.md](./01-QUICKSTART.md)
3. Chạy `npm run dev` locally
4. Khám phá ứng dụng

### 🏃 Intermediate (Sẵn sàng deploy)
1. Đọc [02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md)
2. Đọc [04-DEPLOYMENT-SCRIPTS-REFERENCE.md](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md)
3. Setup `.env.deploy`
4. Chạy deployment scripts
5. Đọc [05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md)

### 🚀 Advanced (Hiểu sâu hệ thống)
1. Đọc [03-VPS_DEPLOYMENT_GUIDE.md](./03-VPS_DEPLOYMENT_GUIDE.md)
2. Đọc [07-KEYCLOAK_26_MIGRATION.md](./07-KEYCLOAK_26_MIGRATION.md)
3. Setup SSL với [08-SSL_KEYCLOAK_SETUP.md](./08-SSL_KEYCLOAK_SETUP.md)
4. Optimize performance
5. Custom configurations

---

## 💡 Tips

### Cho Developers
- Bắt đầu với local development ([01-QUICKSTART.md](./01-QUICKSTART.md))
- Hiểu kiến trúc ([02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md))
- Dùng automated scripts ([04-DEPLOYMENT-SCRIPTS-REFERENCE.md](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md))

### Cho DevOps Engineers
- Đọc deployment strategy ([02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md))
- Sử dụng automation ([04-DEPLOYMENT-SCRIPTS-REFERENCE.md](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md))
- Tham khảo manual guide ([03-VPS_DEPLOYMENT_GUIDE.md](./03-VPS_DEPLOYMENT_GUIDE.md))
- Master guide ([05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md))

### Cho Designers/Content Creators
- Focus vào 3D models ([11-3D_MODELS_GUIDE.md](./11-3D_MODELS_GUIDE.md))
- Học về formats và optimization

---

## 🔍 Tìm Kiếm Theo Topic

### Environment & Configuration
- [00-ENV-FILES-GUIDE.md](./00-ENV-FILES-GUIDE.md)
- [12-VERSION_COMPATIBILITY.md](./12-VERSION_COMPATIBILITY.md)

### Getting Started
- [01-QUICKSTART.md](./01-QUICKSTART.md)

### Deployment
- [02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md)
- [03-VPS_DEPLOYMENT_GUIDE.md](./03-VPS_DEPLOYMENT_GUIDE.md)
- [04-DEPLOYMENT-SCRIPTS-REFERENCE.md](./04-DEPLOYMENT-SCRIPTS-REFERENCE.md)
- [05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md)

### Authentication
- [06-KEYCLOAK_SETUP.md](./06-KEYCLOAK_SETUP.md)
- [07-KEYCLOAK_26_MIGRATION.md](./07-KEYCLOAK_26_MIGRATION.md)

### Security & SSL
- [08-SSL_KEYCLOAK_SETUP.md](./08-SSL_KEYCLOAK_SETUP.md)
- [09-SSL-CERTIFICATES-GUIDE.md](./09-SSL-CERTIFICATES-GUIDE.md)
- [10-SSL-AUTH-SETUP.md](./10-SSL-AUTH-SETUP.md)

### Content & Resources
- [11-3D_MODELS_GUIDE.md](./11-3D_MODELS_GUIDE.md)

### Maintenance
- [13-TROUBLESHOOTING.md](./13-TROUBLESHOOTING.md)
- [14-CHANGELOG.md](./14-CHANGELOG.md)
- [15-UPDATES_SUMMARY.md](./15-UPDATES_SUMMARY.md)

---

## 📞 Hỗ Trợ

### Khi Gặp Vấn Đề

1. **Kiểm tra troubleshooting guide:**
   → [13-TROUBLESHOOTING.md](./13-TROUBLESHOOTING.md)

2. **Search trong tài liệu liên quan:**
   - Deployment issues → [05-DEPLOYMENT-COMPLETE-GUIDE.md](./05-DEPLOYMENT-COMPLETE-GUIDE.md)
   - Keycloak issues → [06-KEYCLOAK_SETUP.md](./06-KEYCLOAK_SETUP.md)
   - SSL issues → [08-SSL_KEYCLOAK_SETUP.md](./08-SSL_KEYCLOAK_SETUP.md)

3. **Check version compatibility:**
   → [12-VERSION_COMPATIBILITY.md](./12-VERSION_COMPATIBILITY.md)

4. **Open an issue trên GitHub**

---

## 🔄 Cập Nhật

- **Latest changes:** [15-UPDATES_SUMMARY.md](./15-UPDATES_SUMMARY.md)
- **Version history:** [14-CHANGELOG.md](./14-CHANGELOG.md)
- **Compatibility:** [12-VERSION_COMPATIBILITY.md](./12-VERSION_COMPATIBILITY.md)

---

## 📊 Thống Kê Tài Liệu

- **Tổng số tài liệu:** 16 files
- **Phân loại:**
  - Getting Started: 3 docs
  - Deployment: 3 docs
  - Authentication: 2 docs
  - SSL/Security: 3 docs
  - Content: 1 doc
  - Reference: 1 doc
  - Maintenance: 3 docs

---

**Phiên bản tài liệu:** 2.0.0  
**Cập nhật lần cuối:** November 22, 2025  
**Tương thích với:** Next.js 16, Keycloak 26.4.5, PostgreSQL 16, Node.js 20+

**Happy Learning! 📚✨**
