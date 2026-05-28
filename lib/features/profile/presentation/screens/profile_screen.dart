import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustlehub/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hustlehub/features/profile/presentation/screens/personal_info_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Profile', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ],
            ).animate().fadeIn().scale(),

            const SizedBox(height: 16),
            
            Text(
              user.name,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            
            Text(
              user.email,
              style: theme.textTheme.bodyMedium,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatItem(context, 'Rating', user.rating.toStringAsFixed(1), Icons.star_rounded, Colors.amber),
                  _buildStatItem(context, 'Jobs', user.totalJobs.toString(), Icons.work_rounded, Colors.blue),
                  _buildStatItem(context, 'Gigs', user.totalGigs.toString(), Icons.bolt_rounded, Colors.purple),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Menu Sections
            _buildMenuSection(context, 'Account Settings', [
              _buildMenuItem(
                context,
                'Personal Information',
                Icons.person_outline_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                  );
                },
              ),
              _buildMenuItem(context, 'Payment Methods', Icons.payment_rounded),
              _buildMenuItem(context, 'Security', Icons.shield_outlined),
            ]),

            _buildMenuSection(context, 'Notifications', [
              _buildMenuItem(context, 'Push Notifications', Icons.notifications_none_rounded, isSwitch: true),
              _buildMenuItem(context, 'Email Notifications', Icons.email_outlined, isSwitch: true),
            ]),

            _buildMenuSection(context, 'Support', [
              _buildMenuItem(context, 'Help Center', Icons.help_outline_rounded),
              _buildMenuItem(context, 'Contact Us', Icons.support_agent_rounded),
              _buildMenuItem(context, 'Privacy Policy', Icons.privacy_tip_outlined),
            ]),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authState.isLoading ? null : () => _handleLogout(context, ref),
                  icon: authState.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.error),
                          ),
                        )
                      : const Icon(Icons.logout_rounded),
                  label: Text(
                    authState.isLoading ? 'Logging out...' : 'Logout',
                    style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error.withOpacity(0.1),
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authControllerProvider.notifier).logout();
    
    if (context.mounted) {
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${failure.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        (_) {
          // Navigate to login screen after successful logout
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        },
      );
    }
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {bool isSwitch = false, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      trailing: isSwitch 
        ? Switch.adaptive(value: true, onChanged: (v) {}, activeColor: theme.colorScheme.primary)
        : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      onTap: onTap ?? () {},
    );
  }
}
