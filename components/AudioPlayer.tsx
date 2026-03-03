import React, { useState, useRef, useEffect } from 'react';
import { Play, Pause, SkipBack, SkipForward, Volume1, Volume2, VolumeX, Music } from 'lucide-react';

interface Track {
    title: string;
    url: string;
}

interface Props {
    tracks: Track[];
}

function formatTime(seconds: number): string {
    if (isNaN(seconds) || seconds < 0) return '0:00';
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s.toString().padStart(2, '0')}`;
}

const AudioPlayer: React.FC<Props> = ({ tracks }) => {
    const audioRef = useRef<HTMLAudioElement>(null);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [isPlaying, setIsPlaying] = useState(false);
    const [isMuted, setIsMuted] = useState(false);
    const [volume, setVolume] = useState(1);
    const [currentTime, setCurrentTime] = useState(0);
    const [duration, setDuration] = useState(0);
    const shouldPlayRef = useRef(false);

    const currentTrack = tracks[currentIndex];

    useEffect(() => {
        const audio = audioRef.current;
        if (!audio) return;
        audio.load();
        setCurrentTime(0);
        setDuration(0);
        if (shouldPlayRef.current) {
            audio.play().catch(() => setIsPlaying(false));
        }
    }, [currentIndex]);

    const togglePlay = () => {
        const audio = audioRef.current;
        if (!audio) return;
        if (isPlaying) {
            audio.pause();
            shouldPlayRef.current = false;
            setIsPlaying(false);
        } else {
            audio.play().catch(() => setIsPlaying(false));
            shouldPlayRef.current = true;
            setIsPlaying(true);
        }
    };

    const skipBack = () => {
        setCurrentIndex(i => (i > 0 ? i - 1 : tracks.length - 1));
    };

    const skipForward = () => {
        setCurrentIndex(i => (i < tracks.length - 1 ? i + 1 : 0));
    };

    const handleEnded = () => {
        if (currentIndex < tracks.length - 1) {
            shouldPlayRef.current = true;
            setCurrentIndex(i => i + 1);
        } else {
            shouldPlayRef.current = false;
            setIsPlaying(false);
        }
    };

    const handleTimeUpdate = () => {
        const audio = audioRef.current;
        if (audio) setCurrentTime(audio.currentTime);
    };

    const handleLoadedMetadata = () => {
        const audio = audioRef.current;
        if (audio) setDuration(audio.duration);
    };

    const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
        const audio = audioRef.current;
        if (!audio) return;
        const time = Number(e.target.value);
        audio.currentTime = time;
        setCurrentTime(time);
    };

    const toggleMute = () => {
        const audio = audioRef.current;
        if (!audio) return;
        audio.muted = !isMuted;
        setIsMuted(!isMuted);
    };

    const handleVolumeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const audio = audioRef.current;
        if (!audio) return;
        const v = Number(e.target.value);
        audio.volume = v;
        setVolume(v);
        if (v === 0) {
            setIsMuted(true);
            audio.muted = true;
        } else if (isMuted) {
            setIsMuted(false);
            audio.muted = false;
        }
    };

    const VolumeIcon = isMuted || volume === 0 ? VolumeX : volume < 0.5 ? Volume1 : Volume2;

    const selectTrack = (index: number) => {
        if (index === currentIndex) {
            togglePlay();
        } else {
            shouldPlayRef.current = true;
            setCurrentIndex(index);
            setIsPlaying(true);
        }
    };

    return (
        <div className="space-y-4">
            {/* Player Controls */}
            <div className="glass-card-static p-5 rounded-2xl">
                {/* Track Info */}
                <div className="flex items-center gap-3 mb-4">
                    <div className="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center flex-shrink-0">
                        <Music size={22} className="text-purple-600" />
                    </div>
                    <div className="min-w-0">
                        <p className="text-sm font-bold text-slate-900 truncate">{currentTrack?.title || 'No track selected'}</p>
                        <p className="text-xs text-slate-500">{currentIndex + 1} / {tracks.length}</p>
                    </div>
                </div>

                {/* Progress Bar */}
                <div className="mb-3">
                    <input
                        type="range"
                        min={0}
                        max={duration || 0}
                        value={currentTime}
                        onChange={handleSeek}
                        className="w-full h-1.5 appearance-none rounded-full bg-purple-100 accent-purple-600 cursor-pointer"
                    />
                    <div className="flex justify-between text-[10px] text-slate-400 mt-1">
                        <span>{formatTime(currentTime)}</span>
                        <span>{formatTime(duration)}</span>
                    </div>
                </div>

                {/* Buttons */}
                <div className="flex items-center justify-center gap-4">
                    <div className="flex items-center gap-1.5">
                        <button onClick={toggleMute} className="p-2 text-slate-400 hover:text-purple-600 transition-colors">
                            <VolumeIcon size={18} />
                        </button>
                        <input
                            type="range"
                            min={0}
                            max={1}
                            step={0.01}
                            value={isMuted ? 0 : volume}
                            onChange={handleVolumeChange}
                            className="w-16 h-1 appearance-none rounded-full bg-purple-100 accent-purple-600 cursor-pointer"
                        />
                    </div>
                    <button onClick={skipBack} className="p-2 text-slate-600 hover:text-purple-600 transition-colors">
                        <SkipBack size={22} />
                    </button>
                    <button
                        onClick={togglePlay}
                        className="w-12 h-12 rounded-full bg-purple-600 hover:bg-purple-700 text-white flex items-center justify-center shadow-lg transition-all active:scale-95"
                    >
                        {isPlaying ? <Pause size={20} /> : <Play size={20} className="ml-0.5" />}
                    </button>
                    <button onClick={skipForward} className="p-2 text-slate-600 hover:text-purple-600 transition-colors">
                        <SkipForward size={22} />
                    </button>
                </div>
            </div>

            {/* Track List */}
            <div className="glass-card-static rounded-2xl overflow-hidden">
                <div className="px-4 py-3 border-b border-slate-100">
                    <p className="text-xs font-bold text-slate-500 uppercase tracking-widest">Tracks</p>
                </div>
                <div className="max-h-72 overflow-y-auto divide-y divide-slate-50">
                    {tracks.map((track, index) => (
                        <button
                            key={index}
                            onClick={() => selectTrack(index)}
                            className={`w-full flex items-center gap-3 px-4 py-3 text-left transition-colors ${index === currentIndex ? 'bg-purple-50' : 'hover:bg-slate-50'}`}
                        >
                            <div className={`w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 ${index === currentIndex ? 'bg-purple-600 text-white' : 'bg-slate-100 text-slate-400'}`}>
                                {index === currentIndex && isPlaying ? (
                                    <Pause size={12} />
                                ) : (
                                    <Play size={12} className="ml-0.5" />
                                )}
                            </div>
                            <span className={`text-sm truncate ${index === currentIndex ? 'font-semibold text-purple-700' : 'text-slate-700'}`}>
                                {track.title}
                            </span>
                        </button>
                    ))}
                </div>
            </div>

            {/* Hidden Audio Element */}
            <audio
                ref={audioRef}
                src={currentTrack?.url}
                preload="none"
                onTimeUpdate={handleTimeUpdate}
                onLoadedMetadata={handleLoadedMetadata}
                onEnded={handleEnded}
                onPlay={() => setIsPlaying(true)}
                onPause={() => setIsPlaying(false)}
            />
        </div>
    );
};

export default AudioPlayer;
