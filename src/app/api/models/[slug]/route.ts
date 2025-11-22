import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    
    const model = await prisma.model.findUnique({
      where: { slug, published: true },
      include: {
        category: true,
        comments: {
          where: { approved: true },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!model) {
      return NextResponse.json({ error: 'Model not found' }, { status: 404 });
    }

    // Increment view count
    await prisma.model.update({
      where: { id: model.id },
      data: { views: { increment: 1 } },
    });

    // Calculate average rating
    const avgRating =
      model.comments.length > 0
        ? model.comments.reduce((sum: number, c: { rating: number }) => sum + c.rating, 0) / model.comments.length
        : 0;

    return NextResponse.json({
      ...model,
      averageRating: Math.round(avgRating * 10) / 10,
    });
  } catch (error) {
    console.error('Error fetching model:', error);
    return NextResponse.json({ error: 'Failed to fetch model' }, { status: 500 });
  }
}

