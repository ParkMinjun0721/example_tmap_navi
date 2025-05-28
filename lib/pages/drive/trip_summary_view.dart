import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/app_routes.dart';
import '../../theme/theme.dart'; // CustomColors 경로에 맞게 수정
import '../../views/main/main_view.dart';

class TripSummary {
  final String? startName;
  final String? destinationName;
  final double totalDistanceKm;
  final Duration drivingTime;
  final int ecoScore;
  final int pointsEarned;
  final double averageSpeed;
  final int rapidAccelCount;
  final int rapidBrakeCount;

  TripSummary({
    this.startName,
    this.destinationName,
    required this.totalDistanceKm,
    required this.drivingTime,
    required this.ecoScore,
    required this.pointsEarned,
    required this.averageSpeed,
    required this.rapidAccelCount,
    required this.rapidBrakeCount,
  });
}

class TripSummaryView extends StatelessWidget {
  const TripSummaryView({Key? key, required this.summary}) : super(key: key);

  final TripSummary summary;

  String get timeString =>
      "${summary.drivingTime.inMinutes}:${(summary.drivingTime.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<CustomColors>()!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.main); // '/' 경로로 이동
          },
        ),
        title: const Text("Trip Summary"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const Text("🎉", style: TextStyle(fontSize: 40)),
                const SizedBox(height: 4),
                Text(
                  "You've reached your destination!",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: customColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _locationCard(theme, customColors),
            const SizedBox(height: 24),
            _summaryCards(context, customColors),
            const SizedBox(height: 24),
            _tripStatistics(theme, customColors),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(ThemeData theme, CustomColors customColors) {
    final hasStart = summary.startName != null && summary.startName!.isNotEmpty;
    final hasDest  = summary.destinationName != null && summary.destinationName!.isNotEmpty;

    // 둘 다 없으면 아예 출력 안 함
    if (!hasStart && !hasDest) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColors.primary10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _locationRow(Icons.my_location, "Starting Point", summary.startName!, customColors),
          const SizedBox(height: 12),
          _locationRow(Icons.flag, "Destination", summary.destinationName!, customColors),
        ],
      ),
    );
  }

  Widget _summaryCards(BuildContext context, CustomColors customColors) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _infoCard(context, customColors, icon: Icons.map, label: "Total Distance", value: "${summary.totalDistanceKm.toStringAsFixed(1)} km"),
        _infoCard(context, customColors, icon: Icons.timer, label: "Driving Time", value: timeString),
        _infoCard(context, customColors, icon: Icons.eco, label: "Eco Score", value: "${summary.ecoScore} pts"),
        _infoCard(
          context,
          customColors,
          icon: Icons.star,
          label: "Points Earned",
          value: "+${summary.pointsEarned} P",
          valueStyle: theme.textTheme.titleLarge?.copyWith(
            color: customColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _tripStatistics(ThemeData theme, CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Statistics",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: customColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: customColors.neutral80!),
          ),
          child: Column(
            children: [
              _statRow("Average Speed", "${summary.averageSpeed.toStringAsFixed(0)} km/h"),
              _divider(),
              _statRow("Rapid Acceleration", "${summary.rapidAccelCount} times"),
              _divider(),
              _statRow("Rapid Deceleration", "${summary.rapidBrakeCount} times"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _locationRow(IconData icon, String label, String name, CustomColors customColors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: customColors.primary60),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
      BuildContext context,
      CustomColors customColors, {
        required IconData icon,
        required String label,
        required String value,
        TextStyle? valueStyle,
      }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: customColors.neutral80!),
        ),
        child: Column(
          children: [
            Icon(icon, color: customColors.primary60, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: valueStyle ?? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text(key)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Divider _divider() => const Divider(height: 1, thickness: 1);
}
