// lib/features/jobs/presentation/screens/post_job_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hustlehub/core/utils/image_picker_utils.dart';
import 'package:hustlehub/core/utils/image_utils.dart';
import 'package:hustlehub/features/jobs/presentation/controllers/job_controller.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Cleaning';
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isUploading = false;
  
  final List<String> _categories = [
    'Cleaning', 'Delivery', 'Tutoring', 'Handyman', 
    'Gardening', 'Photography', 'Writing', 'Design',
    'Programming', 'Moving', 'Event Planning', 'Other'
  ];
  
  Future<void> _pickImages() async {
    final images = await ImagePickerUtils.pickImages(maxCount: 3 - _selectedImages.length);
    setState(() {
      _selectedImages.addAll(images);
    });
  }
  
  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _isUploading = true;
    });
    
    try {
      // Prepare images for upload (compress)
      final List<String> compressedPaths = [];
      for (final image in _selectedImages) {
        final compressed = await ImageUtils.compressImage(
          image.path,
          quality: 80,
          maxSizeMB: 2,
        );
        compressedPaths.add(compressed);
      }
      
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      
      final result = await ref.read(jobControllerProvider.notifier).createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        budget: double.parse(_budgetController.text),
        locationText: _locationController.text,
        images: compressedPaths,
      );
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        (job) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitJob,
            child: _isSubmitting
                ? (_isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Posting...'))
                : const Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title *',
                  hintText: 'e.g., Need house cleaning',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title required';
                  if (value.length < 5) return 'Title too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                validator: (value) => value == null ? 'Select category' : null,
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the job in detail...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Description required';
                  if (value.length < 20) return 'Please provide more details';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Budget
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (KES) *',
                  prefixText: 'KES ',
                  hintText: 'e.g., 5000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Budget required';
                  final budget = double.tryParse(value);
                  if (budget == null) return 'Invalid amount';
                  if (budget <= 0) return 'Budget must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g., Nairobi CBD',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Location required';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Images
              const Text(
                'Images (max 3, 2MB each) *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
      