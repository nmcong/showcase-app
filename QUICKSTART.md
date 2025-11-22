# Quick Start Guide

Get your 3D Models Showcase up and running in 5 minutes!

## Prerequisites

- Node.js 20+ installed
- PostgreSQL database (or use a cloud database)
- Git

## Step 1: Clone and Install

```bash
# Clone the repository
git clone <your-repo-url>
cd showcase-app

# Install dependencies
npm install
```

## Step 2: Set Up Database

### Option A: Local PostgreSQL

```bash
# Create database
createdb showcase_db

# Or using psql
psql -U postgres
CREATE DATABASE showcase_db;
\q
```

### Option B: Cloud Database (Recommended)

Use one of these services:
- [Supabase](https://supabase.com) - Free tier available
- [Railway](https://railway.app) - Easy setup
- [Neon](https://neon.tech) - Serverless PostgreSQL

Get your DATABASE_URL from the service.

## Step 3: Configure Environment

Create `.env.local` file in the root directory:

```env
DATABASE_URL="postgresql://user:password@localhost:5432/showcase_db?schema=public"

# Optional: Keycloak (skip for now if testing without auth)
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"

NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

## Step 4: Initialize Database

```bash
# Generate Prisma client
npm run db:generate

# Run migrations
npm run db:migrate

# Seed with sample data
npm run db:seed
```

## Step 5: Start Development Server

```bash
npm run dev
```

Visit http://localhost:3000 - You should see the showcase page with sample models!

## What You Get

✅ **Showcase Page** - Browse 3D models with filters
✅ **3D Model Viewer** - Interactive 3D preview (sample models included)
✅ **Categories** - Organized model categories
✅ **Comments** - User reviews with ratings
✅ **Sample Data** - 4 sample models to test with

## Next Steps

### 1. Add Your Own Models

You have two options:

#### Option A: Use the API

```bash
# Example: Add a model
curl -X POST http://localhost:3000/api/admin/models \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My 3D Model",
    "slug": "my-3d-model",
    "description": "An awesome 3D model",
    "thumbnailUrl": "https://example.com/thumb.jpg",
    "modelUrl": "https://example.com/model.glb",
    "categoryId": "YOUR_CATEGORY_ID",
    "published": true
  }'
```

#### Option B: Use Prisma Studio

```bash
npm run db:studio
```

Opens a visual database editor at http://localhost:5555

### 2. Set Up Authentication (Optional)

For admin features, set up Keycloak:

```bash
# Run Keycloak with Docker
docker run -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:latest \
  start-dev
```

Then follow [KEYCLOAK_SETUP.md](./KEYCLOAK_SETUP.md) for detailed configuration.

### 3. Customize Your Showcase

Edit these files:
- `src/app/page.tsx` - Home page
- `src/app/globals.css` - Styles
- `src/components/` - UI components

## Working Without Keycloak

If you want to test without Keycloak:

1. Comment out Keycloak in layout:
```typescript
// src/app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        {/* <KeycloakProvider> */}
          {children}
        {/* </KeycloakProvider> */}
      </body>
    </html>
  );
}
```

2. Remove authentication check in admin:
```typescript
// src/app/admin/page.tsx
export default function AdminPage() {
  // return <ProtectedRoute><AdminDashboard /></ProtectedRoute>
  return <AdminDashboard />; // No protection
}
```

3. Remove Bearer token from admin API calls:
```typescript
// Remove Authorization header in admin API routes
// const token = request.headers.get('Authorization')
```

## Sample 3D Models

The seed data includes sample models using free GLB files. Replace with your own:

### Where to Get 3D Models:
- [Sketchfab](https://sketchfab.com) - Many free models
- [Poly Pizza](https://poly.pizza) - Free low-poly models
- [Quaternius](https://quaternius.com) - Free game assets
- [Kenney](https://kenney.nl) - Free game assets

### Converting Models to GLB:
- Use [Blender](https://www.blender.org) (Free)
- Export as GLB/GLTF 2.0
- Keep file size under 10MB for web

## Common Issues

### Database Connection Error

```
Error: Can't reach database server at `localhost:5432`
```

**Solution**: Make sure PostgreSQL is running:
```bash
# Check if PostgreSQL is running
pg_isready

# Start PostgreSQL (depends on your OS)
# macOS with Homebrew:
brew services start postgresql

# Linux:
sudo systemctl start postgresql

# Windows: Start from Services
```

### 3D Model Not Loading

**Solution**: 
- Check if model URL is accessible
- Verify it's in GLB or GLTF format
- Check browser console for errors
- Try with sample models first

### Port Already in Use

```
Error: Port 3000 is already in use
```

**Solution**:
```bash
# Kill process using port 3000
# macOS/Linux:
lsof -ti:3000 | xargs kill -9

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Or use a different port
PORT=3001 npm run dev
```

## Development Workflow

```bash
# 1. Make changes to code
# 2. Save files (hot reload is automatic)
# 3. If you change database schema:
npm run db:migrate

# 4. View database:
npm run db:studio

# 5. Reset database (if needed):
npx prisma migrate reset
npm run db:seed
```

## Production Deployment

Ready to deploy? See [DEPLOYMENT.md](./DEPLOYMENT.md) for:
- Vercel deployment (easiest)
- Docker deployment
- Self-hosted options

Quick Vercel deploy:
```bash
npm i -g vercel
vercel
```

## Getting Help

- 📚 Check [README.md](./README.md) for full documentation
- 🔒 See [KEYCLOAK_SETUP.md](./KEYCLOAK_SETUP.md) for authentication
- 🚀 See [DEPLOYMENT.md](./DEPLOYMENT.md) for deployment guides
- 🐛 Check the GitHub issues

## Project Structure

```
showcase-app/
├── src/
│   ├── app/              # Next.js pages
│   │   ├── page.tsx      # 🏠 Home page
│   │   ├── admin/        # 🔐 Admin panel
│   │   └── api/          # 🔌 API routes
│   ├── components/       # ⚛️ React components
│   └── lib/              # 🛠️ Utilities
├── prisma/
│   ├── schema.prisma     # 📊 Database schema
│   └── seed.ts           # 🌱 Sample data
└── public/               # 📁 Static files
```

## Useful Commands

```bash
# Development
npm run dev              # Start dev server
npm run db:studio        # Open database GUI

# Database
npm run db:generate      # Generate Prisma client
npm run db:migrate       # Run migrations
npm run db:seed          # Seed sample data

# Production
npm run build            # Build for production
npm start                # Start production server
```

## What's Next?

1. ✅ Add your 3D models
2. ✅ Customize the design
3. ✅ Set up authentication
4. ✅ Deploy to production
5. ✅ Share your showcase!

Happy showcasing! 🎉

