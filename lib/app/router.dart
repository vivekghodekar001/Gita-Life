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
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/pending_screen.dart';
import '../screens/auth/suspended_screen.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/gita/gita_chapter_list_screen.dart';
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
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_lectures_screen.dart';
import '../screens/admin/manage_audio_screen.dart';
import '../screens/admin/manage_students_screen.dart';
import '../screens/admin/send_notification_screen.dart';
import '../screens/admin/manage_attendance_screen.dart';
import '../screens/admin/manage_assignments_screen.dart';
import '../screens/preaching/preaching_screen.dart';
import '../screens/admin/assign_counselor_screen.dart';
import '../screens/assignments/assignments_screen.dart';

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

/// Smooth fade transition page for all routes
Page<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
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
            // Route admin directly to admin panel, others to home
            if (profile.role == 'admin') return '/admin';
            return '/home';
          }
          
          // RoleGuard logic: Prevent non-admins from accessing /admin routes
          if (state.matchedLocation.startsWith('/admin') && profile.role != 'admin') {
            return '/home';
          }
          // Guard: /preaching is only for counselors and admins
          if (state.matchedLocation == '/preaching' &&
              profile.role != 'counselor' &&
              profile.role != 'admin') {
            return '/home';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', pageBuilder: (context, state) => _fadePage(state, const SplashScreen())),
      GoRoute(path: '/onboarding', pageBuilder: (context, state) => _fadePage(state, const OnboardingScreen())),

      // Auth routes
      GoRoute(path: '/login', pageBuilder: (context, state) => _fadePage(state, const LoginScreen())),
      GoRoute(path: '/register', pageBuilder: (context, state) => _fadePage(state, const RegisterScreen())),
      GoRoute(path: '/forgot-password', pageBuilder: (context, state) => _fadePage(state, const ForgotPasswordScreen())),
      GoRoute(path: '/pending', pageBuilder: (context, state) => _fadePage(state, const PendingScreen())),
      GoRoute(path: '/suspended', pageBuilder: (context, state) => _fadePage(state, const SuspendedScreen())),

      // Home
      GoRoute(path: '/home', pageBuilder: (context, state) => _fadePage(state, const DashboardScreen())),

      // Gita routes
      GoRoute(path: '/gita', pageBuilder: (context, state) => _fadePage(state, const GitaChapterListScreen())),
      GoRoute(
        path: '/gita/chapter/:chapterId',
        pageBuilder: (context, state) => _fadePage(state, VerseListScreen(chapterId: state.pathParameters['chapterId']!)),
      ),
      GoRoute(
        path: '/gita/chapter/:chapterId/verse/:verseId',
        pageBuilder: (context, state) => _fadePage(state, VerseDetailScreen(
          chapterId: state.pathParameters['chapterId']!,
          verseId: state.pathParameters['verseId']!,
        )),
      ),
      GoRoute(path: '/gita/search', pageBuilder: (context, state) => _fadePage(state, const GitaSearchScreen())),
      GoRoute(path: '/gita/bookmarks', pageBuilder: (context, state) => _fadePage(state, const BookmarksScreen())),

      // Japa routes
      GoRoute(path: '/japa', pageBuilder: (context, state) => _fadePage(state, const JapaCounterScreen())),
      GoRoute(path: '/japa/history', pageBuilder: (context, state) => _fadePage(state, const JapaHistoryScreen())),

      // Audio routes
      GoRoute(path: '/audio', pageBuilder: (context, state) => _fadePage(state, const AudioLibraryScreen())),
      GoRoute(
        path: '/audio/player/:trackId',
        pageBuilder: (context, state) => _fadePage(state, AudioPlayerScreen(trackId: state.pathParameters['trackId']!)),
      ),
      GoRoute(path: '/audio/downloads', pageBuilder: (context, state) => _fadePage(state, const DownloadsScreen())),

      // Lecture routes
      GoRoute(path: '/lectures', pageBuilder: (context, state) => _fadePage(state, const LectureListScreen())),
      GoRoute(
        path: '/lectures/player/:lectureId',
        pageBuilder: (context, state) => _fadePage(state, LecturePlayerScreen(
          lectureId: state.pathParameters['lectureId']!,
          lecture: state.extra as LectureModel?,
        )),
      ),

      // Profile routes
      GoRoute(path: '/profile', pageBuilder: (context, state) => _fadePage(state, const ProfileScreen())),
      GoRoute(path: '/settings', pageBuilder: (context, state) => _fadePage(state, const SettingsScreen())),

      // Preaching route (counselor & admin only — guarded in redirect)
      GoRoute(path: '/preaching', pageBuilder: (context, state) => _fadePage(state, const PreachingScreen())),

      // Admin routes
      GoRoute(path: '/admin', pageBuilder: (context, state) => _fadePage(state, const AdminDashboardScreen())),
      GoRoute(path: '/admin/lectures', pageBuilder: (context, state) => _fadePage(state, const ManageLecturesScreen())),
      GoRoute(path: '/admin/audio', pageBuilder: (context, state) => _fadePage(state, const ManageAudioScreen())),
      GoRoute(path: '/admin/students', pageBuilder: (context, state) => _fadePage(state, const ManageStudentsScreen())),
      GoRoute(path: '/admin/notifications', pageBuilder: (context, state) => _fadePage(state, const SendNotificationScreen())),
      GoRoute(path: '/admin/attendance', pageBuilder: (context, state) => _fadePage(state, const ManageAttendanceScreen())),
      GoRoute(path: '/admin/assignments', pageBuilder: (context, state) => _fadePage(state, const ManageAssignmentsScreen())),
      GoRoute(path: '/admin/counselors', pageBuilder: (context, state) => _fadePage(state, const AssignCounselorScreen())),

      // Assignments (student)
      GoRoute(path: '/assignments', pageBuilder: (context, state) => _fadePage(state, const AssignmentsScreen())),
    ],
  );
});
