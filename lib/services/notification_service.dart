import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _requestPermission();
    await _getToken();
    _setupMessageHandlers();
    _setupTokenRefreshListener();
  }

  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined notification permission');
      }
    } catch (e) {
      print('Error requestiong permission: $e');
    }
  }

  Future<void> _getToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM token: $token');
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Ttile: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      if (message.notification != null) {
        _showForegroundNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background');
      print('Data: ${message.data}');

      _handleNotificationTap(message);
    });

    _checkInitialMessage();
  }

  void _showForegroundNotification(RemoteMessage message) {
    print('Showing foreground notification: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (message.data.containsKey('recipe_id')) {
      String recipeId = message.data['recipe_id'];
      print('Navigate to recipe: $recipeId');
      // TODO: Implement navigation
    }
  }

  Future<void> _checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        print('App opened from notification (terminated state)');
        print('Data: ${initialMessage.data}');
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('Error checking initial message: $e');
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String token) {
      print('FCM Token refreshed: $token');
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

}