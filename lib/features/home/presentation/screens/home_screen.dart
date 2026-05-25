// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/search/domain/services/search_service.dart';
import 'package:hustlehub/features/search/presentation/screens/search_screen.dart';
import 'package:hustlehub/features/jobs/presentation/controllers/job_controller.dart';
import 'package:hustlehub/features/gigs/presentation/controllers/gig_controller.dart';
import 'package:hustlehub/shared/widgets/job_card.dart';
import 'package:hustlehub/shared/widgets/gig_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const FeedScreen(),
    const SearchScreen(),
    const Scaffold(body: Center(child: Text('Post'))),
    const Scaffold(body: Center(child: Text('Inbox'))),
    const Scaffold(body: Center(child: Text('Profile'))),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentJobs = ref.watch(recentJobsProvider);
    final trendingGigs = ref.watch(trendingGigsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('HustleHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentJobsProvider);
          ref.invalidate(trendingGigsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Welcome header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Work Near You',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse jobs and gigs in your area',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            
            // Trending Gigs Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Trending Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: trendingGigs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text('No gigs available')),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GigCard(
                            gig: trendingGigs[index],
                            onTap: () {
                              // Navigate to gig details
                            },
                          );
                        },
                        childCount: trendingGigs.length > 3 ? 3 : trendingGigs.length,
                      ),
                    ),
            ),
            
            // Recent Jobs Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: recentJobs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text('No jobs available')),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return JobCard(
                            job: recentJobs[index],
                            onTap: () {
                              // Navigate to job details
                            },
                          );
                        },
                        childCount: recentJobs.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Providers
final recentJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobControllerProvider).jobs;
  // For recent jobs, we just take the first 10
  return jobs.take(10).toList();
});

final trendingGigsProvider = Provider<List<Gig>>((ref) {
  final gigs = ref.watch(gigControllerProvider).gigs;
  return SearchService.getTrendingGigs(gigs);
});
