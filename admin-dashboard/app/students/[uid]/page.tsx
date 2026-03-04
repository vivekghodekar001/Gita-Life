"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { db } from "@/lib/firebase";
import { doc, getDoc, updateDoc } from "firebase/firestore";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, User, Mail, Phone, ShieldAlert, Calendar } from "lucide-react";

interface UserProfile {
    id: string;
    name: string;
    email: string;
    role: string;
    status: string;
    phone?: string;
    createdAt?: string;
    // Extensible for more GitaLife properties (japa rounds, etc.)
}

export default function StudentDetailPage() {
    const { uid } = useParams();
    const router = useRouter();
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchUser() {
            try {
                const userDoc = await getDoc(doc(db, "users", uid as string));
                if (userDoc.exists()) {
                    const data = userDoc.data();
                    setProfile({
                        id: userDoc.id,
                        name: data.name || data.displayName || "Unknown",
                        email: data.email || "No Email",
                        role: data.role || "student",
                        status: data.status || "active",
                        phone: data.phoneNumber || data.phone || "Not Provided",
                        createdAt: data.createdAt?.toDate?.()?.toLocaleDateString() || "Unknown",
                    });
                }
            } catch (e) {
                console.error("Error fetching user profile", e);
            } finally {
                setLoading(false);
            }
        }

        if (uid) fetchUser();
    }, [uid]);

    const toggleStatus = async () => {
        if (!profile) return;
        try {
            const newStatus = profile.status === "active" ? "suspended" : "active";
            await updateDoc(doc(db, "users", profile.id), { status: newStatus });
            setProfile({ ...profile, status: newStatus });
        } catch (e) {
            console.error(e);
        }
    };

    const promoteToAdmin = async () => {
        if (!profile) return;
        try {
            await updateDoc(doc(db, "users", profile.id), { role: "admin" });
            setProfile({ ...profile, role: "admin" });
        } catch (e) {
            console.error(e);
        }
    }

    if (loading) return <div className="p-8 text-center text-slate-500">Loading student profile...</div>;
    if (!profile) return <div className="p-8 text-center text-red-500">Student not found.</div>;

    return (
        <div className="space-y-6 max-w-4xl">
            <div className="flex items-center gap-4">
                <Button variant="outline" size="icon" onClick={() => router.push("/students")}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <h2 className="text-3xl font-bold tracking-tight text-slate-800">Student Profile</h2>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <User className="h-5 w-5 text-[#FF6600]" />
                            Personal Details
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div>
                            <p className="text-sm font-medium text-slate-500">Full Name</p>
                            <p className="text-lg font-semibold">{profile.name}</p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Email Address</p>
                            <p className="flex items-center gap-2 text-slate-700">
                                <Mail className="h-4 w-4" /> {profile.email}
                            </p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Phone</p>
                            <p className="flex items-center gap-2 text-slate-700">
                                <Phone className="h-4 w-4" /> {profile.phone}
                            </p>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Joined</p>
                            <p className="flex items-center gap-2 text-slate-700">
                                <Calendar className="h-4 w-4" /> {profile.createdAt}
                            </p>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <ShieldAlert className="h-5 w-5 text-[#FF6600]" />
                            Account Administration
                        </CardTitle>
                        <CardDescription>Manage this user's access and roles.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="font-medium">Current Status</p>
                                <p className="text-sm text-slate-500">Active users can log into the app.</p>
                            </div>
                            <span className={`px-3 py-1 rounded-full text-sm font-semibold capitalize ${profile.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                }`}>
                                {profile.status}
                            </span>
                        </div>

                        <div className="flex items-center justify-between border-t pt-4">
                            <div>
                                <p className="font-medium">Account Role</p>
                                <p className="text-sm text-slate-500">Admins can access this dashboard.</p>
                            </div>
                            <span className={`px-3 py-1 rounded-full text-sm font-semibold capitalize ${profile.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                                }`}>
                                {profile.role}
                            </span>
                        </div>

                        <div className="flex flex-col gap-3 border-t pt-6">
                            <Button
                                variant={profile.status === 'active' ? 'destructive' : 'default'}
                                className={profile.status !== 'active' ? 'bg-green-600 hover:bg-green-700' : ''}
                                onClick={toggleStatus}
                            >
                                {profile.status === 'active' ? "Suspend Account" : "Reactivate Account"}
                            </Button>

                            {profile.role !== 'admin' && (
                                <Button variant="outline" onClick={promoteToAdmin}>
                                    Promote to Administrator
                                </Button>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
