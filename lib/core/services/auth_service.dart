import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/models/session_model.dart';
import '../constants/app_constants.dart';
import 'device_service.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _secureStorage = const FlutterSecureStorage();
  UserModel? currentUser;
  String? sessionToken;
  
  Future<Map<String, dynamic>> loginWithInviteCode(String code) async {
    try {
      final deviceId = DeviceService.instance.deviceId;
      final deviceName = DeviceService.instance.deviceName;

      final response = await SupabaseService.instance.client.functions.invoke(
        'validate-invite',
        body: {
          'invite_code': code,
          'device_id': deviceId,
          'device_name': deviceName,
        },
      ).timeout(const Duration(seconds: 10));

      final data = response.data;

      if (data['error'] != null) {
        return {'success': false, 'message': data['error']};
      }

      if (data['success'] == true) {
        sessionToken = data['session_token'];
        currentUser = UserModel.fromJson(data['user']);
        
        await _secureStorage.write(key: AppConstants.sessionTokenKey, value: sessionToken);
        await _secureStorage.write(key: 'veltrik_user_data', value: jsonEncode(currentUser!.toJson()));
        
        return {
          'success': true, 
          'is_first_login': data['is_first_login'] ?? false
        };
      }
      
      return {'success': false, 'message': 'Unknown error occurred'};
    } on FunctionException catch (e) {
      String msg = 'Terjadi kesalahan server';
      try {
        final errData = e.details;
        if (errData is Map && errData['error'] != null) {
           msg = errData['error'];
        }
      } catch (_) {}
      return {'success': false, 'message': msg};
    } on TimeoutException catch (_) {
      return {'success': false, 'message': 'Koneksi timeout. Server terlalu lama merespons.'};
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {'success': false, 'message': 'Koneksi timeout. Cek koneksi internet Anda.'};
      }
      return {'success': false, 'message': 'Terjadi kesalahan: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> validateSession() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.sessionTokenKey);
      if (token == null) return {'valid': false};

      final deviceId = DeviceService.instance.deviceId;

      final response = await SupabaseService.instance.client.functions.invoke(
        'validate-session',
        body: {
          'session_token': token,
          'device_id': deviceId,
        },
      );

      final data = response.data;
      if (data['valid'] == true) {
        sessionToken = token;
        currentUser = UserModel.fromJson(data['user']);
        await _secureStorage.write(key: 'veltrik_user_data', value: jsonEncode(currentUser!.toJson()));
        return {'valid': true};
      } else {
        await logout();
        return {'valid': false, 'message': data['error']};
      }
    } catch (e) {
      await logout();
      return {'valid': false, 'message': 'Session expired or invalid'};
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.sessionTokenKey);
    await _secureStorage.delete(key: 'veltrik_user_data');
    currentUser = null;
    sessionToken = null;
  }
}
