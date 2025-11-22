# SSL Troubleshooting - "Not Secure" Issue

## 🔴 Vấn Đề: Browser Hiển Thị "Not Secure" Dù Đã Setup SSL

### Triệu Chứng

- Certificate đã được cài đặt đúng trên server
- Certificate viewer hiển thị certificate hợp lệ
- Nhưng browser vẫn hiển thị **"Not Secure"** hoặc warning
- Lock icon màu đỏ hoặc có dấu chấm than

---

## 🔍 Nguyên Nhân Phổ Biến

### 1. **Certificate Chain Không Đầy Đủ** ⚠️ (MỌT PHỔ BIẾN)

**Giải thích:**

SSL Certificate cần có **certificate chain** đầy đủ:
```
Domain Certificate (depth 0)
    ↓ issued by
Intermediate CA (depth 1)
    ↓ issued by  
Root CA (depth 2)
```

Nếu thiếu intermediate CA, browser không thể verify chain of trust → "Not Secure"

**Kiểm tra:**

```bash
# Test certificate chain
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null 2>/dev/null | grep -A10 "Certificate chain"
```

**Output tốt (có đầy đủ chain):**
```
Certificate chain
 0 s:/CN=yourdomain.com
   i:/CN=Sectigo RSA Domain Validation Secure Server CA
 1 s:/CN=Sectigo RSA Domain Validation Secure Server CA
   i:/CN=USERTrust RSA Certification Authority
 2 s:/CN=USERTrust RSA Certification Authority
   i:/CN=AddTrust External CA Root
```

**Output xấu (thiếu chain):**
```
Certificate chain
 0 s:/CN=yourdomain.com
   i:/CN=Sectigo RSA Domain Validation Secure Server CA
```
Only 1 certificate → ⚠️ THIẾU INTERMEDIATE CA!

### 2. **Fullchain File Format Sai**

**Vấn đề:**

Khi tạo fullchain certificate, **PHẢI CÓ blank line** giữa các certificates:

❌ **SAI:**
```
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
```

✅ **ĐÚNG:**
```
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
```
^ Có 1 dòng trống ở giữa

**Fix:**

```bash
# Tạo fullchain đúng cách
cat domain.crt > fullchain.crt
echo '' >> fullchain.crt              # ← QUAN TRỌNG!
cat ca-bundle.crt >> fullchain.crt
```

### 3. **Mixed Content (HTTPS page load HTTP resources)**

**Triệu chứng:**
- HTTPS page nhưng load images/scripts/CSS từ HTTP URLs
- Browser console warnings: "Mixed Content"

**Fix:**
- Update tất cả URLs trong code thành HTTPS
- Check `.env` files, hardcoded URLs

### 4. **Certificate Domain Mismatch**

**Vấn đề:**
- Certificate issued cho `example.com`
- Nhưng access qua `www.example.com` hoặc subdomain khác

**Fix:**
- Mua certificate với SAN (Subject Alternative Names)
- Hoặc setup separate certificates cho mỗi subdomain

### 5. **Certificate Expired**

**Check:**
```bash
openssl x509 -in certificate.crt -noout -dates
```

**Fix:**
- Renew certificate trước khi expire
- Setup auto-renewal

---

## 🛠️ Fix Chi Tiết: Certificate Chain Issue

### Bước 1: Kiểm Tra Vấn Đề

```bash
# On VPS
ssh root@vps

# Check current chain
openssl s_client -connect localhost:443 -servername yourdomain.com < /dev/null 2>/dev/null | grep -A10 "Certificate chain"
```

Nếu chỉ thấy 1 certificate → có vấn đề!

### Bước 2: Kiểm Tra Files

```bash
# Check certificate files
ls -lh /etc/nginx/ssl/

# Verify fullchain has multiple certificates
openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/yourdomain-fullchain.crt | openssl pkcs7 -print_certs -noout | grep subject
```

**Expected:** Phải thấy 2-3 subject lines (domain, intermediate CA, root CA)

### Bước 3: Kiểm Tra Format

```bash
# Check for blank lines between certificates
grep -n "END CERTIFICATE" /etc/nginx/ssl/yourdomain-fullchain.crt

# Example output:
# 36:-----END CERTIFICATE-----
# 71:-----END CERTIFICATE-----
# 105:-----END CERTIFICATE-----

# Check spacing
sed -n "35,39p" /etc/nginx/ssl/yourdomain-fullchain.crt
```

Phải thấy blank line giữa `-----END CERTIFICATE-----` và `-----BEGIN CERTIFICATE-----`

### Bước 4: Recreate Fullchain Đúng Cách

```bash
# Backup old file
sudo cp /etc/nginx/ssl/yourdomain-fullchain.crt /etc/nginx/ssl/yourdomain-fullchain.crt.backup

# Create new fullchain với format đúng
sudo bash -c 'cat /etc/nginx/ssl/yourdomain.crt > /etc/nginx/ssl/yourdomain-fullchain.crt'
sudo bash -c 'echo "" >> /etc/nginx/ssl/yourdomain-fullchain.crt'  # ← Thêm blank line!
sudo bash -c 'cat /etc/nginx/ssl/yourdomain-ca.crt >> /etc/nginx/ssl/yourdomain-fullchain.crt'

# Set permissions
sudo chmod 644 /etc/nginx/ssl/yourdomain-fullchain.crt
sudo chown root:root /etc/nginx/ssl/yourdomain-fullchain.crt
```

### Bước 5: Verify New Fullchain

```bash
# Verify certificates in fullchain
openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/yourdomain-fullchain.crt | openssl pkcs7 -print_certs -noout | grep subject
```

**Expected output:**
```
subject=CN = yourdomain.com
subject=CN = Sectigo RSA Domain Validation Secure Server CA
subject=CN = USERTrust RSA Certification Authority
```

3 subject lines = Good! ✅

### Bước 6: Reload Nginx

```bash
# Test config
sudo nginx -t

# Reload
sudo systemctl reload nginx
```

### Bước 7: Test Từ Internet

```bash
# From local machine
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null 2>/dev/null | grep -A10 "Certificate chain"
```

**Expected:** Phải thấy ít nhất 2 certificates trong chain

```bash
# Test với curl
curl -v https://yourdomain.com 2>&1 | grep -i "certificate verify"
```

**Expected:** `* SSL certificate verify ok.`

### Bước 8: Test Browser

1. Hard refresh browser: `Ctrl+Shift+R` (Windows) hoặc `Cmd+Shift+R` (Mac)
2. Clear browser cache và SSL state
3. Open incognito/private window
4. Visit `https://yourdomain.com`
5. Click lock icon → Should show **"Secure"** ✅

---

## 📊 Verify Certificate Chain Script

Tạo script helper để kiểm tra:

```bash
#!/bin/bash

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 domain.com"
    exit 1
fi

echo "=== Checking SSL for $DOMAIN ==="
echo ""

echo "1. Certificate Chain:"
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | grep -A10 "Certificate chain"

echo ""
echo "2. Certificate Verify:"
curl -v https://$DOMAIN 2>&1 | grep -i "certificate verify"

echo ""
echo "3. Certificate Validity:"
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -dates

echo ""
echo "4. Certificate Issuer:"
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -issuer

echo ""
echo "=== SSL Labs Test ==="
echo "https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
```

**Usage:**
```bash
chmod +x check-ssl.sh
./check-ssl.sh showcase.vibytes.tech
```

---

## 🔧 Fix Script Automation

Tạo script tự động fix:

```bash
#!/bin/bash

DOMAIN=$1
CERT_PATH="/etc/nginx/ssl"

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 domain-name"
    echo "Example: $0 showcase-vibytes-tech"
    exit 1
fi

echo "=== Fixing SSL Certificate Chain for $DOMAIN ==="

# Backup
echo "1. Backing up existing fullchain..."
sudo cp $CERT_PATH/${DOMAIN}-fullchain.crt $CERT_PATH/${DOMAIN}-fullchain.crt.backup.$(date +%Y%m%d-%H%M%S)

# Recreate with proper format
echo "2. Creating new fullchain..."
sudo bash -c "cat $CERT_PATH/${DOMAIN}.crt > $CERT_PATH/${DOMAIN}-fullchain.crt"
sudo bash -c "echo '' >> $CERT_PATH/${DOMAIN}-fullchain.crt"
sudo bash -c "cat $CERT_PATH/${DOMAIN}-ca.crt >> $CERT_PATH/${DOMAIN}-fullchain.crt"

# Verify
echo "3. Verifying new fullchain..."
openssl crl2pkcs7 -nocrl -certfile $CERT_PATH/${DOMAIN}-fullchain.crt | openssl pkcs7 -print_certs -noout | grep subject

# Reload Nginx
echo "4. Reloading Nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo ""
echo "✅ Done! Test at: https://${DOMAIN//-/.}"
```

**Usage:**
```bash
chmod +x fix-ssl-chain.sh
./fix-ssl-chain.sh showcase-vibytes-tech
```

---

## 🎯 Best Practices

### 1. Always Use Fullchain Certificate

**Nginx config:**
```nginx
ssl_certificate /etc/nginx/ssl/domain-fullchain.crt;  # ← fullchain!
ssl_certificate_key /etc/nginx/ssl/domain.key;
```

NOT:
```nginx
ssl_certificate /etc/nginx/ssl/domain.crt;  # ← domain only! BAD!
```

### 2. Proper Fullchain Creation

**Correct order:**
```bash
cat domain.crt > fullchain.crt       # 1. Domain certificate
echo '' >> fullchain.crt             # 2. Blank line
cat intermediate.crt >> fullchain.crt # 3. Intermediate CA
echo '' >> fullchain.crt             # 4. Blank line (optional for root)
cat root.crt >> fullchain.crt        # 5. Root CA (optional)
```

### 3. Test Immediately After Setup

```bash
# Right after SSL setup:
openssl s_client -connect localhost:443 -servername domain.com < /dev/null 2>/dev/null | grep -A5 "Certificate chain"
```

Should see multiple certificates immediately!

### 4. Automate Certificate Checks

Setup cron job:
```bash
# /etc/cron.daily/check-ssl
#!/bin/bash
DOMAIN="yourdomain.com"
ALERT_EMAIL="admin@example.com"

# Check chain
CHAIN_COUNT=$(openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>/dev/null | grep -c "s:/")

if [ $CHAIN_COUNT -lt 2 ]; then
    echo "WARNING: SSL chain incomplete for $DOMAIN" | mail -s "SSL Alert" $ALERT_EMAIL
fi
```

### 5. Use SSL Labs for Validation

Always test with SSL Labs after setup:
```
https://www.ssllabs.com/ssltest/analyze.html?d=yourdomain.com
```

**Target:** Grade A or A+

---

## 📝 Common Errors và Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `unable to get local issuer certificate` | Missing intermediate CA | Add intermediate to fullchain |
| `certificate verify failed` | Incomplete chain | Recreate fullchain with all CAs |
| `SSL23_GET_SERVER_HELLO` | No blank line between certs | Add newline when creating fullchain |
| `self signed certificate in certificate chain` | Using wrong CA | Download correct CA bundle từ SSL provider |
| Browser shows "Not Secure" | Incomplete certificate chain | Fix fullchain format và reload Nginx |

---

## 🎓 Understanding Certificate Chain

### Why Chain Matters?

```
Browser
  ↓ trusts
Root CA (in browser's trust store)
  ↓ signed
Intermediate CA
  ↓ signed
Domain Certificate
  ↓ presents
Your Website
```

Nếu thiếu intermediate CA:
- Browser có Root CA
- Server có Domain Certificate
- Nhưng **không có link giữa chúng** → Cannot verify → Not Secure!

### Solution:

Server phải send **full chain**: Domain → Intermediate → Root

Browser sẽ:
1. Receive domain cert
2. Check intermediate CA (from fullchain)
3. Verify intermediate signed by root CA (in trust store)
4. Trust established ✅

---

## 📞 Quick Debug Commands

```bash
# 1. Check what server sends
openssl s_client -connect domain.com:443 -servername domain.com < /dev/null 2>/dev/null | grep -A20 "Certificate chain"

# 2. Verify fullchain file
openssl crl2pkcs7 -nocrl -certfile fullchain.crt | openssl pkcs7 -print_certs -text | grep -E "(Subject:|Issuer:)"

# 3. Test from internet
curl -v https://domain.com 2>&1 | grep -i certificate

# 4. Check Nginx is using correct file
sudo nginx -T | grep ssl_certificate

# 5. Check certificate dates
openssl s_client -connect domain.com:443 -servername domain.com < /dev/null 2>/dev/null | openssl x509 -noout -dates

# 6. SSL Labs check
curl -s "https://api.ssllabs.com/api/v3/analyze?host=domain.com" | jq '.endpoints[0].grade'
```

---

## ✅ Checklist Fix "Not Secure"

- [ ] Check certificate chain có ít nhất 2 levels
- [ ] Verify fullchain file có đúng format (blank lines)
- [ ] Nginx config dùng fullchain, không phải domain cert only
- [ ] Reload Nginx sau khi fix
- [ ] Test với `openssl s_client`
- [ ] Test với `curl -v`
- [ ] Clear browser cache
- [ ] Test trong incognito mode
- [ ] Verify với SSL Labs
- [ ] Ensure all resources load over HTTPS (no mixed content)

---

**Last Updated**: November 22, 2025  
**Common Issue**: Certificate chain incomplete  
**Solution**: Recreate fullchain with proper blank lines

