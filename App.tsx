import React, { useState, useEffect, Suspense, lazy } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import RoleGuard from './components/guards/RoleGuard';
import AdminLayout from './components/layouts/AdminLayout';
import UserLayout from './components/layouts/UserLayout';
import { supabase } from './lib/supabaseClient';
import { storageService } from './services/storageService';

// Lazy Load Components
const Dashboard = lazy(() => import('./components/Dashboard'));
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));
const SessionManagement = lazy(() => import('./components/SessionManagement'));
const GitaInsights = lazy(() => import('./components/GitaInsights'));
const HomeworkManagement = lazy(() => import('./components/HomeworkManagement'));
const ResourcesGallery = lazy(() => import('./components/ResourcesGallery'));
const MentorshipProgram = lazy(() => import('./components/MentorshipProgram'));
const DevoteeManagement = lazy(() => import('./components/DevoteeManagement'));
const ChantingCounter = lazy(() => import('./components/ChantingCounter'));
const AdminQuizManager = lazy(() => import('./components/quiz/AdminQuizManager'));
const UserQuizTaker = lazy(() => import('./components/quiz/UserQuizTaker'));
const UserQuizList = lazy(() => import('./components/quiz/UserQuizList'));
const KirtanPlayer = lazy(() => import('./components/KirtanPlayer'));
const Onboarding = lazy(() => import('./components/Onboarding'));
const MyProfile = lazy(() => import('./components/MyProfile'));

const LoadingSpinner = () => (
  <div className="min-h-screen flex items-center justify-center bg-[#FFFAF3]">
    <div className="text-center">
      <div className="w-10 h-10 border-3 border-divine-200 border-t-divine-600 rounded-full animate-spin mx-auto mb-4" />
      <p className="text-sm text-divine-700 font-serif font-medium animate-pulse">Gita Life</p>
    </div>
  </div>
);

const AppContent: React.FC = () => {
  const [session, setSession] = useState<any>(null);
  const [userRole, setUserRole] = useState<string | null>(null);
  const [profileExists, setProfileExists] = useState<boolean | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Handle Deep Links (Capacitor - loaded dynamically to avoid breaking web)
    let capApp: any = null;
    import('@capacitor/app').then(mod => {
      capApp = mod.App;
      capApp.addListener('appUrlOpen', (data: any) => {
        console.log('App opened with URL:', data.url);
      });
    }).catch(() => { });

    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user?.email) {
        fetchUserRole(session.user.email);
      } else {
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user?.email) {
        setLoading(true);
        fetchUserRole(session.user.email);
      } else {
        setUserRole(null);
        setProfileExists(false);
        setLoading(false);
      }
    });

    return () => {
      subscription.unsubscribe();
      if (capApp) capApp.removeAllListeners();
    };
  }, []);

  const fetchUserRole = async (email: string) => {
    try {
      const profile = await storageService.getProfileByEmail(email);
      if (profile) {
        setUserRole(profile.role || 'student');
        setProfileExists(true);
      } else {
        setUserRole('student');
        setProfileExists(false);
      }
    } catch (error) {
      console.error("Error fetching role:", error);
      setUserRole('student');
      setProfileExists(false);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (!session) {
    return (
      <Routes>
        <Route path="*" element={<Login />} />
      </Routes>
    );
  }

  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        {/* Onboarding */}
        <Route path="/onboarding" element={profileExists ? <Navigate to="/" /> : <Onboarding />} />

        {/* Root Redirect */}
        <Route path="/" element={
          !profileExists ? <Navigate to="/onboarding" replace /> :
            <Navigate to={userRole === 'admin' ? "/admin" : "/app"} replace />
        } />

        {/* Admin Routes */}
        <Route element={<RoleGuard allowedRoles={['admin']} />}>
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<AdminDashboard />} />
            <Route path="sessions" element={<SessionManagement mode="admin" />} />
            <Route path="devotees" element={<DevoteeManagement />} />
            <Route path="quizzes" element={<AdminQuizManager />} />
            <Route path="homework" element={<HomeworkManagement mode="admin" />} />
            <Route path="resources" element={<ResourcesGallery mode="admin" />} />
            <Route path="kirtan" element={<KirtanPlayer />} />
            <Route path="mentorship" element={<MentorshipProgram mode="admin" />} />
          </Route>
        </Route>

        {/* User Routes */}
        <Route element={<RoleGuard allowedRoles={['student', 'mentor']} />}>
          <Route path="/app" element={<UserLayout />}>
            <Route index element={<Dashboard />} />
            <Route path="sessions" element={<SessionManagement mode="student" />} />
            <Route path="chanting" element={<ChantingCounter />} />
            <Route path="homework" element={<HomeworkManagement mode="student" />} />
            <Route path="resources" element={<ResourcesGallery mode="student" />} />
            <Route path="mentorship" element={<MentorshipProgram mode="student" />} />
            <Route path="gita" element={<GitaInsights />} />
            <Route path="kirtan" element={<KirtanPlayer />} />
            <Route path="quiz" element={<UserQuizTaker />} />
            <Route path="my-quizzes" element={<UserQuizList />} />
            <Route path="profile" element={<MyProfile />} />
          </Route>
        </Route>

        {/* Fallback */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Suspense>
  );
};

const App: React.FC = () => (
  <Router>
    <AppContent />
  </Router>
);

export default App;
