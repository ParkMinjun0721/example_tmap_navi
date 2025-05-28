import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tmap_ui_sdk/event/data/driveStatus/tmap_drivestatus.dart';
import 'package:tmap_ui_sdk/event/data/driveguide/tmap_driveguide.dart';
import 'package:tmap_ui_sdk/event/data/markerStatus/marker_status.dart';
import 'package:tmap_ui_sdk/event/data/sdkStatus/tmap_sdk_status.dart';
import 'package:tmap_ui_sdk/tmap_ui_sdk_manager.dart';
import 'package:tmap_ui_sdk/widget/tmap_view_widget.dart';
import 'package:example_tmap_navi/common/app_routes.dart';
import 'package:example_tmap_navi/utils/continue_drive_utils.dart';
import 'package:example_tmap_navi/viewmodels/drive_model_provider.dart';

// Tmap의 UI와 함께 주행
class DrivePage extends ConsumerStatefulWidget {
  const DrivePage({super.key});

  @override
  ConsumerState<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends ConsumerState<DrivePage> {
  int _currentSpeed = 0;
  int _averageSpeed = 0;
  int _limitSpeed = 0;
  bool _isCaution = false;

  // 누적된 주행 거리(km)와 누적 시간(sec)
  double _totalDistanceKm = 0;
  double _totalTimeSec    = 0;

// 수동 계산한 평균 속도 저장용
  int _manualAvgSpeed = 0;


  // 1) EcoScore용 카운터 & 가중치
  int _nSteady    = 0;
  int _nAccel     = 0;
  int _nBrake  = 0;

  static const int _wSteady   = 5; // 안전 주행에 따른 점수 가산점
  static const int _wAccel    = 2; // 급가속 가중치
  static const int _wBrake = 2; // 급감속 가중치

  //  Steady(안전 주행) 감지용
  DateTime? _steadyStartTime;
  static const int _steadyThreshold = 5; // ±5 km/h
  static const Duration _steadyDurationThreshold = Duration(seconds: 10); // 연속 유지 시간
  static const Duration _steadyDuration   = Duration(seconds: 10);
  static const double _steadyRateFallback = 2.0;             // km/h per sec 변동 허용치

  // — 이전 프레임 속도/시간 저장용
  int?      _lastSpeed;
  DateTime? _lastTimestamp;

  @override
  void initState() {
    super.initState();
    TmapUISDKManager().startTmapSDKStatusStream(_onEvent);
    TmapUISDKManager().startMarkerStatusStream(_onMarkerEvent);
    TmapUISDKManager().startTmapDriveStatusStream(_onDriveStatus);
    // ★ 기존 구독에 더해, 드라이브 가이드(속도 포함) 스트림 구독
    TmapUISDKManager().startTmapDriveGuideStream(_onDriveGuide);
  }

  void _onDriveStatus(TmapDriveStatus status) {
    if (status == TmapDriveStatus.onArrivedDestination) {
      debugPrint('[onDriveStatus] - onArrived');
    }
  }

  // ★ 수정: 가이드 이벤트에서 속도 업데이트
  void _onDriveGuide(TmapDriveGuide guide) {
    final now   = DateTime.now();
    final speed = guide.speedInKmPerHour;

    // // 1) Steady 감지: 제한속도 ±_steadyThreshold 이내
    // if ((speed - _limitSpeed).abs() <= _steadyThreshold) {
    //   // 시작 타임이 없으면 지금부터 카운팅
    //   _steadyStartTime ??= now;
    //
    //   // 연속 시간이 _steadyDurationThreshold 넘으면 1회 카운트 후 리셋
    //   if (now.difference(_steadyStartTime!) >= _steadyDurationThreshold) {
    //     _nSteady++;
    //     _steadyStartTime = now;
    //   }
    // } else {
    //   // 범위 벗어나면 리셋
    //   _steadyStartTime = null;
    // }

    // — 1) Steady 감지
    // if (_limitSpeed > 0) {
    //   // 1-a) 제한속도 정보가 있을 때
    //   if ((speed - _limitSpeed).abs() <= _steadyThreshold) {
    //     _steadyStartTime ??= now;
    //     if (now.difference(_steadyStartTime!) >= _steadyDuration) {
    //       _nSteady++;
    //       _steadyStartTime = now;
    //     }
    //   } else {
    //     _steadyStartTime = null;
    //   }
    // } else {
    //   // 1-b) 제한속도 정보가 없을 때: 속도 변화율이 작으면 Steady
    //   if (_lastSpeed != null && _lastTimestamp != null) {
    //     final dt    = now.difference(_lastTimestamp!).inMilliseconds / 1000.0;
    //     final delta = (speed - _lastSpeed!).abs();
    //     final rate  = delta / dt;
    //     if (rate <= _steadyRateFallback) {
    //       // 변화율이 작으면 안정 주행 시작
    //       _steadyStartTime ??= now;
    //       if (now.difference(_steadyStartTime!) >= _steadyDuration) {
    //         _nSteady++;
    //         _steadyStartTime = now;
    //       }
    //     } else {
    //       _steadyStartTime = null;
    //     }
    //   }
    // }

    // 0) 정차 구간 판정: speed < 5km/h 이면 Steady 타이머 리셋만 하고 Steady 감지를 건너뜀
    if (speed < 5) {
      _steadyStartTime = null;  // 정차 중이므로 안전 주행 카운트 초기화
    } else {
      // 1) Steady 감지 로직 (limitSpeed 유무에 따라)
      if (_limitSpeed > 0) {
        if ((speed - _limitSpeed).abs() <= _steadyThreshold) {
          _steadyStartTime ??= now;
          if (now.difference(_steadyStartTime!) >= _steadyDurationThreshold) {
            _nSteady++;
            _steadyStartTime = now;
          }
        } else {
          _steadyStartTime = null;
        }
      } else {
        if (_lastSpeed != null && _lastTimestamp != null) {
          final dt    = now.difference(_lastTimestamp!).inMilliseconds / 1000.0;
          final delta = (speed - _lastSpeed!).abs();
          final rate  = delta / dt;
          if (rate <= _steadyRateFallback) {
            _steadyStartTime ??= now;
            if (now.difference(_steadyStartTime!) >= _steadyDurationThreshold) {
              _nSteady++;
              _steadyStartTime = now;
            }
          } else {
            _steadyStartTime = null;
          }
        }
      }
    }

    // 2) 급가속·급감속 감지
    if (_lastSpeed != null && _lastTimestamp != null) {
      final dt    = now.difference(_lastTimestamp!).inMilliseconds / 1000.0;
      final delta = speed - _lastSpeed!;
      final rate  = delta / dt; // km/h per second

      // 급가속
      if (rate >= 11) {
        _nAccel++;
      }
      // 급감속
      else if (rate <= -7.5) {
        _nBrake++;
      }
    }

    // 1) dt 계산 (이전 콜백과의 경과 시간)
    if (_lastTimestamp != null) {
      final dtSec = now.difference(_lastTimestamp!).inMilliseconds / 1000.0;
      // 2) 이동 중(speed>=5)일 때만 시간·거리 누적
      if (speed >= 5) {
        _totalTimeSec    += dtSec;
        _totalDistanceKm += speed * (dtSec / 3600.0);
      }
    }
    _lastTimestamp = now;

    // 3) 수동 평균속도 계산
    final avgByDistTime = (_totalTimeSec > 0)
        ? (_totalDistanceKm / (_totalTimeSec / 3600.0))
        : 0.0;

    setState(() {
      _currentSpeed = guide.speedInKmPerHour;
      _averageSpeed = guide.averageSpeed;
      _manualAvgSpeed    = avgByDistTime.round(); // 수동 평균
      _totalDistanceKm = _totalDistanceKm;
      _limitSpeed = guide.limitSpeed;
      _isCaution = guide.isCaution;
      _lastSpeed     = speed;
      _lastTimestamp = now;
    });

    debugPrint(
        '[onDriveGuide] Speed: ${guide.speedInKmPerHour} km/h, '
            'Location(${guide.matchedLatitude},${guide.matchedLongitude})'
    );
    debugPrint('[onDriveGuide] - matched Location(${guide.matchedLatitude},${guide.matchedLongitude}) ${guide.currentCourseAngle}');
    debugPrint('[onDriveGuide] - firstSDIInfo: ${guide.firstSDIInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - secondSDIInfo: ${guide.secondSDIInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - secondTBTInfo: ${guide.secondTBTInfo?.toJsonString()}');
    debugPrint('[onDriveGuide] - remainViaPointSize: ${guide.remainViaPointSize}');
  }

  void _onEvent(TmapSDKStatusMsg sdkStatus) {
    switch (sdkStatus.sdkStatus) {
      case TmapSDKStatus.dismissReq:
        if (context.mounted) context.go(AppRoutes.rootPage);
        break;
      case TmapSDKStatus.continueDriveRequestedButNoSavedDriveInfo:
        ContinueDriveUtil.alertContinueDrive(
          context,
          destination: sdkStatus.extraData,
          onGranted: () {
            if (context.mounted) context.go(AppRoutes.rootPage);
          },
        );
        break;
      default:
        break;
    }
  }

  /// EcoScore 계산용 헬퍼 함수
  /// EcoScore 계산 헬퍼 (0~100 클램핑)
  int calculateEcoScore({
    required int nSteady,
    required int wSteady,
    required int nAccel,
    required int wAccel,
    required int nBrake,
    required int wBrake,
  }) {
    final pSteady   = nSteady   * wSteady;
    final pAccel    = nAccel    * wAccel;
    final pBrake = nBrake * wBrake;

    final raw = 50 + pSteady - pAccel - pBrake;
    return raw.clamp(0, 100).toInt();
  }


  void _onMarkerEvent(MarkerStatus selectedMarker) {
    debugPrint(
        'MarkerSelected - ID:${selectedMarker.markerId} '
            'type:${selectedMarker.markerType}'
    );
  }

  @override
  void dispose() {
    TmapUISDKManager().stopTmapSDKStatusStream();
    TmapUISDKManager().stopMarkerStatusStream();
    TmapUISDKManager().stopTmapDriveStatusStream();
    TmapUISDKManager().stopTmapDriveGuideStream(); // ★ 구독 해제
    super.dispose();
  }

  Future<bool?> stopDriving() async {
    return await TmapUISDKManager().stopDriving();
  }

  Future<bool?> toNextViaPointRequest() async {
    return await TmapUISDKManager().toNextViaPointRequest();
  }

  @override
  Widget build(BuildContext context) {
    final displayedSpeed = _currentSpeed;
    final displayedAvgSpeed = _averageSpeed;

    final drive = ref.watch(driveModelProvider); // ✅ Riverpod으로 교체

    // 3) EcoScore 계산
    final ecoScore = calculateEcoScore(
      nSteady:    _nSteady,
      wSteady:    _wSteady,
      nAccel:     _nAccel,
      wAccel:     _wAccel,
      nBrake:  _nBrake,
      wBrake:  _wBrake,
    );


    return WillPopScope(
      onWillPop: () async {
        await stopDriving();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // 기존 지도 UI
              Container(
                color: Colors.white,
                child: TmapViewWidget(data: drive.routeRequestData),
              ),
              // ★ 속도 표시 영역 (좌측 상단)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'EcoScore: $ecoScore',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('sdk 평균: $_averageSpeed km/h'),
                      Text('수동 평균: $_manualAvgSpeed km/h'),
                      Text('제한: $_limitSpeed km/h'),
                      Text('누적 거리: ${_totalDistanceKm.toStringAsFixed(2)} km'),
                      Text('주의: ${_isCaution ? "ON" : "OFF"}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}