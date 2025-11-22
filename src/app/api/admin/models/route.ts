import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// Helper to verify admin token (simplified - in production, verify with Keycloak)
async function verifyAdmin(request: NextRequest) {
  const token = request.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token) {
    return false;
  }
  // In production, verify token with Keycloak
  // For now, we'll just check if token exists
  return true;
}

export async function GET(request: NextRequest) {
  if (!(await verifyAdmin(request))) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const searchParams = request.nextUrl.searchParams;
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');
    const skip = (page - 1) * limit;

    const [models, total] = await Promise.all([
      prisma.model.findMany({
        include: {
          category: true,
          _count: {
            select: { comments: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.model.count(),
    ]);

    return NextResponse.json({
      models,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Error fetching models:', error);
    return NextResponse.json({ error: 'Failed to fetch models' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  if (!(await verifyAdmin(request))) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const {
      title,
      slug,
      description,
      thumbnailUrl,
      modelUrl,
      price,
      unrealMarketUrl,
      unityMarketUrl,
      tags,
      categoryId,
      featured,
      published,
    } = body;

    const model = await prisma.model.create({
      data: {
        title,
        slug,
        description,
        thumbnailUrl,
        modelUrl,
        price,
        unrealMarketUrl,
        unityMarketUrl,
        tags: tags || [],
        categoryId,
        featured: featured || false,
        published: published || false,
      },
      include: {
        category: true,
      },
    });

    return NextResponse.json(model);
  } catch (error) {
    console.error('Error creating model:', error);
    return NextResponse.json({ error: 'Failed to create model' }, { status: 500 });
  }
}

