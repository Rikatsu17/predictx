'use client';

export function ThemeProvider({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <div className="dark min-h-screen bg-slate-950 text-slate-100">
      {children}
    </div>
  );
}
