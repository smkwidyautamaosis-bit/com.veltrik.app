import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'device_service.dart';
import 'supabase_service.dart';

class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  Future<String?> getSignedUrl(String documentId) async {
    try {
      final sessionToken = AuthService.instance.sessionToken;
      final deviceId = DeviceService.instance.deviceId;

      if (sessionToken == null) return null;

      final response = await SupabaseService.instance.client.functions.invoke(
        'get-signed-pdf-url',
        body: {
          'document_id': documentId,
          'session_token': sessionToken,
          'device_id': deviceId,
        },
      );

      final data = response.data;
      if (data['signed_url'] != null) {
        return data['signed_url'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching signed URL: $e');
      return null;
    }
  }
}
