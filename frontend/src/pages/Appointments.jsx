import React, { useState, useEffect } from 'react';
import api from '../api';

export default function Appointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  
  const [confirmModal, setConfirmModal] = useState({
    isOpen: false,
    type: null, 
    appointment: null,
  });

  const [form, setForm] = useState({ 
    patient_id: '', 
    doctor_id: '', 
    appointment_date: new Date().toISOString().split('T')[0], 
    appointment_time: '' 
  });
  
  const [statusMsg, setStatusMsg] = useState({ type: '', text: '' });

  const formatTime = (timeString) => {
    if (!timeString) return 'N/A';
    const parts = timeString.split(':');
    if (parts.length < 2) return timeString;

    let h = parseInt(parts[0], 10);
    const m = parts[1];
    const ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 || 12;
    const formattedHours = h < 10 ? `0${h}` : h;

    return `${formattedHours}:${m} ${ampm}`;
  };

  const fetchAppointments = async (dateToFetch) => {
    setLoading(true);
    try {
      const targetDate = dateToFetch || selectedDate;
      const res = await api.get(`/web/appointments?date=${targetDate}`);
      
      const sortedAppointments = (res.data || []).sort((a, b) => {
        if (a.created_at && b.created_at) {
          return new Date(b.created_at) - new Date(a.created_at);
        }
        return b.id - a.id;
      });

      setAppointments(sortedAppointments);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { 
    fetchAppointments(selectedDate); 
  }, [selectedDate]);

  const handleAdd = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setStatusMsg({ type: '', text: '' });

    try {
      await api.post('/web/appointments', form);
      setStatusMsg({ type: 'success', text: 'Appointment booked successfully.' });
      
      if (form.appointment_date === selectedDate) {
        fetchAppointments(selectedDate);
      } else {
        setSelectedDate(form.appointment_date);
      }

      setForm({ 
        patient_id: '', 
        doctor_id: '', 
        appointment_date: selectedDate, 
        appointment_time: '' 
      });

      setTimeout(() => {
        setIsModalOpen(false);
        setStatusMsg({ type: '', text: '' });
      }, 1200);
    } catch (err) {
      setStatusMsg({
        type: 'error',
        text: err.response?.data?.message || 'Failed to schedule appointment.'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleActionClick = (type, appointment) => {
    setConfirmModal({
      isOpen: true,
      type,
      appointment,
    });
  };

  const handleConfirmAction = async () => {
    const { type, appointment } = confirmModal;
    if (!appointment) return;

    setIsSubmitting(true);
    try {
      if (type === 'confirm') {
        await api.patch(`/web/appointments/${appointment.id}/confirm`);
      } else if (type === 'cancel') {
        await api.patch(`/web/appointments/${appointment.id}/cancel`);
      }
      fetchAppointments(selectedDate);
      setConfirmModal({ isOpen: false, type: null, appointment: null });
    } catch (err) {
      console.error(err);
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
              <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Schedule Management</span>
            </div>
            <h1 className="text-3xl font-serif text-stone-900 tracking-tight">Appointments</h1>
          </div>

          <div className="flex items-center gap-3 self-start sm:self-auto">
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="bg-white border border-stone-300 text-xs text-stone-800 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
            />
            <button
              onClick={() => {
                setForm(prev => ({ ...prev, appointment_date: selectedDate }));
                setIsModalOpen(true);
              }}
              className="text-xs font-medium bg-emerald-900 text-stone-50 px-4 py-2.5 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center gap-2"
            >
              <span className="text-amber-400">✦</span> New Booking
            </button>
          </div>
        </header>

        <section className="bg-white border border-stone-200/90 rounded-xl overflow-hidden shadow-2xs">
          <div className="px-6 py-4 border-b border-stone-100 flex justify-between items-center bg-stone-50/50">
            <h2 className="text-xs font-semibold uppercase tracking-wider text-stone-600">
              Bookings for {new Date(selectedDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
            </h2>
            <span className="text-xs text-stone-400 font-mono">
              {appointments.length} Total
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-stone-700">
              <thead>
                <tr className="border-b border-stone-200/80 bg-stone-50/30 text-[11px] uppercase tracking-wider text-stone-500 font-mono">
                  <th className="px-6 py-3 font-medium">Time</th>
                  <th className="px-6 py-3 font-medium">Patient</th>
                  <th className="px-6 py-3 font-medium">Attending Doctor</th>
                  <th className="px-6 py-3 font-medium">Status</th>
                  <th className="px-6 py-3 font-medium text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {loading ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-12 text-center text-stone-400 font-mono">
                      Loading schedule...
                    </td>
                  </tr>
                ) : appointments.length === 0 ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-12 text-center text-stone-400 font-mono">
                      No appointments scheduled for this date.
                    </td>
                  </tr>
                ) : (
                  appointments.map((a) => {
                    const status = a.status?.toLowerCase();
                    const isCancelled = status === 'cancelled';
                    const isConfirmed = status === 'confirmed';

                    return (
                      <tr key={a.id} className="hover:bg-stone-50/80 transition-colors">
                        <td className="px-6 py-4 font-mono font-medium text-stone-900">
                          {formatTime(a.appointment_time)}
                        </td>
                        <td className="px-6 py-4 font-serif text-sm text-stone-900">
                          {a.patient_name || `Patient #${a.patient_id}`}
                        </td>
                        <td className="px-6 py-4 text-stone-600">
                          {a.doctor_name || `Doctor #${a.doctor_id}`}
                        </td>
                        <td className="px-6 py-4">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[11px] font-medium border ${
                            isCancelled 
                              ? 'bg-red-50 text-red-800 border-red-200' 
                              : isConfirmed
                              ? 'bg-emerald-50 text-emerald-900 border-emerald-200'
                              : 'bg-amber-50 text-amber-900 border-amber-200'
                          }`}>
                            {a.status || 'Pending'}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <div className="flex items-center justify-end gap-3">
                            {/* Show Approve only if pending */}
                            {!isConfirmed && !isCancelled && (
                              <button
                                onClick={() => handleActionClick('confirm', a)}
                                className="text-emerald-700 hover:text-emerald-900 transition text-[11px] font-mono hover:underline font-medium"
                              >
                                Approve
                              </button>
                            )}

                            {/* Show Cancel Booking ONLY if pending (hidden when confirmed or cancelled) */}
                            {!isConfirmed && !isCancelled && (
                              <button
                                onClick={() => handleActionClick('cancel', a)}
                                className="text-stone-400 hover:text-red-700 transition text-[11px] font-mono hover:underline"
                              >
                                Cancel Booking
                              </button>
                            )}

                            {/* Optional indicator when no actions remain */}
                            {(isConfirmed || isCancelled) && (
                              <span className="text-stone-300 font-mono text-[11px]">—</span>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </section>

      </div>

      {/* Booking Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-stone-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white border border-stone-200 rounded-xl shadow-xl w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            
            <div className="px-6 py-4 border-b border-stone-100 bg-stone-50/50 flex justify-between items-center">
              <div>
                <h2 className="text-lg font-serif text-stone-900">Schedule Appointment</h2>
                <p className="text-xs text-stone-500">Add a new entry to the consultation queue</p>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-stone-400 hover:text-stone-600 text-lg font-mono p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAdd} className="p-6 space-y-4">
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

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                    Patient ID
                  </label>
                  <input
                    type="number"
                    placeholder="e.g. 1042"
                    value={form.patient_id}
                    onChange={(e) => setForm({ ...form, patient_id: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                    required
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                    Doctor ID
                  </label>
                  <input
                    type="number"
                    placeholder="e.g. 12"
                    value={form.doctor_id}
                    onChange={(e) => setForm({ ...form, doctor_id: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                    Date
                  </label>
                  <input
                    type="date"
                    value={form.appointment_date}
                    onChange={(e) => setForm({ ...form, appointment_date: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                    required
                  />
                </div>

                <div className="space-y-1">
                  <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                    Time Slot
                  </label>
                  <input
                    type="time"
                    value={form.appointment_time}
                    onChange={(e) => setForm({ ...form, appointment_time: e.target.value })}
                    className="w-full bg-white border border-stone-300 text-xs text-stone-800 px-3 py-2 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                    required
                  />
                </div>
              </div>

              <div className="pt-4 border-t border-stone-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="text-xs font-medium text-stone-600 hover:text-stone-900 px-4 py-2 rounded-lg transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="text-xs font-medium bg-emerald-900 text-stone-50 px-4 py-2 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center gap-2 disabled:opacity-70"
                >
                  {isSubmitting ? (
                    <span className="inline-block w-4 h-4 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
                  ) : (
                    'Confirm Booking'
                  )}
                </button>
              </div>
            </form>

          </div>
        </div>
      )}

      {/* Confirmation Modal for Approve / Cancel */}
      {confirmModal.isOpen && (
        <div className="fixed inset-0 z-50 bg-stone-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white border border-stone-200 rounded-xl shadow-xl w-full max-w-sm overflow-hidden animate-in fade-in zoom-in-95 duration-150 p-6 space-y-4">
            
            <div className="space-y-1">
              <h3 className="text-lg font-serif text-stone-900">
                {confirmModal.type === 'confirm' ? 'Approve Appointment' : 'Cancel Appointment'}
              </h3>
              <p className="text-xs text-stone-500">
                Are you sure you want to {confirmModal.type === 'confirm' ? 'approve' : 'cancel'} the booking for{' '}
                <span className="font-semibold text-stone-800">
                  {confirmModal.appointment?.patient_name || `Patient #${confirmModal.appointment?.patient_id}`}
                </span>{' '}
                at {formatTime(confirmModal.appointment?.appointment_time)}?
              </p>
            </div>

            <div className="pt-3 border-t border-stone-100 flex items-center justify-end gap-3">
              <button
                type="button"
                onClick={() => setConfirmModal({ isOpen: false, type: null, appointment: null })}
                className="text-xs font-medium text-stone-600 hover:text-stone-900 px-4 py-2 rounded-lg transition"
              >
                Go Back
              </button>
              <button
                type="button"
                onClick={handleConfirmAction}
                disabled={isSubmitting}
                className={`text-xs font-medium text-white px-4 py-2 rounded-lg transition shadow-xs flex items-center gap-2 disabled:opacity-70 ${
                  confirmModal.type === 'confirm'
                    ? 'bg-emerald-800 hover:bg-emerald-900'
                    : 'bg-red-700 hover:bg-red-800'
                }`}
              >
                {isSubmitting ? (
                  <span className="inline-block w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : confirmModal.type === 'confirm' ? (
                  'Yes, Approve'
                ) : (
                  'Yes, Cancel'
                )}
              </button>
            </div>

          </div>
        </div>
      )}
    </div>
  );
}