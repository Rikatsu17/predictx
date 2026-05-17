export function Footer() {
  return (
    <footer className="border-t border-white/8 bg-slate-950/50">
      <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3 px-4 py-6 text-sm text-slate-400 sm:px-6 lg:px-8">
        <span className="font-medium text-slate-200">PredictX</span>
        <div className="flex gap-4">
          <a href="#" className="transition hover:text-white">GitHub</a>
          <a href="#" className="transition hover:text-white">Docs</a>
          <a href="#" className="transition hover:text-white">Contracts</a>
        </div>
      </div>
    </footer>
  );
}
