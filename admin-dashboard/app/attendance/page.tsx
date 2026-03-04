"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, getDocs, Timestamp } from "firebase/firestore";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { ChevronRight, Download, Plus } from "lucide-react";
import Link from "next/link";
import { format } from "date-fns"; // Standard JS Date will work too if preferred, using standard to avoid dependency

interface SessionData {
    id: string;
    topic: string;
    speaker: string;
    date: Date | null;
    attendeesCount: number;
}

export default function AttendancePage() {
    const [sessions, setSessions] = useState<SessionData[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchSessions();
    }, []);

    async function fetchSessions() {
        try {
            setLoading(true);
            const snap = await getDocs(collection(db, "sessions"));
            const sessionsData: SessionData[] = [];
            snap.forEach((d) => {
                const data = d.data();
                let dateObj = null;
                if (data.date && data.date instanceof Timestamp) {
                    dateObj = data.date.toDate();
                } else if (data.date && typeof data.date === "string") {
                    dateObj = new Date(data.date);
                }

                sessionsData.push({
                    id: d.id,
                    topic: data.topic || "General Session",
                    speaker: data.speaker || "Unknown",
                    date: dateObj,
                    attendeesCount: (data.attendees || []).length,
                });
            });
            // Sort by newest first
            sessionsData.sort((a, b) => (b.date?.getTime() || 0) - (a.date?.getTime() || 0));
            setSessions(sessionsData);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    const exportCSV = () => {
        if (sessions.length === 0) return;

        // Headers
        let csv = "Session ID,Topic,Speaker,Date,Total Attendees\n";

        // Rows
        sessions.forEach(session => {
            const dateStr = session.date ? session.date.toLocaleDateString() : "Unknown Date";
            // Escape strings containing commas
            const cleanTopic = `"${session.topic.replace(/"/g, '""')}"`;
            const cleanSpeaker = `"${session.speaker.replace(/"/g, '""')}"`;
            csv += `${session.id},${cleanTopic},${cleanSpeaker},${dateStr},${session.attendeesCount}\n`;
        });

        const blob = new Blob([csv], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `attendance-report-${new Date().toISOString().split('T')[0]}.csv`;
        a.click();
        window.URL.revokeObjectURL(url);
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-800">Attendance Sessions</h2>
                    <p className="text-slate-500">Manage classroom attendance and export reports.</p>
                </div>
                <div className="flex gap-3">
                    <Button variant="outline" onClick={exportCSV} disabled={sessions.length === 0}>
                        <Download className="mr-2 h-4 w-4" /> Export CSV
                    </Button>
                    <Button className="bg-[#FF6600] hover:bg-[#e65c00]">
                        <Plus className="mr-2 h-4 w-4" /> Create Session
                    </Button>
                </div>
            </div>

            <div className="rounded-xl border bg-white shadow-sm overflow-hidden">
                <Table>
                    <TableHeader className="bg-slate-50">
                        <TableRow>
                            <TableHead>Date</TableHead>
                            <TableHead>Topic</TableHead>
                            <TableHead>Speaker</TableHead>
                            <TableHead>Total Attendees</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={5} className="text-center h-24 text-slate-500">Loading sessions...</TableCell>
                            </TableRow>
                        ) : sessions.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} className="text-center h-24 text-slate-500">No sessions recorded yet.</TableCell>
                            </TableRow>
                        ) : (
                            sessions.map((session) => (
                                <TableRow key={session.id}>
                                    <TableCell className="font-medium whitespace-nowrap">
                                        {session.date ? session.date.toLocaleDateString() : "Unknown"}
                                    </TableCell>
                                    <TableCell>{session.topic}</TableCell>
                                    <TableCell>{session.speaker}</TableCell>
                                    <TableCell>
                                        <span className="inline-flex items-center justify-center bg-orange-100 text-orange-800 h-6 px-2 rounded-full text-xs font-semibold">
                                            {session.attendeesCount}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <Button variant="ghost" size="sm" asChild>
                                            <Link href={`/attendance/${session.id}`}>
                                                View Details <ChevronRight className="ml-1 h-4 w-4" />
                                            </Link>
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
