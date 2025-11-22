# Models Directory

This directory contains all 3D models for the showcase application.

## Structure

```
models/
├── config.json           # Models metadata configuration
├── ModelName/            # Each model in its own folder
│   ├── model.glb         # 3D model file (GLB or GLTF)
│   ├── thumbnail.jpg     # Thumbnail image (recommended: 800x600px)
│   └── textures/         # Optional: separate texture files
└── README.md            # This file
```

## Adding a New Model

1. **Create a folder** for your model:
   ```bash
   mkdir public/models/YourModelName
   ```

2. **Add your model files**:
   - Place your `.glb` or `.gltf` file in the folder
   - Add a `thumbnail.jpg` (recommended size: 800x600px or 1200x900px)
   - Add any additional texture files if needed

3. **Update config.json**:
   Add a new entry to the `models` array:

   ```json
   {
     "id": "unique-model-id",
     "title": "Your Model Name",
     "slug": "your-model-name",
     "description": "Detailed description of your model...",
     "category": "Category Name",
     "tags": ["tag1", "tag2", "tag3"],
     "thumbnail": "/models/YourModelName/thumbnail.jpg",
     "modelPath": "/models/YourModelName/your-model.glb",
     "unrealMarketUrl": "https://www.unrealengine.com/marketplace/...",
     "unityMarketUrl": "https://assetstore.unity.com/...",
     "featured": false,
     "stats": {
       "polygons": "~10K",
       "textures": "4K PBR",
       "fileSize": "~20MB"
     },
     "features": [
       "High-quality PBR materials",
       "Optimized for real-time rendering",
       "Game-ready asset"
     ],
     "technicalDetails": {
       "textureResolution": "4096x4096",
       "textureFormats": ["Base Color", "Normal", "Roughness", "Metallic"],
       "uvMapping": "Non-overlapping UVs",
       "collisionMesh": "Included"
     }
   }
   ```

## Model Requirements

### 3D Model File
- **Format**: GLB (preferred) or GLTF
- **Size**: Keep under 50MB for web performance
- **Optimization**: 
  - Reduce polygon count where possible (aim for game-ready models)
  - Use texture atlases when applicable
  - Remove unnecessary data (hidden geometry, unused materials)

### Thumbnail Image
- **Format**: JPG or PNG
- **Size**: 800x600px (minimum), 1200x900px (recommended)
- **Quality**: High quality, clear view of the model
- **Background**: Clean, preferably gradient or solid color

### Textures (if using GLTF with separate textures)
- **Format**: JPG for base color, PNG for alpha/transparency
- **Resolution**: Maximum 4096x4096 (4K)
- **Types**: Base Color, Normal, Roughness, Metallic, AO, etc.

## Security Features

The showcase includes the following protection measures:

1. **3D Viewer Protection**:
   - Right-click disabled
   - Download shortcuts disabled (Ctrl+S, F12, etc.)
   - Watermark overlay on 3D view
   - `preserveDrawingBuffer: false` to prevent screenshots

2. **Model Files**:
   - Models are served from public directory but viewer includes protection
   - Consider using lower-poly preview models for web showcase
   - Full quality models only available via marketplace purchase

## Categories

Available categories (customize in your config.json):
- Weapons
- Characters
- Props
- Vehicles
- Environment
- Buildings
- Nature
- Animals
- Furniture
- Architecture

## Tips

1. **Optimize Your Models**:
   - Use Blender or other 3D software to reduce polygon count
   - Combine meshes where possible
   - Use level of detail (LOD) if needed

2. **Create Good Thumbnails**:
   - Show the model from the best angle
   - Use good lighting
   - Include a subtle shadow or reflection
   - Add a simple gradient background

3. **Write Compelling Descriptions**:
   - Highlight key features
   - Mention compatible engines/software
   - Include technical specifications
   - Add use case examples

4. **Set Accurate Marketplace Links**:
   - Double-check your Unreal/Unity marketplace URLs
   - Ensure the links are active and correct

## Example: Adding a New Sword Model

```bash
# 1. Create folder
mkdir public/models/DragonSword

# 2. Copy files
cp ~/my-models/dragon-sword.glb public/models/DragonSword/
cp ~/my-models/dragon-sword-thumb.jpg public/models/DragonSword/thumbnail.jpg

# 3. Edit config.json and add:
{
  "id": "dragon-sword-001",
  "title": "Dragon Sword",
  "slug": "dragon-sword",
  "description": "A legendary sword with dragon motifs...",
  "category": "Weapons",
  "tags": ["Sword", "Dragon", "Fantasy", "Weapon"],
  "thumbnail": "/models/DragonSword/thumbnail.jpg",
  "modelPath": "/models/DragonSword/dragon-sword.glb",
  "unrealMarketUrl": "https://www.unrealengine.com/marketplace/...",
  "featured": true,
  "stats": {
    "polygons": "~8K",
    "textures": "4K PBR",
    "fileSize": "~18MB"
  }
}
```

## Troubleshooting

**Model not showing up?**
- Check that the model file path in config.json is correct
- Verify the thumbnail path is correct
- Make sure the slug is unique and URL-friendly
- Check browser console for any errors

**Model looks wrong in viewer?**
- Verify the model is in GLB/GLTF format
- Check that textures are embedded (for GLB) or properly referenced (for GLTF)
- Try viewing the model in a 3D viewer (like Blender) first
- Check the model's scale and rotation

**Thumbnail not displaying?**
- Check file path and name match config.json
- Verify image file is valid JPG/PNG
- Check file permissions
- Clear browser cache

## Support

For issues or questions about adding models, please check:
- Main project README
- 3D Models Guide in docs/
- Open an issue on GitHub

