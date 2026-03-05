"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, getDocs, updateDoc, doc } from "firebase/firestore";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ChevronRight, Search, ShieldCheck, Ban } from "lucide-react";
import Link from "next/link";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

interface UserData {
    id: string;
    name: string;
    email: string;
    role: string;
    status: string; // active, suspended, pending
    joinedAt?: string;
    phone?: string;
    branch?: string;
    year?: string;
}

export default function StudentsPage() {
    const [users, setUsers] = useState<UserData[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState("");
    const [roleFilter, setRoleFilter] = useState("all");

    useEffect(() => {
        fetchUsers();
    }, []);

    async function fetchUsers() {
        try {
            setLoading(true);
            const snap = await getDocs(collection(db, "users"));
            const usersData: UserData[] = [];
            snap.forEach((d) => {
                const data = d.data();
                usersData.push({
                    id: d.id,
                    name: data.name || data.displayName || "Unknown",
                    email: data.email || "No Email",
                    role: data.role || "student",
                    status: data.status || "active",
                    phone: data.phoneNumber || data.phone || "No Phone",
                    branch: data.collegeBranch || "N/A",
                    year: data.year || "N/A",
                });
            });
            setUsers(usersData);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    }

    const toggleStatus = async (uid: string, currentStatus: string) => {
        try {
            const newStatus = currentStatus === "active" ? "suspended" : "active";
            await updateDoc(doc(db, "users", uid), { status: newStatus });
            setUsers(users.map(u => u.id === uid ? { ...u, status: newStatus } : u));
        } catch (e) {
            console.error("Failed to update status", e);
        }
    };

    const filteredUsers = users.filter((u) => {
        const matchesSearch = u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase());
        const matchesRole = roleFilter === "all" || u.role === roleFilter;
        return matchesSearch && matchesRole;
    });

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h2 className="text-3xl font-bold tracking-tight text-slate-800">Student Profiles & Roles</h2>
            </div>

            <div className="flex items-center gap-4 bg-white p-4 rounded-xl shadow-sm border">
                <div className="relative flex-1 max-w-sm">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-slate-500" />
                    <Input
                        placeholder="Search students..."
                        className="pl-9"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                </div>
                <Select value={roleFilter} onValueChange={setRoleFilter}>
                    <SelectTrigger className="w-[180px]">
                        <SelectValue placeholder="Filter Role" />
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="all">All Roles</SelectItem>
                        <SelectItem value="student">Students</SelectItem>
                        <SelectItem value="admin">Admins</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            <div className="rounded-xl border bg-white shadow-sm overflow-hidden">
                <Table>
                    <TableHeader className="bg-slate-50">
                        <TableRow>
                            <TableHead>Name</TableHead>
                            <TableHead>Email</TableHead>
                            <TableHead>Branch / Year</TableHead>
                            <TableHead>Role</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={5} className="text-center h-24 text-slate-500">Loading directory...</TableCell>
                            </TableRow>
                        ) : filteredUsers.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={5} className="text-center h-24 text-slate-500">No users found matching filters.</TableCell>
                            </TableRow>
                        ) : (
                            filteredUsers.map((user) => (
                                <TableRow key={user.id}>
                                    <TableCell className="font-medium">{user.name}</TableCell>
                                    <TableCell className="text-slate-500">{user.email}</TableCell>
                                    <TableCell>
                                        <div className="text-sm font-medium text-slate-700">{user.branch}</div>
                                        <div className="text-xs text-slate-400">{user.year}</div>
                                    </TableCell>
                                    <TableCell>
                                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${user.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                                            }`}>
                                            {user.role}
                                        </span>
                                    </TableCell>
                                    <TableCell>
                                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${user.status === 'active' ? 'bg-green-100 text-green-800' :
                                            user.status === 'suspended' ? 'bg-red-100 text-red-800' : 'bg-yellow-100 text-yellow-800'
                                            }`}>
                                            {user.status}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-right space-x-2">
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => toggleStatus(user.id, user.status)}
                                            title={user.status === 'active' ? 'Suspend User' : 'Activate User'}
                                        >
                                            {user.status === 'active' ? <Ban className="h-4 w-4 text-red-500" /> : <ShieldCheck className="h-4 w-4 text-green-500" />}
                                        </Button>
                                        <Button variant="ghost" size="sm" asChild>
                                            <Link href={`/students/${user.id}`}>
                                                <ChevronRight className="h-4 w-4" />
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
