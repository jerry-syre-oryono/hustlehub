// lib/app/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:hustlehub/features/auth/presentation/screens/splash_screen.dart';
import 'package:hustlehub/features/auth/presentation/screens/login_screen.dart';
import 'package:hustlehub/features/auth/presentation/screens/register_screen.dart';
import 'package:hustlehub/features/home/presentation/screens/home_screen.dart';
import 'package:hustlehub/features/jobs/presentation/screens/post_job_screen.dart';
import 'package:hustlehub/features/gigs/presentation/screens/post_gig_screen.dart';
import 'package:hustlehub/features/profile/presentation/screens/profile_screen.dart';
import 'package:hustlehub/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/jobs/post',
        name: 'postJob',
        builder: (context, state) => const PostJobScreen(),
      ),
      GoRoute(
        path: '/gigs/post',
        name: 'postGig',
        builder: (context, state) => const PostGigScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
