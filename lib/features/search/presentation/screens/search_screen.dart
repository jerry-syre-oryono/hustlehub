import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  
  String? _selectedCategory;
  double? _maxBudget;
  double? _maxPrice;
  double? _minRating;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Discover', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for jobs or services...',
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Modern Tab Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'Jobs', Icons.work_outline_rounded, Icons.work_rounded),
                  _buildTabItem(1, 'Services', Icons.bolt_outlined, Icons.bolt_rounded),
                ],
              ),
            ),
          ),
          
          // Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SearchFilterBar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) => setState(() => _selectedCategory = category),
              maxBudget: _maxBudget,
              onMaxBudgetChanged: (budget) => setState(() => _maxBudget = budget),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Results
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedTab == 0
                  ? _buildJobResults()
                  : _buildGigResults(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon, IconData activeIcon) {
    final isSelected = _selectedTab == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
        if (jobs.isEmpty) return _buildEmptyState('No jobs found');
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) => JobSearchCard(job: jobs[index])
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .slideY(begin: 0.1),
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
        if (gigs.isEmpty) return _buildEmptyState('No services found');
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: gigs.length,
          itemBuilder: (context, index) => GigSearchCard(gig: gigs[index])
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .slideY(begin: 0.1),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or filters'),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
