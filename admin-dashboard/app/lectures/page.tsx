"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, getDocs, deleteDoc, doc, addDoc } from "firebase/firestore";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Trash2, Plus, ExternalLink, Video } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface Lecture {
    id: string;
    title: string;
    youtubeVideoId: string;
    topic?: string;
    category?: string;
    duration?: string;
}

export default function LecturesPage() {
    const [lectures, setLectures] = useState<Lecture[]>([]);
    const [loading, setLoading] = useState(true);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    // New Lecture Form State
    const [newTitle, setNewTitle] = useState("");
    const [newUrl, setNewUrl] = useState("");
    const [newTopic, setNewTopic] = useState("");

    useEffect(() => {
        fetchLectures();
    }, []);

    async function fetchLectures() {
        try {
            setLoading(true);
            const snap = await getDocs(collection(db, "lectures"));
            const data: Lecture[] = [];
            snap.forEach((d) => {
                data.push({ id: d.id, ...(d.data() as Omit<Lecture, "id">) });
            });
            setLectures(data);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    const handleDelete = async (id: string) => {
        if (!confirm("Are you sure you want to delete this lecture?")) return;
        try {
            await deleteDoc(doc(db, "lectures", id));
            setLectures(lectures.filter(l => l.id !== id));
        } catch (e) {
            console.error("Failed to delete", e);
        }
    };

    const extractYoutubeId = (url: string) => {
        const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
        const match = url.match(regExp);
        return (match && match[2].length === 11) ? match[2] : url; // fallback to URL if exact ID entered
    };

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const videoId = extractYoutubeId(newUrl);
            const docRef = await addDoc(collection(db, "lectures"), {
                title: newTitle,
                youtubeVideoId: videoId,
                topic: newTopic || 'General',
                timestamp: new Date().getTime(),
            });
            setLectures([...lectures, { id: docRef.id, title: newTitle, youtubeVideoId: videoId, topic: newTopic }]);
            setIsDialogOpen(false);
            setNewTitle("");
            setNewUrl("");
            setNewTopic("");
        } catch (e) {
            console.error("Failed to add lecture", e);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-800">Video Lectures</h2>
                    <p className="text-slate-500">Manage the YouTube multimedia library items.</p>
                </div>
                <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                    <DialogTrigger asChild>
                        <Button className="bg-[#FF6600] hover:bg-[#e65c00]">
                            <Plus className="mr-2 h-4 w-4" /> Add Lecture
                        </Button>
                    </DialogTrigger>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Add New Lecture</DialogTitle>
                            <DialogDescription>Link a new YouTube video to the app's library.</DialogDescription>
                        </DialogHeader>
                        <form onSubmit={handleCreate} className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="title">Lecture Title</Label>
                                <Input id="title" required value={newTitle} onChange={e => setNewTitle(e.target.value)} placeholder="e.g. Chapter 1 Summary" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="topic">Topic / Category</Label>
                                <Input id="topic" value={newTopic} onChange={e => setNewTopic(e.target.value)} placeholder="e.g. Philosophy" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="url">YouTube URL or ID</Label>
                                <Input id="url" required value={newUrl} onChange={e => setNewUrl(e.target.value)} placeholder="https://youtube.com/watch?v=..." />
                            </div>
                            <DialogFooter>
                                <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
                                <Button type="submit" className="bg-[#FF6600]">Save Lecture</Button>
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
                            <TableHead>Topic</TableHead>
                            <TableHead>Video ID</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow><TableCell colSpan={5} className="text-center h-24 text-slate-500">Loading library...</TableCell></TableRow>
                        ) : lectures.length === 0 ? (
                            <TableRow><TableCell colSpan={5} className="text-center h-24 text-slate-500">No lectures found.</TableCell></TableRow>
                        ) : (
                            lectures.map((lecture) => (
                                <TableRow key={lecture.id}>
                                    <TableCell><Video className="h-5 w-5 text-slate-400" /></TableCell>
                                    <TableCell className="font-medium text-slate-700">{lecture.title}</TableCell>
                                    <TableCell>
                                        <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-semibold bg-gray-100 text-gray-700">
                                            {lecture.topic || lecture.category || "General"}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-slate-500 font-mono text-sm">{lecture.youtubeVideoId}</TableCell>
                                    <TableCell className="text-right space-x-2">
                                        <Button variant="ghost" size="icon" asChild>
                                            <a href={`https://youtube.com/watch?v=${lecture.youtubeVideoId}`} target="_blank" rel="noreferrer">
                                                <ExternalLink className="h-4 w-4 text-blue-500" />
                                            </a>
                                        </Button>
                                        <Button variant="ghost" size="icon" onClick={() => handleDelete(lecture.id)}>
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
