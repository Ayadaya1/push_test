import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

Future sendPushNotification() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  final body = {
    "message": {
      "token": "$fcmToken",
      "notification": {
        "title": "Пуш из приложения",
        "body": "Это пуш из приложения"
      },
      "android": {"priority": "HIGH"},
      "data": {
        "route": "notification",
      }
    }
  };

  final uri = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/tst-psh-prjct/messages:send');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer ya29.a0AXooCgvbwbecUqRnhgjKyyk6Y4sBDH8Qx-xqqkuY9U49wPsrynO5hJpxVhrmaLH1M2gwW3c4cGJt1ujkL1_8nQFRy2R7vQ6UdVwxtrjNNYBnH3rtU2ZJpEGGPSVsQlEXu339Xo_17Lbx3jAvFk6RlQzW45P8RqJT4YmC8fOPGrgvgHQXWrvejmULveZbNz6YXTLiwA5S-_rQQPDVY-KdYzw81t9z_x67aSiRFklkqrqqcL7DfWnd8lQnlq1aQq2JAfxYqo_z8rIDtE7c1OvviLKCIpnvcFfZ25PuSwE4ax8ALrOUkaRaLXRlQD9XOGykx7e-xqf_9lcJcEMegNxYOE0YD2AfUM3EdV6F4rT0K9R0j8JBPYPELvCD_C-Vij2m8yS6H_mr_g1_c3_8g02ZIK1yczkvKJJ6aCgYKAZsSARESFQHGX2MifFO0EXFDmlA7vKYOig_Hrw0423'
  };
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(body),
  );
  print(response.body);
}
