# 3D Models Showcase - Quick Guide

## 🎯 What This Is

A clean, simple showcase platform for 3D models with:
- ✅ No authentication required
- ✅ No database needed
- ✅ Direct links to Unreal Engine Marketplace
- ✅ 3D model preview with protection
- ✅ Image gallery slider
- ✅ Responsive layout (up to 2552px width)

## 📁 Project Structure

```
public/
└── models/
    ├── config.json          # All models metadata
    ├── README.md            # Guide to add models
    └── [ModelName]/
        ├── model.glb        # 3D model file
        ├── thumbnail.jpg    # Main thumbnail
        └── *.jpg            # Additional images

src/
├── app/
│   ├── page.tsx             # Homepage with grid
│   ├── layout.tsx           # Root layout (no auth)
│   └── models/[slug]/       # Model detail page
├── components/
│   ├── 3d/ModelViewer.tsx   # Protected 3D viewer
│   ├── models/              # Model components
│   └── filters/             # Filter components
└── types/index.ts           # TypeScript types
```

## 🚀 Adding New Models

1. **Create a folder** in `public/models/`:
   ```bash
   mkdir public/models/YourModel
   ```

2. **Add files**:
   - `your-model.glb` - The 3D model
   - `thumbnail.jpg` - Main preview image
   - `view1.jpg`, `view2.jpg`, etc. - Additional images

3. **Update `public/models/config.json`**:
   ```json
   {
     "models": [
       {
         "id": "unique-id",
         "title": "Your Model Name",
         "slug": "your-model-name",
         "description": "Description...",
         "category": "Weapons",
         "tags": ["tag1", "tag2"],
         "thumbnail": "/models/YourModel/thumbnail.jpg",
         "modelPath": "/models/YourModel/your-model.glb",
         "images": [
           "/models/YourModel/view1.jpg",
           "/models/YourModel/view2.jpg"
         ],
         "unrealMarketUrl": "https://...",
         "featured": true,
         "stats": {
           "polygons": "~5K",
           "textures": "4K PBR",
           "fileSize": "~15MB"
         },
         "features": [
           "High-quality PBR materials",
           "Game-ready asset"
         ],
         "technicalDetails": {
           "textureResolution": "4096x4096",
           "textureFormats": ["Base Color", "Normal", "Roughness"],
           "uvMapping": "Non-overlapping UVs"
         }
       }
     ]
   }
   ```

## 🎨 Features

### Homepage
- Grid layout with model cards
- Category and tag filtering
- Search functionality
- Responsive design (max 2552px)

### Model Detail Page
- Large 3D viewer (600-700px height)
- Image gallery slider below
- Click thumbnails to switch between 3D model and images
- Sidebar with details
- Direct CTA buttons to Unreal/Unity marketplace
- Full width layout (max 2552px)

### 3D Viewer Protection
- Right-click disabled
- Keyboard shortcuts disabled (Ctrl+S, F12, etc.)
- No visible "Protected" warnings
- preserveDrawingBuffer: false (prevents screenshots)
- Smooth controls with damping

## �� Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

Visit `http://localhost:3000`

## 🎯 User Flow

1. **Homepage** → Browse models in grid
2. **Click model card** → Go to detail page
3. **View 3D model** → Loads automatically in viewer
4. **Browse gallery** → Click thumbnails to switch views
5. **Want to purchase** → Click "Get on Unreal Marketplace"
6. **See pricing** → Only visible on marketplace site

## 🔒 Security Features

The 3D viewer includes:
- Right-click protection
- Keyboard shortcut blocking
- User selection disabled
- Drag & drop disabled
- Screenshot protection via WebGL settings

**Note:** Protection is silent - no warnings shown to users.

## 📐 Layout Specifications

- **Max width**: 2552px (centers on larger screens)
- **Breakpoints**:
  - Mobile: < 768px
  - Tablet: 768px - 1024px
  - Desktop: > 1024px
  - Wide: 1920px - 2552px
  - Ultra-wide: > 2552px (capped)

## 📝 Tips

1. **Optimize 3D models** - Keep under 50MB
2. **Use good thumbnails** - 1200x900px recommended
3. **Add multiple views** - Show model from different angles
4. **Write clear descriptions** - Highlight key features
5. **Set correct marketplace URLs** - Always double-check

## 🆘 Troubleshooting

**Model not showing?**
- Check file path in config.json
- Verify GLB/GLTF format
- Check browser console for errors

**Images not loading?**
- Verify image paths are correct
- Check file extensions match config
- Ensure images are in public/models/

**Layout issues?**
- Clear browser cache
- Check CSS in browser DevTools
- Verify max-width: 2552px is applied

## 📚 Related Files

- `public/models/README.md` - Detailed guide for adding models
- `public/models/config.json` - All models metadata
- `docs/11-3D_MODELS_GUIDE.md` - Complete 3D models documentation

---

**Version**: 3.0.0 (No Auth, Gallery Enabled)  
**Last Updated**: November 22, 2025
