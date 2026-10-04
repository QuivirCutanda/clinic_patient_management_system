import React, { useEffect, useState } from 'react';
import api from '../api';

export default function Dashboard() {
  const [data, setData] = useState({
    summary: {
      total_money_collected_today: 0,
      patients_waiting: 0,
      active_doctors: 0,
      completed_today: 0
    },
    financial_breakdown: {
      cash: 0,
      digital: 0
    },
    today_queue: []
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/web/dashboard')
      .then((res) => {
        if (res.data) {
          setData({
            summary: res.data.summary || {
              total_money_collected_today: res.data.total_money_collected_today || 0,
              patients_waiting: res.data.patients_waiting || 0,
              active_doctors: res.data.active_doctors || 0,
              completed_today: 0
            },
            financial_breakdown: res.data.financial_breakdown || { cash: 0, digital: 0 },
            today_queue: res.data.today_queue || []
          });
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const formatTime = (timeStr) => {
    if (!timeStr) return '—';
    const parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    let hours = parseInt(parts[0], 10);
    const minutes = parts[1];
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12;
    return `${hours.toString().padStart(2, '0')}:${minutes} ${ampm}`;
  };

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

        <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          <div className="bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between relative overflow-hidden">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-stone-500">Collections Today</span>
                <span className="text-xs font-mono text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                  PHP
                </span>
              </div>
              <p className="mt-4 text-3xl font-serif text-stone-900 tracking-tight">
                {loading ? '—' : `₱${data.summary.total_money_collected_today.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
              </p>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-500 font-mono">
              <span>Cash: ₱{data.financial_breakdown.cash.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
              <span>Digital: ₱{data.financial_breakdown.digital.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
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
                {loading ? '—' : data.summary.patients_waiting}
              </p>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Lobby count</span>
              <span>In triage / waiting</span>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-stone-500">Completed Today</span>
                <span className="text-xs font-mono text-stone-700 bg-stone-100 px-2 py-0.5 rounded border border-stone-300">
                  Done
                </span>
              </div>
              <p className="mt-4 text-3xl font-serif text-stone-900 tracking-tight">
                {loading ? '—' : data.summary.completed_today}
              </p>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Consulted</span>
              <span>Cleared today</span>
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
                {loading ? '—' : data.summary.active_doctors}
              </p>
            </div>
            <div className="z-10 mt-6 pt-4 border-t border-emerald-800/80 flex items-center justify-between text-[11px] text-emerald-300 font-mono">
              <span>Staffing level</span>
              <span>Consultation rooms</span>
            </div>
            <div className="absolute -right-4 -bottom-4 w-28 h-28 rounded-full bg-emerald-800/40 pointer-events-none" />
          </div>
        </section>

        <section className="bg-white rounded-xl border border-stone-200/90 shadow-2xs overflow-hidden">
          <div className="p-6 border-b border-stone-100 flex items-center justify-between">
            <div>
              <h2 className="text-xl font-serif text-stone-900 tracking-tight">Today's Queue</h2>
              <p className="text-xs text-stone-500 mt-1">Scheduled appointments and active patient lobby status</p>
            </div>
            <span className="text-xs font-mono bg-stone-100 text-stone-600 px-2.5 py-1 rounded border border-stone-200">
              {data.today_queue.length} Total
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-stone-50 border-b border-stone-200 text-stone-500 font-mono text-xs uppercase tracking-wider">
                <tr>
                  <th className="px-6 py-3.5 font-semibold">Appt ID</th>
                  <th className="px-6 py-3.5 font-semibold">Time</th>
                  <th className="px-6 py-3.5 font-semibold">Patient</th>
                  <th className="px-6 py-3.5 font-semibold">Doctor</th>
                  <th className="px-6 py-3.5 font-semibold">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100 text-stone-700">
                {loading ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-8 text-center text-stone-400 font-mono text-xs">
                      Loading schedule...
                    </td>
                  </tr>
                ) : data.today_queue.length === 0 ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-8 text-center text-stone-400 font-mono text-xs">
                      No patients in queue today
                    </td>
                  </tr>
                ) : (
                  data.today_queue.map((item) => (
                    <tr key={item.appointment_id} className="hover:bg-stone-50/80 transition-colors">
                      <td className="px-6 py-4 font-mono text-stone-500">
                        #{item.appointment_id}
                      </td>
                      <td className="px-6 py-4 font-mono text-stone-900 font-medium">
                        {formatTime(item.appointment_time)}
                      </td>
                      <td className="px-6 py-4 font-medium text-stone-900">
                        {item.patient_name}
                      </td>
                      <td className="px-6 py-4 text-stone-600">
                        {item.doctor_name}
                      </td>
                      <td className="px-6 py-4">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded text-xs font-mono border ${
                          item.status === 'Confirmed'
                            ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                            : item.status === 'Pending'
                            ? 'bg-amber-50 text-amber-800 border-amber-200'
                            : 'bg-stone-100 text-stone-600 border-stone-200'
                        }`}>
                          {item.status}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>

      </div>
    </div>
  );
}