import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { modelId, authorName, authorEmail, content, rating } = body;

    // Validation
    if (!modelId || !authorName || !authorEmail || !content || !rating) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    if (rating < 1 || rating > 5) {
      return NextResponse.json({ error: 'Rating must be between 1 and 5' }, { status: 400 });
    }

    // Verify model exists
    const model = await prisma.model.findUnique({
      where: { id: modelId },
    });

    if (!model) {
      return NextResponse.json({ error: 'Model not found' }, { status: 404 });
    }

    // Create comment (pending approval)
    const comment = await prisma.comment.create({
      data: {
        modelId,
        authorName,
        authorEmail,
        content,
        rating,
        approved: false, // Comments need approval by default
      },
    });

    return NextResponse.json({
      message: 'Comment submitted successfully. It will appear after approval.',
      comment,
    });
  } catch (error) {
    console.error('Error creating comment:', error);
    return NextResponse.json({ error: 'Failed to create comment' }, { status: 500 });
  }
}

