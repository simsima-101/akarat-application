// lib/device_id.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Returns the device ID (unique per device).
///
/// On Android: returns `androidInfo.id` (SSAID).
/// On iOS: returns `identifierForVendor`.
/// Returns `null` if the device type is not supported or an error occurs.
Future<String?> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID (SSAID)
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor; // iOS identifier
    } else {
      // Unsupported platform
      return null;
    }
  } catch (e, stackTrace) {
    // Optional: log the error and stack trace
    // ignore: avoid_print
    print('Error getting device ID: $e\n$stackTrace');
    return null;
  }
}
