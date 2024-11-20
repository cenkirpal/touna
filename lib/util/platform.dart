import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformChannel {
  static const _channel = MethodChannel('touna');
  static Future open() async {
    var scan = await _channel.invokeMethod('openGallery');
    if (kDebugMode) print('Method channel response : $scan');
    return scan;
  }

  static Future scan(Map<String, dynamic> data) async {
    var scan = await _channel.invokeMethod('scan', data);
    if (kDebugMode) print('Method channel response : $scan');
    return scan;
  }
}
