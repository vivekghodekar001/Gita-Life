import React, { useState } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import {
    ShieldCheck, LayoutDashboard, Calendar, UserPlus,
    BrainCircuit, FileText, Library, Users2, LogOut, Menu, X, Music
} from 'lucide-react';
import { supabase } from '../../lib/supabaseClient';

const AdminLayout: React.FC = () => {
    const [isSidebarOpen, setSidebarOpen] = useState(false);
    const location = useLocation();

    const handleLogout = async () => {
        await supabase.auth.signOut();
    };

    const navItems = [
        {
            section: null, items: [
                { to: '/admin', icon: LayoutDashboard, label: 'Dashboard', exact: true },
            ]
        },
        {
            section: 'Management', items: [
                { to: '/admin/sessions', icon: Calendar, label: 'Sessions' },
                { to: '/admin/devotees', icon: UserPlus, label: 'Devotees' },
                { to: '/admin/quizzes', icon: BrainCircuit, label: 'Quiz Manager' },
                { to: '/admin/homework', icon: FileText, label: 'Homework' },
            ]
        },
        {
            section: 'Resources', items: [
                { to: '/admin/resources', icon: Library, label: 'Library' },
                { to: '/admin/kirtan', icon: Music, label: 'Kirtan Player' },
                { to: '/admin/mentorship', icon: Users2, label: 'Mentors' },
            ]
        },
    ];

    return (
        <div className="min-h-screen flex bg-slate-50 font-sans text-slate-900">
            {/* Mobile Overlay */}
            <div
                className={`fixed inset-0 bg-black/60 z-40 lg:hidden backdrop-blur-sm transition-opacity duration-300 ${isSidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
                    }`}
                onClick={() => setSidebarOpen(false)}
            />

            {/* Sidebar */}
            <aside className={`
        fixed inset-y-0 left-0 z-50 w-64 text-white transform transition-transform duration-300 ease-out lg:relative lg:translate-x-0
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        bg-gradient-to-b from-slate-900 via-slate-900 to-slate-800 flex flex-col
      `} style={{ paddingTop: 'env(safe-area-inset-top)' }}>
                {/* Logo */}
                <div className="p-5 flex items-center justify-between border-b border-white/5">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-lg">
                            <ShieldCheck size={20} className="text-white" />
                        </div>
                        <div>
                            <h1 className="text-base font-bold tracking-tight font-serif">Gita Life</h1>
                            <p className="text-[10px] text-slate-400 font-medium">Admin Portal</p>
                        </div>
                    </div>
                    <button onClick={() => setSidebarOpen(false)} className="lg:hidden text-white/60 hover:text-white p-1">
                        <X size={20} />
                    </button>
                </div>

                {/* Nav */}
                <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
                    {navItems.map((group, gi) => (
                        <div key={gi}>
                            {group.section && (
                                <div className="pt-5 pb-2 px-3 text-[10px] font-bold text-slate-500 uppercase tracking-widest">{group.section}</div>
                            )}
                            {group.items.map(item => {
                                const active = item.exact
                                    ? location.pathname === item.to
                                    : location.pathname.startsWith(item.to);
                                return (
                                    <Link
                                        key={item.to}
                                        to={item.to}
                                        onClick={() => setSidebarOpen(false)}
                                        className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 group ${active
                                                ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20'
                                                : 'text-slate-400 hover:bg-white/5 hover:text-white'
                                            }`}
                                    >
                                        <item.icon size={18} className={`transition-transform duration-200 ${active ? 'scale-110' : 'group-hover:scale-110'}`} />
                                        {item.label}
                                    </Link>
                                );
                            })}
                        </div>
                    ))}
                </nav>

                {/* Logout */}
                <div className="p-3 border-t border-white/5">
                    <button onClick={handleLogout} className="flex items-center gap-3 px-3 py-2.5 w-full text-left text-slate-500 hover:text-white hover:bg-white/5 rounded-lg transition-all text-sm font-medium">
                        <LogOut size={18} />
                        Logout
                    </button>
                </div>
            </aside>

            {/* Main */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                <header className="h-14 bg-white border-b border-slate-200/80 flex items-center justify-between px-4 lg:px-8 sticky top-0 z-30"
                    style={{ paddingTop: 'env(safe-area-inset-top)', height: 'calc(3.5rem + env(safe-area-inset-top))' }}>
                    <button onClick={() => setSidebarOpen(true)} className="lg:hidden p-2 text-slate-500 hover:bg-slate-100 rounded-lg">
                        <Menu size={22} />
                    </button>
                    <div className="ml-auto">
                        <div className="flex items-center gap-1.5 bg-blue-50 text-blue-700 px-3 py-1.5 rounded-lg text-xs font-bold">
                            <ShieldCheck size={14} /> Admin
                        </div>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto p-5 lg:p-8">
                    <Outlet />
                </div>
            </main>
        </div>
    );
};

export default AdminLayout;
