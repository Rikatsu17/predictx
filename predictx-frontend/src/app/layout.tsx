import './globals.css';
import { Space_Grotesk, JetBrains_Mono } from 'next/font/google';

import { Providers } from './providers';
import { NetworkGuard } from '@/components/network-guard';
import { Footer } from '@/components/footer';
import { Navbar } from '@/components/navbar';

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  variable: '--font-space-grotesk',
});

const jetBrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-jetbrains-mono',
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${spaceGrotesk.variable} ${jetBrainsMono.variable}`}>
        <Providers>
          <Navbar />
          <NetworkGuard>{children}</NetworkGuard>
          <Footer />
        </Providers>
      </body>
    </html>
  );
}
