"use client";

import { createContext, useContext, useEffect, useState } from "react";
import { User, onAuthStateChanged } from "firebase/auth";
import { auth, db } from "@/lib/firebase";
import { doc, getDoc } from "firebase/firestore";
import { useRouter, usePathname } from "next/navigation";

interface AuthContextType {
    user: User | null;
    isAdmin: boolean;
    loading: boolean;
}

const AuthContext = createContext<AuthContextType>({ user: null, isAdmin: false, loading: true });

export function AuthProvider({ children }: { children: React.ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [isAdmin, setIsAdmin] = useState(false);
    const [loading, setLoading] = useState(true);
    const router = useRouter();
    const pathname = usePathname();

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, async (user) => {
            setLoading(true);
            if (user) {
                // Here we ideally check the roles in firestore
                // Let's assume an admin collection or checking the 'users' collection for role: 'admin'
                try {
                    const userDoc = await getDoc(doc(db, "users", user.uid));
                    if (userDoc.exists() && userDoc.data()?.role === "admin") {
                        setIsAdmin(true);
                        setUser(user);
                    } else {
                        // Not an admin, sign out or block
                        await auth.signOut();
                        setIsAdmin(false);
                        setUser(null);
                        if (pathname !== "/login") router.push("/login");
                    }
                } catch (error) {
                    console.error("Auth check error:", error);
                    setIsAdmin(false);
                    setUser(null);
                    if (pathname !== "/login") router.push("/login");
                }
            } else {
                setIsAdmin(false);
                setUser(null);
                if (pathname !== "/login") router.push("/login");
            }
            setLoading(false);
        });

        return () => unsubscribe();
    }, [pathname, router]);

    return (
        <AuthContext.Provider value={{ user, isAdmin, loading }}>
            {!loading ? children : <div className="h-screen w-full flex items-center justify-center">Loading...</div>}
        </AuthContext.Provider>
    );
}

export const useAuth = () => useContext(AuthContext);
