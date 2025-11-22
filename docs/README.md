# 📚 Documentation Index

Tài liệu đã được tổ chức theo thứ tự ưu tiên đọc từ cơ bản đến nâng cao.

## 📖 Thứ Tự Đọc Khuyến Nghị

### 🚀 Bắt Đầu Nhanh (Must Read)

#### 1. [Quick Start Guide](./01-QUICKSTART.md) ⭐
- Cài đặt và chạy trong 5 phút
- Hướng dẫn cơ bản nhất
- **Đọc đầu tiên!**

#### 2. [No Docker Deployment](./02-NO_DOCKER_DEPLOYMENT.md) ⭐
- Tại sao không dùng Docker?
- Memory optimization cho 4GB RAM
- Architecture overview
- **Quan trọng để hiểu deployment strategy**

#### 3. [Deployment Scripts Summary](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md) ⭐
- Tổng quan về automated deployment scripts
- One-command deployment
- Environment configuration
- **Đọc trước khi deploy lên VPS**

### 🔧 Deployment (Choose Your Method)

#### 4. [VPS Deployment Guide](./04-VPS_DEPLOYMENT_GUIDE.md)
- Hướng dẫn chi tiết deploy lên VPS
- Manual step-by-step
- Troubleshooting
- **Đọc nếu muốn hiểu từng bước chi tiết**

#### Hoặc: [Automated Scripts](../scripts/README.md)
- One-command deployment
- Sử dụng scripts tự động
- **Đọc nếu muốn deploy nhanh**

#### 9. [Other Deployment Options](./09-DEPLOYMENT.md)
- Deploy lên Vercel
- Deploy lên Railway
- Deploy với Docker
- Self-hosted options
- **Đọc nếu muốn explore các options khác**

### 🔐 Authentication Setup

#### 5. [Keycloak Setup](./05-KEYCLOAK_SETUP.md)
- Basic Keycloak configuration
- Realm và Client setup
- User management
- **Đọc để setup authentication**

#### 6. [Keycloak 26.4.5 Migration](./06-KEYCLOAK_26_MIGRATION.md)
- Chi tiết về Keycloak 26.4.5
- Docker Compose examples
- Production configuration
- Performance tuning
- **Đọc để hiểu sâu về Keycloak**

### 📚 Working with 3D Models

#### 7. [3D Models Guide](./07-3D_MODELS_GUIDE.md)
- Preparing 3D models
- Optimization techniques
- Supported formats (GLB/GLTF)
- Best practices
- **Đọc khi làm việc với 3D models**

### 📊 Technical Information

#### 8. [Version Compatibility](./08-VERSION_COMPATIBILITY.md)
- Keycloak 26.4.5 server + keycloak-js 26.2.1 client
- Why different versions?
- Compatibility matrix
- Update guide
- **Đọc để hiểu về versions**

#### 10. [Changelog](./10-CHANGELOG.md)
- Version history
- New features
- Breaking changes
- **Đọc để biết what's new**

#### 11. [Updates Summary](./11-UPDATES_SUMMARY.md)
- Recent updates summary
- Keycloak 26.4.5 migration notes
- **Đọc để catch up với updates mới nhất**

## 🎯 Quick Navigation

### Tôi Muốn...

**...bắt đầu nhanh với local development**
→ Đọc [01-QUICKSTART.md](./01-QUICKSTART.md)

**...deploy lên VPS tự động (recommended)**
→ Đọc [03-DEPLOYMENT_SCRIPTS_SUMMARY.md](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md)  
→ Sau đó đọc [../scripts/README.md](../scripts/README.md)

**...deploy lên VPS manual**
→ Đọc [04-VPS_DEPLOYMENT_GUIDE.md](./04-VPS_DEPLOYMENT_GUIDE.md)

**...hiểu tại sao không dùng Docker**
→ Đọc [02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md)

**...setup Keycloak authentication**
→ Đọc [05-KEYCLOAK_SETUP.md](./05-KEYCLOAK_SETUP.md)

**...deploy lên Vercel/Railway**
→ Đọc [09-DEPLOYMENT.md](./09-DEPLOYMENT.md)

**...làm việc với 3D models**
→ Đọc [07-3D_MODELS_GUIDE.md](./07-3D_MODELS_GUIDE.md)

**...biết versions compatibility**
→ Đọc [08-VERSION_COMPATIBILITY.md](./08-VERSION_COMPATIBILITY.md)

## 📂 File Organization

```
docs/
├── 01-QUICKSTART.md                    # ⭐ Start here
├── 02-NO_DOCKER_DEPLOYMENT.md          # Why no Docker
├── 03-DEPLOYMENT_SCRIPTS_SUMMARY.md    # Scripts overview
├── 04-VPS_DEPLOYMENT_GUIDE.md          # Manual VPS guide
├── 05-KEYCLOAK_SETUP.md                # Auth setup
├── 06-KEYCLOAK_26_MIGRATION.md         # Keycloak details
├── 07-3D_MODELS_GUIDE.md               # 3D models
├── 08-VERSION_COMPATIBILITY.md         # Versions
├── 09-DEPLOYMENT.md                    # Other options
├── 10-CHANGELOG.md                     # History
└── 11-UPDATES_SUMMARY.md               # Recent updates
```

## 🎓 Learning Path

### Beginner (Just Starting)
1. Read [01-QUICKSTART.md](./01-QUICKSTART.md)
2. Run `npm run dev` locally
3. Explore the app

### Intermediate (Ready to Deploy)
1. Read [02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md)
2. Read [03-DEPLOYMENT_SCRIPTS_SUMMARY.md](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md)
3. Setup `.env`
4. Run deployment scripts

### Advanced (Deep Understanding)
1. Read [04-VPS_DEPLOYMENT_GUIDE.md](./04-VPS_DEPLOYMENT_GUIDE.md)
2. Read [06-KEYCLOAK_26_MIGRATION.md](./06-KEYCLOAK_26_MIGRATION.md)
3. Optimize performance
4. Custom configurations

## 🔍 Search by Topic

### Deployment
- [Quick Start](./01-QUICKSTART.md) - Local
- [No Docker](./02-NO_DOCKER_DEPLOYMENT.md) - Strategy
- [Scripts](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md) - Automated
- [VPS Guide](./04-VPS_DEPLOYMENT_GUIDE.md) - Manual
- [Other Options](./09-DEPLOYMENT.md) - Vercel, Railway

### Authentication
- [Keycloak Setup](./05-KEYCLOAK_SETUP.md) - Basic
- [Keycloak Migration](./06-KEYCLOAK_26_MIGRATION.md) - Advanced

### Content
- [3D Models](./07-3D_MODELS_GUIDE.md) - Working with models

### Reference
- [Versions](./08-VERSION_COMPATIBILITY.md) - Compatibility
- [Changelog](./10-CHANGELOG.md) - History
- [Updates](./11-UPDATES_SUMMARY.md) - Recent

## 💡 Tips

### For Developers
- Start with local development ([01-QUICKSTART.md](./01-QUICKSTART.md))
- Understand the architecture ([02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md))
- Use automated scripts ([03-DEPLOYMENT_SCRIPTS_SUMMARY.md](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md))

### For DevOps
- Read deployment strategy ([02-NO_DOCKER_DEPLOYMENT.md](./02-NO_DOCKER_DEPLOYMENT.md))
- Use automation ([03-DEPLOYMENT_SCRIPTS_SUMMARY.md](./03-DEPLOYMENT_SCRIPTS_SUMMARY.md))
- Reference manual guide ([04-VPS_DEPLOYMENT_GUIDE.md](./04-VPS_DEPLOYMENT_GUIDE.md))

### For Designers/Content Creators
- Focus on 3D models ([07-3D_MODELS_GUIDE.md](./07-3D_MODELS_GUIDE.md))
- Learn about formats and optimization

## 📞 Getting Help

1. Check relevant documentation above
2. Search in the specific guide
3. Check troubleshooting sections
4. Open an issue on GitHub

## 🔄 Keeping Updated

- Check [11-UPDATES_SUMMARY.md](./11-UPDATES_SUMMARY.md) for latest changes
- Review [10-CHANGELOG.md](./10-CHANGELOG.md) for version history
- Follow [08-VERSION_COMPATIBILITY.md](./08-VERSION_COMPATIBILITY.md) for compatibility

---

**Documentation Version**: 1.0.0  
**Last Updated**: November 22, 2025  
**Total Documents**: 11 files

**Happy Reading! 📚**

