import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Google API 키 설정
const String googleApiKey = 'AIzaSyArz1qIls9zBVmI7ZdFGdTQd8eaocDpb68';  // 여기에 본인의 API 키 입력

Future<String> getPlaceNameFromLatLng(LatLng latLng) async {
  final geocoding = GoogleGeocodingApi(googleApiKey);

  try {
    final response = await geocoding.reverse(
      '${latLng.latitude},${latLng.longitude}',
      language: 'ko',
    );

    if (response.results.isNotEmpty) {
      return response.results.first.formattedAddress ?? "주소 없음";
    } else {
      return "주소를 찾을 수 없음";
    }
  } catch (e) {
    return "에러 발생: ${e.toString()}";
  }
}
