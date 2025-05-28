import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmap_ui_sdk/auth/data/auth_data.dart';
import 'package:tmap_ui_sdk/auth/data/init_result.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk_manager.dart';
import 'package:example_tmap_navi/widgets/common_toast.dart';

/// 전역 초기화 결과 저장 변수
InitResult tmapUISDKInitResult = InitResult.notGranted;

/// Tmap SDK 초기화 상태 확인 및 필요 시 초기화
Future<bool> checkTmapUISDK(BuildContext context) async {
  if (tmapUISDKInitResult == InitResult.notGranted) {
    await initPlatformState(context);
  }
  return tmapUISDKInitResult == InitResult.granted;
}

/// 실제 SDK 초기화 로직
Future<void> initPlatformState(BuildContext context) async {
  try {
    final platformVersion = await TmapUiSdk().getPlatformVersion() ?? 'Unknown platform version';

    final manager = TmapUISDKManager();
    final authInfo = AuthData(
      clientServiceName: "",
      clientAppVersion: "",
      clientID: "",
      clientApiKey: "ZL6ehYGTGJ96R4pUEzb5J8URphaOWjHP67Afpm3q",
      clientApCode: "",
      userKey: "",
      deviceKey: "",
      clientDeviceId: "",
    );

    final result = await manager.initSDK(authInfo) ?? InitResult.notGranted;
    tmapUISDKInitResult = result;

    CommonToast.show('TmapUISDK ${result.text}');
  } on PlatformException {
    CommonToast.show('Tmap SDK 초기화 실패');
  }
}
