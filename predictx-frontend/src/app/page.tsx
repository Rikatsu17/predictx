'use client';

import {
  ConnectButton
} from '@rainbow-me/rainbowkit';

export default function Home() {

  return (
    <main className="min-h-screen bg-black text-white p-10">

      <div className="flex justify-between items-center">

        <h1 className="text-4xl font-bold">
          PredictX
        </h1>

        <ConnectButton />

      </div>

      <div className="mt-20">

        <h2 className="text-3xl font-semibold">

          AI & Tech Prediction Markets

        </h2>

        <p className="mt-4 text-gray-400">

          Trade on the future of AI.

        </p>

      </div>

    </main>
  );
}