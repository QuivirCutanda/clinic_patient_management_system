import React, { useEffect, useState } from 'react';
import api from '../api';

export default function Dashboard() {
  const [stats, setStats] = useState({ 
    total_money_collected_today: 0, 
    patients_waiting: 0, 
    active_doctors: 0 
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/web/dashboard')
      .then((res) => setStats(res.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 p-6 md:p-10">
      <div className="max-w-6xl mx-auto space-y-8">
        
        <header className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 border-b border-stone-200 pb-6">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className="w-2 h-2 rounded-full bg-emerald-600 animate-pulse" />
              <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Live Operations</span>
            </div>
            <h1 className="text-3xl font-serif text-stone-900 tracking-tight">Clinic Overview</h1>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-xs font-mono text-stone-400 bg-stone-200/60 px-3 py-1.5 rounded-md border border-stone-300/50">
              {new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
            </span>
          </div>
        </header>

        <section className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div className="bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between relative overflow-hidden">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-stone-500">Collections Today</span>
                <span className="text-xs font-mono text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                  PHP
                </span>
              </div>
              <p className="mt-4 text-3xl font-serif text-stone-900 tracking-tight">
                {loading ? '—' : `₱${stats.total_money_collected_today.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
              </p>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Daily ledger</span>
              <span>Updated live</span>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-stone-500">Patients Waiting</span>
                <span className="text-xs font-mono text-amber-800 bg-amber-50 px-2 py-0.5 rounded border border-amber-200">
                  Queue
                </span>
              </div>
              <p className="mt-4 text-3xl font-serif text-stone-900 tracking-tight">
                {loading ? '—' : stats.patients_waiting}
              </p>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Lobby count</span>
              <span>In triage / waiting</span>
            </div>
          </div>

          <div className="bg-emerald-900 text-stone-100 p-6 rounded-xl shadow-2xs flex flex-col justify-between relative overflow-hidden">
            <div className="z-10">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-emerald-200">Active Doctors</span>
                <span className="text-xs font-mono text-emerald-200 bg-emerald-800/80 px-2 py-0.5 rounded border border-emerald-700">
                  On Duty
                </span>
              </div>
              <p className="mt-4 text-3xl font-serif tracking-tight">
                {loading ? '—' : stats.active_doctors}
              </p>
            </div>
            <div className="z-10 mt-6 pt-4 border-t border-emerald-800/80 flex items-center justify-between text-[11px] text-emerald-300 font-mono">
              <span>Staffing level</span>
              <span>Consultation rooms</span>
            </div>
            <div className="absolute -right-4 -bottom-4 w-28 h-28 rounded-full bg-emerald-800/40 pointer-events-none" />
          </div>
        </section>

      </div>
    </div>
  );
}