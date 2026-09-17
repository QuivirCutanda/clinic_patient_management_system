import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './pages/Login';
import SidebarLayout from './components/SidebarLayout';
import Dashboard from './pages/Dashboard';
import Patients from './pages/Patients';
import Appointments from './pages/Appointments';
import Consultations from './pages/Consultations';
import Billing from './pages/Billing';
import './app.css';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route element={<SidebarLayout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/patients" element={<Patients />} />
          <Route path="/appointments" element={<Appointments />} />
          <Route path="/consultations" element={<Consultations />} />
          <Route path="/billing" element={<Billing />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
