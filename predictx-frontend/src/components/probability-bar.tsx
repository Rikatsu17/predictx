export function ProbabilityBar({ yes }: { yes: number }) {
  const no = 100 - yes;
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between text-[11px] uppercase tracking-[0.24em] text-slate-400">
        <span>YES {yes.toFixed(1)}%</span>
        <span>NO {no.toFixed(1)}%</span>
      </div>
      <div className="h-3 overflow-hidden rounded-full bg-white/6 shadow-inner">
        <div
          className="h-full rounded-full bg-[linear-gradient(90deg,#62e5ff_0%,#72b4ff_55%,#8b7dff_100%)] shadow-[0_0_26px_rgba(102,224,255,0.32)] transition-all"
          style={{ width: `${yes}%` }}
        />
      </div>
    </div>
  );
}
