import React, { useState, useEffect, useRef } from 'react';
import api from '../api';

export default function Billing() {
  const [form, setForm] = useState({ 
    consultation_id: '', 
    patient_id: '', 
    fee_amount: '', 
    payment_method: 'Cash' 
  });
  const [consultations, setConsultations] = useState([]);
  const [consultationSuggestions, setConsultationSuggestions] = useState([]);
  const [patientSuggestions, setPatientSuggestions] = useState([]);
  const [selectedPatientName, setSelectedPatientName] = useState('');
  const [showConsultationDropdown, setShowConsultationDropdown] = useState(false);
  const [showPatientDropdown, setShowPatientDropdown] = useState(false);

  const [printData, setPrintData] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [modal, setModal] = useState({ isOpen: false, type: '', message: '' });

  const consultationRef = useRef(null);
  const patientRef = useRef(null);

  useEffect(() => {
    fetchConsultations();
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (consultationRef.current && !consultationRef.current.contains(event.target)) {
        setShowConsultationDropdown(false);
      }
      if (patientRef.current && !patientRef.current.contains(event.target)) {
        setShowPatientDropdown(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const fetchConsultations = async () => {
    try {
      const res = await api.get('/web/consultations');
      if (res.data && res.data.data) {
        setConsultations(res.data.data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleConsultationChange = (e) => {
    const val = e.target.value;
    setForm((prev) => ({ ...prev, consultation_id: val }));

    if (!val.trim()) {
      setConsultationSuggestions([]);
      setShowConsultationDropdown(false);
      return;
    }

    const filtered = consultations.filter((item) =>
      String(item.consultation_id).includes(val) ||
      String(item.patient_id).includes(val) ||
      item.patient_name.toLowerCase().includes(val.toLowerCase())
    );

    setConsultationSuggestions(filtered);
    setShowConsultationDropdown(true);
  };

  const selectConsultation = (item) => {
    setForm((prev) => ({
      ...prev,
      consultation_id: String(item.consultation_id),
      patient_id: String(item.patient_id)
    }));
    setSelectedPatientName(item.patient_name);
    setShowConsultationDropdown(false);
  };

  const handlePatientChange = (e) => {
    const val = e.target.value;
    setForm((prev) => ({ ...prev, patient_id: val }));

    if (!val.trim()) {
      setPatientSuggestions([]);
      setShowPatientDropdown(false);
      return;
    }

    const filtered = consultations.filter((item) =>
      String(item.patient_id).includes(val) ||
      item.patient_name.toLowerCase().includes(val.toLowerCase()) ||
      String(item.consultation_id).includes(val)
    );

    setPatientSuggestions(filtered);
    setShowPatientDropdown(true);
  };

  const selectPatient = (item) => {
    setForm((prev) => ({
      ...prev,
      patient_id: String(item.patient_id),
      consultation_id: String(item.consultation_id)
    }));
    setSelectedPatientName(item.patient_name);
    setShowPatientDropdown(false);
  };

  const closeModal = () => {
    setModal({ isOpen: false, type: '', message: '' });
  };

  const handlePayment = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const res = await api.post('/web/billing', {
        ...form,
        payment_method: 'Cash'
      });
      const invoiceData = { 
        ...form, 
        patient_name: selectedPatientName,
        payment_method: 'Cash', 
        invoice_id: res.data.invoice_id 
      };
      setPrintData(invoiceData);
      
      setModal({
        isOpen: true,
        type: 'success',
        message: 'Transaction processed successfully.'
      });

      setForm({
        consultation_id: '',
        patient_id: '',
        fee_amount: '',
        payment_method: 'Cash'
      });
      setSelectedPatientName('');

      fetchConsultations();

      setTimeout(() => { 
        window.print(); 
      }, 500);
    } catch (err) {
      setModal({
        isOpen: true,
        type: 'error',
        message: err.response?.data?.message || 'Payment processing failed.'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 p-6 md:p-10 relative">
      <div className="max-w-xl mx-auto space-y-8 no-print">
        <header className="border-b border-stone-200 pb-6">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 rounded-full bg-emerald-600" />
            <span className="text-xs font-mono uppercase tracking-wider text-stone-500">Finance & Billing</span>
          </div>
          <h1 className="text-3xl font-serif text-stone-900 tracking-tight">Cashier Counter</h1>
        </header>

        <form 
          onSubmit={handlePayment} 
          className="bg-white border border-stone-200/90 rounded-xl p-6 md:p-8 shadow-2xs space-y-5"
        >
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1 relative" ref={consultationRef}>
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Consultation ID
              </label>
              <input 
                type="text" 
                placeholder="Search Consultation ID or Patient..." 
                value={form.consultation_id} 
                onChange={handleConsultationChange} 
                onFocus={() => form.consultation_id && setShowConsultationDropdown(true)}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono" 
                required 
              />
              {showConsultationDropdown && consultationSuggestions.length > 0 && (
                <div className="absolute z-20 left-0 right-0 mt-1 bg-white border border-stone-200 rounded-lg shadow-lg max-h-56 overflow-y-auto">
                  {consultationSuggestions.map((item) => (
                    <button
                      key={`c-${item.consultation_id}`}
                      type="button"
                      onClick={() => selectConsultation(item)}
                      className="w-full text-left px-3 py-2 text-xs border-b border-stone-100 last:border-0 hover:bg-emerald-50 transition flex flex-col gap-0.5"
                    >
                      <div className="flex items-center justify-between font-mono font-semibold text-stone-800">
                        <span>Consultation #{item.consultation_id}</span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded ${item.billing_status === 'Paid' ? 'bg-amber-100 text-amber-800' : 'bg-emerald-100 text-emerald-800'}`}>
                          {item.billing_status}
                        </span>
                      </div>
                      <div className="text-stone-600 font-sans">
                        Patient: {item.patient_name} (ID: #{item.patient_id})
                      </div>
                      <div className="text-[10px] text-stone-400 font-sans">
                        Doctor: {item.doctor_name} • {item.diagnosis}
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>

            <div className="space-y-1 relative" ref={patientRef}>
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Patient ID
              </label>
              <input 
                type="text" 
                placeholder="Search Patient ID or Name..." 
                value={form.patient_id} 
                onChange={handlePatientChange} 
                onFocus={() => form.patient_id && setShowPatientDropdown(true)}
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono" 
                required 
              />
              {showPatientDropdown && patientSuggestions.length > 0 && (
                <div className="absolute z-20 left-0 right-0 mt-1 bg-white border border-stone-200 rounded-lg shadow-lg max-h-56 overflow-y-auto">
                  {patientSuggestions.map((item) => (
                    <button
                      key={`p-${item.consultation_id}`}
                      type="button"
                      onClick={() => selectPatient(item)}
                      className="w-full text-left px-3 py-2 text-xs border-b border-stone-100 last:border-0 hover:bg-emerald-50 transition flex flex-col gap-0.5"
                    >
                      <div className="flex items-center justify-between font-semibold text-stone-800">
                        <span>{item.patient_name}</span>
                        <span className="font-mono text-stone-500">Patient #{item.patient_id}</span>
                      </div>
                      <div className="text-stone-600 text-[11px] font-mono">
                        Linked Consultation #{item.consultation_id} ({item.billing_status})
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {selectedPatientName && (
            <div className="text-xs text-emerald-800 bg-emerald-50 border border-emerald-200 px-3 py-2 rounded-lg font-medium flex items-center justify-between">
              <span>Selected Patient: <strong>{selectedPatientName}</strong></span>
              <span className="text-[10px] uppercase font-mono text-emerald-700">Matched</span>
            </div>
          )}

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Total Fee Amount (PHP)
            </label>
            <div className="relative">
              <span className="absolute left-3 top-2.5 text-xs font-mono text-stone-400">₱</span>
              <input 
                type="number" 
                step="0.01" 
                placeholder="0.00" 
                value={form.fee_amount} 
                onChange={(e) => setForm({ ...form, fee_amount: e.target.value })} 
                className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 pl-7 pr-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs font-mono" 
                required 
              />
            </div>
          </div>

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Payment Method
            </label>
            <input 
              type="text" 
              value="Cash" 
              disabled 
              readOnly 
              className="w-full bg-stone-100 border border-stone-200 text-xs text-stone-500 font-semibold px-3 py-2.5 rounded-lg cursor-not-allowed shadow-2xs" 
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
                  <span className="text-amber-400">✦</span> Process & Print Receipt
                </>
              )}
            </button>
          </div>
        </form>
      </div>

      {modal.isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/40 backdrop-blur-xs no-print">
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
                  {modal.type === 'success' ? 'Success' : 'Billing Error'}
                </h3>
                <p className="text-xs text-stone-500">
                  {modal.type === 'success'
                    ? 'Payment completed.'
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

      {printData && (
        <div className="print-receipt p-8 font-mono text-xs text-stone-900 max-w-xs mx-auto border border-stone-900 rounded-none bg-white space-y-4 my-8">
          <div className="text-center space-y-1 border-b border-stone-900 pb-4">
            <h2 className="font-bold text-sm uppercase tracking-wider">Official Receipt</h2>
            <p className="text-[10px] text-stone-600">INV-#{printData.invoice_id}</p>
          </div>

          <div className="space-y-1 text-[11px] py-2 border-b border-dashed border-stone-400">
            {printData.patient_name && (
              <div className="flex justify-between">
                <span>Patient Name:</span>
                <span className="font-bold">{printData.patient_name}</span>
              </div>
            )}
            <div className="flex justify-between">
              <span>Patient ID:</span>
              <span className="font-bold">#{printData.patient_id}</span>
            </div>
            <div className="flex justify-between">
              <span>Consultation:</span>
              <span className="font-bold">#{printData.consultation_id}</span>
            </div>
            <div className="flex justify-between">
              <span>Payment Mode:</span>
              <span className="font-bold">{printData.payment_method}</span>
            </div>
          </div>

          <div className="pt-2 text-center space-y-1">
            <span className="text-[10px] uppercase text-stone-500">Total Paid</span>
            <p className="text-2xl font-bold">
              ₱{parseFloat(printData.fee_amount || 0).toFixed(2)}
            </p>
          </div>

          <div className="pt-6 text-center text-[9px] text-stone-500 border-t border-stone-900">
            Thank you for choosing our clinic.
          </div>
        </div>
      )}
    </div>
  );
}