import React, { useState, useEffect } from 'react';
import { Library, Plus, X, Search, ExternalLink, Trash2, BookOpen, VideoIcon, Image, Mic, Music } from 'lucide-react';
import { storageService } from '../services/storageService';
import { Resource, ResourceType } from '../types';

interface Props { mode: 'admin' | 'student'; }

const TYPES: { value: ResourceType; label: string; icon: any }[] = [
    { value: 'book', label: 'Books', icon: BookOpen },
    { value: 'video', label: 'Videos', icon: VideoIcon },
    { value: 'lecture', label: 'Lectures', icon: Mic },
    { value: 'photo', label: 'Photos', icon: Image },
    { value: 'audio', label: 'Audio', icon: Music },
];

const ResourcesGallery: React.FC<Props> = ({ mode }) => {
    const [resources, setResources] = useState<Resource[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [typeFilter, setTypeFilter] = useState<string>('all');
    const [showForm, setShowForm] = useState(false);
    const [form, setForm] = useState({ title: '', type: 'book' as ResourceType, category: '', url: '', thumbnailUrl: '' });

    useEffect(() => { load(); }, []);

    const load = async () => {
        try {
            const r = await storageService.getResources();
            setResources(r);
        } catch (err) { console.error(err); }
        finally { setLoading(false); }
    };

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await storageService.createResource(form);
            setShowForm(false);
            setForm({ title: '', type: 'book', category: '', url: '', thumbnailUrl: '' });
            load();
        } catch (err) { console.error(err); alert('Failed to add resource'); }
    };

    const handleDelete = async (id: string) => {
        if (!confirm('Delete this resource?')) return;
        try {
            await storageService.deleteResource(id);
            setResources(prev => prev.filter(r => r.id !== id));
        } catch (err) { console.error(err); }
    };

    const filtered = resources.filter(r => {
        if (typeFilter !== 'all' && r.type !== typeFilter) return false;
        if (search && !r.title.toLowerCase().includes(search.toLowerCase())) return false;
        return true;
    });

    const typeIcon = (type: string) => {
        switch (type) {
            case 'book': return <BookOpen size={16} />;
            case 'video': return <VideoIcon size={16} />;
            case 'lecture': return <Mic size={16} />;
            case 'photo': return <Image size={16} />;
            case 'audio': return <Music size={16} />;
            default: return <Library size={16} />;
        }
    };

    const typeColor = (type: string) => {
        switch (type) {
            case 'book': return 'bg-amber-50 text-amber-600';
            case 'video': return 'bg-red-50 text-red-600';
            case 'lecture': return 'bg-purple-50 text-purple-600';
            case 'photo': return 'bg-blue-50 text-blue-600';
            case 'audio': return 'bg-green-50 text-green-600';
            default: return 'bg-slate-50 text-slate-600';
        }
    };

    if (loading) {
        return <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-3 border-teal-200 border-t-teal-600 rounded-full animate-spin" /></div>;
    }

    return (
        <div className="space-y-6 animate-in">
            <div className="page-header flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1>Digital Library</h1>
                    <p>{resources.length} resources available</p>
                </div>
                {mode === 'admin' && (
                    <button onClick={() => setShowForm(true)} className="btn-divine"><Plus size={18} /> Add Resource</button>
                )}
            </div>

            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                    <input className="search-input" placeholder="Search resources..." value={search} onChange={e => setSearch(e.target.value)} />
                </div>
                <div className="tab-nav">
                    <button className={`tab-item ${typeFilter === 'all' ? 'active' : ''}`} onClick={() => setTypeFilter('all')}>All</button>
                    {TYPES.map(t => (
                        <button key={t.value} className={`tab-item ${typeFilter === t.value ? 'active' : ''}`} onClick={() => setTypeFilter(t.value)}>
                            {t.label}
                        </button>
                    ))}
                </div>
            </div>

            {/* Resource Grid */}
            {filtered.length === 0 ? (
                <div className="empty-state"><Library size={48} /><p>No resources found</p></div>
            ) : (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {filtered.map(r => (
                        <div key={r.id} className="glass-card-static overflow-hidden group">
                            {/* Thumbnail */}
                            <div className="h-36 bg-slate-100 relative overflow-hidden">
                                {r.thumbnailUrl ? (
                                    <img src={r.thumbnailUrl} alt={r.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100">
                                        <div className={`w-14 h-14 rounded-2xl ${typeColor(r.type)} flex items-center justify-center`}>
                                            {typeIcon(r.type)}
                                        </div>
                                    </div>
                                )}
                                <span className={`absolute top-3 left-3 badge ${r.type === 'book' ? 'badge-saffron' : r.type === 'video' ? 'badge-red' : r.type === 'lecture' ? 'badge-purple' : r.type === 'audio' ? 'badge-green' : 'badge-blue'
                                    } text-[10px]`}>{r.type}</span>
                            </div>
                            <div className="p-4">
                                <h3 className="text-sm font-bold text-slate-900 mb-1 truncate">{r.title}</h3>
                                {r.category && <p className="text-xs text-slate-500 mb-3">{r.category}</p>}
                                <div className="flex items-center justify-between">
                                    <a href={r.url} target="_blank" rel="noopener noreferrer" className="text-divine-700 text-xs font-semibold hover:underline flex items-center gap-1">
                                        <ExternalLink size={12} /> Open
                                    </a>
                                    {mode === 'admin' && (
                                        <button onClick={() => handleDelete(r.id)} className="text-slate-400 hover:text-red-500 transition-colors">
                                            <Trash2 size={14} />
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Add Resource Modal */}
            {showForm && (
                <div className="modal-overlay" onClick={() => setShowForm(false)}>
                    <div className="modal-content p-6" onClick={e => e.stopPropagation()}>
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="text-lg font-bold text-slate-900">Add Resource</h2>
                            <button onClick={() => setShowForm(false)} className="text-slate-400 hover:text-slate-600"><X size={20} /></button>
                        </div>
                        <form onSubmit={handleCreate} className="space-y-4">
                            <div>
                                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Title *</label>
                                <input className="input-divine" placeholder="Resource title" value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} required />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-semibold text-slate-700 mb-1.5">Type</label>
                                    <select className="select-divine" value={form.type} onChange={e => setForm({ ...form, type: e.target.value as ResourceType })}>
                                        {TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-semibold text-slate-700 mb-1.5">Category</label>
                                    <input className="input-divine" placeholder="e.g. Scripture, Events" value={form.category} onChange={e => setForm({ ...form, category: e.target.value })} />
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-slate-700 mb-1.5">URL *</label>
                                <input className="input-divine" placeholder="Resource URL" value={form.url} onChange={e => setForm({ ...form, url: e.target.value })} required />
                            </div>
                            <div>
                                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Thumbnail URL</label>
                                <input className="input-divine" placeholder="Image URL for thumbnail" value={form.thumbnailUrl} onChange={e => setForm({ ...form, thumbnailUrl: e.target.value })} />
                            </div>
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={() => setShowForm(false)} className="btn-ghost flex-1">Cancel</button>
                                <button type="submit" className="btn-divine flex-1">Add Resource</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ResourcesGallery;
