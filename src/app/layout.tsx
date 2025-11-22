import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "3D Models Showcase",
  description: "Professional 3D assets for Unreal Engine and Unity",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body id="app-root" className="app-body">
        <div id="app-wrapper" className="app-wrapper">
          {children}
        </div>
      </body>
    </html>
  );
}
