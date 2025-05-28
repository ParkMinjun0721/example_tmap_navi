// dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';
import '../../viewmodels/custom_colors_provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/tab_controller.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/eco_score_chart.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                return _DashboardTab(
                  text: ["Weekly", "Monthly", "Total"][i],
                  isSelected: selectedTab == i,
                  onTap: () => ref.read(selectedTabProvider.notifier).state = i,
                );
              }),
            ),
            const SizedBox(height: 20),

            _SectionCard(
              title: "Eco Score Trend",
              child: EcoScoreChart(dataPoints: dashboardData.ecoScoreTrend),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: "Carbon Reduction",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.eco, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Reduction this week"),
                    ],
                  ),
                  Text(
                    dashboardData.ecoScore,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: "Fuel Efficiency Improvement",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Compared to Average"),
                      Text("28%", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  EcoScoreChart(dataPoints: dashboardData.fuelEfficiencyTrend),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: "My Ranking",
              child: Column(
                children: dashboardData.rankings.map((rank) => _RankingBar(
                  label: rank.label,
                  valueText: rank.valueText,
                  ratio: rank.ratio,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DashboardTab({required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RankingBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double ratio;

  const _RankingBar({required this.label, required this.valueText, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}