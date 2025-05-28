/// File: custom_app_bar.dart
/// Purpose: 앱에서 커스터마이즈된 AppBar 위젯을 제공하여 타이틀, 검색 버튼 등을 설정 가능하게 함
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2024-12-30 by 박민준

/*
    사용 방법
    Scaffold 에서 아래와 같이 사용

    appBar: CustomAppBar(
      title: '매장 목록',
      onSearchPressed: () {
        print("검색");
      },
    ),

    ////// 1 Depth //////

    1. CustomAppBar_Main
      appBar: CustomAppBar_Logo(),

*/

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../theme/font.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';      // ← Consumer 사용
import '../../viewmodels/point_provider.dart';                // ← pointProvider 사용

//////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////        1 Depth App Bar        //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

// 기본 형식 앱바
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor; // null 가능하도록 수정
  final Function()? onSearchPressed; //action 함수를 호출하는 곳에서 설정할 수 있도록 함

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor, // null이면 default로 설정
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return AppBar(
      scrolledUnderElevation: 0,
      leading: Container(child: Image.asset('assets/images/logo.png')),// logo 부분. 추후 진짜 로고로 바꿀 것
      title: Text(
        title,
        style: TextStyle(
          color: customColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [// 이 부분에 아이콘 버튼을 추가
        IconButton(
          icon: Icon(Icons.search, color: Colors.orange),
          onPressed: onSearchPressed,
        ),
      ],
      backgroundColor: backgroundColor ?? customColors.neutral100,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 실제 코드
class CustomAppBar_Main extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor; // null 가능하도록 수정
  final Function()? onNotificationPressed; //action 함수를 호출하는 곳에서 설정할 수 있도록 함

  const CustomAppBar_Main({
    Key? key,
    this.backgroundColor, // null이면 default로 설정
    this.onNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return AppBar(
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/images/logo.png',
          height: 28,
          width: 35,
        ),
      ),// logo 부분
      actions: [// 이 부분에 아이콘 버튼을 추가
        IconButton(
          icon: Icon(Icons.notifications, color: customColors.neutral30, size: 28,),
          onPressed: onNotificationPressed ?? () {
            Navigator.pushNamed(context, '/notification');
          },
        ),
      ],
      backgroundColor: backgroundColor ?? customColors.neutral100,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar_PointShop extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar_PointShop();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Point Shop', style: pretendardBold(context)),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Consumer(
            builder: (context, ref, _) {
              final point = ref.watch(pointProvider);
              return Row(
                children: [
                  const SizedBox(width: 4),
                  Text('$point P', style: pretendardBold(context)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 에코 미션 앱바 추가
class CustomAppBar_Mission extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar_Mission({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return AppBar(
      title: Text(
        'Eco Mission',
        style: TextStyle(
          color: customColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: customColors.neutral100,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: customColors.neutral30, size: 28),
          onPressed: () => Navigator.pushNamed(context, '/notification'),
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/images/logo.png',
          height: 28,
          width: 35,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
