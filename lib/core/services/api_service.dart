import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

class ClaimRequestModel {
  final String claimId;
  final double amount;
  final String method;
  final String details;
  final String status;
  final String? note;
  final String? code;
  final String date;

  ClaimRequestModel({
    required this.claimId,
    required this.amount,
    required this.method,
    required this.details,
    required this.status,
    this.note,
    this.code,
    required this.date,
  });

  factory ClaimRequestModel.fromJson(Map<String, dynamic> json) {
    final noteVal = json['note']?.toString();
    final codeVal = json['code']?.toString();
    return ClaimRequestModel(
      claimId: json['claim_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      note: (noteVal != null && noteVal != 'null' && noteVal.isNotEmpty) ? noteVal : null,
      code: (codeVal != null && codeVal != 'null' && codeVal.isNotEmpty) ? codeVal : null,
      date: json['date']?.toString() ?? '',
    );
  }
}

class ApiServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final bool isMaintenance;
  final bool isUpdateRequired;

  ApiServiceResult.success(this.data)
      : isSuccess = true,
        errorMessage = null,
        isMaintenance = false,
        isUpdateRequired = false;

  ApiServiceResult.failure(this.errorMessage, {this.isMaintenance = false, this.isUpdateRequired = false})
      : isSuccess = false,
        data = null;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'https://games.sponsorle.com/';
  static const String _appId = 'word_puzzle_01';

  // Obfuscated Salt key algorithm
  static String _xorDecrypt(List<int> bytes) {
    final sb = StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      final keyCode = (((i * 13) + 7) ^ 0x5A) & 0xFF;
      sb.writeCharCode(bytes[i] ^ keyCode);
    }
    return sb.toString();
  }

  static String get appSecretSalt => _xorDecrypt(const [
        46, 43, 24, 1, 19, 119, 80, 72, 71, 67, 160, 164, 152, 152, 130, 244, 210, 205, 202, 200, 37, 29, 20, 13, 28, 73, 49, 12, 27, 236
      ]);

  static String get tmuS2SSecret => _xorDecrypt(const [
        46, 47, 15, 28, 8, 123, 80, 95, 84, 75, 182, 187, 152, 134, 139, 207, 254, 140, 216, 251, 34, 39, 28, 26, 0, 98, 92, 87, 76, 163, 136, 242, 205, 220, 172
      ]);

  static String get trackMyEventSdkKey => _xorDecrypt(const [
        41, 35, 14, 43, 3, 42, 62, 94, 80, 69, 234, 245, 159, 219, 213, 167, 188, 139, 158, 193, 99, 115, 28, 93, 83, 114, 102, 94, 72, 184, 231, 248, 152, 221, 248, 164
      ]);

  String _buildSignature(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final queryString = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    final hmac = Hmac(sha256, utf8.encode(appSecretSalt));
    final digest = hmac.convert(utf8.encode(queryString));
    return digest.toString();
  }

  Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id.isNotEmpty ? androidInfo.id : 'flutter_android_device';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'flutter_ios_device';
      }
    } catch (e) {
      debugPrint('Error fetching device id: $e');
    }
    return 'flutter_generic_device';
  }

  Future<String?> _executePost(
    String endpoint,
    String jsonPayload, {
    String? authKey,
  }) async {
    try {
      final url = Uri.parse(_baseUrl + endpoint);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (authKey != null && authKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authKey';
      }

      final response = await http
          .post(url, headers: headers, body: jsonPayload)
          .timeout(const Duration(seconds: 10));

      debugPrint('POST $endpoint (${response.statusCode}): ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      return response.body.isNotEmpty ? response.body : null;
    } catch (e) {
      debugPrint('Network request failed for $endpoint: $e');
      return null;
    }
  }

  /// Unified Login / Signup API call
  Future<ApiServiceResult<Map<String, dynamic>>> loginSignup() async {
    final connected = await ConnectivityService().isConnected();
    if (!connected) {
      return ApiServiceResult.failure('No internet connection');
    }

    final prefs = await SharedPreferences.getInstance();
    final deviceId = await getDeviceId();
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final signParams = {
      'device_id': deviceId,
      'app_id': _appId,
      'timestamp': timestamp,
    };
    final signature = _buildSignature(signParams);

    final payload = {
      'device_id': deviceId,
      'app_id': _appId,
      'timestamp': int.parse(timestamp),
      'signature': signature,
      'play_integrity_token': '',
      'from': '',
    };

    final result = await _executePost('login_signup.php', jsonEncode(payload));
    if (result == null) {
      return ApiServiceResult.failure('Server unreachable');
    }

    try {
      final jsonObj = jsonDecode(result) as Map<String, dynamic>;
      final status = jsonObj['status']?.toString();

      if (status == 'success') {
        final authKey = jsonObj['auth_key']?.toString() ?? '';
        final trackMyUserKey = jsonObj['trackmyuser_key']?.toString() ?? '';
        final appVersion = (jsonObj['app_version'] as num?)?.toInt() ?? 1;
        final appMaintenance = (jsonObj['app_maintenance'] as num?)?.toInt() ?? 0;

        await prefs.setInt('app_version', appVersion);
        await prefs.setInt('app_maintenance', appMaintenance);

        if (appMaintenance == 1) {
          return ApiServiceResult.failure('Server is under maintenance', isMaintenance: true);
        }

        const currentVersionCode = 1; // App's current local version code
        if (appVersion > currentVersionCode) {
          return ApiServiceResult.failure('Update required', isUpdateRequired: true);
        }

        final userObj = jsonObj['user'] as Map<String, dynamic>?;
        final topBannerUrl = jsonObj['kaamkaro_banner_url']?.toString() ?? '';
        final topClickUrl = jsonObj['kaamkaro_click_url']?.toString() ?? '';
        final userBannerUrl = userObj?['kaamkaro_banner_url']?.toString() ?? '';
        final userClickUrl = userObj?['kaamkaro_click_url']?.toString() ?? '';
        final finalBannerUrl = userBannerUrl.isNotEmpty ? userBannerUrl : topBannerUrl;
        final finalClickUrl = userClickUrl.isNotEmpty ? userClickUrl : topClickUrl;

        await prefs.setString('auth_key', authKey);
        await prefs.setString('trackmyuser_key', trackMyUserKey);
        await prefs.setString('kaamkaro_banner_url', finalBannerUrl);
        await prefs.setString('kaamkaro_click_url', finalClickUrl);

        if (userObj != null) {
          final userId = userObj['user_id']?.toString() ?? '0';
          final currentLevel = (userObj['current_level'] as num?)?.toInt() ?? 1;
          final targetLevel = (userObj['target_level'] as num?)?.toInt() ?? 15;
          final rewardAmount = (userObj['reward_amount'] as num?)?.toDouble() ?? 500.0;
          final rewardCurrency = userObj['reward_currency']?.toString() ?? 'INR';
          final rewardIconUrl = userObj['reward_icon_url']?.toString() ?? '';
          final totalScore = (userObj['total_score'] as num?)?.toInt() ?? 0;

          await prefs.setString('user_id', userId);
          await prefs.setInt('current_level', currentLevel);
          await prefs.setInt('target_level', targetLevel);
          await prefs.setDouble('reward_amount', rewardAmount);
          await prefs.setString('reward_currency', rewardCurrency);
          await prefs.setString('reward_icon_url', rewardIconUrl);
          await prefs.setInt('total_score', totalScore);
        }

        return ApiServiceResult.success(jsonObj);
      } else {
        final message = jsonObj['message']?.toString() ?? 'Authentication Failed';
        return ApiServiceResult.failure(message);
      }
    } catch (e) {
      return ApiServiceResult.failure('JSON Parsing error');
    }
  }

  /// Log Level Completion to server
  Future<ApiServiceResult<bool>> logLevelCompletion(int level, int scoreEarned) async {
    final connected = await ConnectivityService().isConnected();
    if (!connected) {
      return ApiServiceResult.failure('No internet connection');
    }

    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('auth_key');
    if (authKey == null || authKey.isEmpty) {
      return ApiServiceResult.failure('Authentication required');
    }

    final payload = {
      'level': level,
      'score_earned': scoreEarned,
    };

    final result = await _executePost('level.php', jsonEncode(payload), authKey: authKey);
    if (result == null) {
      return ApiServiceResult.failure('Network error');
    }

    try {
      final jsonObj = jsonDecode(result) as Map<String, dynamic>;
      if (jsonObj['status'] == 'success') {
        final currentLevelVal = (jsonObj['current_level'] as num?)?.toInt() ?? (level + 1);
        final totalScore = (jsonObj['total_score'] as num?)?.toInt() ?? 0;

        final existingLevel = prefs.getInt('current_level') ?? 1;
        final levelToSave = currentLevelVal > existingLevel ? currentLevelVal : existingLevel;

        await prefs.setInt('current_level', levelToSave);
        await prefs.setInt('total_score', totalScore);

        return ApiServiceResult.success(true);
      } else {
        final message = jsonObj['message']?.toString() ?? 'Failed to update level';
        return ApiServiceResult.failure(message);
      }
    } catch (e) {
      return ApiServiceResult.failure('Parsing error');
    }
  }

  /// Submit Withdrawal Claim
  Future<ApiServiceResult<String>> submitClaim({
    required String method,
    required String details,
    required double amount,
  }) async {
    final connected = await ConnectivityService().isConnected();
    if (!connected) {
      return ApiServiceResult.failure('No internet connection');
    }

    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('auth_key');
    if (authKey == null || authKey.isEmpty) {
      return ApiServiceResult.failure('Session expired. Please restart the app.');
    }

    final payload = {
      'withdrawal_method': method,
      'withdrawal_details': details,
      'amount': amount,
    };

    final result = await _executePost('redeem.php', jsonEncode(payload), authKey: authKey);
    if (result == null) {
      return ApiServiceResult.failure('No connection. Please check your internet and retry.');
    }

    try {
      final jsonObj = jsonDecode(result) as Map<String, dynamic>;
      if (jsonObj['status'] == 'success') {
        final claimId = jsonObj['claim_id']?.toString() ?? '';
        await prefs.setInt('current_level', 1);
        return ApiServiceResult.success(claimId);
      } else {
        final errorCode = jsonObj['error_code']?.toString() ?? '';
        final serverMsg = jsonObj['message']?.toString() ?? '';
        String userMsg = serverMsg;
        switch (errorCode) {
          case 'LEVEL_NOT_REACHED':
            userMsg = serverMsg.isNotEmpty ? serverMsg : 'You haven\'t reached the required level yet.';
            break;
          case 'PENDING_CLAIM_EXISTS':
            userMsg = 'You already have a pending withdrawal. Please wait for it to be reviewed.';
            break;
          case 'SEC_CHEATING_DETECTED':
            userMsg = '⚠️ Security alert: unusual activity detected. Please play normally.';
            break;
          case 'INVALID_INPUT':
            userMsg = 'Invalid details. Please check your address and try again.';
            break;
          case 'UNAUTHORIZED':
            userMsg = 'Session expired. Please restart the app.';
            break;
          default:
            if (userMsg.isEmpty) userMsg = 'Claim rejected. Please try again later.';
            break;
        }
        return ApiServiceResult.failure(userMsg);
      }
    } catch (e) {
      return ApiServiceResult.failure('Unexpected response from server. Please try again.');
    }
  }

  /// Fetch History
  Future<ApiServiceResult<List<ClaimRequestModel>>> fetchHistory() async {
    final connected = await ConnectivityService().isConnected();
    if (!connected) {
      return ApiServiceResult.failure('No internet connection');
    }

    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('auth_key');
    if (authKey == null || authKey.isEmpty) {
      return ApiServiceResult.failure('Authentication required.');
    }

    final result = await _executePost('history.php', '{}', authKey: authKey);
    if (result == null) {
      return ApiServiceResult.failure('Server network error');
    }

    try {
      final jsonObj = jsonDecode(result) as Map<String, dynamic>;
      if (jsonObj['status'] == 'success') {
        final historyArr = jsonObj['history'] as List<dynamic>? ?? [];
        final list = historyArr
            .map((item) => ClaimRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiServiceResult.success(list);
      } else {
        final message = jsonObj['message']?.toString() ?? 'Failed to fetch history';
        return ApiServiceResult.failure(message);
      }
    } catch (e) {
      return ApiServiceResult.failure('Failed to parse history');
    }
  }
}
