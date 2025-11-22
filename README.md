# 3D Models Showcase

A professional showcase platform for 3D models with Keycloak authentication, built with Next.js and React Three Fiber.

## ✨ Features

### Frontend Features
- 🎨 **Modern UI** - Beautiful, responsive design with Tailwind CSS 4
- 🎮 **3D Model Viewer** - Interactive 3D model preview using React Three Fiber
- 🔍 **Advanced Filtering** - Filter by category, tags, price range, and search
- ⭐ **Featured Models** - Highlight your best models
- 🛒 **Marketplace Integration** - Direct links to Unreal and Unity marketplaces
- 📱 **Responsive Design** - Works perfectly on desktop, tablet, and mobile

### Authentication
- 🔐 **Keycloak Authentication** - Secure access with role-based authentication
- 👤 **User Management** - Seamless login/logout experience

## 🚀 Tech Stack

- **Frontend**: Next.js 16, React 19, TypeScript
- **3D Rendering**: Three.js, React Three Fiber, Drei
- **Styling**: Tailwind CSS 4
- **State Management**: Zustand
- **Authentication**: Keycloak 26.4.5 (server) + keycloak-js 26.2.1 (client)
- **API**: Next.js API Routes

## 📋 Prerequisites

Before you begin, ensure you have:
- Node.js 20+ and npm
- Keycloak server (optional for local development)

## 🛠️ Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/showcase-app.git
cd showcase-app
```

### 2. Install dependencies
```bash
npm install
```

### 3. Set up environment variables

Create a `.env.local` file in the root directory:

```env
# Keycloak Configuration
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-client-secret"

# Next.js
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

### 4. Run the development server

```bash
npm run dev
```

Visit `http://localhost:3000` to see the showcase page!

## 📖 Documentation

Comprehensive documentation is available in the [`docs/`](./docs/) folder:

### 🎯 Getting Started
- **[Environment Files Guide](./docs/00-ENV-FILES-GUIDE.md)** - Understanding `.env.local` vs `.env.deploy`
- **[Quick Start Guide](./docs/01-QUICKSTART.md)** - Get started in 5 minutes
- **[No Docker Deployment](./docs/02-NO_DOCKER_DEPLOYMENT.md)** - Deploy without Docker (optimal for 4GB RAM)

### 🚀 Production Deployment
- **[VPS Deployment Guide](./docs/03-VPS_DEPLOYMENT_GUIDE.md)** - Complete VPS setup (manual)
- **[Deployment Scripts Reference](./docs/04-DEPLOYMENT-SCRIPTS-REFERENCE.md)** - Automated deployment overview
- **[Complete Deployment Guide](./docs/05-DEPLOYMENT-COMPLETE-GUIDE.md)** - All-in-one deployment guide ⭐

### 🔐 Authentication
- **[Keycloak Setup](./docs/06-KEYCLOAK_SETUP.md)** - Authentication configuration
- **[Keycloak 26 Migration](./docs/07-KEYCLOAK_26_MIGRATION.md)** - Latest Keycloak version

### 🔒 SSL & Security
- **[SSL Keycloak Setup](./docs/08-SSL_KEYCLOAK_SETUP.md)** - HTTPS configuration
- **[SSL Certificates Guide](./docs/09-SSL-CERTIFICATES-GUIDE.md)** - Certificate management
- **[SSL Auth Setup](./docs/10-SSL-AUTH-SETUP.md)** - Auth domain SSL

### 📚 Additional Resources
- **[3D Models Guide](./docs/11-3D_MODELS_GUIDE.md)** - Prepare and optimize 3D models
- **[Version Compatibility](./docs/12-VERSION_COMPATIBILITY.md)** - Component versions
- **[Troubleshooting](./docs/13-TROUBLESHOOTING.md)** - Common issues and solutions
- **[Changelog](./docs/14-CHANGELOG.md)** - Version history
- **[Updates Summary](./docs/15-UPDATES_SUMMARY.md)** - Recent updates

**→ Start here**: [`docs/README.md`](./docs/README.md) - Complete documentation index with reading order

## 🚀 Quick Deployment

### Local Development
```bash
npm install
npm run dev
```

### Production Deployment (VPS)
```bash
# 1. Setup deployment config
cp env.deploy.example .env.deploy
nano .env.deploy  # Configure VPS & credentials

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Deploy everything
./scripts/full-deploy.sh
```

✅ **Automated deployment in ~15-20 minutes!**

## 📂 Project Structure

```
showcase-app/
├── docs/                      # 📚 Complete documentation
├── scripts/                   # 🤖 Deployment automation scripts
├── ca/                        # 🔒 SSL certificates
├── src/
│   ├── app/                   # Next.js app directory
│   │   ├── layout.tsx         # Root layout
│   │   └── page.tsx           # Home page
│   ├── components/            # React components
│   │   ├── 3d/                # 3D viewer components
│   │   ├── auth/              # Authentication components
│   │   ├── comments/          # Comment components
│   │   ├── filters/           # Filter components
│   │   ├── models/            # Model components
│   │   └── providers/         # Context providers
│   ├── lib/                   # Utility libraries
│   │   └── keycloak.ts        # Keycloak configuration
│   ├── store/                 # Zustand stores
│   │   ├── useAuthStore.ts    # Auth state
│   │   └── useFilterStore.ts  # Filter state
│   └── types/                 # TypeScript types
│       └── index.ts
├── public/                    # Static files
├── .env.local                 # Local environment (create this)
├── package.json
├── tsconfig.json
└── README.md                  # This file
```

## 🎨 Customization

### Adding 3D Models

Refer to the [3D Models Guide](./docs/11-3D_MODELS_GUIDE.md) for:
- Supported formats (GLB/GLTF)
- Optimization techniques
- Best practices

### Customizing the Theme

Edit Tailwind configuration in `tailwind.config.js` and `src/app/globals.css`.

## 🔧 Development

### Available Scripts

```bash
npm run dev              # Start development server
npm run build            # Build for production
npm start                # Start production server
npm run lint             # Run ESLint
```

### Deployment Scripts

Located in `scripts/` folder:

```bash
./scripts/full-deploy.sh              # Full deployment
./scripts/deploy-app-auto.sh          # Update app code
./scripts/check-status.sh             # Check services status
./scripts/setup-ssl-showcase-only.sh  # Setup SSL
```

See [Deployment Scripts Reference](./docs/04-DEPLOYMENT-SCRIPTS-REFERENCE.md) for details.

## 🐛 Troubleshooting

### Keycloak Authentication Issues
- Verify Keycloak URL and realm settings
- Check client configuration
- Ensure user has appropriate roles

### 3D Models Not Loading
- Ensure model URLs are accessible
- Check CORS settings
- Verify GLB/GLTF format

For more issues and solutions, see [Troubleshooting Guide](./docs/13-TROUBLESHOOTING.md).

## 📦 Environment Files

This project uses **2 separate environment files**:

| File | Purpose | Used By |
|------|---------|---------|
| `.env.local` | Local development | Next.js app on local machine |
| `.env.deploy` | VPS deployment | Deployment scripts |

**📖 Details**: See [Environment Files Guide](./docs/00-ENV-FILES-GUIDE.md)

## 🔐 Security

- HTTPS enabled via SSL certificates
- Keycloak for secure authentication
- Environment variables for sensitive data
- CORS properly configured

## 🌟 Features Roadmap

### Planned Features
- [ ] File upload for models and thumbnails (S3/R2 integration)
- [ ] Advanced analytics dashboard
- [ ] Email notifications
- [ ] Social media integration
- [ ] Multi-language support (i18n)
- [ ] Advanced 3D viewer controls
  - [ ] Wireframe mode
  - [ ] Animation playback
  - [ ] Lighting controls
  - [ ] Environment presets
- [ ] Model comparison feature
- [ ] Shopping cart integration
- [ ] Payment gateway (Stripe/PayPal)
- [ ] SEO optimization

### Current Version Features
- ✅ Keycloak 26.4.5 integration
- ✅ Complete showcase functionality
- ✅ 3D model viewer
- ✅ Advanced filtering
- ✅ Marketplace links
- ✅ Responsive design
- ✅ Automated deployment scripts

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

MIT License - feel free to use this project for your own showcase!

## 🙏 Credits

Built with ❤️ using:
- [Next.js](https://nextjs.org/)
- [React Three Fiber](https://docs.pmnd.rs/react-three-fiber)
- [Keycloak](https://www.keycloak.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Three.js](https://threejs.org/)

## 📞 Support

For issues and questions:
- 📚 Check [`docs/README.md`](./docs/README.md) for complete documentation
- 🐛 See [Troubleshooting Guide](./docs/13-TROUBLESHOOTING.md)
- 💬 Open an issue on GitHub
- 📖 Review documentation in `docs/` folder

---

**Version**: 2.0.0 (Database-Free)  
**Last Updated**: November 22, 2025  
**Powered by**: Next.js 16 • React 19 • Keycloak 26.4.5 • Tailwind CSS 4
