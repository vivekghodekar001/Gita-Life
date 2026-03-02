import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
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
import '../screens/profile/settings_screen.dart';
import '../screens/attendance/attendance_history_screen.dart';
import '../screens/attendance/mark_attendance_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_lectures_screen.dart';
import '../screens/admin/manage_audio_screen.dart';
import '../screens/admin/manage_students_screen.dart';
import '../screens/admin/send_notification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

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
        builder: (context, state) => LecturePlayerScreen(lectureId: state.pathParameters['lectureId']!),
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
    ],
  );
});
