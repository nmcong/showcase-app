# Bamboo Katana Model

## 📁 Structure

```
KatanaBamboo/
├── bamboo_katana.glb                    # 3D Model file
├── thumbnail.jpg                        # Main thumbnail (shown in grid)
├── images/                              # Gallery images
│   ├── 079c33e8-*.jpg                  # View 1
│   ├── 1a1b6953-*.jpg                  # View 2
│   ├── 7bd42116-*.jpg                  # View 3
│   ├── a3c98f70-*.jpg                  # View 4
│   ├── 48c3f069-*.jpg                  # View 5
│   ├── 062995ea-*.jpg                  # View 6
│   ├── 0b0ec75a-*.jpg                  # View 7
│   ├── 3dd5a77f-*.jpg                  # View 8
│   ├── bladeoldbamboo_basecolor.jpg    # Blade texture preview
│   ├── guardfoxstandard_basecolor.jpg  # Guard texture preview
│   ├── handlebamboostandard_basecolor.jpg  # Handle texture preview
│   └── scabbardbamboostandard_basecolor.jpg # Scabbard texture preview
└── [texture files]                      # PBR texture maps

Total: 8 rendered views + 4 texture previews = 12 images in gallery
```

## 🎨 Images

### Thumbnail
- **File**: `thumbnail.jpg`
- **Purpose**: Main preview image shown in model grid
- **Source**: Copy of best gallery image

### Gallery Images (in /images/)
- **8 rendered views**: Different angles of the complete katana
- **4 texture previews**: Close-up views of PBR textures for each part

All images are displayed in the detail page gallery slider.

## 📝 Usage

This model is referenced in `/public/models/config.json`:

```json
{
  "thumbnail": "/models/KatanaBamboo/thumbnail.jpg",
  "modelPath": "/models/KatanaBamboo/bamboo_katana.glb",
  "images": [
    "/models/KatanaBamboo/images/[filename].jpg",
    ...
  ]
}
```

## 🔄 Adding More Images

To add new images to the gallery:

1. Add image files to the `images/` folder
2. Update `config.json` to include the new image paths
3. Images will automatically appear in the gallery slider

## 📐 Image Specifications

- **Format**: JPG (recommended for photos/renders)
- **Recommended size**: 1920x1080 or 1200x900
- **Max file size**: Keep under 1MB each for fast loading
- **Aspect ratio**: 16:9 or 4:3 preferred

## 🎮 3D Model

- **Format**: GLB (embedded textures)
- **Polygons**: ~5K
- **Textures**: 4K PBR (4096x4096)
- **File size**: ~570KB (compressed)

