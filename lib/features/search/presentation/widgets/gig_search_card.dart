// lib/features/search/presentation/widgets/gig_search_card.dart
import 'package:flutter/material.dart';
import 'package:hustlehub/features/gigs/domain/entities/gig.dart';
import 'package:hustlehub/shared/widgets/gig_card.dart';

class GigSearchCard extends StatelessWidget {
  final Gig gig;
  const GigSearchCard({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    return GigCard(gig: gig);
  }
}
