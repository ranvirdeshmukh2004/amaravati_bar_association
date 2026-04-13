import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SmsService {
  // ⚠️ SECURITY WARNING: In a production client-side app, this key would be exposed.
  // Since this is a desktop admin app, we are storing it here as requested.
  static const String _apiKey = '4chLYzTjibF9UsPO127SIDNraWXukpqHRCgyldM6ABE5eJnZGfMVE4bJ8cv2xUSTKtOBLiWqZ9GNQoyX';
  static const String _baseUrl = 'https://www.fast2sms.com/dev/bulkV2';

  /// Sends SMS to a list of phone numbers.
  /// 
  /// [numbers] List of phone numbers (should be 10 digits).
  /// [message] The message content.
  /// [type] 'custom' or 'alert' (for logging purposes - currently logs to console/memory only).
  /// 
  /// Returns the number of recipients if successful.
  Future<int> sendSms({
    required List<String> numbers,
    required String message,
    String type = 'custom',
  }) async {
    if (numbers.isEmpty) return 0;

    // Fast2SMS Bulk V2 expects comma separated numbers
    final numbersStr = numbers.join(',');

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'authorization': _apiKey,
        'route': 'q',
        'sender_id': 'FSTSMS',
        'message': message,
        'language': 'english',
        'flash': '0',
        'numbers': numbersStr,
      });

      debugPrint('SmsService: Calling GET $uri');

      final response = await http.get(uri);

      debugPrint('SmsService: API Response Status: ${response.statusCode}');
      debugPrint('SmsService: API Response Body Raw: "${response.body}"');
      
      if (response.body.trim().isEmpty) {
         throw Exception('Received empty response body from Fast2SMS. Status Code: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['return'] == true) {
        debugPrint('SMS Sent Successfully: ${data['message']}');
        return numbers.length;
      } else {
        throw Exception(data['message'] ?? 'Fast2SMS Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to send SMS: $e');
      throw Exception('Failed to send SMS: $e');
    }
  }
}

final smsServiceProvider = Provider<SmsService>((ref) => SmsService());
