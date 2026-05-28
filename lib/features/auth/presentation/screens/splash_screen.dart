import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hustlehub/features/auth/presentation/controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    // Wait for the auth state to be checked
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    
    // Navigate based on authentication state
    if (authState.isAuthenticated && authState.user != null) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withOpacity(0.08),
                ),
              ).animate().fadeIn(duration: 1000.ms),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.06),
                ),
              ).animate().fadeIn(duration: 1200.ms),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      )
                      .shimmer(duration: 2000.ms, delay: 600.ms),

                  const SizedBox(height: 40),

                  // App name with animation
                  Column(
                    children: [
                      Text(
                        'HustleHub',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          fontSize: 42,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find Work, Offer Services',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0.0,
                        delay: 400.ms,
                        duration: 600.ms,
                      ),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),

            // Decorative elements
            Positioned(
              top: size.height * 0.2,
              left: 20,
              child: Container(
                width: 8,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms)
                  .scaleY(begin: 0.0, end: 1.0, delay: 1000.ms),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: 20,
              child: Container(
                width: 8,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1100.ms)
                  .scaleY(begin: 0.0, end: 1.0, delay: 1100.ms),
            ),
          ],
        ),
      ),
    );
  }
}
