"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, getDocs, deleteDoc, doc, addDoc } from "firebase/firestore";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Trash2, Plus, Music, Headphones } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface AudioTrack {
    id: string;
    title: string;
    url: string;
    category?: string;
    artist?: string;
    duration?: string;
}

export default function AudioPage() {
    const [tracks, setTracks] = useState<AudioTrack[]>([]);
    const [loading, setLoading] = useState(true);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    // New Track Form State
    const [newTitle, setNewTitle] = useState("");
    const [newUrl, setNewUrl] = useState("");
    const [newCategory, setNewCategory] = useState("");
    const [newArtist, setNewArtist] = useState("");

    useEffect(() => {
        fetchTracks();
    }, []);

    async function fetchTracks() {
        try {
            setLoading(true);
            const snap = await getDocs(collection(db, "audio_tracks"));
            const data: AudioTrack[] = [];
            snap.forEach((d) => {
                data.push({ id: d.id, ...(d.data() as Omit<AudioTrack, "id">) });
            });
            setTracks(data);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this audio track?")) return;
        try {
            await deleteDoc(doc(db, "audio_tracks", id));
            setTracks(tracks.filter(t => t.id !== id));
        } catch (e) {
            console.error("Failed to delete", e);
        }
    };

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const docRef = await addDoc(collection(db, "audio_tracks"), {
                title: newTitle,
                url: newUrl,
                category: newCategory || 'Kirtan',
                artist: newArtist || 'Unknown',
                timestamp: new Date().getTime(),
            });
            setTracks([...tracks, { id: docRef.id, title: newTitle, url: newUrl, category: newCategory, artist: newArtist }]);
            setIsDialogOpen(false);
            setNewTitle("");
            setNewUrl("");
            setNewCategory("");
            setNewArtist("");
        } catch (e) {
            console.error("Failed to add track", e);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-800">Audio Library</h2>
                    <p className="text-slate-500">Manage audio and kirtan tracks used in the app.</p>
                </div>
                <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                    <DialogTrigger asChild>
                        <Button className="bg-[#FF6600] hover:bg-[#e65c00]">
                            <Plus className="mr-2 h-4 w-4" /> Add Audio Track
                        </Button>
                    </DialogTrigger>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Add New Audio Track</DialogTitle>
                            <DialogDescription>Add a direct MP3 download or stream URL.</DialogDescription>
                        </DialogHeader>
                        <form onSubmit={handleCreate} className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="title">Track Title</Label>
                                <Input id="title" required value={newTitle} onChange={e => setNewTitle(e.target.value)} placeholder="e.g. Morning Japa" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="artist">Artist / Speaker</Label>
                                <Input id="artist" value={newArtist} onChange={e => setNewArtist(e.target.value)} placeholder="e.g. Srila Prabhupada" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="category">Category</Label>
                                <Input id="category" value={newCategory} onChange={e => setNewCategory(e.target.value)} placeholder="e.g. Kirtan, Lecture" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="url">Direct Audio URL (MP3/Link)</Label>
                                <Input id="url" required value={newUrl} onChange={e => setNewUrl(e.target.value)} placeholder="https://..." />
                            </div>
                            <DialogFooter>
                                <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
                                <Button type="submit" className="bg-[#FF6600]">Save Track</Button>
                            </DialogFooter>
                        </form>
                    </DialogContent>
                </Dialog>
            </div>

            <div className="rounded-xl border bg-white shadow-sm overflow-hidden">
                <Table>
                    <TableHeader className="bg-slate-50">
                        <TableRow>
                            <TableHead className="w-12"></TableHead>
                            <TableHead>Title</TableHead>
                            <TableHead>Artist</TableHead>
                            <TableHead>Category</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow><TableCell colSpan={5} className="text-center h-24 text-slate-500">Loading library...</TableCell></TableRow>
                        ) : tracks.length === 0 ? (
                            <TableRow><TableCell colSpan={5} className="text-center h-24 text-slate-500">No audio tracks found.</TableCell></TableRow>
                        ) : (
                            tracks.map((track) => (
                                <TableRow key={track.id}>
                                    <TableCell><Music className="h-5 w-5 text-slate-400" /></TableCell>
                                    <TableCell className="font-medium text-slate-700">{track.title}</TableCell>
                                    <TableCell className="text-slate-500">{track.artist || "Unknown"}</TableCell>
                                    <TableCell>
                                        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-semibold bg-gray-100 text-gray-700">
                                            {track.category || "General"}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-right space-x-2">
                                        <Button variant="ghost" size="icon" onClick={() => handleDelete(track.id)}>
                                            <Trash2 className="h-4 w-4 text-red-500" />
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
