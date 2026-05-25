// lib/features/gigs/presentation/screens/post_gig_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hustlehub/core/utils/image_picker_utils.dart';
import 'package:hustlehub/core/utils/image_utils.dart';
import 'package:hustlehub/features/gigs/presentation/controllers/gig_controller.dart';

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
  String _selectedCategory = 'Cleaning';
  final List<XFile> _portfolioImages = [];
  bool _isSubmitting = false;
  
  final List<String> _categories = [
    'Cleaning', 'Delivery', 'Tutoring', 'Handyman', 
    'Gardening', 'Photography', 'Writing', 'Design',
    'Programming', 'Moving', 'Event Planning', 'Other'
  ];
  
  final List<String> _deliveryOptions = [
    '24 hours', '2-3 days', '5-7 days', '1-2 weeks', 'Custom'
  ];
  
  Future<void> _pickImages() async {
    final images = await ImagePickerUtils.pickImages(maxCount: 5 - _portfolioImages.length);
    setState(() {
      _portfolioImages.addAll(images);
    });
  }
  
  Future<void> _submitGig() async {
    if (!_formKey.currentState!.validate()) return;
    if (_portfolioImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one portfolio image')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // Compress images
      final List<String> compressedPaths = [];
      for (final image in _portfolioImages) {
        final compressed = await ImageUtils.compressImage(
          image.path,
          quality: 85,
          maxSizeMB: 2,
        );
        compressedPaths.add(compressed);
      }
      
      final result = await ref.read(gigControllerProvider.notifier).createGig(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        deliveryTime: _deliveryTimeController.text,
        portfolioImages: compressedPaths,
      );
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
          );
        },
        (gig) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gig posted successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Gig'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitGig,
            child: Text(_isSubmitting ? 'Creating...' : 'Publish'),
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
                  labelText: 'Gig Title *',
                  hintText: 'e.g., Professional House Cleaning',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title required';
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
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe your service in detail...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Description required';
                  if (value.length < 20) return 'Please provide more details';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (KES) *',
                  prefixText: 'KES ',
                  hintText: 'e.g., 5000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Price required';
                  if (double.tryParse(value) == null) return 'Invalid price';
                  if (double.parse(value) <= 0) return 'Price must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Delivery Time
              DropdownButtonFormField<String>(
                value: _deliveryTimeController.text.isEmpty ? null : _deliveryTimeController.text,
                decoration: const InputDecoration(
                  labelText: 'Delivery Time *',
                  border: OutlineInputBorder(),
                ),
                items: _deliveryOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _deliveryTimeController.text = value!;
                  });
                },
                validator: (value) => value == null ? 'Select delivery time' : null,
              ),
              const SizedBox(height: 16),
              
              // Portfolio Images
              const Text(
                'Portfolio Images (max 5, 2MB each) *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._portfolioImages.asMap().entries.map((entry) {
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
                            onTap: () {
                              setState(() {
                                _portfolioImages.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_portfolioImages.length < 5)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 40),
                            SizedBox(height: 4),
                            const Text('Add Image'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
}
