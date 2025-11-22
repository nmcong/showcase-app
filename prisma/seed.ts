import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Start seeding...');

  // Create categories
  const categories = await Promise.all([
    prisma.category.create({
      data: {
        name: 'Characters',
        slug: 'characters',
        description: '3D character models for games and animations',
      },
    }),
    prisma.category.create({
      data: {
        name: 'Environment',
        slug: 'environment',
        description: 'Environment and landscape assets',
      },
    }),
    prisma.category.create({
      data: {
        name: 'Props',
        slug: 'props',
        description: 'Various props and objects',
      },
    }),
    prisma.category.create({
      data: {
        name: 'Weapons',
        slug: 'weapons',
        description: 'Weapon models for games',
      },
    }),
    prisma.category.create({
      data: {
        name: 'Vehicles',
        slug: 'vehicles',
        description: 'Cars, ships, and other vehicles',
      },
    }),
  ]);

  console.log(`Created ${categories.length} categories`);

  // Create sample models
  const models = await Promise.all([
    prisma.model.create({
      data: {
        title: 'Medieval Knight Character',
        slug: 'medieval-knight-character',
        description: 'High-quality medieval knight character model with full armor. Includes multiple texture variations and LODs. Perfect for fantasy games and medieval settings.',
        thumbnailUrl: 'https://picsum.photos/seed/knight/400/300',
        modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/CesiumMan/glTF/CesiumMan.gltf',
        price: 49.99,
        unrealMarketUrl: 'https://www.unrealengine.com/marketplace',
        unityMarketUrl: 'https://assetstore.unity.com/',
        tags: ['Character', 'Medieval', 'Fantasy', 'Armor'],
        featured: true,
        published: true,
        categoryId: categories[0].id,
      },
    }),
    prisma.model.create({
      data: {
        title: 'Sci-Fi Spaceship',
        slug: 'sci-fi-spaceship',
        description: 'Futuristic spaceship model with detailed interior. Includes PBR textures and animations.',
        thumbnailUrl: 'https://picsum.photos/seed/spaceship/400/300',
        modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF/Duck.gltf',
        price: 79.99,
        unrealMarketUrl: 'https://www.unrealengine.com/marketplace',
        unityMarketUrl: 'https://assetstore.unity.com/',
        tags: ['Vehicle', 'Sci-Fi', 'Spaceship'],
        featured: true,
        published: true,
        categoryId: categories[4].id,
      },
    }),
    prisma.model.create({
      data: {
        title: 'Fantasy Sword Collection',
        slug: 'fantasy-sword-collection',
        description: 'Collection of 10 fantasy swords with unique designs. High-poly models with PBR materials.',
        thumbnailUrl: 'https://picsum.photos/seed/swords/400/300',
        modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF/Box.gltf',
        price: 29.99,
        unrealMarketUrl: 'https://www.unrealengine.com/marketplace',
        tags: ['Weapon', 'Fantasy', 'Medieval'],
        featured: false,
        published: true,
        categoryId: categories[3].id,
      },
    }),
    prisma.model.create({
      data: {
        title: 'Modern City Building Pack',
        slug: 'modern-city-building-pack',
        description: 'Complete set of modern city buildings. Includes offices, apartments, and shops. Optimized for games.',
        thumbnailUrl: 'https://picsum.photos/seed/buildings/400/300',
        modelUrl: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF/Box.gltf',
        price: 99.99,
        unityMarketUrl: 'https://assetstore.unity.com/',
        tags: ['Environment', 'Modern', 'City', 'Buildings'],
        featured: true,
        published: true,
        categoryId: categories[1].id,
      },
    }),
  ]);

  console.log(`Created ${models.length} models`);

  // Create sample comments
  const comments = await Promise.all([
    prisma.comment.create({
      data: {
        authorName: 'John Developer',
        authorEmail: 'john@example.com',
        content: 'Amazing quality! The textures are incredibly detailed and the model is very well optimized.',
        rating: 5,
        approved: true,
        modelId: models[0].id,
      },
    }),
    prisma.comment.create({
      data: {
        authorName: 'Sarah Designer',
        authorEmail: 'sarah@example.com',
        content: 'Great model, works perfectly in my project. Would love to see more variations.',
        rating: 4,
        approved: true,
        modelId: models[0].id,
      },
    }),
    prisma.comment.create({
      data: {
        authorName: 'Mike Studio',
        authorEmail: 'mike@example.com',
        content: 'Perfect for our game! The animations are smooth and the model is very versatile.',
        rating: 5,
        approved: true,
        modelId: models[1].id,
      },
    }),
  ]);

  console.log(`Created ${comments.length} comments`);

  console.log('Seeding finished.');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });

