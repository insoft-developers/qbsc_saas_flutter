import 'package:flutter/services.dart';

class DeviceSecurityService {
  static const _channel = MethodChannel('security/developer_mode');

  static Future<bool> isDeveloperMode() async {
    try {
      final bool result = await _channel.invokeMethod('isDeveloperMode');
      return result;
    } catch (_) {
      return false;
    }
  }
}
