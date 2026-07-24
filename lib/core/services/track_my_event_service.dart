import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class TrackMyEventService {
  static final TrackMyEventService _instance = TrackMyEventService._internal();
  factory TrackMyEventService() => _instance;
  TrackMyEventService._internal();

  static const String _defaultBaseUrl = 'https://gameanalytics.sathii.in/';

  Future<void> trackCustomEvent(String eventName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final deviceId = await ApiService().getDeviceId();
      final sdkKey = ApiService.trackMyEventSdkKey;
      final s2sSecret = ApiService.tmuS2SSecret;

      final alreadyTracked = prefs.getBool('tmu_event_$eventName') ?? false;
      if (alreadyTracked) {
        debugPrint('TrackMyEvent: event \'$eventName\' already tracked.');
        return;
      }

      // signature = SHA-256(sdk_key + device_id + user_id + event_name + s2s_secret)
      final signatureSource = '$sdkKey$deviceId$userId$eventName$s2sSecret';
      final signature = sha256.convert(utf8.encode(signatureSource)).toString();

      final payload = {
        'sdk_key': sdkKey,
        'device_id': deviceId,
        'user_id': userId,
        'event_name': eventName,
        'signature': signature,
      };

      final url = Uri.parse('${_defaultBaseUrl}event.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      debugPrint('TrackMyEvent \'$eventName\' status: ${response.statusCode}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await prefs.setBool('tmu_event_$eventName', true);
      }
    } catch (e) {
      debugPrint('Failed to track event \'$eventName\': $e');
    }
  }

  void trackInstall() => trackCustomEvent('install');
  void trackInterstitialAd() => trackCustomEvent('interstitial_ad');
  void trackRewardedAd() => trackCustomEvent('rewarded_ad');

  void checkAndTrackLevelMilestones(int completedLevel) {
    final milestone = switch (completedLevel) {
      20 => 'ce_level_20',
      50 => 'ce_level_50',
      100 => 'ce_level_100',
      200 => 'ce_level_200',
      300 => 'ce_level_300',
      _ => null,
    };
    if (milestone != null) {
      trackCustomEvent(milestone);
    }
  }
}
