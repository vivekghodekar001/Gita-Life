"use client";

import { Bar, BarChart, ResponsiveContainer, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

interface AttendanceChartProps {
    data: { date: string; attendees: number }[];
    isLoading?: boolean;
}

export function AttendanceChart({ data, isLoading }: AttendanceChartProps) {
    return (
        <Card className="col-span-4">
            <CardHeader>
                <CardTitle>Attendance Overview (Last 7 Days)</CardTitle>
            </CardHeader>
            <CardContent className="h-[300px]">
                {isLoading ? (
                    <div className="h-full w-full animate-pulse bg-slate-100 rounded-md flex items-center justify-center">
                        <span className="text-slate-400">Loading chart data...</span>
                    </div>
                ) : data.length === 0 ? (
                    <div className="h-full w-full flex items-center justify-center">
                        <span className="text-slate-400">No recent attendance data</span>
                    </div>
                ) : (
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={data}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} />
                            <XAxis dataKey="date" stroke="#888888" fontSize={12} tickLine={false} axisLine={false} />
                            <YAxis stroke="#888888" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(value) => `${value}`} />
                            <Tooltip cursor={{ fill: "transparent" }} />
                            <Bar dataKey="attendees" fill="#FF6600" radius={[4, 4, 0, 0]} />
                        </BarChart>
                    </ResponsiveContainer>
                )}
            </CardContent>
        </Card>
    );
}
