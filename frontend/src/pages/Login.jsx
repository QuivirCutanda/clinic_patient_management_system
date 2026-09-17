import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';

export default function Login() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await api.post('/web/login', { username, password });
      localStorage.setItem('web_token', response.data.token);
      localStorage.setItem('user_role', response.data.user.role);
      localStorage.setItem('username', response.data.user.username);
      navigate('/dashboard');
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F8F6F0] text-stone-800 font-sans selection:bg-emerald-200 flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        <div className="mb-8 text-center">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-emerald-900 text-stone-100 font-serif font-bold text-xl shadow-xs mb-3">
            K
          </div>
          <h1 className="text-2xl font-serif text-stone-900 tracking-tight">Clinic Portal</h1>
          <p className="text-xs text-stone-500 mt-1">Sign in to access patient records & scheduling</p>
        </div>

        <form 
          onSubmit={handleLogin} 
          className="bg-white border border-stone-200/90 rounded-xl p-6 shadow-2xs space-y-4"
        >
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 text-red-800 text-xs rounded-lg flex items-center gap-2">
              <span className="text-red-500">●</span>
              <span>{error}</span>
            </div>
          )}

          <div className="space-y-1">
            <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
              Email Address
            </label>
            <input 
              type="email" 
              placeholder="drsmith@clinic.com" 
              value={username} 
              onChange={(e) => setUsername(e.target.value)} 
              className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
              required 
            />
          </div>

          <div className="space-y-1">
            <div className="flex justify-between items-center">
              <label className="block text-xs font-semibold uppercase tracking-wider text-stone-600">
                Password
              </label>
            </div>
            <input 
              type="password" 
              placeholder="••••••••"
              value={password} 
              onChange={(e) => setPassword(e.target.value)} 
              className="w-full bg-white border border-stone-300 text-xs text-stone-800 placeholder-stone-400 px-3 py-2.5 rounded-lg focus:outline-none focus:border-emerald-700 transition shadow-2xs"
              required 
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="w-full text-xs font-medium bg-emerald-900 text-stone-50 py-2.5 rounded-lg hover:bg-emerald-950 transition shadow-xs flex items-center justify-center gap-2 disabled:opacity-70 mt-2"
          >
            {loading ? (
              <span className="inline-block w-4 h-4 border-2 border-stone-100 border-t-transparent rounded-full animate-spin" />
            ) : (
              'Authenticate'
            )}
          </button>
        </form>

        <p className="text-center text-[11px] text-stone-400 font-mono mt-6">
          Encrypted Session • Restricted System Access
        </p>
      </div>
    </div>
  );
}