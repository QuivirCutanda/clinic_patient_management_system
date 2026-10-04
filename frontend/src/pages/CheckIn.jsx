import React, { useState, useEffect } from 'react';
import api from '../api';

export default function CheckIn() {
  const [query, setQuery] = useState('');
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [checkingIn, setCheckingIn] = useState(false);
  const [selectedAppt, setSelectedAppt] = useState(null);
  const [resultModal, setResultModal] = useState({
    isOpen: false,
    type: 'success',
    title: '',
    message: ''
  });

  const formatTime = (timeStr) => {
    if (!timeStr) return '';
    if (timeStr.includes('AM') || timeStr.includes('PM')) return timeStr;
    const parts = timeStr.split(':');
    if (parts.length < 2) return timeStr;
    let hours = parseInt(parts[0], 10);
    const minutes = parts[1].substring(0, 2);
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12;
    const formattedHours = hours < 10 ? `0${hours}` : hours;
    return `${formattedHours}:${minutes} ${ampm}`;
  };

  const fetchAppointments = async (searchQuery = '') => {
    setLoading(true);
    try {
      const response = await api.get('/web/check-in/search', {
        params: { query: searchQuery }
      });
      setAppointments(response.data.data || []);
    } catch (err) {
      setResultModal({
        isOpen: true,
        type: 'error',
        title: 'Fetch Error',
        message: err.response?.data?.message || 'Failed to fetch check-in list.'
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAppointments();
  }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    fetchAppointments(query);
  };

  const confirmCheckIn = async () => {
    if (!selectedAppt) return;
    setCheckingIn(true);

    try {
      const response = await api.patch(`/web/appointments/${selectedAppt.appointment_id}/check-in`);
      const targetId = selectedAppt.appointment_id;
      setSelectedAppt(null);
      setAppointments((prev) => prev.filter((item) => item.appointment_id !== targetId));
      setResultModal({
        isOpen: true,
        type: 'success',
        title: 'Check-In Complete',
        message: response.data.message || 'Patient has been checked in and moved to the doctor waiting queue.'
      });
    } catch (err) {
      setSelectedAppt(null);
      setResultModal({
        isOpen: true,
        type: 'error',
        title: 'Check-In Failed',
        message: err.response?.data?.message || 'Failed to check in patient.'
      });
    } finally {
      setCheckingIn(false);
    }
  };

  return (
    <div className="p-8 max-w-6xl mx-auto space-y-6">
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 border-b border-stone-200 pb-6">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="w-2 h-2 rounded-full bg-emerald-600" />
            <span className="text-[11px] font-mono uppercase tracking-wider text-stone-500">
              Reception & Triage
            </span>
          </div>
          <h1 className="text-2xl font-serif text-stone-900 tracking-tight">
            Patient Check-In Desk
          </h1>
          <p className="text-xs text-stone-500 mt-1">
            Search confirmed patient appointments for today and mark them as waiting in queue.
          </p>
        </div>
      </div>

      <div className="bg-white border border-stone-200/90 rounded-xl p-5 shadow-2xs">
        <form onSubmit={handleSearch} className="flex gap-3">
          <input
            type="text"
            placeholder="Search by Patient Name or Appointment ID..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="flex-1 bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3.5 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
          />
          <button
            type="submit"
            disabled={loading}
            className="text-xs font-medium bg-emerald-900 text-stone-50 px-5 py-2.5 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center gap-2 disabled:opacity-70 cursor-pointer"
          >
            {loading ? (
              <span className="w-4 h-4 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
            ) : (
              'Search'
            )}
          </button>
        </form>
      </div>

      <div className="bg-white border border-stone-200/90 rounded-xl shadow-2xs overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-100 flex items-center justify-between">
          <h2 className="text-sm font-semibold text-stone-900">
            Today's Confirmed Appointments
          </h2>
          <span className="text-xs font-mono bg-stone-100 text-stone-600 px-2.5 py-1 rounded-md border border-stone-200">
            {appointments.length} Pending Check-In
          </span>
        </div>

        {loading ? (
          <div className="p-12 text-center text-xs text-stone-500 font-mono">
            Searching appointments...
          </div>
        ) : appointments.length === 0 ? (
          <div className="p-12 text-center text-xs text-stone-400 font-mono">
            No confirmed appointments found for check-in today.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-stone-700">
              <thead className="bg-stone-50 text-stone-500 font-mono uppercase text-[10px] tracking-wider border-b border-stone-100">
                <tr>
                  <th className="px-6 py-3.5 font-semibold">Appt ID</th>
                  <th className="px-6 py-3.5 font-semibold">Patient Name</th>
                  <th className="px-6 py-3.5 font-semibold">Contact</th>
                  <th className="px-6 py-3.5 font-semibold">Attending Doctor</th>
                  <th className="px-6 py-3.5 font-semibold">Time Slot</th>
                  <th className="px-6 py-3.5 font-semibold">Type</th>
                  <th className="px-6 py-3.5 font-semibold text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {appointments.map((appt) => (
                  <tr key={appt.appointment_id} className="hover:bg-stone-50/60 transition">
                    <td className="px-6 py-4 font-mono text-stone-500">
                      #{appt.appointment_id}
                    </td>
                    <td className="px-6 py-4 font-medium text-stone-900">
                      {appt.patient_name}
                    </td>
                    <td className="px-6 py-4 text-stone-600 font-mono">
                      {appt.contact_number || 'N/A'}
                    </td>
                    <td className="px-6 py-4 text-stone-700">
                      Dr. {appt.doctor_name}
                    </td>
                    <td className="px-6 py-4 font-mono text-stone-600">
                      {formatTime(appt.appointment_time)}
                    </td>
                    <td className="px-6 py-4 font-mono text-stone-600">
                     General Checkup
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => setSelectedAppt(appt)}
                        className="text-xs font-medium bg-emerald-900 text-stone-50 px-3.5 py-2 rounded-lg hover:bg-emerald-950 transition shadow-xs inline-flex items-center gap-1.5 cursor-pointer"
                      >
                        Check-In Patient
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {selectedAppt && (
        <div className="fixed inset-0 bg-stone-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-stone-200 rounded-2xl max-w-md w-full p-6 shadow-xl space-y-5">
            <div className="flex items-center justify-between border-b border-stone-100 pb-3">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-600" />
                <h3 className="text-base font-serif text-stone-900 font-semibold">
                  Confirm Patient Check-In
                </h3>
              </div>
              <button
                onClick={() => setSelectedAppt(null)}
                disabled={checkingIn}
                className="text-stone-400 hover:text-stone-600 font-mono text-lg leading-none cursor-pointer"
              >
                ×
              </button>
            </div>

            <p className="text-xs text-stone-600 leading-relaxed">
              Are you sure you want to process check-in for this patient? This action will change the appointment status to <strong className="text-stone-900 font-semibold">Waiting</strong> and add them to the queue.
            </p>

            <div className="bg-stone-50 border border-stone-200/80 rounded-xl p-4 space-y-2 text-xs">
              <div className="flex justify-between">
                <span className="text-stone-500">Appointment ID:</span>
                <span className="font-mono text-stone-800 font-medium">#{selectedAppt.appointment_id}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">Patient Name:</span>
                <span className="text-stone-900 font-medium">{selectedAppt.patient_name}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">Attending Doctor:</span>
                <span className="text-stone-800 font-medium">Dr. {selectedAppt.doctor_name}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">Schedule Time:</span>
                <span className="font-mono text-stone-800 font-medium">{formatTime(selectedAppt.appointment_time)}</span>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2 border-t border-stone-100">
              <button
                type="button"
                onClick={() => setSelectedAppt(null)}
                disabled={checkingIn}
                className="text-xs font-medium px-4 py-2.5 rounded-lg border border-stone-300 text-stone-700 hover:bg-stone-100 transition cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={confirmCheckIn}
                disabled={checkingIn}
                className="text-xs font-medium px-4 py-2.5 bg-emerald-900 text-stone-50 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center gap-2 disabled:opacity-70 cursor-pointer"
              >
                {checkingIn ? (
                  <>
                    <span className="w-3.5 h-3.5 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
                    <span>Processing...</span>
                  </>
                ) : (
                  <span>Confirm Check-In</span>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {resultModal.isOpen && (
        <div className="fixed inset-0 bg-stone-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-stone-200 rounded-2xl max-w-sm w-full p-6 shadow-xl space-y-4 text-center">
            <div className="mx-auto flex items-center justify-center w-12 h-12 rounded-full border shadow-2xs">
              {resultModal.type === 'success' ? (
                <div className="w-12 h-12 rounded-full bg-emerald-50 border border-emerald-200 flex items-center justify-center text-emerald-700 font-bold text-lg">
                  ✓
                </div>
              ) : (
                <div className="w-12 h-12 rounded-full bg-red-50 border border-red-200 flex items-center justify-center text-red-700 font-bold text-lg">
                  !
                </div>
              )}
            </div>

            <div className="space-y-1">
              <h3 className="text-base font-serif text-stone-900 font-semibold">
                {resultModal.title}
              </h3>
              <p className="text-xs text-stone-600 leading-relaxed">
                {resultModal.message}
              </p>
            </div>

            <div className="pt-2">
              <button
                onClick={() => setResultModal({ isOpen: false, type: 'success', title: '', message: '' })}
                className="w-full py-2.5 bg-stone-900 hover:bg-stone-800 text-stone-100 text-xs font-medium rounded-lg transition cursor-pointer"
              >
                Dismiss
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}