import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmap_ui_sdk/auth/data/auth_data.dart';
import 'package:tmap_ui_sdk/auth/data/init_result.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk_manager.dart';
import 'package:example_tmap_navi/widgets/common_toast.dart';
import 'package:example_tmap_navi/models/config_car_model.dart';
import 'location_utils.dart';

final tmapSdkInitializedProvider = StateProvider<bool>((ref) => false);
InitResult tmapUISDKInitResult = InitResult.notGranted;

/// Flutter에서 호출하는 단순 상태 확인 함수
Future<bool> checkTmapUISDK(BuildContext context, WidgetRef ref) async {
  if (tmapUISDKInitResult == InitResult.notGranted) {
    await initializeTmapSdk(context, ref);
  }
  return tmapUISDKInitResult == InitResult.granted;
}

/// 위치 권한 → SDK 초기화 → 차량 설정까지 모두 포함
Future<void> initializeTmapSdk(BuildContext context, WidgetRef ref) async {
  try {
    log("✅ Tmap SDK 초기화 시작");

    await LocationUtils.requestLocationPermission(context, onGranted: () async {
      log("✅ 위치 권한 허용됨");

      final authData = AuthData(
        clientApiKey: "ZL6ehYGTGJ96R4pUEzb5J8URphaOWjHP67Afpm3q",
        userKey: "USER_KEY",
        clientServiceName: "CashDriving",
        clientID: "YOUR_CLIENT_ID",
        clientDeviceId: "YOUR_DEVICE_ID",
        clientAppVersion: "1.0.0",
        clientApCode: "YOUR_APP_CODE",
      );

      final result = await TmapUISDKManager().initSDK(authData) ?? InitResult.notGranted;
      tmapUISDKInitResult = result;
      log("✅ SDK 초기화 결과: $result");

      if (result == InitResult.granted) {
        ref.read(tmapSdkInitializedProvider.notifier).state = true;
        await setCarConfig();
        CommonToast.show('TmapUISDK Initialized');
      } else {
        CommonToast.show('SDK 초기화 실패: ${result.text}');
      }
    });
  } catch (e, stackTrace) {
    log("🚨 초기화 에러: $e");
    log("StackTrace: $stackTrace");
  }
}

Future<void> setCarConfig() async {
  try {
    final model = ConfigCarModel();
    final result = await TmapUISDKManager().setConfigSDK(model.normalCar);
    log(result == true ? "✅ 차량 설정 성공" : "❌ 차량 설정 실패");
  } catch (e, stackTrace) {
    log("🚨 차량 설정 에러: $e");
    log("StackTrace: $stackTrace");
  }
}
