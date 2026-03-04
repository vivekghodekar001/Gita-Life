"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function SettingsPage() {
    return (
        <div className="space-y-6 max-w-4xl">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight text-slate-800">Admin Settings</h2>
                    <p className="text-slate-500">Configure global dashboard preferences.</p>
                </div>
            </div>

            <div className="grid gap-6">
                <Card>
                    <CardHeader>
                        <CardTitle>System Information</CardTitle>
                        <CardDescription>Technical details for this deployment.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="grid grid-cols-2 gap-4 border-b pb-4">
                            <div>
                                <p className="text-sm font-medium text-slate-500">Platform Version</p>
                                <p className="font-semibold text-slate-800">GitaLife Admin v1.0.0</p>
                            </div>
                            <div>
                                <p className="text-sm font-medium text-slate-500">Firebase Database</p>
                                <p className="font-semibold text-slate-800">Connected</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle>Application Settings</CardTitle>
                        <CardDescription>Global variables across the mobile apps.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <div className="flex items-center justify-between">
                            <div className="space-y-0.5">
                                <Label className="text-base">Allow New User Signups</Label>
                                <p className="text-sm text-slate-500">When disabled, new accounts cannot be created on the mobile app.</p>
                            </div>
                            <Switch defaultChecked />
                        </div>

                        <div className="border-t pt-4">
                            <div className="space-y-2">
                                <Label>Support Contact Email</Label>
                                <div className="flex gap-4">
                                    <Input defaultValue="support@gitalife.com" className="max-w-md" />
                                    <Button variant="outline">Update</Button>
                                </div>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
