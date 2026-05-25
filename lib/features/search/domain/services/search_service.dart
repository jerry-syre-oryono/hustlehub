// lib/features/search/domain/services/search_service.dart
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/core/utils/distance_utils.dart';

class SearchService {
  /// Search jobs by text query
  static List<Job> searchJobs({
    required List<Job> jobs,
    required String query,
    String? category,
    double? maxBudget,
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
  }) {
    var results = jobs.where((job) {
      // Text search
      final matchesQuery = query.isEmpty ||
          job.title.toLowerCase().contains(query.toLowerCase()) ||
          job.description.toLowerCase().contains(query.toLowerCase());
      
      // Category filter
      final matchesCategory = category == null || job.category == category;
      
      // Budget filter
      final matchesBudget = maxBudget == null || job.budget <= maxBudget;
      
      // Distance filter
      bool matchesDistance = true;
      if (userLat != null && userLng != null && job.latitude != null && job.longitude != null && maxDistanceKm != null) {
        final distance = DistanceUtils.calculateDistance(
          userLat, userLng,
          job.latitude!, job.longitude!,
        );
        matchesDistance = distance <= maxDistanceKm;
      }
      
      return matchesQuery && matchesCategory && matchesBudget && matchesDistance;
    }).toList();
    
    // Sort by relevance (priority: urgent > nearby > newest)
    results.sort((a, b) {
      // Urgent jobs first
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      
      // Then by distance (if location available)
      if (userLat != null && userLng != null) {
        final distA = a.latitude != null && a.longitude != null
            ? DistanceUtils.calculateDistance(userLat, userLng, a.latitude!, a.longitude!)
            : double.infinity;
        final distB = b.latitude != null && b.longitude != null
            ? DistanceUtils.calculateDistance(userLat, userLng, b.latitude!, b.longitude!)
            : double.infinity;
        return distA.compareTo(distB);
      }
      
      // Finally by creation date
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return results;
  }
  
  /// Search gigs by text query
  static List<Gig> searchGigs({
    required List<Gig> gigs,
    required String query,
    String? category,
    double? maxPrice,
    double? minRating,
  }) {
    var results = gigs.where((gig) {
      // Text search
      final matchesQuery = query.isEmpty ||
          gig.title.toLowerCase().contains(query.toLowerCase()) ||
          gig.description.toLowerCase().contains(query.toLowerCase());
      
      // Category filter
      final matchesCategory = category == null || gig.category == category;
      
      // Price filter
      final matchesPrice = maxPrice == null || gig.price <= maxPrice;
      
      // Rating filter
      final matchesRating = minRating == null || gig.rating >= minRating;
      
      return matchesQuery && matchesCategory && matchesPrice && matchesRating;
    }).toList();
    
    // Sort by rating (highest first)
    results.sort((a, b) => b.rating.compareTo(a.rating));
    
    return results;
  }
  
  /// Get trending gigs (based on sales and rating)
  static List<Gig> getTrendingGigs(List<Gig> gigs, {int limit = 10}) {
    final trending = List<Gig>.from(gigs);
    trending.sort((a, b) {
      // Score = totalSales * 0.7 + rating * 0.3
      final scoreA = (a.totalSales * 0.7) + (a.rating * 0.3);
      final scoreB = (b.totalSales * 0.7) + (b.rating * 0.3);
      return scoreB.compareTo(scoreA);
    });
    return trending.take(limit).toList();
  }
  
  /// Get trending jobs (based on applications count)
  static List<Job> getTrendingJobs(List<Job> jobs, {int limit = 10}) {
    final trending = List<Job>.from(jobs);
    trending.sort((a, b) => b.applicationsCount.compareTo(a.applicationsCount));
    return trending.take(limit).toList();
  }
}
