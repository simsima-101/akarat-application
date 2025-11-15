// lib/device_id.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String? deviceId;

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // You may prefer androidInfo.androidId depending on your needs / SDK
      deviceId = androidInfo.id; // Android ID (SSAID)
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor; // Per-app, per-vendor ID
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error getting device ID: $e");
  }

  return deviceId;
}
