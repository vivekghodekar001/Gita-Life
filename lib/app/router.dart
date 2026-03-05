import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/lecture_model.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/pending_screen.dart';
import '../screens/auth/suspended_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/gita/chapter_list_screen.dart';
import '../screens/gita/verse_list_screen.dart';
import '../screens/gita/verse_detail_screen.dart';
import '../screens/gita/gita_search_screen.dart';
import '../screens/gita/bookmarks_screen.dart';
import '../screens/japa/japa_counter_screen.dart';
import '../screens/japa/japa_history_screen.dart';
import '../screens/audio/audio_library_screen.dart';
import '../screens/audio/audio_player_screen.dart';
import '../screens/audio/downloads_screen.dart';
import '../screens/lectures/lecture_list_screen.dart';
import '../screens/lectures/lecture_player_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/attendance/attendance_history_screen.dart';
import '../screens/attendance/mark_attendance_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_lectures_screen.dart';
import '../screens/admin/manage_audio_screen.dart';
import '../screens/admin/manage_students_screen.dart';
import '../screens/admin/send_notification_screen.dart';
import '../screens/admin/manage_attendance_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<AsyncValue<UserModel?>>(
      userProfileProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final userProfile = ref.read(userProfileProvider);

      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/forgot-password';
      final isOnboardingRoute = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      // Don't redirect from splash or onboarding — they handle their own navigation
      if (isOnboardingRoute) return null;

      debugPrint('ROUTER: loc=${state.matchedLocation}, auth=$isAuthenticated, status=${userProfile.valueOrNull?.status}');

      if (!isAuthenticated && !isAuthRoute) return '/login';
      
      if (isAuthenticated) {
        final profile = userProfile.valueOrNull;
        
        // Wait for profile to load before making further redirect decisions
        if (userProfile.isLoading) return null;
        
        if (profile != null) {
          if (profile.status == 'pending' && state.matchedLocation != '/pending') {
            return '/pending';
          }
          if (profile.status == 'suspended' && state.matchedLocation != '/suspended') {
            return '/suspended';
          }
          if (profile.status == 'active' && 
              (isAuthRoute || state.matchedLocation == '/pending' || state.matchedLocation == '/suspended')) {
            return '/home';
          }
          
          // RoleGuard logic: Prevent non-admins from accessing /admin routes
          if (state.matchedLocation.startsWith('/admin') && profile.role != 'admin') {
            return '/home';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/pending', builder: (context, state) => const PendingScreen()),
      GoRoute(path: '/suspended', builder: (context, state) => const SuspendedScreen()),

      // Home
      GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),

      // Gita routes
      GoRoute(path: '/gita', builder: (context, state) => const ChapterListScreen()),
      GoRoute(
        path: '/gita/chapter/:chapterId',
        builder: (context, state) => VerseListScreen(chapterId: state.pathParameters['chapterId']!),
      ),
      GoRoute(
        path: '/gita/chapter/:chapterId/verse/:verseId',
        builder: (context, state) => VerseDetailScreen(
          chapterId: state.pathParameters['chapterId']!,
          verseId: state.pathParameters['verseId']!,
        ),
      ),
      GoRoute(path: '/gita/search', builder: (context, state) => const GitaSearchScreen()),
      GoRoute(path: '/gita/bookmarks', builder: (context, state) => const BookmarksScreen()),

      // Japa routes
      GoRoute(path: '/japa', builder: (context, state) => const JapaCounterScreen()),
      GoRoute(path: '/japa/history', builder: (context, state) => const JapaHistoryScreen()),

      // Audio routes
      GoRoute(path: '/audio', builder: (context, state) => const AudioLibraryScreen()),
      GoRoute(
        path: '/audio/player/:trackId',
        builder: (context, state) => AudioPlayerScreen(trackId: state.pathParameters['trackId']!),
      ),
      GoRoute(path: '/audio/downloads', builder: (context, state) => const DownloadsScreen()),

      // Lecture routes
      GoRoute(path: '/lectures', builder: (context, state) => const LectureListScreen()),
      GoRoute(
        path: '/lectures/player/:lectureId',
        builder: (context, state) => LecturePlayerScreen(
          lectureId: state.pathParameters['lectureId']!,
          lecture: state.extra as LectureModel?,
        ),
      ),

      // Profile routes
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),

      // Attendance routes
      GoRoute(path: '/attendance/history', builder: (context, state) => const AttendanceHistoryScreen()),
      GoRoute(
        path: '/admin/attendance/mark/:sessionId',
        builder: (context, state) => MarkAttendanceScreen(sessionId: state.pathParameters['sessionId']!),
      ),

      // Admin routes
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/lectures', builder: (context, state) => const ManageLecturesScreen()),
      GoRoute(path: '/admin/audio', builder: (context, state) => const ManageAudioScreen()),
      GoRoute(path: '/admin/students', builder: (context, state) => const ManageStudentsScreen()),
      GoRoute(path: '/admin/notifications', builder: (context, state) => const SendNotificationScreen()),
      GoRoute(path: '/admin/attendance', builder: (context, state) => const ManageAttendanceScreen()),
    ],
  );
});
