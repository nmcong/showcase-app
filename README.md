# 3D Models Showcase

A professional showcase platform for 3D models with marketplace integration (Unreal Engine & Unity), built with Next.js, React Three Fiber, Prisma, and Keycloak authentication.

## Features

### Frontend Features
- 🎨 **Modern UI** - Beautiful, responsive design with Tailwind CSS
- 🎮 **3D Model Viewer** - Interactive 3D model preview using React Three Fiber
- 🔍 **Advanced Filtering** - Filter by category, tags, price range, and search
- ⭐ **Featured Models** - Highlight your best models
- 💬 **User Comments & Reviews** - Star ratings and text reviews with moderation
- 🛒 **Marketplace Integration** - Direct links to Unreal and Unity marketplaces
- 📱 **Responsive Design** - Works perfectly on desktop, tablet, and mobile

### Admin Features
- 🔐 **Keycloak Authentication** - Secure admin access with role-based authentication
- 📝 **Model Management** - Create, edit, and delete models
- ✅ **Comment Moderation** - Approve or reject user comments
- 📊 **Dashboard** - Overview of models, comments, and statistics

## Tech Stack

- **Frontend**: Next.js 16, React 19, TypeScript
- **3D Rendering**: Three.js, React Three Fiber, Drei
- **Styling**: Tailwind CSS 4
- **State Management**: Zustand
- **Authentication**: Keycloak 26.4.5 (server) + keycloak-js 26.2.1 (client)
- **Database**: PostgreSQL with Prisma ORM
- **API**: Next.js API Routes

## Prerequisites

Before you begin, ensure you have the following installed:
- Node.js 20+ and npm
- PostgreSQL database
- Keycloak server (optional for local development)

## Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd showcase-app
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**

Create a `.env.local` file in the root directory:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/showcase_db?schema=public"

# Keycloak Configuration
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-client-secret"

# Next.js
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

4. **Set up the database**

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init

# (Optional) Seed the database
npx prisma db seed
```

5. **Set up Keycloak** (if using authentication)

- Start Keycloak server
- Create a new realm called `showcase-realm`
- Create a client called `showcase-client`
- Add admin role to your user
- Update `.env.local` with your Keycloak configuration

## Running the Application

### Development Mode

```bash
npm run dev
```

Visit `http://localhost:3000` to see the showcase page.

### Production Build

```bash
npm run build
npm start
```

## Project Structure

```
showcase-app/
├── prisma/
│   └── schema.prisma          # Database schema
├── public/                     # Static files
├── src/
│   ├── app/                    # Next.js app directory
│   │   ├── api/                # API routes
│   │   │   ├── models/         # Model endpoints
│   │   │   ├── categories/     # Category endpoints
│   │   │   ├── comments/       # Comment endpoints
│   │   │   └── admin/          # Admin endpoints
│   │   ├── admin/              # Admin pages
│   │   ├── models/             # Model detail pages
│   │   ├── layout.tsx          # Root layout
│   │   └── page.tsx            # Home page
│   ├── components/             # React components
│   │   ├── 3d/                 # 3D viewer components
│   │   ├── auth/               # Authentication components
│   │   ├── comments/           # Comment components
│   │   ├── filters/            # Filter components
│   │   ├── models/             # Model components
│   │   └── providers/          # Context providers
│   ├── lib/                    # Utility libraries
│   │   ├── prisma.ts           # Prisma client
│   │   └── keycloak.ts         # Keycloak configuration
│   ├── store/                  # Zustand stores
│   │   ├── useAuthStore.ts     # Auth state
│   │   └── useFilterStore.ts   # Filter state
│   └── types/                  # TypeScript types
│       └── index.ts
├── .env.local                  # Environment variables (create this)
├── package.json
├── tsconfig.json
└── README.md
```

## API Endpoints

### Public Endpoints

- `GET /api/models` - Get all published models (with filters)
- `GET /api/models/[slug]` - Get a specific model
- `GET /api/categories` - Get all categories
- `POST /api/comments` - Submit a comment/review

### Admin Endpoints (Requires Authentication)

- `GET /api/admin/models` - Get all models
- `POST /api/admin/models` - Create a new model
- `PUT /api/admin/models/[id]` - Update a model
- `DELETE /api/admin/models/[id]` - Delete a model
- `GET /api/admin/comments` - Get all comments
- `POST /api/admin/comments/[id]/approve` - Approve a comment
- `DELETE /api/admin/comments/[id]` - Delete a comment

## Database Schema

### Models
- id, title, slug, description
- thumbnailUrl, modelUrl
- price, unrealMarketUrl, unityMarketUrl
- tags[], views, featured, published
- categoryId, createdAt, updatedAt

### Categories
- id, name, slug, description
- createdAt, updatedAt

### Comments
- id, authorName, authorEmail
- content, rating (1-5)
- approved, modelId
- createdAt, updatedAt

### Users
- id, keycloakId, email, name
- role, createdAt, updatedAt

## Usage

### Adding a New Model

1. Log in as an admin
2. Go to Admin Dashboard
3. Click "Add New Model"
4. Fill in the form:
   - Title, description, category
   - Upload thumbnail and 3D model (GLB/GLTF format)
   - Add marketplace links (Unreal/Unity)
   - Set price and tags
   - Mark as featured/published
5. Submit

### Managing Comments

1. Go to Admin Dashboard > Comments
2. View pending comments
3. Approve or delete comments
4. Approved comments appear on model pages

### Filtering Models (User Side)

Users can filter models by:
- Search text
- Category
- Tags
- Price range
- Featured only

## Customization

### Adding New Categories

Use Prisma Studio or create a migration:

```bash
npx prisma studio
```

### Customizing the Theme

Edit Tailwind configuration in `tailwind.config.js` and `globals.css`.

### Adding More Model Formats

The 3D viewer supports GLB and GLTF formats. To add more formats, modify the `ModelViewer` component.

## Deployment

### Vercel (Recommended)

1. Push your code to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy

### Docker

```bash
docker build -t showcase-app .
docker run -p 3000:3000 showcase-app
```

## Troubleshooting

### 3D Models Not Loading
- Ensure model URLs are accessible
- Check CORS settings
- Verify GLB/GLTF format

### Keycloak Authentication Issues
- Verify Keycloak URL and realm settings
- Check client configuration
- Ensure user has admin role

### Database Connection Issues
- Verify DATABASE_URL in .env.local
- Ensure PostgreSQL is running
- Run `npx prisma generate`

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License - feel free to use this project for your own showcase!

## 🚀 Quick Start

**→ See [QUICK-START.md](./QUICK-START.md) for detailed quick start guide**

### Local Development
```bash
npm install
cp .env.local.example .env.local
nano .env.local  # Configure
npm run dev
```

### Production Deployment
```bash
cp env.deploy.example .env.deploy
nano .env.deploy  # Configure VPS & credentials
chmod +x scripts/*.sh
./scripts/full-deploy.sh
```

✅ **All deployment fixes integrated** - No manual fixes needed!

## Environment Files

Project này sử dụng **2 env files** riêng biệt:

| File | Purpose | Documentation |
|------|---------|---------------|
| `.env.local` | Local development (Next.js app) | Standard Next.js env file |
| `.env.deploy` | VPS deployment (scripts) | Used by deployment scripts |

**📖 Chi tiết**: [ENV-FILES-GUIDE.md](./ENV-FILES-GUIDE.md)

## Documentation

Comprehensive guides available (organized by reading priority):

### 🎯 Getting Started
**🆕 [Quick Start Guide](./QUICK-START.md)** - Get started in 5 minutes  
**🆕 [Environment Files Guide](./ENV-FILES-GUIDE.md)** - Understand .env.local vs .env.deploy

### ⚡ Production Deployment (v2.0 - RECOMMENDED)
**🆕 [Complete Deployment Guide - Fixed Version](./docs/13-DEPLOYMENT-FIXED.md)** - All issues resolved!  
**🆕 [Troubleshooting Guide](./docs/12-TROUBLESHOOTING.md)** - All errors and solutions

### 🚀 Getting Started
1. 📖 **[Quick Start Guide](./docs/01-QUICKSTART.md)** - Get started in 5 minutes
2. 🐳 **[No Docker Deployment](./docs/02-NO_DOCKER_DEPLOYMENT.md)** - Deploy without Docker (optimal for 4GB RAM)
3. 🤖 **[Deployment Scripts Summary](./docs/03-DEPLOYMENT_SCRIPTS_SUMMARY.md)** - Automated deployment overview

### 🔧 Deployment Guides
4. 🚀 **[VPS Deployment Guide](./docs/04-VPS_DEPLOYMENT_GUIDE.md)** - Complete VPS setup (manual)
5. 💻 **[Automated Deployment Scripts](./scripts/README.md)** - One-command deployment
6. 📦 **[Other Deployment Options](./docs/09-DEPLOYMENT.md)** - Vercel, Railway, Docker, etc.

### 🔐 Authentication
7. 🔑 **[Keycloak Setup](./docs/05-KEYCLOAK_SETUP.md)** - Authentication configuration
8. 🔄 **[Keycloak 26.4.5 Migration](./docs/06-KEYCLOAK_26_MIGRATION.md)** - Latest Keycloak version

### 📚 Additional Resources
9. 🎨 **[3D Models Guide](./docs/07-3D_MODELS_GUIDE.md)** - Prepare and optimize 3D models
10. 📊 **[Version Compatibility](./docs/08-VERSION_COMPATIBILITY.md)** - Component versions
11. 📝 **[Changelog](./docs/10-CHANGELOG.md)** - Version history
12. 🔄 **[Updates Summary](./docs/11-UPDATES_SUMMARY.md)** - Recent updates

## Support

For issues and questions:
- Open an issue on GitHub
- Check the documentation
- Review the API endpoints

## Roadmap

### Planned Features
- [ ] File upload for models and thumbnails (S3/R2 integration)
- [ ] Advanced analytics dashboard
- [ ] Email notifications for comments
- [ ] Social media integration (Share models)
- [ ] Multi-language support (i18n)
- [ ] Advanced 3D viewer controls
  - [ ] Wireframe mode
  - [ ] Animation playback
  - [ ] Lighting controls
  - [ ] Environment presets
- [ ] Model comparison feature
- [ ] User wishlists and favorites
- [ ] Shopping cart integration
- [ ] Payment gateway (Stripe/PayPal)
- [ ] Affiliate tracking
- [ ] SEO optimization
- [ ] Sitemap generation

### Current Version
- ✅ Keycloak 26.4.5 integration
- ✅ Complete showcase functionality
- ✅ Admin dashboard
- ✅ 3D model viewer
- ✅ Comment system with moderation
- ✅ Advanced filtering
- ✅ Marketplace links

## 📖 Complete Documentation

All documentation is organized in [`docs/`](./docs/) folder:

**→ Start here**: [`docs/README.md`](./docs/README.md) - Complete documentation index with reading order

## Credits

Built with ❤️ using:
- [Next.js](https://nextjs.org/)
- [React Three Fiber](https://docs.pmnd.rs/react-three-fiber)
- [Prisma](https://www.prisma.io/)
- [Keycloak](https://www.keycloak.org/)
- [Tailwind CSS](https://tailwindcss.com/)

## License

MIT License - feel free to use this project for your own showcase!

## Support

For issues and questions:
- 📚 Check [`docs/README.md`](./docs/README.md) for complete documentation
- 💬 Open an issue on GitHub
- 📖 Review troubleshooting sections in relevant guides
