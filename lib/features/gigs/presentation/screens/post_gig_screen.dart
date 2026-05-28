import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hustlehub/features/gigs/presentation/controllers/gig_controller.dart';
import 'package:hustlehub/features/auth/presentation/widgets/auth_button.dart';

class PostGigScreen extends ConsumerStatefulWidget {
  const PostGigScreen({super.key});

  @override
  ConsumerState<PostGigScreen> createState() => _PostGigScreenState();
}

class _PostGigScreenState extends ConsumerState<PostGigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  String _selectedCategory = 'Design';

  final List<String> _categories = [
    'Design', 'Development', 'Writing', 'Marketing', 'Repairs', 'Events', 'Other'
  ];

  Future<void> _handlePost() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref.read(gigControllerProvider.notifier).createGig(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      price: double.parse(_priceController.text),
      deliveryTime: _deliveryTimeController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Theme.of(context).colorScheme.error),
        );
      },
      (gig) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service posted successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offer a Service'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Showcase your skills and start earning.', style: theme.textTheme.bodyMedium),
              
              const SizedBox(height: 32),
              
              _buildFieldLabel('Service Title'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Professional Logo Design'),
                validator: (value) => value == null || value.isEmpty ? 'Title required' : null,
              ),
              
              const SizedBox(height: 24),
              
              _buildFieldLabel('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              
              const SizedBox(height: 24),
              
              _buildFieldLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'What exactly do you offer?'),
                validator: (value) => value == null || value.isEmpty ? 'Description required' : null,
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Price (KES)'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0.00'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Delivery Time'),
                        TextFormField(
                          controller: _deliveryTimeController,
                          decoration: const InputDecoration(hintText: 'e.g. 2 days'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              AuthButton(
                text: 'Publish Service',
                onPressed: _handlePost,
                isLoading: ref.watch(gigControllerProvider).isLoading,
              ).animate().fadeIn(delay: 400.ms).scale(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
