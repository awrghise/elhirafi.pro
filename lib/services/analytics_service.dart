import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Added for FlutterErrorDetails

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize Analytics
  static Future<void> initialize() async {
    // Enable analytics collection
    await _analytics.setAnalyticsCollectionEnabled(true);
    
    // Enable crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  // Set User Properties
  static Future<void> setUserProperties({
    required String userId,
    required String userType,
    String? profession,
    String? country,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
    if (profession != null) {
      await _analytics.setUserProperty(name: 'profession', value: profession);
    }
    if (country != null) {
      await _analytics.setUserProperty(name: 'country', value: country);
    }
  }

  // Track Screen Views
  static Future<void> trackScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track User Registration
  static Future<void> trackUserRegistration({
    required String method,
    required String userType,
    String? profession,
  }) async {
    await _analytics.logSignUp(signUpMethod: method);
    await _analytics.logEvent(
      name: 'user_registration',
      parameters: {
        'method': method,
        'user_type': userType,
        if (profession != null) 'profession': profession,
      },
    );
  }

  // Track User Login
  static Future<void> trackUserLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Track Request Sent
  static Future<void> trackRequestSent({
    required String professionType,
    required String city,
    required String country,
    bool hasTextDescription = false,
  }) async {
    await _analytics.logEvent(
      name: 'request_sent',
      parameters: {
        'profession_type': professionType,
        'city': city,
        'country': country,
        'has_text_description': hasTextDescription,
      },
    );
  }

  // Track Request Response
  static Future<void> trackRequestResponse({
    required String professionType,
    required String responseType, // 'contacted', 'ignored'
  }) async {
    await _analytics.logEvent(
      name: 'request_response',
      parameters: {
        'profession_type': professionType,
        'response_type': responseType,
      },
    );
  }

  // Track Chat Started
  static Future<void> trackChatStarted({
    required String initiatorType, // 'client', 'craftsman'
    required String professionType,
  }) async {
    await _analytics.logEvent(
      name: 'chat_started',
      parameters: {
        'initiator_type': initiatorType,
        'profession_type': professionType,
      },
    );
  }

  // Track Message Sent
  static Future<void> trackMessageSent({
    required String messageType, // 'text', 'audio', 'image'
    required String senderType, // 'client', 'craftsman'
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'message_type': messageType,
        'sender_type': senderType,
      },
    );
  }

  // Track Audio Recording
  static Future<void> trackAudioRecording({
    required int durationSeconds,
    required String context, // 'request', 'chat'
  }) async {
    await _analytics.logEvent(
      name: 'audio_recorded',
      parameters: {
        'duration_seconds': durationSeconds,
        'context': context,
      },
    );
  }

  // Track Craftsman Availability Toggle
  static Future<void> trackAvailabilityToggle({
    required bool isAvailable,
    required String profession,
  }) async {
    await _analytics.logEvent(
      name: 'availability_toggled',
      parameters: {
        'is_available': isAvailable,
        'profession': profession,
      },
    );
  }

  // Track Ad Interactions
  static Future<void> trackAdShown(String adType) async {
    await _analytics.logEvent(
      name: 'ad_shown',
      parameters: {
        'ad_type': adType,
      },
    );
  }

  static Future<void> trackAdClicked(String adType) async {
    await _analytics.logEvent(
      name: 'ad_clicked',
      parameters: {
        'ad_type': adType,
      },
    );
  }

  static Future<void> trackRewardEarned({
    required String rewardType,
    required int rewardAmount,
  }) async {
    await _analytics.logEvent(
      name: 'reward_earned',
      parameters: {
        'reward_type': rewardType,
        'reward_amount': rewardAmount,
      },
    );
  }

  // Track App Performance
  static Future<void> trackAppLaunch() async {
    await _analytics.logAppOpen();
  }

  static Future<void> trackFeatureUsage(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  // Error and Crash Reporting
  static Future<void> recordError({
    required dynamic exception,
    required StackTrace stackTrace,
    String? reason,
    Map<String, dynamic>? customKeys,
  }) async {
    if (customKeys != null) {
      for (final entry in customKeys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }
    
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }

  static Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    await _crashlytics.recordFlutterError(errorDetails);
  }

  // Log Custom Events
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}


