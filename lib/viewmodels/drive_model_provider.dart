import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example_tmap_navi/models/drive_model.dart';

final driveModelProvider = ChangeNotifierProvider<DriveModel>((ref) {
  return DriveModel();
});
