"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { db } from "@/lib/firebase";
import { doc, onSnapshot, updateDoc } from "firebase/firestore";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, User, Mail, Phone, ShieldAlert, Calendar, MapPin, GraduationCap, Briefcase, Heart, BookOpen } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface UserProfile {
    id: string;
    name: string;
    email: string;
    role: string;
    status: string;
    phone?: string;
    createdAt?: string;
    address?: string;
    dob?: string;
    branch?: string;
    year?: string;
    interests?: string[];
    skills?: string[];
}

export default function StudentDetailPage() {
    const { uid } = useParams();
    const router = useRouter();
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!uid) return;

        setLoading(true);
        const docRef = doc(db, "users", uid as string);

        const unsubscribe = onSnapshot(docRef, (userDoc) => {
            if (userDoc.exists()) {
                const data = userDoc.data();
                console.log("Admin Dashboard - Fetched User:", data);
                setProfile({
                    id: userDoc.id,
                    name: data.fullName || data.name || data.displayName || "Unknown",
                    email: data.email || "No Email",
                    role: data.role || "student",
                    status: data.status || "active",
                    phone: data.phoneNumber || data.phone || "Not Provided",
                    createdAt: data.createdAt?.toDate?.()?.toLocaleDateString() || "Unknown",
                    address: data.address || "Not Provided",
                    dob: data.dateOfBirth?.toDate?.()?.toLocaleDateString() || data.dateOfBirth || "Not Provided",
                    branch: data.collegeBranch || "Not Provided",
                    year: data.year || "Not Provided",
                    interests: data.interests || [],
                    skills: data.skills || [],
                });
            } else {
                setProfile(null);
            }
            setLoading(false);
        }, (error) => {
            console.error("Error listening to user profile:", error);
            setLoading(false);
        });

        return () => unsubscribe();
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
                            <GraduationCap className="h-5 w-5 text-[#FF6600]" />
                            Education & Location
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="flex items-start gap-2">
                            <MapPin className="h-4 w-4 mt-1 text-slate-400" />
                            <div>
                                <p className="text-sm font-medium text-slate-500">Address</p>
                                <p className="text-slate-700">{profile.address}</p>
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <p className="text-sm font-medium text-slate-500">College Branch</p>
                                <p className="flex items-center gap-2 text-slate-700">
                                    <BookOpen className="h-4 w-4" /> {profile.branch}
                                </p>
                            </div>
                            <div>
                                <p className="text-sm font-medium text-slate-500">Year of Study</p>
                                <p className="text-slate-700">{profile.year}</p>
                            </div>
                        </div>
                        <div>
                            <p className="text-sm font-medium text-slate-500">Date of Birth</p>
                            <p className="text-slate-700">{profile.dob}</p>
                        </div>
                    </CardContent>
                </Card>

                <Card className="md:col-span-2">
                    <CardHeader>
                        <CardTitle className="text-lg">Interests & Skills</CardTitle>
                    </CardHeader>
                    <CardContent className="grid gap-6 md:grid-cols-2">
                        <div>
                            <div className="flex items-center gap-2 mb-3">
                                <Heart className="h-4 w-4 text-rose-500" />
                                <h4 className="font-semibold text-slate-800">Interests</h4>
                            </div>
                            <div className="flex flex-wrap gap-2">
                                {profile.interests?.length ? profile.interests.map((it, idx) => (
                                    <Badge key={idx} variant="secondary" className="bg-slate-100">{it}</Badge>
                                )) : <span className="text-sm text-slate-400 italic">No interests listed</span>}
                            </div>
                        </div>
                        <div>
                            <div className="flex items-center gap-2 mb-3">
                                <Briefcase className="h-4 w-4 text-blue-500" />
                                <h4 className="font-semibold text-slate-800">Skills</h4>
                            </div>
                            <div className="flex flex-wrap gap-2">
                                {profile.skills?.length ? profile.skills.map((sk, idx) => (
                                    <Badge key={idx} variant="outline" className="text-blue-600 border-blue-200">{sk}</Badge>
                                )) : <span className="text-sm text-slate-400 italic">No skills listed</span>}
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card className="md:col-span-2">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <ShieldAlert className="h-5 w-5 text-[#FF6600]" />
                            Account Administration
                        </CardTitle>
                        <CardDescription>Manage this user&apos;s access and roles.</CardDescription>
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
