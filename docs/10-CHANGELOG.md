# Changelog

All notable changes to the 3D Models Showcase project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-22

### Added

#### Core Features
- 🎨 **Showcase Page** with modern, responsive design
- 🎮 **3D Model Viewer** using React Three Fiber and Drei
- 🔍 **Advanced Filtering System**
  - Filter by category
  - Filter by tags
  - Price range filtering
  - Text search
  - Featured models filter
- 📊 **Model Management**
  - Create, read, update, delete operations
  - Thumbnail and model URL management
  - Category organization
  - Tag system
  - Featured/published flags

#### User Features
- 💬 **Comment System**
  - User reviews with star ratings (1-5)
  - Comment moderation (approval required)
  - Author name and email
  - Timestamp display
- 🛒 **Marketplace Integration**
  - Links to Unreal Engine Marketplace
  - Links to Unity Asset Store
  - Price display
- 📱 **Responsive Design**
  - Mobile-friendly interface
  - Touch-enabled 3D viewer controls
  - Adaptive layouts

#### Admin Features
- 🔐 **Keycloak Authentication**
  - Role-based access control
  - Admin role requirement
  - Secure authentication flow
  - SSO support
- 📝 **Admin Dashboard**
  - Overview statistics
  - Model management interface
  - Comment moderation panel
  - Quick actions
- ✅ **Content Management**
  - Create new models
  - Edit existing models
  - Delete models
  - Approve/reject comments
  - Publish/unpublish content

#### Technical Implementation
- ⚡ **Next.js 16 App Router**
  - Server and client components
  - API routes
  - Dynamic routing
  - Optimized builds
- 🗄️ **Database with Prisma ORM**
  - PostgreSQL support
  - Type-safe queries
  - Migrations system
  - Seeding capability
- 🎨 **Tailwind CSS 4**
  - Modern styling
  - Dark mode ready
  - Custom components
- 📦 **State Management**
  - Zustand for filters
  - Zustand for authentication
  - Local state where appropriate

#### API Endpoints

**Public APIs:**
- `GET /api/models` - List all published models with filters
- `GET /api/models/[slug]` - Get model details
- `GET /api/categories` - List all categories
- `POST /api/comments` - Submit a comment

**Admin APIs:**
- `GET /api/admin/models` - List all models (including unpublished)
- `POST /api/admin/models` - Create new model
- `PUT /api/admin/models/[id]` - Update model
- `DELETE /api/admin/models/[id]` - Delete model
- `GET /api/admin/comments` - List all comments
- `POST /api/admin/comments/[id]/approve` - Approve comment
- `DELETE /api/admin/comments/[id]` - Delete comment

#### Components
- `ModelViewer` - Interactive 3D model display
- `ModelCard` - Model preview card
- `ModelGrid` - Grid layout with pagination
- `ModelFilters` - Filter sidebar
- `CommentSection` - Comments and review form
- `MarketplaceLinks` - Purchase links component
- `KeycloakProvider` - Authentication provider
- `ProtectedRoute` - Route protection HOC

#### Documentation
- 📚 README.md - Complete project documentation
- 🚀 QUICKSTART.md - Quick setup guide
- 🔒 KEYCLOAK_SETUP.md - Authentication setup
- 🌐 DEPLOYMENT.md - Deployment guides
- 🎨 3D_MODELS_GUIDE.md - 3D model preparation guide
- 📝 CHANGELOG.md - This file

#### Database Schema
- **Models** table - 3D model information
- **Categories** table - Model categories
- **Comments** table - User reviews
- **Users** table - User accounts (Keycloak integration)

#### Scripts
- `npm run dev` - Development server
- `npm run build` - Production build
- `npm run start` - Production server
- `npm run db:generate` - Generate Prisma client
- `npm run db:migrate` - Run migrations
- `npm run db:seed` - Seed database
- `npm run db:studio` - Open Prisma Studio

### Dependencies
- Next.js 16.0.3
- React 19.2.0
- Three.js 0.181.2
- React Three Fiber 9.4.0
- React Three Drei 10.7.7
- Prisma 7.0.0
- Keycloak Server 26.4.5 (latest)
- Keycloak.js 26.2.1 (client library, fully compatible)
- Zustand 5.0.8
- Axios 1.13.2
- Tailwind CSS 4
- TypeScript 5

### Development Tools
- ESLint 9 with Next.js config
- TypeScript strict mode
- Prisma Studio for database management
- Hot module replacement

### Sample Data
- 5 categories (Characters, Environment, Props, Weapons, Vehicles)
- 4 sample models with demo data
- 3 sample comments
- Sample tags and metadata

## [Unreleased]

### Planned Features
- [ ] File upload for models and thumbnails
- [ ] Advanced analytics and statistics
- [ ] Email notifications for comments
- [ ] Social media integration
- [ ] Multi-language support (i18n)
- [ ] Advanced 3D viewer controls
  - Wireframe mode
  - Animation playback
  - Material editor
- [ ] Model comparison feature
- [ ] User wishlists
- [ ] Search with Algolia/Meilisearch
- [ ] GraphQL API option
- [ ] Webhook integrations
- [ ] Export functionality
- [ ] Batch operations
- [ ] Advanced caching strategies
- [ ] Progressive Web App (PWA)
- [ ] Server-side rendering optimization

### Known Issues
- None at initial release

### Security
- All API routes implement basic authentication checks
- SQL injection protection via Prisma
- XSS protection via React
- CSRF protection recommended for production

## Contributing

See [README.md](./README.md#contributing) for contribution guidelines.

## License

MIT License - See LICENSE file for details

---

### Version History

- **0.1.0** - Initial release (2025-11-22)

### Versioning Policy

- **Major version** (X.0.0): Breaking changes
- **Minor version** (0.X.0): New features, backwards compatible
- **Patch version** (0.0.X): Bug fixes, minor improvements

---

For detailed documentation, see [README.md](./README.md)

