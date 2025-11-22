# 3D Models Guide

A comprehensive guide for preparing and adding 3D models to your showcase.

## Supported Formats

The showcase uses **Three.js** and supports:
- ✅ **GLB** (GL Binary) - Recommended
- ✅ **GLTF** (GL Transmission Format)

### Why GLB?
- Single file (includes textures, materials)
- Smaller file size
- Faster loading
- Better for web

## Preparing Your Models

### 1. Model Requirements

**Technical Specs:**
- Format: GLB or GLTF
- Max file size: 50MB (recommended: 5-10MB)
- Polygon count: 10k-100k triangles
- Textures: Embedded or external (max 2048x2048)

**Best Practices:**
- Clean geometry (no overlapping faces)
- Proper UV unwrapping
- Optimized materials (PBR preferred)
- Centered at origin (0,0,0)
- Appropriate scale

### 2. Exporting from Blender

#### Step-by-Step:

1. **Prepare Model**
   - Apply all modifiers
   - Clean up geometry (Mesh > Clean Up)
   - Remove duplicate vertices
   - Check normals (Mesh > Normals > Recalculate Outside)

2. **Set Up Materials**
   - Use Principled BSDF shader
   - Connect textures properly
   - Keep material count low

3. **Export as GLB**
   - File > Export > glTF 2.0 (.glb/.gltf)
   - Format: **glTF Binary (.glb)**
   - Include: Selected Objects (or Scene)
   - Transform: +Y Up
   - Geometry: Apply Modifiers ✓
   - Materials: Export ✓
   - Compression: Check for smaller files

4. **Test Before Upload**
   - Open in [glTF Viewer](https://gltf-viewer.donmccurdy.com/)
   - Check textures, materials, scale
   - Verify file size

### 3. Exporting from Maya

```mel
# Install: glTF-Maya-Exporter
# https://github.com/KhronosGroup/glTF-Maya-Exporter

# Export:
1. Select mesh
2. File > Export Selection
3. File Type: glTF
4. Options:
   - Binary: Yes
   - Export Materials: Yes
   - Export Normals: Yes
```

### 4. Exporting from 3ds Max

```
# Install: Babylon.js Exporter
# https://github.com/BabylonJS/Exporters

1. File > Export > Babylon.js
2. Format: GLB
3. Export textures: Yes
4. Export
```

### 5. Converting Other Formats

If you have FBX, OBJ, or other formats:

**Using Blender:**
```
1. Import your model (File > Import)
2. Fix materials and textures
3. Export as GLB (see above)
```

**Using Online Tools:**
- [glTF Converter](https://products.aspose.app/3d/conversion/fbx-to-glb)
- [AnyConv](https://anyconv.com/fbx-to-glb-converter/)

## Optimization

### 1. Reduce Polygon Count

**In Blender:**
```
1. Select mesh
2. Add Modifier > Decimate
3. Ratio: 0.5 (reduces by 50%)
4. Apply modifier
```

### 2. Optimize Textures

**Recommended sizes:**
- Thumbnails: 512x512 or 800x600
- Model textures: 1024x1024 or 2048x2048
- Avoid 4K textures for web

**Compress textures:**
- Use JPEG for color maps (lower quality = smaller size)
- Use PNG for alpha channels
- Consider WebP for better compression

**Tools:**
- [TinyPNG](https://tinypng.com/)
- [Squoosh](https://squoosh.app/)
- Photoshop "Save for Web"

### 3. Use Draco Compression

Draco reduces GLB file size by 60-80%:

**Using glTF-Pipeline:**
```bash
npm install -g gltf-pipeline

# Compress
gltf-pipeline -i model.glb -o model-compressed.glb -d
```

**Using Blender:**
- Enable Draco compression in export options

### 4. Level of Detail (LOD)

For large models, create multiple versions:
- High detail (for close-up)
- Medium detail (for normal view)
- Low detail (for thumbnails)

## Hosting Your Models

### Option 1: Static File Hosting

**Vercel (with your app):**
```
/public/models/
  ├── my-model.glb
  ├── another-model.glb
  └── ...

URL: https://yourdomain.com/models/my-model.glb
```

**Pros:** Simple, fast
**Cons:** Increases deployment size

### Option 2: Cloud Storage

**AWS S3:**
```bash
aws s3 cp model.glb s3://your-bucket/models/
aws s3 presign s3://your-bucket/models/model.glb
```

**CloudFlare R2:**
- Cheaper than S3
- No egress fees
- CDN included

**Supabase Storage:**
```javascript
const { data } = await supabase.storage
  .from('models')
  .upload('my-model.glb', file);
```

**Pros:** Scalable, CDN, cheaper
**Cons:** Requires setup

### Option 3: Dedicated 3D Asset CDN

**Sketchfab:**
- Host models on Sketchfab
- Embed viewer or use API
- Good for showcasing

**Pros:** Professional, built for 3D
**Cons:** Less control

## Adding Models to Database

### Method 1: Admin Panel

1. Log in as admin
2. Go to Admin Dashboard
3. Click "Add New Model"
4. Fill in details:
   ```
   Title: My 3D Character
   Slug: my-3d-character
   Description: A detailed character model
   Thumbnail URL: https://cdn.example.com/thumb.jpg
   Model URL: https://cdn.example.com/model.glb
   Category: Characters
   Tags: Character, Fantasy, Medieval
   Price: 49.99
   Marketplace Links: [Unreal/Unity URLs]
   ```
5. Mark as Published
6. Submit

### Method 2: API

```bash
curl -X POST https://yoursite.com/api/admin/models \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "My 3D Model",
    "slug": "my-3d-model",
    "description": "An awesome model",
    "thumbnailUrl": "https://example.com/thumb.jpg",
    "modelUrl": "https://example.com/model.glb",
    "price": 29.99,
    "unrealMarketUrl": "https://unrealengine.com/...",
    "unityMarketUrl": "https://assetstore.unity.com/...",
    "tags": ["Props", "Medieval"],
    "categoryId": "category-id",
    "featured": false,
    "published": true
  }'
```

### Method 3: Prisma Studio

```bash
npm run db:studio
```

1. Open http://localhost:5555
2. Click on "Model" table
3. Click "Add record"
4. Fill in all fields
5. Save

### Method 4: Bulk Import

Create a script:

```typescript
// scripts/import-models.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const models = [
  {
    title: "Model 1",
    slug: "model-1",
    // ... other fields
  },
  // ... more models
];

async function main() {
  for (const model of models) {
    await prisma.model.create({ data: model });
    console.log(`Created: ${model.title}`);
  }
}

main();
```

Run: `npx tsx scripts/import-models.ts`

## Thumbnail Creation

### Option 1: Blender Render

```python
# Blender Python script
import bpy

# Set up camera
bpy.data.objects['Camera'].location = (5, -5, 3)
bpy.data.objects['Camera'].rotation_euler = (1.1, 0, 0.8)

# Render
bpy.context.scene.render.filepath = "//thumbnail.png"
bpy.context.scene.render.resolution_x = 800
bpy.context.scene.render.resolution_y = 600
bpy.ops.render.render(write_still=True)
```

### Option 2: Screenshot from Viewer

1. Load model in glTF Viewer
2. Position camera
3. Take screenshot
4. Crop and resize

### Option 3: Automated

Use headless browser with Puppeteer:

```javascript
const puppeteer = require('puppeteer');

async function generateThumbnail(modelUrl) {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.goto(`https://gltf-viewer.com?model=${modelUrl}`);
  await page.screenshot({ path: 'thumbnail.png' });
  
  await browser.close();
}
```

## Testing Your Models

### Local Testing

1. **Add to public folder:**
   ```
   /public/test-model.glb
   ```

2. **Test in viewer:**
   ```
   http://localhost:3000/models/test-slug
   ```

3. **Check console** for errors

### Online Testing

Before adding to your showcase:

1. **glTF Validator**
   - Upload to: https://gltf.report/
   - Check for errors and warnings
   - Fix issues in 3D software

2. **glTF Viewer**
   - https://gltf-viewer.donmccurdy.com/
   - Test loading and rendering
   - Check textures and materials

3. **Three.js Editor**
   - https://threejs.org/editor/
   - Import and test
   - Verify scale and orientation

## Common Issues

### Model Too Large

**Problem:** Model file is 100MB+

**Solutions:**
- Reduce polygon count
- Compress textures
- Use Draco compression
- Remove unused materials
- Simplify geometry

### Textures Not Loading

**Problem:** Model loads but no textures

**Solutions:**
- Embed textures in GLB
- Check texture paths in GLTF
- Use relative paths
- Verify CORS headers

### Wrong Scale

**Problem:** Model too big/small in viewer

**Solutions:**
- Scale in 3D software before export
- Apply scale transformations
- Set consistent unit scale

### Dark or Missing Materials

**Problem:** Model appears black

**Solutions:**
- Add lights in your scene
- Check material setup
- Use PBR materials
- Add ambient light

### Model Not Centered

**Problem:** Model off-center in viewer

**Solutions:**
- Center object to origin in 3D software
- Apply transformations
- Use "Center to Origin" tool

## Best Practices

### For Marketplace Assets

1. **Professional presentation**
   - High-quality thumbnails
   - Multiple angles
   - Good lighting
   - Clean background

2. **Clear descriptions**
   - Polygon count
   - Texture resolution
   - File formats included
   - Compatible engines

3. **Include documentation**
   - Installation instructions
   - Usage examples
   - License information

### For Performance

1. **Keep it light**
   - Under 10MB per model
   - Optimize everything
   - Use compression

2. **Progressive loading**
   - Load low-res first
   - Upgrade to high-res
   - Show loading progress

3. **Caching**
   - Use CDN
   - Set cache headers
   - Version your files

## Resources

### Tools
- [Blender](https://www.blender.org/) - Free 3D software
- [glTF Viewer](https://gltf-viewer.donmccurdy.com/) - Test models
- [glTF Validator](https://github.khronos.org/glTF-Validator/) - Validate files
- [glTF Pipeline](https://github.com/CesiumGS/gltf-pipeline) - Optimize GLB

### Learning
- [glTF Tutorial](https://www.khronos.org/gltf/)
- [Three.js Documentation](https://threejs.org/docs/)
- [Blender GLB Export](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html)

### Free Models
- [Sketchfab](https://sketchfab.com/3d-models?features=downloadable)
- [Poly Pizza](https://poly.pizza/)
- [Quaternius](https://quaternius.com/)
- [Kenney](https://kenney.nl/assets)

## Getting Help

For 3D model issues:
- Check model in glTF Validator
- Test in multiple viewers
- Verify export settings
- Ask in Three.js forum

Happy modeling! 🎨

