import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/features/search/domain/services/search_service.dart';
import 'package:hustlehub/features/search/presentation/screens/search_screen.dart';
import 'package:hustlehub/features/jobs/presentation/controllers/job_controller.dart';
import 'package:hustlehub/features/gigs/presentation/controllers/gig_controller.dart';
import 'package:hustlehub/features/jobs/presentation/screens/post_job_screen.dart';
import 'package:hustlehub/features/gigs/presentation/screens/post_gig_screen.dart';
import 'package:hustlehub/features/profile/presentation/screens/profile_screen.dart';
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
    const PostSelectionScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'HustleHub',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface),
              onPressed: () {},
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentJobsProvider);
          ref.invalidate(trendingGigsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Welcome header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Work Near You',
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Browse the latest jobs and top-rated gigs',
                      style: theme.textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),
            
            // Trending Gigs Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top Services', style: theme.textTheme.titleLarge),
                        TextButton(
                          onPressed: () {},
                          child: Text('View all', style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: trendingGigs.isEmpty
                        ? const Center(child: Text('No services found'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingGigs.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 280,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: GigCard(
                                    gig: trendingGigs[index],
                                    onTap: () {},
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recent Jobs Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Jobs', style: theme.textTheme.titleLarge),
                    TextButton(
                      onPressed: () {},
                      child: Text('Filters', style: TextStyle(color: colorScheme.primary)),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: recentJobs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text('No jobs available')),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return JobCard(
                            job: recentJobs[index],
                            onTap: () {},
                          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
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

// Post Selection Screen
class PostSelectionScreen extends ConsumerWidget {
  const PostSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('What would you like to post?', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                // Post Job Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PostJobScreen()),
                      );
                    },
                    child: Container(
                      height: 380,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.work_rounded, color: Colors.blue, size: 40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Post a Job',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hire freelancers for your project',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureBullet(context, 'Get bids from pros', colorScheme.primary),
                                const SizedBox(height: 8),
                                _buildFeatureBullet(context, 'Secure payments', colorScheme.primary),
                                const SizedBox(height: 8),
                                _buildFeatureBullet(context, 'No upfront cost', colorScheme.primary),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Get Started',
                                style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),
                ),

                const SizedBox(width: 16),

                // Post Gig Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PostGigScreen()),
                      );
                    },
                    child: Container(
                      height: 380,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.bolt_rounded, color: Colors.purple, size: 40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Post a Gig',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Offer your services to the community',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureBullet(context, 'Flexible schedule', Colors.purple),
                                const SizedBox(height: 8),
                                _buildFeatureBullet(context, 'Instant bookings', Colors.purple),
                                const SizedBox(height: 8),
                                _buildFeatureBullet(context, 'Earn instantly', Colors.purple),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Get Started',
                                style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(BuildContext context, String text, Color bulletColor) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            color: bulletColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// Inbox Screen
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Messages', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_outline_rounded,
                size: 48,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your messages will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// Providers  
final recentJobsProvider = Provider((ref) {
  final controller = ref.watch(jobControllerProvider);
  return controller.jobs.take(10).toList();
});

final trendingGigsProvider = Provider((ref) {
  final controller = ref.watch(gigControllerProvider);
  return SearchService.getTrendingGigs(controller.gigs);
});
