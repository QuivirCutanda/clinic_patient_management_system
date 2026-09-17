import React, { useState, useEffect, useCallback } from 'react';
import api from '../api';

export default function Patients() {
  const [search, setSearch] = useState('');
  const [results, setResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  const [expandedHistory, setExpandedHistory] = useState({});

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [form, setForm] = useState({
    email: '',
    password: '',
    full_name: '',
    contact_number: '',
    emergency_contact: '',
    insurance_provider: ''
  });

  const [statusMsg, setStatusMsg] = useState({ type: '', text: '' });

  const toggleHistory = (patientId) => {
    setExpandedHistory((prev) => ({
      ...prev,
      [patientId]: !prev[patientId]
    }));
  };

  const handleSearch = useCallback(async (e) => {
    if (e) e.preventDefault();
    setIsSearching(true);
    try {
      const res = await api.get(`/web/patients?search=${encodeURIComponent(search)}`);
      setResults(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsSearching(false);
    }
  }, [search]);

  useEffect(() => {
    handleSearch();
  }, []);

  const handleRegister = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setStatusMsg({ type: '', text: '' });

    try {
      await api.post('/web/patients', form);
      setStatusMsg({ type: 'success', text: 'Patient profile successfully registered.' });
      setForm({
        email: '',
        password: '',
        full_name: '',
        contact_number: '',
        emergency_contact: '',
        insurance_provider: ''
      });
      handleSearch();
      setTimeout(() => {
        setIsModalOpen(false);
        setStatusMsg({ type: '', text: '' });
      }, 1500);
    } catch (err) {
      setStatusMsg({
        type: 'error',
        text: err.response?.data?.message || 'Registration failed. Please check the entries.'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 p-6 md:p-10">
      <div className="max-w-6xl mx-auto space-y-8">
        
        <header className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 border-b border-stone-200 pb-6">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span className="w-2 h-2 rounded-full bg-emerald-600" />
              <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Medical Directory</span>
            </div>
            <h1 className="text-3xl font-serif text-stone-900 tracking-tight">Patient Records</h1>
          </div>

          <button
            onClick={() => setIsModalOpen(true)}
            className="text-xs font-medium bg-emerald-900 text-stone-50 px-4 py-2.5 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center justify-center gap-2 self-start sm:self-auto cursor-pointer"
          >
            <span className="text-amber-400">✦</span> Register New Patient
          </button>
        </header>

        <section className="bg-white border border-stone-200/90 rounded-xl p-6 shadow-2xs space-y-6">
          <form onSubmit={handleSearch} className="flex gap-3 max-w-xl">
            <input
              type="text"
              placeholder="Search by patient name or email address..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="flex-1 bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3.5 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
            />
            <button
              type="submit"
              disabled={isSearching}
              className="text-xs font-medium bg-stone-800 text-stone-50 px-5 py-2.5 rounded-lg hover:bg-stone-900 transition shadow-2xs flex items-center gap-2 disabled:opacity-70 cursor-pointer"
            >
              {isSearching ? 'Searching...' : 'Search'}
            </button>
          </form>

          <div className="space-y-4">
            {results.length === 0 ? (
              <div className="text-center py-12 border border-dashed border-stone-200 rounded-xl">
                <p className="text-xs font-mono text-stone-400">
                  {isSearching ? 'Loading records...' : 'No patient records found.'}
                </p>
              </div>
            ) : (
              results.map((p) => {
                const isOpen = !!expandedHistory[p.id];
                const historyCount = p.medical_history?.length || 0;

                return (
                  <div
                    key={p.id}
                    className="border border-stone-200/80 rounded-xl p-5 hover:border-stone-300 transition bg-stone-50/30 space-y-4"
                  >
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-stone-100 pb-3">
                      <div>
                        <h3 className="text-base font-serif text-stone-900">{p.full_name}</h3>
                        <p className="text-xs text-stone-500 font-mono">{p.email}</p>
                      </div>
                      <span className="text-[11px] font-mono text-emerald-900 bg-emerald-50 border border-emerald-200/80 px-2.5 py-1 rounded-full self-start sm:self-auto">
                        Patient ID: #{p.id}
                      </span>
                    </div>

                    <div className="space-y-3">
                      {/* Collapsible Header Toggle */}
                      <button
                        type="button"
                        onClick={() => toggleHistory(p.id)}
                        className="w-full flex items-center justify-between text-left py-1 hover:opacity-80 transition cursor-pointer group"
                      >
                        <span className="text-xs font-semibold uppercase tracking-wider text-stone-600 group-hover:text-stone-900">
                          Medical History ({historyCount})
                        </span>
                        <span className="text-xs font-mono text-stone-400 group-hover:text-stone-700">
                          {isOpen ? '▲ Hide' : '▼ View'}
                        </span>
                      </button>

                      {/* Collapsible Body */}
                      {isOpen && (
                        <div className="grid grid-cols-1 gap-3 pt-1 transition-all duration-200">
                          {historyCount === 0 ? (
                            <p className="text-xs text-stone-400 italic font-mono py-2">
                              No history recorded.
                            </p>
                          ) : (
                            p.medical_history.map((h) => (
                              <div
                                key={h.consultation_id || h.id}
                                className="bg-white border border-stone-200/80 rounded-lg p-4 space-y-2 text-xs text-stone-700 shadow-2xs"
                              >
                                <div className="flex flex-wrap justify-between items-center text-[11px] font-mono border-b border-stone-100 pb-2 gap-2">
                                  <div className="flex gap-3 items-center">
                                    <span className="bg-stone-100 text-stone-700 font-semibold px-2 py-0.5 rounded border border-stone-200">
                                      Consultation ID: #{h.consultation_id}
                                    </span>
                                    <span className="text-stone-500">
                                      Patient ID: #{h.patient_id}
                                    </span>
                                  </div>
                                  <span className="text-stone-600 font-medium">{h.consultation_date}</span>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-3 gap-2 pt-1">
                                  <div>
                                    <span className="font-semibold text-stone-900 block text-[11px] uppercase tracking-wider">Vitals</span>
                                    <p className="text-stone-600">{h.vitals || 'N/A'}</p>
                                  </div>
                                  <div>
                                    <span className="font-semibold text-stone-900 block text-[11px] uppercase tracking-wider">Diagnosis</span>
                                    <p className="text-stone-600">{h.diagnosis || 'N/A'}</p>
                                  </div>
                                  <div>
                                    <span className="font-semibold text-stone-900 block text-[11px] uppercase tracking-wider">Prescription</span>
                                    <p className="text-stone-600">{h.prescription_list || 'N/A'}</p>
                                  </div>
                                </div>
                              </div>
                            ))
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </section>

      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-stone-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white border border-stone-200 rounded-xl shadow-xl w-full max-w-lg overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            
            <div className="px-6 py-4 border-b border-stone-100 bg-stone-50/50 flex justify-between items-center">
              <div>
                <h2 className="text-lg font-serif text-stone-900">Register Patient Profile</h2>
                <p className="text-xs text-stone-500">Create mobile portal credentials & record baseline details</p>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-stone-400 hover:text-stone-600 text-lg font-mono p-1 cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleRegister} className="p-6 space-y-4">
              {statusMsg.text && (
                <div
                  className={`p-3 text-xs rounded-lg border flex items-center gap-2 ${
                    statusMsg.type === 'success'
                      ? 'bg-emerald-50 border-emerald-200 text-emerald-900'
                      : 'bg-red-50 border-red-200 text-red-800'
                  }`}
                >
                  <span className={statusMsg.type === 'success' ? 'text-emerald-600' : 'text-red-500'}>●</span>
                  <span>{statusMsg.text}</span>
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1 sm:col-span-2">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">Full Name</label>
                  <input
                    type="text"
                    placeholder="e.g. Eleanor Vance"
                    value={form.full_name}
                    onChange={(e) => setForm({ ...form, full_name: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                    required
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">Email Address</label>
                  <input
                    type="email"
                    placeholder="patient@domain.com"
                    value={form.email}
                    onChange={(e) => setForm({ ...form, email: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                    required
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">App Password</label>
                  <input
                    type="password"
                    placeholder="••••••••"
                    value={form.password}
                    onChange={(e) => setForm({ ...form, password: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                    required
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">Contact Number</label>
                  <input
                    type="text"
                    placeholder="+63 900 000 0000"
                    value={form.contact_number}
                    onChange={(e) => setForm({ ...form, contact_number: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">Emergency Contact</label>
                  <input
                    type="text"
                    placeholder="Name & Relationship"
                    value={form.emergency_contact}
                    onChange={(e) => setForm({ ...form, emergency_contact: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                  />
                </div>

                <div className="space-y-1 sm:col-span-2">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">Insurance Provider</label>
                  <input
                    type="text"
                    placeholder="Provider name / Policy ID"
                    value={form.insurance_provider}
                    onChange={(e) => setForm({ ...form, insurance_provider: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                  />
                </div>
              </div>

              <div className="pt-4 border-t border-stone-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="text-xs font-medium text-stone-600 hover:text-stone-900 px-4 py-2 rounded-lg transition cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="text-xs font-medium bg-emerald-900 text-stone-50 px-4 py-2 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center gap-2 disabled:opacity-70 cursor-pointer"
                >
                  {isSubmitting ? (
                    <span className="inline-block w-4 h-4 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
                  ) : (
                    'Save Profile'
                  )}
                </button>
              </div>
            </form>

          </div>
        </div>
      )}
    </div>
  );
}