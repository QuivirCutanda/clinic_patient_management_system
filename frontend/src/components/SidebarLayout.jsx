import React from 'react';
import { Link, useLocation, useNavigate, Outlet } from 'react-router-dom';

export default function SidebarLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const role = localStorage.getItem('user_role') || 'User';
  const username = localStorage.getItem('username') || 'Staff';

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  const navLinks = [
    {
      to: '/dashboard',
      label: 'Dashboard',
      allowedRoles: ['Admin', 'Doctor', 'Nurse', 'Cashier'],
    },
    {
      to: '/patients',
      label: 'Patients',
      allowedRoles: ['Admin', 'Nurse'],
    },
    {
      to: '/appointments',
      label: 'Appointments',
      allowedRoles: ['Admin', 'Nurse'],
    },
    {
      to: '/consultations',
      label: 'Consultation Desk',
      allowedRoles: ['Admin', 'Doctor'],
    },
    {
      to: '/billing',
      label: 'Billing Desk',
      allowedRoles: ['Admin', 'Cashier'],
    },
  ];

  const visibleLinks = navLinks.filter((link) =>
    link.allowedRoles.includes(role)
  );

  return (
    <div className="flex h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 overflow-hidden">
      {/* Sidebar Container */}
      <aside className="w-64 bg-stone-900 text-stone-200 flex flex-col justify-between p-6 border-r border-stone-800 shrink-0">
        <div className="space-y-8">
          {/* Header & User Info */}
          <div className="border-b border-stone-800 pb-5">
            <div className="flex items-center gap-2 mb-2">
              <span className="w-2 h-2 rounded-full bg-emerald-500" />
              <span className="text-[10px] font-mono uppercase tracking-wider text-stone-400">
                Clinic Platform
              </span>
            </div>
            <h2 className="text-xl font-serif text-stone-100 tracking-tight">
              Clinical Admin
            </h2>
            <p className="mt-1 text-xs text-stone-400 font-mono truncate">
              {username} <span className="text-emerald-400">({role})</span>
            </p>
          </div>

          {/* Navigation Items */}
          <nav className="flex flex-col gap-1">
            {visibleLinks.map((link) => {
              const isActive = location.pathname === link.to;
              return (
                <Link
                  key={link.to}
                  to={link.to}
                  className={`text-xs font-medium px-3.5 py-2.5 rounded-lg transition-colors flex items-center justify-between ${
                    isActive
                      ? 'bg-stone-800 text-stone-50 border border-stone-700/80 shadow-2xs'
                      : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/50'
                  }`}
                >
                  <span>{link.label}</span>
                  {isActive && (
                    <span className="text-emerald-400 text-[10px]">✦</span>
                  )}
                </Link>
              );
            })}
          </nav>
        </div>

        {/* Logout Action */}
        <div className="pt-6 border-t border-stone-800">
          <button
            onClick={handleLogout}
            className="w-full text-xs font-medium text-stone-300 hover:text-stone-100 bg-stone-800/60 hover:bg-red-950/40 border border-stone-700/60 hover:border-red-900/50 py-2.5 rounded-lg transition-all flex items-center justify-center gap-2 cursor-pointer"
          >
            <span>Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 overflow-y-auto">
        <Outlet />
      </main>
    </div>
  );
}