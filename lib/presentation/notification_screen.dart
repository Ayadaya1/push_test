import 'package:flutter/material.dart';
import 'package:push_test_app/main.dart';

class NotificationScreen extends StatelessWidget {
  final String? text;

  const NotificationScreen({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const MyHomePage(title: 'Notifications');
                  },
                ),
              );
            },
          ),
          title: Text('Notification: ${text ?? ''}'),
        ),
        body: const SizedBox(),
      ),
    );
  }
}
