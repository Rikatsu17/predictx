export function ErrorToast({ message }: { message: string }) {
  return (
    <div className="rounded-xl border border-rose-500/30 bg-rose-500/10 px-4 py-3 text-sm text-rose-100">
      {message}
    </div>
  );
}
