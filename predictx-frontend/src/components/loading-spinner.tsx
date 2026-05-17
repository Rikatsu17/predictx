export function LoadingSpinner() {
  return (
    <div className="inline-flex items-center gap-2 text-sm text-slate-300">
      <span className="h-3 w-3 animate-spin rounded-full border border-cyan-400 border-t-transparent" />
      Loading
    </div>
  );
}
