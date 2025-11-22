/* eslint-disable @typescript-eslint/no-unused-vars */
// Mock Prisma client for development when database is not available
const mockPrismaClient = {
  model: {
    findMany: async (...args: unknown[]) => [],
    findUnique: async (...args: unknown[]) => ({
      id: '1',
      title: 'Sample Model',
      slug: 'sample-model',
      description: 'Sample description',
      thumbnailUrl: '/placeholder.jpg',
      modelUrl: '/model.gltf',
      views: 0,
      comments: [],
      category: { id: '1', name: 'Sample', slug: 'sample' }
    }),
    count: async (...args: unknown[]) => 0,
    create: async (...args: unknown[]) => ({}),
    update: async (...args: unknown[]) => ({}),
    delete: async (...args: unknown[]) => ({}),
  },
  category: {
    findMany: async (...args: unknown[]) => [],
    create: async (...args: unknown[]) => ({}),
    update: async (...args: unknown[]) => ({}),
    delete: async (...args: unknown[]) => ({}),
  },
  comment: {
    findMany: async (...args: unknown[]) => [],
    create: async (...args: unknown[]) => ({}),
    update: async (...args: unknown[]) => ({}),
    delete: async (...args: unknown[]) => ({}),
    count: async (...args: unknown[]) => 0,
  },
  user: {
    findMany: async (...args: unknown[]) => [],
    create: async (...args: unknown[]) => ({}),
    update: async (...args: unknown[]) => ({}),
    delete: async (...args: unknown[]) => ({}),
    findUnique: async (...args: unknown[]) => null,
  },
  $disconnect: async () => {},
};

// Try to import PrismaClient, fall back to mock if not available
let ActualPrismaClient: unknown = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const prismaModule = require('@prisma/client');
  ActualPrismaClient = prismaModule.PrismaClient;
} catch {
  console.log('Prisma client not available, using mock');
  ActualPrismaClient = null;
}

const globalForPrisma = global as unknown as { prisma: typeof mockPrismaClient };

export const prisma = globalForPrisma.prisma || 
  (ActualPrismaClient ? new (ActualPrismaClient as new () => typeof mockPrismaClient)() : mockPrismaClient);

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

