import React, { useState, useEffect } from 'react';
import { Music } from 'lucide-react';
import { fetchKirtanTracks, AudioTrack } from '../services/audioService';
import AudioPlayer from './AudioPlayer';

const KirtanPlayer: React.FC = () => {
    const [tracks, setTracks] = useState<AudioTrack[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchKirtanTracks()
            .then(setTracks)
            .finally(() => setLoading(false));
    }, []);

    return (
        <div className="space-y-6 animate-in">
            {/* Header */}
            <div className="page-header">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center">
                        <Music size={20} className="text-purple-600" />
                    </div>
                    <div>
                        <h1>Hare Krishna Kirtan</h1>
                        <p>
                            His Holiness Lokanath Swami
                            {!loading && tracks.length > 0 && ` · ${tracks.length} tracks`}
                        </p>
                    </div>
                </div>
            </div>

            {/* Content */}
            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <div className="w-8 h-8 border-3 border-purple-200 border-t-purple-600 rounded-full animate-spin" />
                </div>
            ) : tracks.length === 0 ? (
                <div className="empty-state">
                    <Music size={48} />
                    <p>No tracks available at the moment</p>
                    <p className="text-sm text-slate-400 mt-1">Please try again later</p>
                </div>
            ) : (
                <AudioPlayer tracks={tracks} />
            )}
        </div>
    );
};

export default KirtanPlayer;
