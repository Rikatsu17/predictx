export function GovernanceTimeline() {
  return (
    <section className="glass-panel rounded-[28px] p-5">
      <p className="section-kicker">Lifecycle</p>
      <h2 className="mt-2 text-lg font-semibold text-white">Timeline</h2>
      <div className="mt-5 flex flex-wrap gap-3 text-sm text-slate-300">
        {['Propose', 'Vote', 'Queue', 'Execute'].map((step) => (
          <span key={step} className="rounded-full border border-white/8 bg-white/4 px-4 py-2 text-[11px] uppercase tracking-[0.2em]">
            {step}
          </span>
        ))}
      </div>
    </section>
  );
}
