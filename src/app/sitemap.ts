import { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://3dmodels-showcase.com'

  // Fetch models for dynamic routes
  let modelSlugs: string[] = []
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000'}/models/config.json`)
    const config = await response.json()
    modelSlugs = config.models.map((model: any) => model.slug)
  } catch (error) {
    console.error('Error fetching models for sitemap:', error)
  }

  // Static pages
  const staticPages = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 1,
    },
  ]

  // Dynamic model pages
  const modelPages = modelSlugs.map((slug) => ({
    url: `${baseUrl}/models/${slug}`,
    lastModified: new Date(),
    changeFrequency: 'weekly' as const,
    priority: 0.8,
  }))

  return [...staticPages, ...modelPages]
}

