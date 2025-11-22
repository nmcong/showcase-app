# Keycloak Setup Guide

This guide will help you set up Keycloak for the 3D Models Showcase application.

## Option 1: Using Docker (Recommended for Development)

### 1. Start Keycloak with Docker

```bash
# Chạy Keycloak 26.4.5 trong Docker (Development mode)
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_HOSTNAME=localhost \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HTTP_ENABLED=true \
  quay.io/keycloak/keycloak:26.4.5 \
  start-dev

# Hoặc với database (Production mode)
docker run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://host.docker.internal:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KC_HOSTNAME=localhost \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HTTP_ENABLED=true \
  -e KC_PROXY=edge \
  quay.io/keycloak/keycloak:26.4.5 \
  start --optimized

# Xem logs
docker logs -f keycloak

# Stop container
docker stop keycloak
docker rm keycloak
```

### 2. Access Keycloak Admin Console

- Open: http://localhost:8080
- Login with:
  - Username: `admin`
  - Password: `admin`

## Configuration Steps

### 1. Create a Realm

1. Click on the dropdown in the top-left (says "Master")
2. Click "Create Realm"
3. Name: `showcase-realm`
4. Click "Create"

### 2. Create a Client

1. Go to "Clients" in the left sidebar
2. Click "Create client"
3. Client ID: `showcase-client`
4. Client Protocol: `openid-connect`
5. Click "Next"
6. Enable "Standard flow" and "Direct access grants"
7. Click "Save"

### 3. Configure Client Settings

1. In the client settings:
   - Valid redirect URIs: `http://localhost:3000/*`
   - Valid post logout redirect URIs: `http://localhost:3000/*`
   - Web origins: `http://localhost:3000`
   - Access Type: `public` (for frontend) or `confidential` (for backend)

2. If you chose "confidential":
   - Go to "Credentials" tab
   - Copy the "Client Secret"
   - Add to your `.env.local` as `KEYCLOAK_CLIENT_SECRET`

### 4. Create Realm Roles

1. Go to "Realm roles" in the left sidebar
2. Click "Create role"
3. Create the following roles:
   - Name: `admin`
   - Description: "Administrator role"
   - Click "Save"
   
4. Create another role:
   - Name: `user`
   - Description: "Regular user role"
   - Click "Save"

### 5. Create a Test User

1. Go to "Users" in the left sidebar
2. Click "Add user"
3. Fill in:
   - Username: `testadmin`
   - Email: `admin@example.com`
   - First name: `Test`
   - Last name: `Admin`
   - Email verified: ON
4. Click "Create"

### 6. Set User Password

1. Click on the user you just created
2. Go to "Credentials" tab
3. Click "Set password"
4. Enter password: `admin123`
5. Turn OFF "Temporary"
6. Click "Save"
7. Click "Save password"

### 7. Assign Admin Role to User

1. Still in the user details
2. Go to "Role mapping" tab
3. Click "Assign role"
4. Select `admin` role
5. Click "Assign"

### 8. Update Environment Variables

Update your `.env.local`:

```env
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-client-secret-if-confidential"
```

## Option 2: Using Keycloak without Docker

### Download and Install

1. Download Keycloak 26.4.5 from: https://github.com/keycloak/keycloak/releases/tag/26.4.5
2. Extract the archive
3. Navigate to the `bin` directory
4. Set admin credentials and start Keycloak:

**Windows:**
```cmd
set KEYCLOAK_ADMIN=admin
set KEYCLOAK_ADMIN_PASSWORD=admin
kc.bat start-dev
```

**Linux/Mac:**
```bash
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
./kc.sh start-dev
```

**For Production Mode:**
```bash
# Build configuration first
./kc.sh build

# Then start with production settings
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=YourStrongPassword
./kc.sh start --optimized --hostname=localhost --http-enabled=true
```

Then follow the same configuration steps as above.

## Testing the Setup

### 1. Test Login

1. Start your Next.js application: `npm run dev`
2. Visit: http://localhost:3000
3. Click "Login" button
4. You should be redirected to Keycloak login page
5. Login with:
   - Username: `testadmin`
   - Password: `admin123`
6. You should be redirected back to the app

### 2. Test Admin Access

1. After logging in, you should see "Admin Panel" button
2. Click it to access the admin dashboard
3. You should be able to create and manage models

## Production Considerations

### 1. Use HTTPS

In production, always use HTTPS for both your application and Keycloak.

### 2. Secure Client Credentials

- Use confidential clients with client secrets
- Store secrets securely (environment variables, secrets manager)
- Never commit secrets to version control

### 3. Configure Proper Redirect URIs

Only allow specific redirect URIs, not wildcards:
```
https://yourdomain.com/
https://yourdomain.com/admin
```

### 4. Enable Email Verification

1. In Realm Settings > Login tab
2. Enable "Verify email"
3. Configure email settings in Realm Settings > Email tab

### 5. Set Up Token Lifespans

1. Go to Realm Settings > Tokens tab
2. Configure appropriate token lifespans:
   - Access Token Lifespan: 5 minutes
   - SSO Session Idle: 30 minutes
   - SSO Session Max: 10 hours

### 6. Enable Additional Security Features

- Two-factor authentication
- Password policies
- Brute force detection
- HTTPS requirement

## Troubleshooting

### CORS Issues

If you encounter CORS errors:
1. Check Web Origins in client settings
2. Add your frontend URL: `http://localhost:3000`

### Redirect URI Mismatch

Error: "Invalid redirect URI"
- Ensure redirect URIs in client settings match your app URLs
- Include trailing slashes if your app uses them

### Token Expired

If tokens expire too quickly:
- Increase token lifespans in Realm Settings > Tokens
- Implement token refresh in your application

### Connection Refused

If can't connect to Keycloak:
- Ensure Keycloak is running on the correct port
- Check firewall settings
- Verify KEYCLOAK_URL in environment variables

## Advanced Configuration

### Custom Themes

1. Create theme directory in Keycloak
2. Customize login pages
3. Match your application branding

### User Federation

1. Connect to LDAP or Active Directory
2. Sync existing users
3. Configure attribute mappings

### Social Login

1. Enable social identity providers
2. Configure Google, Facebook, GitHub, etc.
3. Test social login flow

## Resources

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak Server Admin](https://www.keycloak.org/docs/latest/server_admin/)
- [Keycloak Getting Started](https://www.keycloak.org/guides#getting-started)

## Support

For Keycloak-specific issues:
- [Keycloak Discourse](https://keycloak.discourse.group/)
- [GitHub Issues](https://github.com/keycloak/keycloak/issues)

