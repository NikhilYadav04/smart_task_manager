import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_task_manager/providers/task_provider.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SummaryCardsShimmer(sw: sw, sh: sh, isTablet: isTablet);
        }

        final stats = provider.stats;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? sw * 0.025 : sw * 0.04,
          ),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Pending',
                  count: stats?.pending ?? 0,
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                  sw: sw,
                  sh: sh,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? sw * 0.015 : sw * 0.03),
              Expanded(
                child: _SummaryCard(
                  title: 'In Progress',
                  count: stats?.inProgress ?? 0,
                  color: Colors.blue,
                  icon: Icons.autorenew,
                  sw: sw,
                  sh: sh,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? sw * 0.015 : sw * 0.03),
              Expanded(
                child: _SummaryCard(
                  title: 'Completed',
                  count: stats?.completed ?? 0,
                  color: Colors.green,
                  icon: Icons.check_circle,
                  sw: sw,
                  sh: sh,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final double sw;
  final double sh;
  final bool isTablet;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.01 : sw * 0.02),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? sw * 0.025 : sw * 0.05,
              ),
            ),
            SizedBox(height: sh * 0.015),

            // Count and title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.035 : sw * 0.065,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCardsShimmer extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const SummaryCardsShimmer({
    super.key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
      ),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < 2 ? (isTablet ? sw * 0.015 : sw * 0.03) : 0,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: isTablet ? sh * 0.15 : sh * 0.14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
