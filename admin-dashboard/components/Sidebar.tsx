"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
    LayoutDashboard,
    Users,
    CalendarDays,
    Video,
    Music,
    BellRing,
    Settings,
    LogOut,
} from "lucide-react";
import { auth } from "@/lib/firebase";

const navItems = [
    { name: "Dashboard", href: "/", icon: LayoutDashboard },
    { name: "Students & Roles", href: "/students", icon: Users },
    { name: "Attendance", href: "/attendance", icon: CalendarDays },
    { name: "Lectures", href: "/lectures", icon: Video },
    { name: "Audio Library", href: "/audio", icon: Music },
    { name: "Notifications", href: "/notifications", icon: BellRing },
    { name: "Settings", href: "/settings", icon: Settings },
];

export function Sidebar() {
    const pathname = usePathname();

    if (pathname === "/login") return null;

    return (
        <div className="flex h-screen w-64 flex-col border-r bg-slate-50">
            <div className="flex h-16 shrink-0 items-center px-6 border-b">
                <h1 className="text-xl font-bold tracking-tight text-[#FF6600]">
                    GitaLife Admin
                </h1>
            </div>
            <div className="flex-1 overflow-auto py-4">
                <nav className="space-y-1 px-4">
                    {navItems.map((item) => {
                        const Icon = item.icon;
                        const isActive = pathname === item.href || (pathname.startsWith(item.href) && item.href !== "/");
                        return (
                            <Link
                                key={item.href}
                                href={item.href}
                                className={cn(
                                    "flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors",
                                    isActive
                                        ? "bg-[#FF6600] text-white"
                                        : "text-slate-700 hover:bg-slate-200"
                                )}
                            >
                                <Icon className={cn("h-4 w-4", isActive ? "text-white" : "text-slate-500")} />
                                {item.name}
                            </Link>
                        );
                    })}
                </nav>
            </div>
            <div className="p-4 border-t">
                <button
                    onClick={() => auth.signOut()}
                    className="flex w-full items-center gap-3 rounded-md px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-200"
                >
                    <LogOut className="h-4 w-4 text-slate-500" />
                    Logout
                </button>
            </div>
        </div>
    );
}
