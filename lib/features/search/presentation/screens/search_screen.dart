// lib/features/search/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/search/presentation/widgets/search_filter_bar.dart';
import 'package:hustlehub/features/search/presentation/widgets/job_search_card.dart';
import 'package:hustlehub/features/search/presentation/widgets/gig_search_card.dart';
import 'package:hustlehub/features/search/domain/services/search_service.dart';
import 'package:hustlehub/features/jobs/presentation/controllers/job_controller.dart';
import 'package:hustlehub/features/gigs/presentation/controllers/gig_controller.dart';

// Search Providers
final searchJobsProvider = FutureProvider.family<List<Job>, SearchParams>((ref, params) async {
  final jobs = ref.watch(jobControllerProvider).jobs;
  return SearchService.searchJobs(
    jobs: jobs,
    query: params.query,
    category: params.category,
    maxBudget: params.maxBudget,
  );
});

final searchGigsProvider = FutureProvider.family<List<Gig>, SearchParams>((ref, params) async {
  final gigs = ref.watch(gigControllerProvider).gigs;
  return SearchService.searchGigs(
    gigs: gigs,
    query: params.query,
    category: params.category,
    maxPrice: params.maxPrice,
    minRating: params.minRating,
  );
});

class SearchParams {
  final String query;
  final String? category;
  final double? maxBudget;
  final double? maxPrice;
  final double? minRating;

  SearchParams({
    this.query = '',
    this.category,
    this.maxBudget,
    this.maxPrice,
    this.minRating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category &&
          maxBudget == other.maxBudget &&
          maxPrice == other.maxPrice &&
          minRating == other.minRating;

  @override
  int get hashCode =>
      query.hashCode ^
      category.hashCode ^
      maxBudget.hashCode ^
      maxPrice.hashCode ^
      minRating.hashCode;
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Jobs, 1 = Gigs
  
  // Filters
  String? _selectedCategory;
  double? _maxBudget;
  double? _maxPrice;
  double? _minRating;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs or services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab selector
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Jobs')),
                ButtonSegment(value: 1, label: Text('Gigs/Services')),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _selectedTab = selection.first;
                });
              },
            ),
          ),
          
          // Filter bar
          SearchFilterBar(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            maxBudget: _maxBudget,
            onMaxBudgetChanged: (budget) {
              setState(() {
                _maxBudget = budget;
              });
            },
          ),
          
          const Divider(),
          
          // Results
          Expanded(
            child: _selectedTab == 0
                ? _buildJobResults()
                : _buildGigResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobResults() {
    final params = SearchParams(
      query: _searchQuery,
      category: _selectedCategory,
      maxBudget: _maxBudget,
    );
    
    final jobsAsync = ref.watch(searchJobsProvider(params));
    
    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No jobs found', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Try adjusting your search or filters'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobSearchCard(job: job);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildGigResults() {
    final params = SearchParams(
      query: _searchQuery,
      category: _selectedCategory,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
    
    final gigsAsync = ref.watch(searchGigsProvider(params));
    
    return gigsAsync.when(
      data: (gigs) {
        if (gigs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No services found', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Try adjusting your search or filters'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: gigs.length,
          itemBuilder: (context, index) {
            final gig = gigs[index];
            return GigSearchCard(gig: gig);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
