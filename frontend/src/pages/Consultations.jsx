import React, { useState, useEffect, useRef } from 'react';
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

  const [patientSearch, setPatientSearch] = useState('');
  const [doctorSearch, setDoctorSearch] = useState('');
  const [appointments, setAppointments] = useState([]);

  const [showApptList, setShowApptList] = useState(false);
  const [showPatientList, setShowPatientList] = useState(false);
  const [showDoctorList, setShowDoctorList] = useState(false);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [modal, setModal] = useState({ isOpen: false, type: '', message: '' });

  const apptRef = useRef(null);
  const patientRef = useRef(null);
  const doctorRef = useRef(null);

  const fetchWaitingAppointments = async () => {
    try {
      const res = await api.get('/web/appointments/waiting-today');
      setAppointments(res.data.data || res.data || []);
    } catch (err) {
      setAppointments([]);
    }
  };

  useEffect(() => {
    fetchWaitingAppointments();
  }, []);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (apptRef.current && !apptRef.current.contains(e.target)) {
        setShowApptList(false);
      }
      if (patientRef.current && !patientRef.current.contains(e.target)) {
        setShowPatientList(false);
      }
      if (doctorRef.current && !doctorRef.current.contains(e.target)) {
        setShowDoctorList(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const closeModal = () => {
    setModal({ isOpen: false, type: '', message: '' });
  };

  const getFullName = (item) => {
    if (!item) return '';
    if (typeof item === 'string') return item;
    const target = item.user || item.patient || item.doctor || item;
    if (item.full_name) return item.full_name;
    if (item.patient_name) return item.patient_name;
    if (item.doctor_name) return item.doctor_name;
    if (target.full_name) return target.full_name;
    if (target.name) return target.name;
    const firstName = target.first_name || target.fname || '';
    const lastName = target.last_name || target.lname || '';
    const combined = `${firstName} ${lastName}`.trim();
    if (combined) return combined;
    return item.name || '';
  };

  const selectAppointment = (appt) => {
    const patientName = appt.patient_name || getFullName(appt.patient || appt);
    const doctorName = appt.doctor_name || getFullName(appt.doctor || appt);
    const pId = appt.patient_id ?? appt.patient?.id ?? appt.patient_user_id ?? '';
    const dId = appt.doctor_id ?? appt.doctor?.id ?? appt.doctor_user_id ?? '';

    setForm((prev) => ({
      ...prev,
      appointment_id: appt.appointment_id || appt.id || '',
      patient_id: pId !== '' ? Number(pId) : '',
      doctor_id: dId !== '' ? Number(dId) : ''
    }));
    setPatientSearch(patientName);
    setDoctorSearch(doctorName);
    setShowApptList(false);
    setShowPatientList(false);
    setShowDoctorList(false);
  };

  const handleApptInputChange = (val) => {
    setForm((prev) => ({ ...prev, appointment_id: val }));
    setShowApptList(true);
    const matched = appointments.find(
      (item) => String(item.appointment_id || item.id) === String(val)
    );
    if (matched) {
      selectAppointment(matched);
    }
  };

  const apptSuggestions = appointments.filter((item) => {
    if (!form.appointment_id) return true;
    const query = String(form.appointment_id).toLowerCase();
    const idMatches = String(item.appointment_id || item.id).toLowerCase().includes(query);
    const patientMatches = (item.patient_name || getFullName(item.patient || item)).toLowerCase().includes(query);
    return idMatches || patientMatches;
  });

  const patientSuggestions = appointments.filter((item) => {
    if (!patientSearch.trim()) return true;
    const query = patientSearch.toLowerCase();
    const name = (item.patient_name || getFullName(item.patient || item)).toLowerCase();
    const id = String(item.patient_id || item.appointment_id || '');
    return name.includes(query) || id.includes(query);
  });

  const doctorSuggestions = appointments.filter((item) => {
    if (!doctorSearch.trim()) return true;
    const query = doctorSearch.toLowerCase();
    const name = (item.doctor_name || getFullName(item.doctor || item)).toLowerCase();
    const id = String(item.doctor_id || item.appointment_id || '');
    return name.includes(query) || id.includes(query);
  });

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!form.patient_id || !form.doctor_id) {
      setModal({
        isOpen: true,
        type: 'error',
        message: 'Please select a valid appointment from the list so Patient ID and Doctor ID can be set.'
      });
      return;
    }

    setIsSubmitting(true);

    const payload = {
      ...form,
      appointment_id: form.appointment_id ? parseInt(form.appointment_id, 10) : null,
      patient_id: parseInt(form.patient_id, 10),
      doctor_id: parseInt(form.doctor_id, 10)
    };

    try {
      await api.post('/web/consultations', payload);

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
      setPatientSearch('');
      setDoctorSearch('');
      fetchWaitingAppointments();
    } catch (err) {
      let errorMessage = 'Failed to submit consultation record. Please try again.';
      if (err.response?.data?.errors) {
        errorMessage = Object.values(err.response.data.errors).flat().join(' ');
      } else if (err.response?.data?.message) {
        errorMessage = err.response.data.message;
      }

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
            <div className="space-y-1 relative" ref={apptRef}>
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Appt ID
              </label>
              <input
                type="text"
                placeholder="e.g. 9 or select..."
                value={form.appointment_id}
                onFocus={() => setShowApptList(true)}
                onChange={(e) => handleApptInputChange(e.target.value)}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono"
                required
              />
              {showApptList && apptSuggestions.length > 0 && (
                <div className="absolute z-10 top-full left-0 right-0 mt-1 bg-white border border-stone-200 rounded-lg shadow-lg max-h-48 overflow-y-auto text-xs">
                  {apptSuggestions.map((appt) => (
                    <div
                      key={appt.appointment_id || appt.id}
                      onClick={() => selectAppointment(appt)}
                      className="px-3 py-2 hover:bg-emerald-50 cursor-pointer text-stone-700 hover:text-emerald-900 border-b border-stone-100 last:border-none flex justify-between items-center"
                    >
                      <div>
                        <span className="font-medium text-stone-900 block">Appt #{appt.appointment_id || appt.id}</span>
                        <span className="text-[10px] text-stone-500">{appt.patient_name || getFullName(appt.patient)} • {appt.doctor_name || getFullName(appt.doctor)}</span>
                      </div>
                      <span className="text-[10px] text-emerald-700 font-mono font-medium">{appt.appointment_time || appt.status}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="space-y-1 relative" ref={patientRef}>
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Patient
              </label>
              <input
                type="text"
                placeholder="Type patient name or select..."
                value={patientSearch}
                onFocus={() => setShowPatientList(true)}
                onChange={(e) => {
                  setPatientSearch(e.target.value);
                  setForm((prev) => ({ ...prev, patient_id: '' }));
                  setShowPatientList(true);
                }}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                required
              />
              {showPatientList && patientSuggestions.length > 0 && (
                <div className="absolute z-10 top-full left-0 right-0 mt-1 bg-white border border-stone-200 rounded-lg shadow-lg max-h-48 overflow-y-auto text-xs">
                  {patientSuggestions.map((appt) => {
                    const id = appt.appointment_id || appt.id;
                    const name = appt.patient_name || getFullName(appt.patient || appt);
                    return (
                      <div
                        key={id}
                        onClick={() => selectAppointment(appt)}
                        className="px-3 py-2 hover:bg-emerald-50 cursor-pointer text-stone-700 hover:text-emerald-900 border-b border-stone-100 last:border-none flex justify-between items-center"
                      >
                        <div>
                          <span className="font-medium text-stone-900 block">{name}</span>
                          <span className="text-[10px] text-stone-500">{appt.doctor_name || getFullName(appt.doctor)}</span>
                        </div>
                        <span className="text-[10px] text-stone-500 font-mono">Appt #{id}</span>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="space-y-1 relative" ref={doctorRef}>
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Doctor
              </label>
              <input
                type="text"
                placeholder="Type doctor name or select..."
                value={doctorSearch}
                onFocus={() => setShowDoctorList(true)}
                onChange={(e) => {
                  setDoctorSearch(e.target.value);
                  setForm((prev) => ({ ...prev, doctor_id: '' }));
                  setShowDoctorList(true);
                }}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
                required
              />
              {showDoctorList && doctorSuggestions.length > 0 && (
                <div className="absolute z-10 top-full left-0 right-0 mt-1 bg-white border border-stone-200 rounded-lg shadow-lg max-h-48 overflow-y-auto text-xs">
                  {doctorSuggestions.map((appt) => {
                    const id = appt.appointment_id || appt.id;
                    const name = appt.doctor_name || getFullName(appt.doctor || appt);
                    return (
                      <div
                        key={id}
                        onClick={() => selectAppointment(appt)}
                        className="px-3 py-2 hover:bg-emerald-50 cursor-pointer text-stone-700 hover:text-emerald-900 border-b border-stone-100 last:border-none flex justify-between items-center"
                      >
                        <div>
                          <span className="font-medium text-stone-900 block">{name}</span>
                          <span className="text-[10px] text-stone-500">Patient: {appt.patient_name || getFullName(appt.patient)}</span>
                        </div>
                        <span className="text-[10px] text-stone-500 font-mono">Appt #{id}</span>
                      </div>
                    );
                  })}
                </div>
              )}
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