# SSL Certificates cho showcase.vibytes.tech

> **Thư mục này chứa SSL certificates cho Showcase application (Next.js app)**

## 📁 Cấu trúc file

Thư mục này cần chứa các file sau:

### Required Files (Bắt buộc)

1. **Private Key** - Một trong các tên sau:
   - `private_key_showcase-vibytes-tech.txt` ✅ (recommended)
   - `private_key_vibytes-tech.txt`
   - `private_key.txt`

2. **Root CA Certificate** - Một trong các tên sau:
   - `rootca_showcase-vibytes-tech.txt` ✅ (recommended)
   - `rootca_vibytes-tech.txt`
   - `rootca.txt`

### Optional Files

3. **Domain Certificate** (optional):
   - `certificate_showcase-vibytes-tech.txt` ✅ (recommended)
   - `certificate_vibytes-tech.txt`
   - `certificate.txt`

> 💡 **Note:** Nếu không có domain certificate, script sẽ tự động sử dụng Root CA certificate.

## 🔍 Kiểm tra certificates

### Kiểm tra Private Key

```bash
# View key info
openssl rsa -in private_key_showcase-vibytes-tech.txt -text -noout

# Check if key is valid
openssl rsa -in private_key_showcase-vibytes-tech.txt -check

# Get key modulus (để compare với certificate)
openssl rsa -in private_key_showcase-vibytes-tech.txt -modulus -noout | openssl md5
```

### Kiểm tra Certificate

```bash
# View certificate details
openssl x509 -in rootca_showcase-vibytes-tech.txt -text -noout

# Check expiration date
openssl x509 -in rootca_showcase-vibytes-tech.txt -noout -dates

# Get certificate modulus
openssl x509 -in rootca_showcase-vibytes-tech.txt -modulus -noout | openssl md5

# Verify certificate and key match
# (Modulus của key và cert phải giống nhau)
```

### Verify Domain

```bash
# Check what domain(s) the certificate is for
openssl x509 -in rootca_showcase-vibytes-tech.txt -text -noout | grep -A1 "Subject:"

# Check Subject Alternative Names (SAN)
openssl x509 -in rootca_showcase-vibytes-tech.txt -text -noout | grep -A1 "Subject Alternative Name"
```

## 🚀 Sử dụng

Sau khi đã có đầy đủ certificates trong thư mục này, chạy script setup:

```bash
# Từ thư mục gốc của project
./scripts/setup-ssl-showcase.sh
```

Script sẽ:
1. Tự động detect files trong `ca/showcase/`
2. Upload lên VPS tại `/etc/nginx/ssl/`
3. Configure Nginx với HTTPS
4. Restart Nginx
5. Test SSL connection

## 🔐 Security

### Permissions

Các file trong thư mục này **KHÔNG** được commit lên Git (đã được ignore).

### Backup

**⚠️ QUAN TRỌNG:** Backup private key ở nơi an toàn!

```bash
# Backup locally (encrypted)
tar czf ~/ssl-backup-showcase-$(date +%Y%m%d).tar.gz ca/showcase/*.txt
gpg -c ~/ssl-backup-*.tar.gz  # Encrypt with password
rm ~/ssl-backup-*.tar.gz      # Remove unencrypted
```

### Best Practices

✅ **DO:**
- Giữ private key ở chế độ bảo mật cao
- Backup certificates encrypted
- Monitor expiration dates
- Use strong file permissions trên VPS (600 for key, 644 for certs)

❌ **DON'T:**
- Share private key qua email/chat/Slack
- Commit private key to Git
- Reuse certificates giữa các environments
- Ignore certificate warnings

## 📊 Certificate Info

Sau khi deploy, certificates sẽ được đặt tại VPS:

```
/etc/nginx/ssl/
├── showcase-vibytes-tech.key              # Private key (600)
├── showcase-vibytes-tech-ca.crt           # Root CA (644)
├── showcase-vibytes-tech.crt              # Domain cert (644) - if provided
└── showcase-vibytes-tech-fullchain.crt    # Full chain: domain + CA (644)
```

## 🔄 Certificate Renewal

### Khi nào cần renew?

```bash
# Check expiration
openssl x509 -in rootca_showcase-vibytes-tech.txt -noout -enddate

# Set reminder 30 days trước khi hết hạn
```

### Renewal Steps

1. **Lấy certificates mới** từ SSL provider
2. **Backup certificates cũ:**
   ```bash
   mv ca/showcase ca/showcase.old-$(date +%Y%m%d)
   mkdir ca/showcase
   ```
3. **Copy certificates mới** vào `ca/showcase/`
4. **Verify certificates:**
   ```bash
   openssl x509 -in ca/showcase/rootca_showcase-vibytes-tech.txt -text -noout
   ```
5. **Re-run setup script:**
   ```bash
   ./scripts/setup-ssl-showcase.sh
   ```
6. **Test:**
   ```bash
   curl -I https://showcase.vibytes.tech
   ```

## 📝 Wildcard Certificate

Nếu bạn sử dụng **wildcard certificate** (*.vibytes.tech):

- Một certificate có thể dùng cho cả auth và showcase
- Copy cùng một bộ certificates vào cả `ca/auth/` và `ca/showcase/`
- Hoặc symbolic link:
  ```bash
  ln -s ../auth/private_key_auth-vibytes-tech.txt private_key_showcase-vibytes-tech.txt
  ln -s ../auth/rootca_auth-vibytes-tech.txt rootca_showcase-vibytes-tech.txt
  ```

## 🔗 Related Documentation

- [Setup SSL Script Usage](../../docs/13-SSL_SHOWCASE_SETUP.md)
- [VPS Deployment](../../docs/04-VPS_DEPLOYMENT_GUIDE.md)
- [Nginx Configuration](../../docs/09-DEPLOYMENT.md)

---

**Domain:** showcase.vibytes.tech  
**SSL Provider:** [Your SSL Provider]  
**Certificate Type:** [Type, e.g., DV SSL, Wildcard, etc.]  
**Valid Until:** [Check with openssl command above]

