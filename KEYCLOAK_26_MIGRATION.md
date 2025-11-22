# Keycloak 26.4.5 Migration & Setup Guide

Hướng dẫn chi tiết về Keycloak 26.4.5 (phiên bản mới nhất) với các tính năng mới và cải tiến.

## What's New in Keycloak 26.4.5

### Improvements
- 🚀 **Enhanced Performance** - Cải thiện hiệu suất khởi động và runtime
- 🔒 **Better Security** - Cập nhật các security patches mới nhất
- 🎯 **Simplified Configuration** - Cấu hình đơn giản hơn với các defaults tốt hơn
- 📦 **Smaller Image Size** - Docker image nhẹ hơn
- ⚡ **Faster Startup** - Thời gian khởi động nhanh hơn
- 🔧 **Improved Admin Console** - Giao diện quản trị được cải thiện
- 🌐 **Better Proxy Support** - Hỗ trợ proxy và reverse proxy tốt hơn

### Breaking Changes
- Một số endpoints cũ đã deprecated
- Thay đổi trong cấu hình database connection pooling
- Cập nhật trong CORS handling

## Quick Start với Docker

### Development Mode

```bash
docker run -d --name keycloak-dev \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  -e KC_HOSTNAME=localhost \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HTTP_ENABLED=true \
  quay.io/keycloak/keycloak:26.4.5 \
  start-dev

# Check logs
docker logs -f keycloak-dev

# Access at: http://localhost:8080
```

### Production Mode với PostgreSQL

```bash
# 1. Tạo network
docker network create keycloak-network

# 2. Start PostgreSQL
docker run -d --name keycloak-postgres \
  --network keycloak-network \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=keycloak123 \
  -v keycloak-db:/var/lib/postgresql/data \
  postgres:16-alpine

# 3. Start Keycloak
docker run -d --name keycloak-prod \
  --network keycloak-network \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://keycloak-postgres:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=keycloak123 \
  -e KC_HOSTNAME=localhost \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HTTP_ENABLED=true \
  -e KC_PROXY=edge \
  -e KC_HEALTH_ENABLED=true \
  -e KC_METRICS_ENABLED=true \
  quay.io/keycloak/keycloak:26.4.5 \
  start --optimized

# Check health
curl http://localhost:8080/health
curl http://localhost:8080/health/ready
curl http://localhost:8080/health/live
```

## Docker Compose (Recommended)

Create `docker-compose.yml`:

```yaml
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    container_name: keycloak-db
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: ${DB_PASSWORD:-keycloak123}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - keycloak-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U keycloak"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  keycloak:
    image: quay.io/keycloak/keycloak:26.4.5
    container_name: keycloak
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      # Admin credentials
      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN:-admin}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD:-admin123}
      
      # Database
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${DB_PASSWORD:-keycloak123}
      KC_DB_SCHEMA: public
      
      # Hostname
      KC_HOSTNAME: ${KC_HOSTNAME:-localhost}
      KC_HOSTNAME_STRICT: false
      KC_HOSTNAME_STRICT_HTTPS: false
      
      # HTTP
      KC_HTTP_ENABLED: true
      KC_HTTP_HOST: 0.0.0.0
      KC_HTTP_PORT: 8080
      
      # Proxy
      KC_PROXY: edge
      KC_PROXY_HEADERS: xforwarded
      
      # Observability
      KC_HEALTH_ENABLED: true
      KC_METRICS_ENABLED: true
      KC_LOG_LEVEL: info
      
      # Performance
      KC_CACHE: ispn
      KC_CACHE_STACK: tcp
      
    ports:
      - "8080:8080"
    networks:
      - keycloak-net
    command:
      - start
      - --optimized
    healthcheck:
      test: ["CMD-SHELL", "exec 3<>/dev/tcp/127.0.0.1/8080 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 90s
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local

networks:
  keycloak-net:
    driver: bridge
```

Create `.env`:

```env
# Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=ChangeMeInProduction123!

# Database
DB_PASSWORD=StrongDatabasePassword123!

# Hostname (change in production)
KC_HOSTNAME=localhost
```

Start:

```bash
docker-compose up -d

# View logs
docker-compose logs -f

# Check health
docker-compose exec keycloak curl -s http://localhost:8080/health/ready

# Stop
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Configuration Options

### Essential Environment Variables

```bash
# Admin Account
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=password

# Database
KC_DB=postgres  # postgres, mysql, mariadb, mssql, oracle
KC_DB_URL=jdbc:postgresql://localhost:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=password
KC_DB_SCHEMA=public

# Hostname
KC_HOSTNAME=auth.yourdomain.com
KC_HOSTNAME_STRICT=false              # Set true in production
KC_HOSTNAME_STRICT_HTTPS=false        # Set true in production with HTTPS

# HTTP/HTTPS
KC_HTTP_ENABLED=true                  # Enable HTTP (for dev/behind proxy)
KC_HTTP_HOST=0.0.0.0                  # Listen on all interfaces
KC_HTTP_PORT=8080
KC_HTTPS_PORT=8443

# Proxy (when behind Nginx/Apache)
KC_PROXY=edge                         # edge, reencrypt, passthrough
KC_PROXY_HEADERS=xforwarded          # Which headers to trust

# Observability
KC_HEALTH_ENABLED=true
KC_METRICS_ENABLED=true
KC_LOG_LEVEL=info                     # debug, info, warn, error

# Performance
KC_CACHE=ispn                         # Infinispan cache
KC_CACHE_STACK=tcp                    # tcp, udp
```

### Production Settings

```bash
# Security
KC_HOSTNAME_STRICT=true
KC_HOSTNAME_STRICT_HTTPS=true
KC_HTTP_ENABLED=false                 # Disable HTTP, use HTTPS only
KC_HTTPS_CERTIFICATE_FILE=/path/to/cert.pem
KC_HTTPS_CERTIFICATE_KEY_FILE=/path/to/key.pem

# Performance
KC_CACHE=ispn
KC_CACHE_STACK=tcp
KC_DB_POOL_INITIAL_SIZE=10
KC_DB_POOL_MIN_SIZE=10
KC_DB_POOL_MAX_SIZE=50

# Logging
KC_LOG_LEVEL=warn
KC_LOG_CONSOLE_FORMAT=json
KC_LOG_CONSOLE_OUTPUT=json
```

## Building from Source

```bash
# Clone repository
git clone https://github.com/keycloak/keycloak.git
cd keycloak

# Checkout specific version
git checkout 26.4.5

# Build
./mvnw clean install -DskipTests

# Distribution will be in: distribution/server-dist/target/
```

## Nginx Configuration for Keycloak 26.4.5

```nginx
upstream keycloak {
    server localhost:8080;
}

server {
    listen 80;
    server_name auth.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name auth.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/auth.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/auth.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://keycloak;
        proxy_http_version 1.1;
        
        # Essential headers for Keycloak
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Buffer settings
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        
        # Timeouts
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        
        proxy_cache_bypass $http_upgrade;
    }

    # Health check endpoint (optional)
    location /health {
        proxy_pass http://keycloak/health;
        access_log off;
    }
}
```

## Systemd Service File

```ini
[Unit]
Description=Keycloak 26.4.5 Identity and Access Management
Documentation=https://www.keycloak.org/documentation
After=network.target postgresql.service

[Service]
Type=exec
User=keycloak
Group=keycloak
WorkingDirectory=/opt/keycloak

# Environment
Environment="KEYCLOAK_ADMIN=admin"
Environment="KEYCLOAK_ADMIN_PASSWORD=YourStrongPassword"
Environment="KC_DB=postgres"
Environment="KC_DB_URL=jdbc:postgresql://localhost:5432/keycloak"
Environment="KC_DB_USERNAME=keycloak"
Environment="KC_DB_PASSWORD=YourDbPassword"
Environment="KC_HOSTNAME=auth.yourdomain.com"
Environment="KC_HOSTNAME_STRICT=false"
Environment="KC_HTTP_ENABLED=true"
Environment="KC_HTTP_HOST=0.0.0.0"
Environment="KC_HTTP_PORT=8080"
Environment="KC_PROXY=edge"
Environment="KC_HEALTH_ENABLED=true"
Environment="KC_METRICS_ENABLED=true"
Environment="KC_LOG_LEVEL=info"
Environment="JAVA_OPTS=-Xms512m -Xmx2048m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m"

ExecStart=/opt/keycloak/bin/kc.sh start --optimized

StandardOutput=journal
StandardError=journal
SyslogIdentifier=keycloak

# Restart policy
Restart=on-failure
RestartSec=10s

# Resource limits
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

## Performance Tuning

### JVM Options

```bash
# In systemd service or startup script
export JAVA_OPTS="-Xms1024m -Xmx2048m \
  -XX:MetaspaceSize=256M \
  -XX:MaxMetaspaceSize=512m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:ParallelGCThreads=4 \
  -XX:ConcGCThreads=2 \
  -XX:+DisableExplicitGC \
  -Djava.net.preferIPv4Stack=true \
  -Djboss.modules.system.pkgs=org.jboss.byteman"
```

### Database Connection Pooling

Add to `conf/keycloak.conf`:

```conf
db-pool-initial-size=10
db-pool-min-size=10
db-pool-max-size=50
```

### Cache Configuration

```conf
cache=ispn
cache-stack=tcp
cache-config-file=cache-ispn.xml
```

## Health Checks & Monitoring

### Health Endpoints

```bash
# Overall health
curl http://localhost:8080/health

# Readiness probe
curl http://localhost:8080/health/ready

# Liveness probe
curl http://localhost:8080/health/live

# All checks
curl http://localhost:8080/health | jq
```

### Metrics

```bash
# Enable metrics
KC_METRICS_ENABLED=true

# Access metrics
curl http://localhost:8080/metrics

# With auth (if configured)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/metrics
```

### Prometheus Integration

Add to `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'keycloak'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
```

## Troubleshooting

### Check Logs

```bash
# Docker
docker logs -f keycloak

# Docker Compose
docker-compose logs -f keycloak

# Systemd
sudo journalctl -u keycloak -f

# File logs (if configured)
tail -f /opt/keycloak/data/log/keycloak.log
```

### Common Issues

#### 1. Database Connection Failed

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test connection
psql -h localhost -U keycloak -d keycloak

# Check Keycloak can reach DB
docker exec keycloak-db pg_isready
```

#### 2. Port Already in Use

```bash
# Find process using port 8080
sudo lsof -i :8080
sudo netstat -tulpn | grep :8080

# Kill process
sudo kill -9 <PID>
```

#### 3. Hostname Issues

```bash
# Check hostname configuration
docker exec keycloak env | grep KC_HOSTNAME

# Update if needed
KC_HOSTNAME=your-actual-hostname
KC_HOSTNAME_STRICT=false
```

#### 4. Memory Issues

```bash
# Increase memory limits
JAVA_OPTS="-Xms2048m -Xmx4096m"

# Or in docker-compose
environment:
  JAVA_OPTS: "-Xms2048m -Xmx4096m"
```

## Migration from Older Versions

### From Keycloak 23.x to 26.4.5

1. **Backup database:**
```bash
pg_dump -U keycloak keycloak > keycloak_backup.sql
```

2. **Update configuration:**
- Review breaking changes
- Update environment variables
- Update proxy configuration

3. **Test in staging first**

4. **Deploy:**
```bash
# Stop old version
docker stop keycloak-old

# Start new version
docker-compose up -d

# Monitor logs
docker-compose logs -f keycloak
```

## Resources

- [Official Documentation](https://www.keycloak.org/documentation)
- [GitHub Repository](https://github.com/keycloak/keycloak)
- [Release Notes](https://www.keycloak.org/docs/latest/release_notes/)
- [Docker Hub](https://quay.io/repository/keycloak/keycloak)
- [Community Forum](https://github.com/keycloak/keycloak/discussions)

## Next Steps

1. ✅ Set up Keycloak with Docker Compose
2. ✅ Configure Nginx reverse proxy
3. ✅ Set up SSL certificates
4. ✅ Configure realms and clients
5. ✅ Integrate with your application
6. ✅ Set up monitoring
7. ✅ Configure backups
8. ✅ Test authentication flow

Happy Keycloak-ing! 🔐

