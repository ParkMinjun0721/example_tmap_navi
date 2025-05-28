// mypage_view.dart (세련되고 푸른색 계열 디자인 적용)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/custom_colors_provider.dart';
import '../../viewmodels/point_provider.dart';
import '../../models/purchased_product.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPageView extends ConsumerStatefulWidget {
  const MyPageView({super.key});

  @override
  ConsumerState<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends ConsumerState<MyPageView> {
  String nickname = 'Loading...';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      nickname = user.displayName!;
    } else {
      nickname = 'Anonymous';
    }
  }

  void _changeNickname(BuildContext context) async {
    final controller = TextEditingController(text: nickname);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Nickname'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() => nickname = newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final point = ref.watch(pointProvider);

    return Scaffold(
      // appBar: CustomAppBar_Main(backgroundColor: customColors.white),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileSection(nickname: nickname, onEdit: () => _changeNickname(context)),
              const SizedBox(height: 24),
              _EcoDrivingScore(score: 92),
              const SizedBox(height: 24),
              Text("Current Points: $point P", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const _PurchasedItemsSection(),
              const _BadgeSection(),
              const SizedBox(height: 24),
              const _BottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
}



class _PurchasedItemsSection extends ConsumerStatefulWidget {
  const _PurchasedItemsSection();

  @override
  ConsumerState<_PurchasedItemsSection> createState() => _PurchasedItemsSectionState();
}

class _PurchasedItemsSectionState extends ConsumerState<_PurchasedItemsSection> with TickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final purchases = ref.watch(purchaseHistoryProvider);
    final itemsToShow = isExpanded ? purchases : purchases.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Purchased Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (purchases.isEmpty)
          const Text("No purchases yet.", style: TextStyle(color: Colors.grey)),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: itemsToShow.map((item) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, color: Color(0xFF2196F3)),
                title: Text(item.name),
                trailing: Text('${item.point} P', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
        ),
        if (purchases.length > 4)
          TextButton(
            onPressed: () => setState(() => isExpanded = !isExpanded),
            child: Text(isExpanded ? "Show Less" : "Show More"),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String nickname;
  final VoidCallback onEdit;

  const _ProfileSection({required this.nickname, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFF90CAF9),
          child: Text('Image', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Safe Driving Master', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Color(0xFF2196F3))),
      ],
    );
  }
}


class _EcoDrivingScore extends StatelessWidget {
  final int score;
  const _EcoDrivingScore({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accumulated Eco-Driving Score:'),
              Text('$score', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF2196F3),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection();

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': Icons.eco, 'label': 'Eco Driver'},
      {'icon': Icons.shield, 'label': 'Safety Master'},
      {'icon': Icons.emoji_events, 'label': 'Top Driver'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Earned Badges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: badges.map((badge) {
            return Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: Icon(badge['icon'] as IconData, color: const Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 8),
                  Text(badge['label'] as String, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons();

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      // 로그인 페이지로 이동 (기존 stack 제거)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: const Text('View Driving History'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3),
              side: const BorderSide(color: Color(0xFF2196F3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _logout(context),
            child: const Text('Logout'),
          ),
        )
      ],
    );
  }
}