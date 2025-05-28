// main_view.dart (Modified to replace 'Start Driving' with buttons on tap and increased button size)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/tmap_sdk_initializer.dart';
import '../../theme/box_shadow_styles.dart';
import '../../theme/theme.dart';
import '../../viewmodels/custom_colors_provider.dart';
import '../../viewmodels/point_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

final scoreProvider = StateProvider<int>((ref) => 85);
final showDriveOptionsProvider = StateProvider<bool>((ref) => false);

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final score = ref.watch(scoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: customColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: const [
            Icon(Icons.directions_car, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Cash Driving",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DrivingStartSection(customColors: customColors),
                const SizedBox(height: 20),
                _EcoScoreSection(score: score, customColors: customColors),
                const SizedBox(height: 16),
                _PointSection(customColors: customColors),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _DrivingStartSection extends ConsumerWidget {
  final CustomColors customColors;
  const _DrivingStartSection({required this.customColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSdkInitialized = ref.watch(tmapSdkInitializedProvider);
    final showOptions = ref.watch(showDriveOptionsProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenHeight * 0.33,
      height: screenHeight * 0.33,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: showOptions
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(showDriveOptionsProvider.notifier).state = false;
                  context.go('/root/location/start');
                },
                child: const Text('Choose destination'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(showDriveOptionsProvider.notifier).state = false;
                  context.go('/safedriving');
                },
                child: const Text('안전 운전'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
          ],
        )
            : GestureDetector(
          onTap: () async {
            if (!isSdkInitialized) {
              await _initializeTmapSdk(ref, context);
            } else {
              ref.read(showDriveOptionsProvider.notifier).state = true;
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.drive_eta, size: 48, color: Colors.white),
              SizedBox(height: 12),
              Text(
                "Start Driving",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeTmapSdk(WidgetRef ref, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Initializing Tmap SDK..."),
        duration: Duration(seconds: 2),
      ),
    );
    await TmapSdkInitializer.initializeTmapSdk(context, ref);
  }
}

class _EcoScoreSection extends StatelessWidget {
  final int score;
  final CustomColors customColors;

  const _EcoScoreSection({required this.score, required this.customColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: customColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BoxShadowStyles.shadow1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Eco-Driving Score"),
              Text("$score pts", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: customColors.neutral80,
              color: Colors.blue,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointSection extends ConsumerWidget {
  final CustomColors customColors;

  const _PointSection({required this.customColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final point = ref.watch(pointProvider);

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: customColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BoxShadowStyles.shadow1(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Current Points"),
          Row(
            children: [
              const Icon(Icons.attach_money_rounded, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "$point",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
