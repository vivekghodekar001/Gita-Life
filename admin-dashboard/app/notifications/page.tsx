"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, addDoc, getDocs, orderBy, query, limit } from "firebase/firestore";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { BellRing, Send } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

interface NotificationHistory {
    id: string;
    title: string;
    body: string;
    timestamp: string;
    status: string;
}

export default function NotificationsPage() {
    const [title, setTitle] = useState("");
    const [body, setBody] = useState("");
    const [loading, setLoading] = useState(false);
    const [history, setHistory] = useState<NotificationHistory[]>([]);

    useEffect(() => {
        fetchHistory();
    }, []);

    async function fetchHistory() {
        try {
            // Assuming a 'notification_history' collection or similar
            const q = query(collection(db, "notifications"), orderBy("timestamp", "desc"), limit(10));
            const snap = await getDocs(q);
            const data: NotificationHistory[] = [];
            snap.forEach(d => {
                const item = d.data();
                data.push({
                    id: d.id,
                    title: item.title || "No Title",
                    body: item.body || "",
                    timestamp: item.timestamp ? new Date(item.timestamp).toLocaleString() : new Date().toLocaleString(),
                    status: item.status || "Sent",
                });
            });
            setHistory(data);
        } catch (e) {
            console.error("Failed to fetch notification history", e);
        }
    }

    const handleSend = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            // Writing to notifications collection. 
            // A Firebase Cloud Function should trigger on 'created' to send FCM payload.
            await addDoc(collection(db, "notifications"), {
                title,
                body,
                timestamp: new Date().getTime(),
                status: "Sent",
                sender: "Admin Dashboard",
            });

            setTitle("");
            setBody("");
            fetchHistory(); // refresh the list
        } catch (error) {
            console.error("Failed to send notification", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6 max-w-6xl">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-800">Push Notifications</h2>
                    <p className="text-slate-500">Send global alerts and updates to all mobile app users.</p>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <Card className="shadow-sm">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Send className="h-5 w-5 text-[#FF6600]" />
                            Compose Message
                        </CardTitle>
                        <CardDescription>This message will be broadcasted to all enrolled devices.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={handleSend} className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="title">Notification Title</Label>
                                <Input
                                    id="title"
                                    required
                                    placeholder="e.g. Special Sunday Feast"
                                    value={title}
                                    onChange={(e) => setTitle(e.target.value)}
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="body">Message Body</Label>
                                <Textarea
                                    id="body"
                                    required
                                    placeholder="Enter your message here..."
                                    className="min-h-[120px]"
                                    value={body}
                                    onChange={(e) => setBody(e.target.value)}
                                />
                            </div>
                            <Button type="submit" className="w-full bg-[#FF6600] hover:bg-[#e65c00]" disabled={loading}>
                                {loading ? "Sending Broadcast..." : "Send Global Broadcast"}
                            </Button>
                        </form>
                    </CardContent>
                </Card>

                <Card className="shadow-sm">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <BellRing className="h-5 w-5 text-slate-500" />
                            Recent Broadcasts
                        </CardTitle>
                        <CardDescription>History of the last 10 notifications sent.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="rounded-md border">
                            <Table>
                                <TableHeader className="bg-slate-50">
                                    <TableRow>
                                        <TableHead>Title</TableHead>
                                        <TableHead>Date & Time</TableHead>
                                        <TableHead>Status</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {history.length === 0 ? (
                                        <TableRow>
                                            <TableCell colSpan={3} className="text-center h-24 text-slate-500">
                                                No previous broadcasts found.
                                            </TableCell>
                                        </TableRow>
                                    ) : (
                                        history.map((item) => (
                                            <TableRow key={item.id}>
                                                <TableCell className="font-medium">{item.title}</TableCell>
                                                <TableCell className="text-slate-500 text-sm">{item.timestamp}</TableCell>
                                                <TableCell>
                                                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-800">
                                                        {item.status}
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
