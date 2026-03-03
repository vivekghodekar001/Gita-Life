import React, { useState } from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import {
    BookOpen, LayoutDashboard, Calendar, Activity,
    FileText, Library, Users2, LogOut, Menu, X, Bell, Brain, User, Sparkles, Music
} from 'lucide-react';
import { supabase } from '../../lib/supabaseClient';

const UserLayout: React.FC = () => {
    const [isSidebarOpen, setSidebarOpen] = useState(false);
    const location = useLocation();

    const handleLogout = async () => {
        await supabase.auth.signOut();
    };

    const navItems = [
        {
            section: null, items: [
                { to: '/app', icon: LayoutDashboard, label: 'My Dashboard', exact: true },
            ]
        },
        {
            section: 'Sadhana', items: [
                { to: '/app/sessions', icon: Calendar, label: 'Sessions' },
                { to: '/app/chanting', icon: Activity, label: 'Japa Sadhana' },
                { to: '/app/homework', icon: FileText, label: 'Assignments' },
                { to: '/app/my-quizzes', icon: Brain, label: 'My Quizzes' },
            ]
        },
        {
            section: 'Resources', items: [
                { to: '/app/resources', icon: Library, label: 'Digital Library' },
                { to: '/app/kirtan', icon: Music, label: 'Kirtan Player' },
                { to: '/app/mentorship', icon: Users2, label: 'Mentorship' },
                { to: '/app/gita', icon: BookOpen, label: 'Gita Wisdom' },
            ]
        },
        {
            section: 'Account', items: [
                { to: '/app/profile', icon: User, label: 'My Profile' },
            ]
        },
    ];

    return (
        <div className="min-h-screen flex bg-[#FFFAF3] font-sans text-slate-900">
            {/* Mobile Overlay */}
            <div
                className={`fixed inset-0 bg-black/60 z-40 lg:hidden backdrop-blur-sm transition-opacity duration-300 ${isSidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'
                    }`}
                onClick={() => setSidebarOpen(false)}
            />

            {/* Sidebar */}
            <aside className={`
        fixed inset-y-0 left-0 z-50 w-72 text-white transform transition-transform duration-300 ease-out lg:relative lg:translate-x-0
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        bg-gradient-to-b from-divine-700 via-divine-700 to-divine-800 flex flex-col
      `} style={{ paddingTop: 'env(safe-area-inset-top)' }}>
                {/* Logo */}
                <div className="p-5 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-11 h-11 rounded-xl bg-white/15 flex items-center justify-center backdrop-blur-sm shadow-lg border border-white/10">
                            <Sparkles size={22} className="text-saffron-300" />
                        </div>
                        <div>
                            <h1 className="text-lg font-bold tracking-tight font-serif">Gita Life</h1>
                            <p className="text-[10px] text-white/50 font-medium">Devotee Sadhu Sanga</p>
                        </div>
                    </div>
                    <button onClick={() => setSidebarOpen(false)} className="lg:hidden text-white/60 hover:text-white p-1">
                        <X size={20} />
                    </button>
                </div>

                {/* Nav */}
                <nav className="flex-1 px-3 py-2 space-y-0.5 overflow-y-auto">
                    {navItems.map((group, gi) => (
                        <div key={gi}>
                            {group.section && (
                                <div className="pt-5 pb-2 px-3 flex items-center gap-2">
                                    <span className="text-[10px] font-bold text-white/30 uppercase tracking-widest">{group.section}</span>
                                    <span className="flex-1 h-px bg-white/10" />
                                </div>
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
                                        className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group active:scale-[0.98] ${active
                                                ? 'bg-white/15 text-white shadow-lg backdrop-blur-sm'
                                                : 'text-white/60 hover:bg-white/8 hover:text-white'
                                            }`}
                                    >
                                        <item.icon size={18} className={`transition-transform duration-200 ${active ? 'scale-110' : 'group-hover:scale-110'}`} />
                                        {item.label}
                                        {active && <div className="ml-auto w-1.5 h-1.5 rounded-full bg-saffron-400" />}
                                    </Link>
                                );
                            })}
                        </div>
                    ))}
                </nav>

                {/* Logout */}
                <div className="p-3 border-t border-white/10">
                    <button onClick={handleLogout} className="flex items-center gap-3 px-3 py-2.5 w-full text-left text-white/50 hover:text-white hover:bg-white/10 rounded-xl transition-all text-sm font-medium active:scale-[0.98]">
                        <LogOut size={18} />
                        Logout
                    </button>
                </div>
            </aside>

            {/* Main */}
            <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
                <header className="h-14 bg-white/80 backdrop-blur-xl border-b border-orange-100/50 flex items-center justify-between px-4 lg:px-8 sticky top-0 z-30"
                    style={{ paddingTop: 'env(safe-area-inset-top)', height: 'calc(3.5rem + env(safe-area-inset-top))' }}>
                    <button onClick={() => setSidebarOpen(true)} className="lg:hidden p-2 text-slate-500 hover:bg-slate-100 rounded-xl active:scale-95">
                        <Menu size={22} />
                    </button>
                    <div className="ml-auto">
                        <button className="p-2 text-slate-500 hover:bg-orange-50 rounded-xl transition-colors active:scale-95">
                            <Bell size={20} />
                        </button>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto p-4 lg:p-8">
                    <Outlet />
                </div>
            </main>
        </div>
    );
};

export default UserLayout;
