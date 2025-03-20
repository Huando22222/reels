import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
//https://www.youtube.com/watch?v=X3i9SErMGD0

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "reels-7f647",
      "private_key_id": "dc162adaa6c178f92b2d24fcabc552d2d659471f",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC2Rf5M+dMnyTug\nFPZxAcs+mC2yOMdH1fCpes3I0i/8qEyd0aSDA4tvaJFR1nxxQauEC+jdUsrSfR+E\niNLe1ab1di7X2tOiJw5kWj7zyvFos690RCo5oYgjkXvL+EyVPCTY3OGwxY5OnnWx\nRzDbLrHygruyOBfdo1+8U4xraPL0zXutBKyAYI0l5bKf1qihN48KI3TlXV9l/EnR\nRLbztWPvciMjVatMmLnyUSRdY3PJPCxPhm8KavyX18ptVQ82Yyfr418Rx53wELH3\nlPrX4ZQf/BY6C+r/P0UDGnzEgdK+xXM8wloRFUTmT8CQtQBNIwPMHGeWSVcfC5Nf\numfXOqiNAgMBAAECggEAAd/QLYN0h+UaVcGRbSt0pxHSh0TtMhBoBDe5wPxkUO4V\ntGbw9zkeNTv3VPn/8PwylgEdvy54Qz5uu6KnV6VzxsD7dCD3nYqJ3wwZUWsMHQsB\nkJAyecHVXNd31R4AnGVwOlvYsd2+Lytfw3E1D+ceUYOSblLRIzU1KU8X03NShQp8\nkwmTL5Svz+7hUYlk6DiOQW44rRUANKaVkQHnqYlsC+Ge1lHfQX9ajXTtmbgQYC0W\nt0u0MhYLKBk4tK/9nvnSHAT70es3tX3yZ9fBvNsksY0jwfovvE9OKd/f+Glrxja9\nbrgy+5TaBvhHg8A6pZ6WBcmOysHnomY7bjkS2vFsgQKBgQD+sa2GZ7gjcKSFXiMm\nC4CoasmoHIKeIXFhrHsvXJVKIk+dbmTrjlutNI1xtIVMFo5liQXNJFnAnzxhYfyQ\n/2VNHxwzhferFJDNwl9yQFFKPP6bNKbavnWLCY5AZwCaTwkKsrDcwD6YxWP44B79\nD00Ctf+cIqvVUPGfVh8VBDs9QQKBgQC3NUDNmfqVT3zzNHBLAL2FCXWkemsdBtqs\nu+Aukak+RLH1EmMQSfQ+/sTakSOPlFcNoOzJfF7KB5UkBFtz7syDmkG96Y1OtVas\n8IDe7vsXcNyxkK3rVJBpttOZD4TfYTgd/A7KoN2oqd1ZvdO+Y58Oz2L3UmCKKSvC\nGb/9dY48TQKBgQCMpNUr6U6X03YmZ6uFMMjlN8MP4F6Ir/MKetKzfq6592R7jSCR\nq1UYunJ5HbSWJcaQbzAS7kXZxpTzOcbc0wu/oLRUB2CSypKD7RgD4VyCYFhAoLyb\nAp2qH6a8DaUZkRdvHunnnQl0F1xzbF/wYmimXJZARC0baM1krYwQcPu9gQKBgQC1\nnJ6esZMLy/4rAMKINzWn2Za683eXEKJZNOyofVBuH57hN9bn4Me0Ys01dUbxH7Wk\nFvBjU1yLnTSkvYUCyagGlTWyUwD3Ex/W05qMZA6YUBMWGjut2uhFQy1Cv3WSEkeU\nwbbP+uOAPNLmER0D0LFt9vs9/HUiwGlWQjxlvtC+yQKBgQCrKDIhbU0lfpD44gph\nDUfdf16Bg5OVZgY1dAbvCDxI5/k0vu4sc46BXiKlpT1jEcM0AFcr4BlnQF5dp6IW\n0iUSwgEDasCV4iIbsXLT5j+3KZ29GvCTaOnXO35GNKn/BkKccmW+VOv+ulO2i3se\nXX0CEu7p4kp1yHQW70RGvyzJjg==\n-----END PRIVATE KEY-----\n",
      "client_email": "reels-362@reels-7f647.iam.gserviceaccount.com",
      "client_id": "117629217884268391656",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/reels-362%40reels-7f647.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  //static
  Future<void> sendNotificationToSelectedUser({
    required String deviceToken,
    required BuildContext context,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/reels-7f647/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        // 'token':
        //     "ePz3cCx1ReaYImN9WRcQRR:APA91bFGmhBuvf09PQrezKlEX2ICEGHCzMoGnHaQ0K9r2q3CDANEuN9nxiQN9ten402I8SL7qj-NI_wHlV4DbRoRYXBb1lgkprHXTfY_l_KnCg_l5yQysJs", //testing only
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      log('gui thong bao thanh cong');
    } else {
      //
      log('ERROR: gui thong bao khong thanh cong');
    }
  }

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void _initLocalNotification() {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        //
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );

    final androidDetails = AndroidNotificationDetails(
      "com.example.reels", //channelId,
      "mychannelid", //channelName,
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.max,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: message.data['body'],
    );
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //granted permission
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      //granted provisional
    } else {
      //declined permission
    }
  }

  Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    _saveToken(token!);
  }

  Future<void> _saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  void firebaseNotification({required BuildContext context}) {
    _initLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        // await Navigator.of(context)
        //     .pushNamed('routeName:asdasdasdasdasdasdasdasd');
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        await _showLocalNotification(message);
      },
    );
  }
}
