import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

async function verifyAdmin(request: NextRequest) {
  const token = request.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token) {
    return false;
  }
  return true;
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  if (!(await verifyAdmin(request))) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { id } = await params;

    const comment = await prisma.comment.update({
      where: { id },
      data: { approved: true },
    });

    return NextResponse.json(comment);
  } catch (error) {
    console.error('Error approving comment:', error);
    return NextResponse.json({ error: 'Failed to approve comment' }, { status: 500 });
  }
}

