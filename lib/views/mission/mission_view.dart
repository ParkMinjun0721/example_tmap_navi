// mission_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/eco_mission_provider.dart';
import '../../viewmodels/point_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';

class MissionView extends ConsumerWidget {
  const MissionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final selectedTab = ref.watch(missionTabProvider);
    final missions = ref.watch(filteredMissionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flag, color: Colors.blue),
            SizedBox(width: 8),
            Text("Missions", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final label = ['Daily', 'Weekly', 'Event'][index];
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () => ref.read(missionTabProvider.notifier).state = index,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Mission List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: missions.length,
              itemBuilder: (context, index) {
                final mission = missions[index];
                final progressPercent = mission.current / mission.goal;
                final isCompleted = progressPercent >= 1.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Points
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mission.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('+${mission.point}P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Description
                      Text(mission.description, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),

                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${mission.currentLabel} / ${mission.goalLabel}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          if (isCompleted)
                            Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text("Completed", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(ecoMissionProvider.notifier).toggleMission(mission.id);
                            if (!mission.isAccepted && isCompleted) {
                              ref.read(pointProvider.notifier).earn(mission.point);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: mission.isAccepted ? Colors.red : Colors.white,
                            backgroundColor: mission.isAccepted ? Colors.white : Colors.blue,
                            side: mission.isAccepted ? const BorderSide(color: Colors.red) : BorderSide.none,
                          ),
                          child: Text(mission.isAccepted ? 'Cancel' : 'Accept'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
