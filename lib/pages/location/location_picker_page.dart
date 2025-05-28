import 'package:example_tmap_navi/pages/location/placename_getter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';                     // ← 추가
import 'package:tmap_ui_sdk/route/data/route_point.dart';
import 'package:example_tmap_navi/common/app_routes.dart';
import 'package:example_tmap_navi/utils/location_utils.dart';
import 'package:example_tmap_navi/viewmodels/drive_model_provider.dart';

import '../../common/app_routes.dart';  // ← 변경된 Utils

enum PickMode { start, destination }

class LocationPickerPage extends ConsumerStatefulWidget {
  final PickMode mode;
  const LocationPickerPage({Key? key, required this.mode}) : super(key: key);

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _picked;
  LatLng? _currentLatLng;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // 권한 요청 → granted 콜백에서 위치 가져오기
    LocationUtils.requestLocationPermission(
      context,
      onGranted: () async {
        Position pos = await LocationUtils.getCurrentLocation();
        setState(() {
          _currentLatLng = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStart = widget.mode == PickMode.start;

    if (_loading || _currentLatLng == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isStart ? '출발지 선택' : '목적지 선택')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final initialCamera = CameraPosition(
      target: _currentLatLng!,
      zoom: 15,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isStart ? '출발지 선택' : '목적지 선택'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCamera,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _mapController = c,
            onTap: (pos) async {
              setState(() {
                _picked = pos;
              });

              final placeName = await getPlaceNameFromLatLng(pos);
              print("선택한 위치의 이름: $placeName");

              // 필요하면 상태로 저장해서 UI에도 표시 가능
            },
            markers: {
              if (_picked != null)
                Marker(
                  markerId: MarkerId(isStart ? 'start' : 'dest'),
                  position: _picked!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    isStart
                        ? BitmapDescriptor.hueBlue
                        : BitmapDescriptor.hueRed,
                  ),
                ),
            },
          ),
          if (_picked != null)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () async {
                  final drive = ref.watch(driveModelProvider);
                  final placeName = await getPlaceNameFromLatLng(_picked!);
                  if (isStart) {
                    drive.setSource(
                      RoutePoint(
                        latitude: _picked!.latitude,
                        longitude: _picked!.longitude,
                        name: placeName,
                      ),
                    );
                    context.go('/root/location/destination');
                  } else {
                    drive.setDestination(
                      RoutePoint(
                        latitude: _picked!.latitude,
                        longitude: _picked!.longitude,
                        name: placeName,
                      ),
                    );
                    drive.setSafeDriving(false);

                    context.go(AppRoutes.drivePage);
                  }
                },
                child: Text(isStart ? '목적지 선택으로' : '네비게이션 시작'),
              ),
            ),
        ],
      ),
    );
  }
}