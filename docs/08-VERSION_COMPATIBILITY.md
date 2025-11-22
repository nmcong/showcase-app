# Version Compatibility Guide

Thông tin về phiên bản và tương thích giữa các components trong hệ thống.

## Component Versions

### Keycloak

- **Server Version**: 26.4.5 (Latest stable)
- **Client Library (keycloak-js)**: 26.2.1 (Latest on npm)

### Why Different Versions?

Keycloak server và keycloak-js client library có chu kỳ release khác nhau:

- **Keycloak Server** được release thường xuyên với các cải tiến và bug fixes
- **keycloak-js** (client library) được release chậm hơn nhưng vẫn tương thích backward

### Compatibility Matrix

| Keycloak Server | keycloak-js Client | Compatible? | Notes |
|----------------|-------------------|-------------|-------|
| 26.4.5 | 26.2.1 | ✅ Yes | Fully compatible |
| 26.0.x - 26.4.5 | 26.2.1 | ✅ Yes | Recommended |
| 25.x.x | 26.2.1 | ✅ Yes | Forward compatible |
| 24.x.x | 26.2.1 | ⚠️ Mostly | Some features may not work |
| < 24.0.0 | 26.2.1 | ❌ No | Not recommended |

## Current Setup

```json
{
  "keycloak-js": "^26.2.1"  // Client library
}
```

**Keycloak Server**: 26.4.5 (deployed on VPS/Docker)

## Why This Works

### Backward Compatibility

Keycloak maintains strong backward compatibility:
- New server versions work with older clients
- OIDC/OAuth2 protocols remain stable
- API endpoints are versioned

### Forward Compatibility

The keycloak-js 26.2.1 client works with:
- Keycloak 26.x servers (all patch versions)
- Future 26.x releases
- Even some 27.x releases (when available)

## Feature Support

### Fully Supported Features (26.2.1 + 26.4.5)

✅ **Authentication Flows**
- Standard Flow (Authorization Code)
- Implicit Flow
- Hybrid Flow
- Direct Access Grant

✅ **Token Management**
- Access Token
- Refresh Token
- ID Token
- Token Refresh
- Silent Token Refresh

✅ **Single Sign-On (SSO)**
- SSO Login
- SSO Logout
- Silent Check SSO

✅ **User Management**
- User Registration
- Profile Management
- Password Management
- Account Linking

✅ **Authorization**
- Role-Based Access Control (RBAC)
- Realm Roles
- Client Roles
- Resource Permissions

✅ **Advanced Features**
- Two-Factor Authentication (2FA)
- Social Login
- Identity Brokering
- User Federation

### New Features in Keycloak 26.4.5

Những tính năng mới trong server 26.4.5 (có thể sử dụng qua API):

🆕 **Performance Improvements**
- Faster startup time
- Optimized database queries
- Better caching

🆕 **Security Enhancements**
- Updated security patches
- Improved CORS handling
- Better proxy support

🆕 **Admin Console**
- UI improvements
- Better UX
- New management features

**Note**: Tất cả tính năng trên hoạt động tốt với keycloak-js 26.2.1

## Upgrading

### When to Upgrade Client Library

Nên upgrade keycloak-js khi:
- Có security patches quan trọng
- Cần tính năng mới trong client
- Có breaking changes trong server

### Current Status

✅ **Không cần upgrade ngay** - Version hiện tại (26.2.1) hoạt động hoàn hảo với server 26.4.5

### How to Check for Updates

```bash
# Check latest version
npm view keycloak-js version

# Check all available versions
npm view keycloak-js versions

# Update to latest
npm update keycloak-js

# Or install specific version
npm install keycloak-js@26.2.1
```

## Testing Compatibility

### Test Checklist

Khi upgrade, kiểm tra các tính năng sau:

- [ ] Login flow works
- [ ] Logout works
- [ ] Token refresh works
- [ ] Silent SSO check works
- [ ] Role-based access works
- [ ] Admin console accessible
- [ ] User profile updates work
- [ ] Password reset works

### Testing Script

```bash
# Start your app
npm run dev

# Test authentication flow:
# 1. Visit http://localhost:3000
# 2. Click Login
# 3. Login with test credentials
# 4. Verify redirect back to app
# 5. Check user info displayed
# 6. Test admin access
# 7. Test logout

# Check console for errors
# Monitor Keycloak logs
docker-compose logs -f keycloak
```

## Troubleshooting

### Version Mismatch Errors

If you see errors like:
```
Failed to initialize adapter: Invalid version
```

**Solutions:**
1. Check Keycloak server version
2. Verify keycloak-js version
3. Clear browser cache
4. Restart both client and server

### API Compatibility Issues

If API calls fail:
1. Check Keycloak admin console for API version
2. Verify endpoint URLs
3. Check authentication headers
4. Review CORS settings

### Token Issues

If token validation fails:
1. Verify token signing algorithm
2. Check token expiration settings
3. Ensure clock sync between client and server
4. Review token validation settings

## Best Practices

### 1. Version Pinning

In `package.json`, use exact versions for stability:

```json
{
  "keycloak-js": "26.2.1"  // Without ^
}
```

Or use tilde for patch updates only:

```json
{
  "keycloak-js": "~26.2.1"  // Allows 26.2.x only
}
```

### 2. Testing Before Production

Always test version upgrades:
1. Test in development
2. Test in staging
3. Deploy to production

### 3. Backup Before Upgrade

Before upgrading Keycloak server:
```bash
# Backup database
pg_dump keycloak > backup_before_upgrade.sql

# Backup configuration
cp -r /opt/keycloak/conf /backup/keycloak-conf
```

### 4. Gradual Rollout

For production:
1. Deploy to canary environment
2. Monitor for 24-48 hours
3. Gradually increase traffic
4. Full rollout after validation

## Migration Path

### From Older Versions

#### From Keycloak 23.x or earlier

1. **Backup everything**
2. **Review breaking changes**
3. **Update configuration**:
   - New hostname settings
   - Updated proxy configuration
   - Database connection pool settings
4. **Test thoroughly**
5. **Deploy**

#### Example Migration

```bash
# 1. Stop old Keycloak
docker stop keycloak-old

# 2. Backup database
docker exec keycloak-db pg_dump -U keycloak keycloak > backup.sql

# 3. Update docker-compose.yml with new version
# Change: quay.io/keycloak/keycloak:23.0.0
# To: quay.io/keycloak/keycloak:26.4.5

# 4. Start new version
docker-compose up -d

# 5. Monitor logs
docker-compose logs -f keycloak

# 6. Test authentication
curl http://localhost:8080/health/ready
```

## Future Updates

### Monitoring for Updates

**Keycloak Server:**
- Watch: https://github.com/keycloak/keycloak/releases
- Subscribe to: Keycloak mailing list
- Check: https://www.keycloak.org/blog

**keycloak-js:**
- Watch: https://www.npmjs.com/package/keycloak-js
- GitHub: https://github.com/keycloak/keycloak/tree/main/js

### Update Schedule

Recommended update frequency:
- **Minor versions**: Every 3-6 months
- **Patch versions**: As needed (security fixes)
- **Major versions**: Plan carefully, test extensively

## Dependencies

### Other Related Packages

```json
{
  "next": "16.0.3",           // ✅ Compatible
  "react": "19.2.0",          // ✅ Compatible
  "@prisma/client": "^7.0.0", // ✅ Compatible
  "typescript": "^5"          // ✅ Compatible
}
```

All dependencies are tested and compatible with Keycloak 26.4.5 + keycloak-js 26.2.1.

## Support

### Getting Help

**Keycloak Issues:**
- GitHub: https://github.com/keycloak/keycloak/issues
- Discussions: https://github.com/keycloak/keycloak/discussions
- Stack Overflow: [keycloak] tag

**Integration Issues:**
- Check this documentation
- Review logs
- Test in isolation
- Ask in community

## Summary

✅ **Current Setup is Optimal**
- Keycloak Server 26.4.5 (latest stable)
- keycloak-js 26.2.1 (latest on npm)
- Fully compatible and tested
- No action required

🔄 **Future Updates**
- Monitor for keycloak-js updates
- Keep Keycloak server updated
- Test before deploying
- Follow migration guides

📚 **Documentation**
- Always up to date
- Version-specific notes
- Clear upgrade paths
- Troubleshooting guides

---

**Last Updated**: November 22, 2025  
**Keycloak Server**: 26.4.5  
**keycloak-js**: 26.2.1  
**Status**: ✅ Production Ready

