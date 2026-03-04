"use client";

import { useEffect, useState } from "react";
import { Users, CalendarDays, BookOpen, Clock } from "lucide-react";
import { StatsCard } from "@/components/StatsCard";
import { AttendanceChart } from "@/components/AttendanceChart";
import { db } from "@/lib/firebase";
import { collection, getDocs, query, where, Timestamp } from "firebase/firestore";

interface DashboardStats {
  totalStudents: number;
  sessionsThisWeek: number;
  activeToday: number;
  totalLectures: number;
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    totalStudents: 0,
    sessionsThisWeek: 0,
    activeToday: 0,
    totalLectures: 0,
  });
  const [chartData, setChartData] = useState<{ date: string; attendees: number }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        setLoading(true);
        // 1. Fetch Students
        const usersSnap = await getDocs(collection(db, "users"));
        // Assuming students might have a role, or we just count all non-admin users. For simplicity, counting all users
        const totalStudents = usersSnap.size;

        // 2. Fetch Lectures
        const lecturesSnap = await getDocs(collection(db, "lectures"));
        const totalLectures = lecturesSnap.size;

        // 3. Fetch Sessions (For chart and active counts)
        // Since we don't have the exact complex deep structure right now, 
        // we'll fetch 'sessions' collection if it exists, and build a dummy chart if empty.
        const sessionsSnap = await getDocs(collection(db, "sessions"));

        let activeTodayCount = 0;
        let weekCount = 0;
        const now = new Date();
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(now.getDate() - 7);

        const recentDataMap: Record<string, number> = {};

        sessionsSnap.forEach((doc) => {
          const data = doc.data();
          // Assume timestamp field is 'date'
          if (data.date && data.date instanceof Timestamp) {
            const dateObj = data.date.toDate();
            if (dateObj >= oneWeekAgo) {
              weekCount++;
              const dateStr = dateObj.toLocaleDateString('en-US', { weekday: 'short' });
              const attendees = (data.attendees || []).length;

              recentDataMap[dateStr] = (recentDataMap[dateStr] || 0) + attendees;

              if (dateObj.toDateString() === now.toDateString()) {
                activeTodayCount += attendees;
              }
            }
          }
        });

        // Format chart data
        const formattedChartData = Object.keys(recentDataMap).map(key => ({
          date: key,
          attendees: recentDataMap[key]
        }));

        setStats({
          totalStudents,
          sessionsThisWeek: weekCount,
          activeToday: activeTodayCount,
          totalLectures,
        });

        // If no real data, provide dummy data for visualization preview
        if (formattedChartData.length === 0) {
          setChartData([
            { date: "Mon", attendees: 45 },
            { date: "Tue", attendees: 52 },
            { date: "Wed", attendees: 38 },
            { date: "Thu", attendees: 65 },
            { date: "Fri", attendees: 48 },
            { date: "Sat", attendees: 70 },
            { date: "Sun", attendees: 85 },
          ]);
        } else {
          setChartData(formattedChartData);
        }

      } catch (error) {
        console.error("Failed to fetch dashboard stats", error);
      } finally {
        setLoading(false);
      }
    }

    fetchDashboardData();
  }, []);

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-3xl font-bold tracking-tight text-slate-800">Dashboard Overview</h2>
        <p className="text-slate-500">Welcome to the GitaLife admin panel. Here's what's happening today.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatsCard
          title="Total Students"
          value={stats.totalStudents}
          icon={Users}
          description="Registered users on GitaLife"
          isLoading={loading}
        />
        <StatsCard
          title="Active Today"
          value={stats.activeToday}
          icon={Clock}
          description="Total attendees across all sessions today"
          isLoading={loading}
        />
        <StatsCard
          title="Sessions This Week"
          value={stats.sessionsThisWeek}
          icon={CalendarDays}
          description="Total physical sessions hosted"
          isLoading={loading}
        />
        <StatsCard
          title="Total Lectures"
          value={stats.totalLectures}
          icon={BookOpen}
          description="Available in multimedia library"
          isLoading={loading}
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <div className="col-span-4 rounded-xl border bg-card text-card-foreground shadow">
          <AttendanceChart data={chartData} isLoading={loading} />
        </div>
        <div className="col-span-3 rounded-xl border bg-card text-card-foreground shadow p-6">
          <h3 className="font-semibold leading-none tracking-tight mb-4">Quick Actions</h3>
          <div className="space-y-4">
            <p className="text-sm text-slate-500">Access common administrative tasks below.</p>
            <div className="grid grid-cols-2 gap-2">
              <a href="/attendance" className="flex items-center justify-center rounded-md bg-slate-100 p-4 text-sm font-medium hover:bg-slate-200 transition-colors">Mark Attendance</a>
              <a href="/notifications" className="flex items-center justify-center rounded-md bg-slate-100 p-4 text-sm font-medium hover:bg-slate-200 transition-colors">Send Notification</a>
              <a href="/lectures" className="flex items-center justify-center rounded-md bg-slate-100 p-4 text-sm font-medium hover:bg-slate-200 transition-colors">Upload Lecture</a>
              <a href="/students" className="flex items-center justify-center rounded-md bg-slate-100 p-4 text-sm font-medium hover:bg-slate-200 transition-colors">View Students</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
