import React, { useEffect, useState, useRef } from 'react';
import api from '../api';

export default function PublicQueue() {
  const [queue, setQueue] = useState({
    waiting_area: [],
    consultation_desk: [],
    billing_area: []
  });
  const [loading, setLoading] = useState(true);
  const [currentTime, setCurrentTime] = useState(new Date());
  const announcedIdsRef = useRef(new Set());

  const speakPatient = (patientName, doctorName) => {
    if (!('speechSynthesis' in window)) return;

    window.speechSynthesis.cancel();

    const text = `Attention please. Now serving ${patientName}. Please proceed to ${doctorName}'s room. Thank you.`;

    const utterance1 = new SpeechSynthesisUtterance(text);
    utterance1.rate = 0.9;
    utterance1.pitch = 1.0;
    utterance1.lang = 'en-US';

    const utterance2 = new SpeechSynthesisUtterance(text);
    utterance2.rate = 0.9;
    utterance2.pitch = 1.0;
    utterance2.lang = 'en-US';

    window.speechSynthesis.speak(utterance1);
    window.speechSynthesis.speak(utterance2);
  };

  const fetchQueue = () => {
    api.get('/public/queue')
      .then((res) => {
        if (res.data) {
          const consultationDesk = res.data.consultation_desk || [];

          consultationDesk.forEach((item) => {
            if (!announcedIdsRef.current.has(item.appointment_id)) {
              announcedIdsRef.current.add(item.appointment_id);
              speakPatient(item.patient_name, item.doctor_name);
            }
          });

          setQueue({
            waiting_area: res.data.waiting_area || [],
            consultation_desk: consultationDesk,
            billing_area: res.data.billing_area || []
          });
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchQueue();
    const queueInterval = setInterval(fetchQueue, 3000);
    const timeInterval = setInterval(() => setCurrentTime(new Date()), 1000);

    return () => {
      clearInterval(queueInterval);
      clearInterval(timeInterval);
    };
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

  const formatDateTime = (dateStr) => {
    if (!dateStr) return '—';
    const date = new Date(dateStr);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
  };

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 p-6 md:p-10">
      <div className="max-w-7xl mx-auto space-y-8">
        <header className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 border-b border-stone-200 pb-6">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-600 animate-pulse" />
              <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Live Queue Monitor</span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-serif text-stone-900 tracking-tight">Patient Queue Status</h1>
          </div>

          <div className="flex items-center gap-3">
            <span className="text-sm font-mono text-stone-700 bg-stone-200/60 px-4 py-2 rounded-md border border-stone-300/50">
              {currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true })}
            </span>
            <span className="text-sm font-mono text-stone-500 bg-stone-200/60 px-4 py-2 rounded-md border border-stone-300/50">
              {currentTime.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
            </span>
          </div>
        </header>

        <main className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <section className="lg:col-span-4 bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between pb-4 border-b border-stone-100">
                <div>
                  <h2 className="text-xl font-serif text-stone-900 tracking-tight">Waiting Area</h2>
                  <p className="text-xs text-stone-500 mt-0.5">Patients in Lobby</p>
                </div>
                <span className="text-xs font-mono text-emerald-800 bg-emerald-50 px-2.5 py-1 rounded border border-emerald-200 font-medium">
                  {queue.waiting_area.length} Waiting
                </span>
              </div>

              <div className="mt-4 space-y-3 max-h-[500px] overflow-y-auto pr-1">
                {loading ? (
                  <div className="p-8 text-center text-stone-400 font-mono text-xs">Loading queue...</div>
                ) : queue.waiting_area.length === 0 ? (
                  <div className="p-8 text-center text-stone-400 font-mono text-xs">No waiting patients</div>
                ) : (
                  queue.waiting_area.map((item) => (
                    <div key={item.appointment_id} className="p-4 bg-[#F8F6F0]/60 border border-stone-200 rounded-lg flex items-center justify-between">
                      <div>
                        <p className="font-medium text-stone-900 text-base">{item.patient_name}</p>
                        <p className="text-xs text-stone-500 mt-0.5">Doctor: {item.doctor_name}</p>
                      </div>
                      <span className="text-xs font-mono bg-white text-stone-700 px-2.5 py-1 rounded border border-stone-300">
                        {formatTime(item.appointment_time)}
                      </span>
                    </div>
                  ))
                )}
              </div>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Lobby count</span>
              <span>Updated live</span>
            </div>
          </section>

          <section className="lg:col-span-4 bg-emerald-900 text-stone-100 p-6 rounded-xl shadow-2xs flex flex-col justify-between relative overflow-hidden min-h-[420px]">
            <div className="z-10">
              <div className="flex items-center justify-between pb-4 border-b border-emerald-800/80">
                <span className="text-xs font-semibold uppercase tracking-wider text-emerald-200">Consultation Desk</span>
                <span className="text-xs font-mono text-emerald-200 bg-emerald-800/80 px-2.5 py-1 rounded border border-emerald-700">
                  Now Serving
                </span>
              </div>

              <div className="my-8 flex-1 flex flex-col justify-center items-center text-center">
                {loading ? (
                  <div className="text-emerald-300/80 font-mono text-xs">Loading status...</div>
                ) : queue.consultation_desk.length === 0 ? (
                  <div className="space-y-2">
                    <p className="text-2xl font-serif text-stone-100">Desk Available</p>
                    <p className="text-xs text-emerald-300/80">No active consultation</p>
                  </div>
                ) : (
                  queue.consultation_desk.map((item) => (
                    <div key={item.appointment_id} className="w-full space-y-4">
                      <span className="inline-block bg-emerald-800/80 text-emerald-200 border border-emerald-700 font-mono text-xs px-3 py-1 rounded-full">
                        ACTIVE CALL
                      </span>
                      <div>
                        <h3 className="text-4xl font-serif text-white tracking-tight">
                          {item.patient_name}
                        </h3>
                        <p className="text-emerald-200 text-sm mt-2">
                          Assigned Doctor: <span className="font-semibold text-white">{item.doctor_name}</span>
                        </p>
                      </div>
                      <p className="text-xs font-mono text-emerald-300/80">
                        Appt Time: {formatTime(item.appointment_time)}
                      </p>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="z-10 pt-4 border-t border-emerald-800/80 flex items-center justify-between text-[11px] text-emerald-300 font-mono">
              <span>Voice announcement active</span>
              <span>Room Call</span>
            </div>
            <div className="absolute -right-4 -bottom-4 w-32 h-32 rounded-full bg-emerald-800/40 pointer-events-none" />
          </section>

          <section className="lg:col-span-4 bg-white p-6 rounded-xl border border-stone-200/90 shadow-2xs flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between pb-4 border-b border-stone-100">
                <div>
                  <h2 className="text-xl font-serif text-stone-900 tracking-tight">Billing Area</h2>
                  <p className="text-xs text-stone-500 mt-0.5">Proceed to Cashier</p>
                </div>
                <span className="text-xs font-mono text-amber-800 bg-amber-50 px-2.5 py-1 rounded border border-amber-200 font-medium">
                  {queue.billing_area.length} Unbilled
                </span>
              </div>

              <div className="mt-4 space-y-3 max-h-[500px] overflow-y-auto pr-1">
                {loading ? (
                  <div className="p-8 text-center text-stone-400 font-mono text-xs">Loading billing list...</div>
                ) : queue.billing_area.length === 0 ? (
                  <div className="p-8 text-center text-stone-400 font-mono text-xs">No pending billing</div>
                ) : (
                  queue.billing_area.map((item) => (
                    <div key={item.consultation_id} className="p-4 bg-[#F8F6F0]/60 border border-stone-200 rounded-lg flex items-center justify-between">
                      <div>
                        <p className="font-medium text-stone-900 text-base">{item.patient_name}</p>
                        <p className="text-xs text-stone-500 mt-0.5">Consultation #{item.consultation_id}</p>
                      </div>
                      <div className="text-right">
                        <span className="text-xs font-mono bg-amber-50 text-amber-800 border border-amber-200 px-2 py-0.5 rounded font-medium">
                          {item.billing_status}
                        </span>
                        <p className="text-[11px] font-mono text-stone-400 mt-1">
                          {formatDateTime(item.created_at)}
                        </p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
            <div className="mt-6 pt-4 border-t border-stone-100 flex items-center justify-between text-[11px] text-stone-400 font-mono">
              <span>Cashier counter</span>
              <span>Pending payment</span>
            </div>
          </section>
        </main>
      </div>
    </div>
  );
}