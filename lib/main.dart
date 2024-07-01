import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_test_app/firebase_options.dart';
import 'package:push_test_app/presentation/notification_screen.dart';
import 'package:push_test_app/presentation/notification_services.dart';
import 'package:rxdart/rxdart.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _messageStreamController.sink.add(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInitializationSettings = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (payload) {},
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();

  //print('token: $fcmToken');

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      'High Importance Notification',
      importance: Importance.max,
    );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: channel.importance,
      priority: Priority.high,
      ticker: 'Ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    if(message.notification != null) {
      Future.delayed(Duration.zero, () {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
        );
      });
    }
    _messageStreamController.sink.add(message);
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await messaging.subscribeToTopic('topic');

  runApp(
    const MaterialApp(
      home: MyHomePage(
        title: 'Notifications',
      ),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    super.key,
    required this.title,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _lastMessage = "";

  _MyHomePageState() {
    _messageStreamController.listen(
      (message) {
        if(mounted) {
          setState(
                () {
              if (message.notification != null) {
                _lastMessage = 'Received a notification message:'
                    '\nTitle=${message.notification?.title},'
                    '\nBody=${message.notification?.body},'
                    '\nData=${message.data}';
              } else {
                _lastMessage = 'Received a data message: ${message.data}';
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (context.mounted) {
          if (message.data['route'] == 'notification') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return NotificationScreen(
                    text: message.data['text'],
                  );
                },
              ),
            );
          }
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SendPushButton(),
            const SizedBox(height: 10),
            if (_lastMessage.isNotEmpty) _LastPushText(message: _lastMessage),
          ],
        ),
      ),
    );
  }
}

class _SendPushButton extends StatelessWidget {
  const _SendPushButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async => await sendPushNotification(),
      child: const Text('Отправить пуш'),
    );
  }
}

class _LastPushText extends StatelessWidget {
  final String message;

  const _LastPushText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Последний пуш:', style: Theme.of(context).textTheme.titleLarge),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
