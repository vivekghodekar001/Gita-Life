"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { db } from "@/lib/firebase";
import { doc, getDoc, Timestamp } from "firebase/firestore";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Users, Calendar, User, FileText } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export default function SessionDetailPage() {
    const { sessionId } = useParams();
    const router = useRouter();
    const [sessionInfo, setSessionInfo] = useState<any>(null);
    const [attendees, setAttendees] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchSessionDetails() {
            try {
                const docRef = doc(db, "sessions", sessionId as string);
                const docSnap = await getDoc(docRef);

                if (docSnap.exists()) {
                    const data = docSnap.data();
                    let dateStr = "Unknown Date";
                    if (data.date && data.date instanceof Timestamp) {
                        dateStr = data.date.toDate().toLocaleDateString();
                    } else if (data.date) {
                        dateStr = new Date(data.date).toLocaleDateString();
                    }

                    setSessionInfo({
                        id: docSnap.id,
                        topic: data.topic || "General Session",
                        speaker: data.speaker || "Unknown",
                        date: dateStr,
                        notes: data.notes || "No additional notes.",
                    });

                    // Fetch attendee details
                    // Depending on schema, attendees might be a subcollection or an array of UIDs
                    // Here we assume it's an array of objects or UIDs for demonstration
                    const attendeeList = data.attendees || [];
                    // If they are just UIDs, we would need to bulk-fetch user profiles.
                    // For now, let's map what we have.
                    const mappedAttendees = attendeeList.map((a: any, i: number) => {
                        if (typeof a === 'string') {
                            return { id: a, name: "Loading...", status: "Present" };
                        }
                        return { id: a.id || `temp-${i}`, name: a.name || 'Unknown', status: a.status || 'Present' };
                    });

                    setAttendees(mappedAttendees);
                }
            } catch (e) {
                console.error("Error fetching session", e);
            } finally {
                setLoading(false);
            }
        }

        if (sessionId) fetchSessionDetails();
    }, [sessionId]);

    if (loading) return <div className="p-8 text-center text-slate-500">Loading session reports...</div>;
    if (!sessionInfo) return <div className="p-8 text-center text-red-500">Session not found.</div>;

    return (
        <div className="space-y-6 max-w-5xl">
            <div className="flex items-center gap-4">
                <Button variant="outline" size="icon" onClick={() => router.push("/attendance")}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <h2 className="text-3xl font-bold tracking-tight text-slate-800">Session Summary</h2>
            </div>

            <div className="grid gap-6 md:grid-cols-3">
                <Card className="md:col-span-1">
                    <CardHeader>
                        <CardTitle>Details</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <p className="text-sm font-medium text-slate-500 flex items-center gap-2"><FileText className="h-4 w-4" /> Topic</p>
                            <p className="font-semibold">{sessionInfo.topic}</p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500 flex items-center gap-2"><User className="h-4 w-4" /> Speaker</p>
                            <p className="font-semibold">{sessionInfo.speaker}</p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500 flex items-center gap-2"><Calendar className="h-4 w-4" /> Date</p>
                            <p className="font-semibold">{sessionInfo.date}</p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500 flex items-center gap-2"><Users className="h-4 w-4" /> Total Present</p>
                            <p className="font-semibold text-[#FF6600] text-xl">{attendees.length}</p>
                        </div>
                    </CardContent>
                </Card>

                <Card className="md:col-span-2">
                    <CardHeader>
                        <CardTitle>Attendance Register</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader className="bg-slate-50">
                                    <TableRow>
                                        <TableHead>Identifier</TableHead>
                                        <TableHead>Status</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {attendees.length === 0 ? (
                                        <TableRow>
                                            <TableCell colSpan={2} className="text-center h-24 text-slate-500">
                                                No attendance recorded for this session.
                                            </TableCell>
                                        </TableRow>
                                    ) : (
                                        attendees.map((a, i) => (
                                            <TableRow key={i}>
                                                <TableCell className="font-medium">{a.id}</TableCell>
                                                <TableCell>
                                                    <span className="inline-flex items-center justify-center bg-green-100 text-green-800 px-2 py-0.5 rounded-full text-xs font-semibold">
                                                        {a.status}
                                                    </span>
                                                </TableCell>
                                            </TableRow>
                                        ))
                                    )}
                                </TableBody>
                            </Table>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
