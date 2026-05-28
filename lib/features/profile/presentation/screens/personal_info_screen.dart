import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustlehub/features/auth/presentation/controllers/auth_controller.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _showPasswordForm = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _savePersonalInfo() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Name cannot be empty');
      return;
    }
    
    // TODO: Implement actual save functionality via repository
    _showSuccessSnackBar('Personal information updated successfully');
  }

  void _changePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('All fields are required');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('New passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showErrorSnackBar('Password must be at least 8 characters');
      return;
    }

    // TODO: Implement actual password change via repository
    _showSuccessSnackBar('Password changed successfully');
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    setState(() => _showPasswordForm = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Personal Information', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            Text(
              'Profile Details',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Name Field
            _buildTextInputField(
              context,
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Email Field
            _buildTextInputField(
              context,
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Phone Field
            _buildTextInputField(
              context,
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Location Field
            _buildTextInputField(
              context,
              label: 'Location',
              controller: _locationController,
              icon: Icons.location_on_outlined,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            // Bio Field
            _buildTextAreaField(
              context,
              label: 'Bio',
              controller: _bioController,
              icon: Icons.description_outlined,
              maxLines: 4,
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePersonalInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 40),

            // Password Change Section
            Text(
              'Security',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(),

            const SizedBox(height: 12),

            // Change Password Button
            GestureDetector(
              onTap: () => setState(() => _showPasswordForm = !_showPasswordForm),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Change Password', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                          Text('Update your password regularly for security', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(
                      _showPasswordForm ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            if (_showPasswordForm) ...[
              const SizedBox(height: 16),
              // Password Form
              _buildPasswordField(
                context,
                label: 'Current Password',
                controller: _oldPasswordController,
                obscureText: !_showCurrentPassword,
                onToggleVisibility: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
              ).animate().fadeIn(),

              const SizedBox(height: 16),

              _buildPasswordField(
                context,
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                onToggleVisibility: () => setState(() => _showNewPassword = !_showNewPassword),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              _buildPasswordField(
                context,
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                onToggleVisibility: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showPasswordForm = false),
                      icon: const Icon(Icons.close),
                      label: Text('Cancel', style: theme.textTheme.labelLarge),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.check),
                      label: Text('Update Password', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
            hintText: 'Enter $label',
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 3,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            hintText: 'Enter $label',
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.primary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            hintText: 'Enter $label',
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
