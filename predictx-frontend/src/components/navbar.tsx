'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

import { WalletButton } from '@/components/wallet-button';

const navItems = [
  { href: '/markets', label: 'Markets' },
  { href: '/portfolio', label: 'Portfolio' },
  { href: '/governance', label: 'Governance' },
  { href: '/analytics', label: 'Analytics' },
];

export function Navbar() {
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-30 border-b border-white/8 bg-slate-950/55 backdrop-blur-xl">
      <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3">
          <span className="flex h-10 w-10 items-center justify-center rounded-2xl border border-cyan-400/30 bg-cyan-300/8 text-sm font-semibold text-cyan-200 shadow-[0_0_30px_rgba(102,224,255,0.18)]">
            PX
          </span>
          <span>
            <span className="block text-lg font-semibold tracking-[0.08em] text-white">PredictX</span>
            <span className="block text-[10px] uppercase tracking-[0.26em] text-slate-500">AI Markets</span>
          </span>
        </Link>
        <nav className="hidden items-center gap-2 rounded-full border border-white/8 bg-white/4 p-1 md:flex">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`rounded-full px-4 py-2 text-sm transition ${
                pathname === item.href
                  ? 'bg-white text-slate-950'
                  : 'text-slate-300 hover:bg-white/6 hover:text-white'
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <WalletButton />
      </div>
    </header>
  );
}
