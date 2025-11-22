# Dependencies Upgrade Guide

Hướng dẫn nâng cấp dependencies lên phiên bản mới nhất, bao gồm major version updates.

## 📋 Tổng Quan

Project này bao gồm các scripts tự động để nâng cấp tất cả dependencies lên phiên bản mới nhất một cách an toàn:

- ✅ **check-updates.sh** - Kiểm tra các packages có phiên bản mới
- ✅ **upgrade-deps.sh** - Nâng cấp với xác nhận
- ✅ **upgrade-deps-auto.sh** - Nâng cấp tự động (không cần xác nhận)

## 🚀 Quick Start

### Cách 1: Sử dụng npm scripts (Khuyến nghị)

```bash
# Kiểm tra các package cần nâng cấp
npm run deps:check

# Nâng cấp với xác nhận
npm run deps:upgrade

# Nâng cấp tự động
npm run deps:upgrade-auto
```

### Cách 2: Chạy trực tiếp scripts

```bash
# Kiểm tra updates
./scripts/check-updates.sh

# Nâng cấp với xác nhận
./scripts/upgrade-deps.sh

# Nâng cấp tự động
./scripts/upgrade-deps-auto.sh
```

## 📝 Chi Tiết Từng Script

### 1. check-updates.sh

**Mục đích:** Kiểm tra các package có phiên bản mới mà không thực hiện nâng cấp.

**Sử dụng:**

```bash
npm run deps:check
```

**Output:**

```
@prisma/client       ^6.1.0  →  ^7.2.0
@react-three/drei    ^10.7.7 →  ^11.5.0
next                 16.0.3  →  16.1.5
react                19.2.0  →  19.3.1
...
```

**Khi nào dùng:**
- Trước khi nâng cấp để xem có gì thay đổi
- Định kỳ kiểm tra updates hàng tuần/tháng
- Khi có lỗi bảo mật cần patch

### 2. upgrade-deps.sh

**Mục đích:** Nâng cấp dependencies với xác nhận từ người dùng.

**Sử dụng:**

```bash
npm run deps:upgrade
```

**Workflow:**

1. ✅ Kiểm tra và cài đặt `npm-check-updates` nếu cần
2. ✅ Tạo backup `package.json.backup.YYYYMMDD_HHMMSS`
3. ✅ Hiển thị danh sách packages sẽ được nâng cấp
4. ⚠️ **Hỏi xác nhận** từ người dùng (y/n)
5. ✅ Nâng cấp `package.json`
6. ✅ Xóa `node_modules` và `package-lock.json`
7. ✅ Cài đặt lại dependencies
8. ✅ Hiển thị thay đổi
9. ✅ Auto-rollback nếu có lỗi

**Khi nào dùng:**
- Khi muốn review trước khi nâng cấp
- Nâng cấp lần đầu tiên
- Không chắc chắn về tác động của updates

### 3. upgrade-deps-auto.sh

**Mục đích:** Nâng cấp tự động không cần xác nhận (CI/CD friendly).

**Sử dụng:**

```bash
npm run deps:upgrade-auto
```

**Workflow:**

Giống `upgrade-deps.sh` nhưng **bỏ qua bước xác nhận**.

**Khi nào dùng:**
- Trong CI/CD pipelines
- Khi đã review và chắc chắn
- Scheduled updates tự động

## 🔒 An Toàn và Backup

### Automatic Backup

Mỗi lần nâng cấp, script tự động tạo backup:

```
package.json.backup.20251122_143045
```

### Restore từ Backup

Nếu có vấn đề sau khi nâng cấp:

```bash
# Restore backup
cp package.json.backup.YYYYMMDD_HHMMSS package.json

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Auto-Rollback

Script tự động rollback nếu `npm install` thất bại:

```
✗ Có lỗi xảy ra trong quá trình cài đặt!
Đang khôi phục từ backup...
Đã khôi phục về phiên bản cũ.
```

## ✅ Checklist Sau Khi Nâng Cấp

### 1. Kiểm tra Build

```bash
npm run build
```

**Nếu thất bại:**
- Check error messages
- Review breaking changes của packages
- Restore backup nếu cần

### 2. Chạy Tests (nếu có)

```bash
npm test
```

### 3. Kiểm tra Dev Server

```bash
npm run dev
```

**Test các chức năng chính:**
- ✅ Homepage loads
- ✅ Navigation works
- ✅ Authentication works (Keycloak)
- ✅ 3D models render correctly
- ✅ Database queries work
- ✅ Admin panel accessible

### 4. Check Database

```bash
# Regenerate Prisma client
npm run db:generate

# Check migrations
npm run db:migrate
```

### 5. Review Breaking Changes

Xem changelog của các packages có major version update:

```bash
# Example: Next.js 16.0 → 17.0
npm info next@latest

# Visit package repository
# Check CHANGELOG.md or release notes
```

## 🎯 Best Practices

### 1. Nâng Cấp Thường Xuyên

```bash
# Hàng tuần: check updates
npm run deps:check

# Hàng tháng: upgrade
npm run deps:upgrade
```

**Lợi ích:**
- Tránh technical debt
- Security patches mới nhất
- Bug fixes
- Performance improvements

### 2. Nâng Cấp Từng Loại

#### Minor & Patch Updates (An toàn)

```bash
# Chỉ minor & patch
ncu -u --target minor
npm install
```

#### Major Updates (Cẩn thận)

```bash
# Chỉ major updates
ncu --target major

# Review breaking changes trước
# Sau đó nâng cấp từng package
ncu -u [package-name]
npm install
```

### 3. Test Trước Khi Commit

```bash
# After upgrade
npm run build
npm run dev
# Test thoroughly

# If OK, commit
git add package.json package-lock.json
git commit -m "chore: upgrade dependencies"
```

### 4. Use Git Branches

```bash
# Create branch for upgrade
git checkout -b upgrade-deps

# Run upgrade
npm run deps:upgrade

# Test thoroughly
npm run build
npm run dev

# If OK, merge
git checkout main
git merge upgrade-deps
```

## ⚠️ Common Issues & Solutions

### Issue 1: Peer Dependencies Conflict

**Error:**

```
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^18.0.0" from some-package@1.0.0
```

**Solution:**

```bash
# Install with --legacy-peer-deps
npm install --legacy-peer-deps

# Or upgrade peer dependencies
npm run deps:upgrade
```

### Issue 2: Breaking Changes in Major Updates

**Symptoms:**
- Build fails
- Runtime errors
- Features broken

**Solution:**

```bash
# 1. Restore backup
cp package.json.backup.YYYYMMDD_HHMMSS package.json
npm install

# 2. Upgrade selectively
ncu -u --target minor  # Safe updates first
npm install

# 3. Major updates one by one
ncu -u next  # Example: upgrade Next.js
npm install
npm run build  # Test

# 4. Read migration guides
# Check package documentation
```

### Issue 3: Prisma Schema Mismatch

**Error:**

```
Error: Prisma schema is out of sync
```

**Solution:**

```bash
# Regenerate Prisma client
npm run db:generate

# Run migrations
npm run db:migrate
```

### Issue 4: TypeScript Errors

**Error:**

```
TS2345: Argument of type 'X' is not assignable to parameter of type 'Y'.
```

**Solution:**

```bash
# Check TypeScript version
npm list typescript

# Update types
npm install -D @types/node@latest @types/react@latest @types/react-dom@latest

# Fix code if needed
```

## 📊 Version Strategy

### Current Stack

| Package | Current | Strategy |
|---------|---------|----------|
| Next.js | 16.x | Follow latest stable |
| React | 19.x | Major: test carefully |
| Prisma | 6.x | Follow latest |
| Keycloak-js | 26.x | Match server version |
| TypeScript | 5.x | Major: review breaking changes |

### Update Frequency

| Type | Frequency | Risk | Testing |
|------|-----------|------|---------|
| **Patch** (0.0.x) | Weekly | Low | Basic |
| **Minor** (0.x.0) | Monthly | Medium | Thorough |
| **Major** (x.0.0) | Quarterly | High | Extensive |

## 🔍 Advanced Usage

### Nâng cấp chỉ một package

```bash
ncu -u react
npm install
```

### Nâng cấp theo pattern

```bash
# Chỉ React packages
ncu -u '/react.*/'

# Chỉ types
ncu -u '/@types\/.*/'
```

### Check specific package

```bash
ncu next
ncu react
```

### Interactive mode

```bash
ncu -i
# Choose which packages to upgrade
```

## 📚 Related Documentation

- [Version Compatibility](08-VERSION_COMPATIBILITY.md)
- [Deployment Guide](09-DEPLOYMENT.md)
- [Changelog](10-CHANGELOG.md)
- [Troubleshooting](12-TROUBLESHOOTING.md)

## 🛠️ npm-check-updates Reference

### Installation

```bash
# Global
npm install -g npm-check-updates

# Or use without installing
npx npm-check-updates
```

### Common Commands

```bash
# Check updates
ncu

# Update package.json
ncu -u

# Interactive mode
ncu -i

# Target specific level
ncu --target minor
ncu --target patch
ncu --target latest

# Filter packages
ncu -f react
ncu -f '/react.*/'

# Exclude packages
ncu -x typescript
```

### Options

```bash
# Group by major/minor/patch
ncu --format group

# Doctor mode (test each upgrade)
ncu --doctor

# JSON output
ncu --format json
```

## 💡 Tips

1. **Read Changelogs**: Always check changelogs for major updates
2. **Test Locally First**: Never upgrade directly in production
3. **Use Git Branches**: Create a branch for upgrades
4. **Backup Before Deploy**: Always backup before deploying upgrades
5. **Monitor After Deploy**: Watch logs and metrics after upgrade
6. **Keep Dependencies Updated**: Regular updates are easier than big jumps

## 📞 Support

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review package changelogs and migration guides
3. Search GitHub issues
4. Restore from backup if needed
5. Contact team for help

---

**Last Updated**: November 22, 2025  
**Scripts Version**: 1.0.0  
**Compatible with**: Node.js 20+, npm 10+

