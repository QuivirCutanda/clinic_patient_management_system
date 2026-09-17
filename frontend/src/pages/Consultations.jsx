import React, { useState } from 'react';
import api from '../api';

export default function Consultations() {
  const [form, setForm] = useState({
    appointment_id: '',
    patient_id: '',
    doctor_id: '',
    vitals: '',
    diagnosis: '',
    prescription_list: ''
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [modal, setModal] = useState({ isOpen: false, type: '', message: '' });

  const closeModal = () => {
    setModal({ isOpen: false, type: '', message: '' });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      await api.post('/web/consultations', form);
      
      setModal({
        isOpen: true,
        type: 'success',
        message: 'Checkup notes saved successfully.'
      });

      setForm({
        appointment_id: '',
        patient_id: '',
        doctor_id: '',
        vitals: '',
        diagnosis: '',
        prescription_list: ''
      });
    } catch (err) {
      const errorMessage =
        err.response?.data?.message ||
        'Failed to submit consultation record. Please try again.';

      setModal({
        isOpen: true,
        type: 'error',
        message: errorMessage
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 p-6 md:p-10 relative">
      <div className="max-w-2xl mx-auto space-y-8">
        
        <header className="border-b border-stone-200 pb-6">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 rounded-full bg-emerald-600" />
            <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Clinical Workstation</span>
          </div>
          <h1 className="text-3xl font-serif text-stone-900 tracking-tight">Consultation Desk</h1>
        </header>

        <form 
          onSubmit={handleSubmit} 
          className="bg-white border border-stone-200/90 rounded-xl p-6 md:p-8 shadow-2xs space-y-6"
        >
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1">
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Appt ID
              </label>
              <input
                type="number"
                placeholder="e.g. 501"
                value={form.appointment_id}
                onChange={(e) => setForm({ ...form, appointment_id: e.target.value })}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                required
              />
            </div>

            <div className="space-y-1">
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Patient ID
              </label>
              <input
                type="number"
                placeholder="e.g. 1042"
                value={form.patient_id}
                onChange={(e) => setForm({ ...form, patient_id: e.target.value })}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
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
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                required
              />
            </div>
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Vitals & Measurements
            </label>
            <textarea
              placeholder="e.g. BP: 120/80 mmHg, Temp: 36.6°C, Weight: 68kg..."
              value={form.vitals}
              onChange={(e) => setForm({ ...form, vitals: e.target.value })}
              rows={2}
              className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 p-3 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs resize-none"
              required
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Clinical Diagnosis
            </label>
            <textarea
              placeholder="Enter clinical findings, symptoms, and primary diagnosis..."
              value={form.diagnosis}
              onChange={(e) => setForm({ ...form, diagnosis: e.target.value })}
              rows={3}
              className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 p-3 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs resize-none"
              required
            />
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Prescriptions & Care Instructions
            </label>
            <textarea
              placeholder="List medications, dosage, frequency, and follow-up guidance..."
              value={form.prescription_list}
              onChange={(e) => setForm({ ...form, prescription_list: e.target.value })}
              rows={4}
              className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 p-3 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs resize-none"
              required
            />
          </div>

          <div className="pt-2">
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full text-xs font-medium bg-emerald-900 text-stone-50 py-3 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center justify-center gap-2 disabled:opacity-70 cursor-pointer"
            >
              {isSubmitting ? (
                <span className="inline-block w-4 h-4 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <span className="text-amber-400">✦</span> Submit Check-up Record
                </>
              )}
            </button>
          </div>
        </form>

      </div>

      {/* Modal Backdrop & Dialog */}
      {modal.isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/40 backdrop-blur-xs">
          <div className="bg-white rounded-xl max-w-sm w-full p-6 shadow-xl border border-stone-200 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            
            <div className="flex items-center gap-3">
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${
                  modal.type === 'success'
                    ? 'bg-emerald-100 text-emerald-800'
                    : 'bg-red-100 text-red-800'
                }`}
              >
                {modal.type === 'success' ? '✓' : '✕'}
              </div>
              <div>
                <h3 className="text-base font-semibold text-stone-900">
                  {modal.type === 'success' ? 'Success' : 'Validation Error'}
                </h3>
                <p className="text-xs text-stone-500">
                  {modal.type === 'success'
                    ? 'Consultation logged.'
                    : 'Action required.'}
                </p>
              </div>
            </div>

            <p className="text-xs text-stone-700 leading-relaxed bg-stone-50 p-3 rounded-lg border border-stone-100">
              {modal.message}
            </p>

            <div className="pt-2">
              <button
                onClick={closeModal}
                className={`w-full py-2.5 rounded-lg text-xs font-medium transition cursor-pointer ${
                  modal.type === 'success'
                    ? 'bg-emerald-900 text-white hover:bg-emerald-950'
                    : 'bg-stone-800 text-white hover:bg-stone-900'
                }`}
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