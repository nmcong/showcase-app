import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const category = searchParams.get('category');
    const tags = searchParams.get('tags')?.split(',');
    const minPrice = searchParams.get('minPrice');
    const maxPrice = searchParams.get('maxPrice');
    const search = searchParams.get('search');
    const featured = searchParams.get('featured');
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '12');

    interface WhereClause {
      published: boolean;
      category?: { slug: string };
      tags?: { hasSome: string[] };
      price?: { gte?: number; lte?: number };
      OR?: Array<{
        title?: { contains: string; mode: 'insensitive' };
        description?: { contains: string; mode: 'insensitive' };
      }>;
      featured?: boolean;
    }

    const where: WhereClause = { published: true };

    if (category) {
      where.category = { slug: category };
    }

    if (tags && tags.length > 0) {
      where.tags = { hasSome: tags };
    }

    if (minPrice || maxPrice) {
      where.price = {};
      if (minPrice) where.price.gte = parseFloat(minPrice);
      if (maxPrice) where.price.lte = parseFloat(maxPrice);
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (featured === 'true') {
      where.featured = true;
    }

    const skip = (page - 1) * limit;

    const [models, total] = await Promise.all([
      prisma.model.findMany({
        where,
        include: {
          category: true,
          comments: {
            where: { approved: true },
            select: {
              id: true,
              rating: true,
            },
          },
        },
        orderBy: [{ featured: 'desc' }, { createdAt: 'desc' }],
        skip,
        take: limit,
      }),
      prisma.model.count({ where }),
    ]);

    // Calculate average rating for each model
    const modelsWithRating = models.map((model: { comments: { rating: number }[]; [key: string]: unknown }) => {
      const avgRating =
        model.comments.length > 0
          ? model.comments.reduce((sum: number, c: { rating: number }) => sum + c.rating, 0) / model.comments.length
          : 0;
      return {
        ...model,
        averageRating: Math.round(avgRating * 10) / 10,
        commentsCount: model.comments.length,
      };
    });

    return NextResponse.json({
      models: modelsWithRating,
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

