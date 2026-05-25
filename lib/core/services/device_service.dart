import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class DeviceService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();

  final _secureStorage = const FlutterSecureStorage();
  final _deviceInfo = DeviceInfoPlugin();

  String? _deviceId;
  String? _deviceName;

  String get deviceId => _deviceId ?? '';
  String get deviceName => _deviceName ?? '';

  Future<void> initialize() async {
    _deviceId = await _secureStorage.read(key: AppConstants.deviceIdKey);
    _deviceName = await _secureStorage.read(key: '${AppConstants.deviceIdKey}_name');

    if (_deviceId == null) {
      await _generateAndSaveDeviceFingerprint();
    }
  }

  Future<void> _generateAndSaveDeviceFingerprint() async {
    String rawId = '';
    String name = 'Unknown Device';

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final brand = androidInfo.brand;
      final model = androidInfo.model;
      final id = androidInfo.id; // Unique ID for hardware
      final version = androidInfo.version.release;
      
      rawId = '${id}_${model}_$brand';
      name = '$brand $model (Android $version)';
    } catch (e) {
      // Fallback
      rawId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    final bytes = utf8.encode(rawId);
    final hash = sha256.convert(bytes);
    
    _deviceId = hash.toString();
    _deviceName = name;

    await _secureStorage.write(key: AppConstants.deviceIdKey, value: _deviceId);
    await _secureStorage.write(key: '${AppConstants.deviceIdKey}_name', value: _deviceName);
  }
}
