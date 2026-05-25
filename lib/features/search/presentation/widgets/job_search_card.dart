// lib/features/search/presentation/widgets/job_search_card.dart
import 'package:flutter/material.dart';
import 'package:hustlehub/features/jobs/domain/entities/job.dart';
import 'package:hustlehub/shared/widgets/job_card.dart';

class JobSearchCard extends StatelessWidget {
  final Job job;
  const JobSearchCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return JobCard(job: job);
  }
}
