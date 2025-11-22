import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "3D Models Showcase - Professional 3D Assets for Unreal Engine & Unity",
  description: "Browse our curated collection of high-quality 3D models, characters, props, and environments for Unity, Unreal Engine. Professional 3D assets for game development and creative projects.",
  keywords: ["3D models", "3D assets", "Unreal Engine", "Unity", "game development", "3D characters", "3D props", "3D environments", "game assets"],
  authors: [{ name: "3D Models Showcase" }],
  creator: "3D Models Showcase",
  publisher: "3D Models Showcase",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL('https://3dmodels-showcase.com'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: "3D Models Showcase - Professional 3D Assets",
    description: "High-quality 3D models for Unreal Engine, Unity and game development",
    url: 'https://3dmodels-showcase.com',
    siteName: '3D Models Showcase',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: '3D Models Showcase',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: '3D Models Showcase - Professional 3D Assets',
    description: 'High-quality 3D models for Unreal Engine, Unity and game development',
    images: ['/og-image.jpg'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
    yandex: 'your-yandex-verification-code',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
        <meta name="theme-color" content="#6366f1" />
      </head>
      <body id="app-root" className="app-body">
        <div id="app-wrapper" className="app-wrapper">
          {children}
        </div>
        
        {/* JSON-LD Structured Data for SEO */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "WebSite",
              "name": "3D Models Showcase",
              "description": "Professional 3D assets for Unreal Engine and Unity",
              "url": "https://3dmodels-showcase.com",
              "potentialAction": {
                "@type": "SearchAction",
                "target": "https://3dmodels-showcase.com/?search={search_term_string}",
                "query-input": "required name=search_term_string"
              }
            })
          }}
        />
      </body>
    </html>
  );
}
