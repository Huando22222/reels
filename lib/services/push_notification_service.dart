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
      "private_key_id": "6cc32f4556cf85067336f6d062adcfd0fe924a65",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3SrKwnQz5B2fL\nPdT66bi8TeRuvIRQozusGyhHShHDGSy1jaHmOOK4KzQ6OCZXsxgobYY8bGZNvJ7j\nKQGbR7fIXu9YNZmwzVEzSy4oj4+riei0VPLcY4DVWsMX03h3Ox49tvWsjVnG5Sko\ncd9WvEfZcM78CWVPvRy+FbBNVvDwPRA0KqkEi2gb3JRqXRArr5bUSnM/5cNKhIgZ\nODHEDgejp57v9K1NjQOtOYGv1rSnBMwvJeQnJScKfsQd4WsVJXvz8CEEfFy3vm9h\nn7wa70DdgQZc7u79P7WRJoNXZ5WrftHNKs031TVWY3KCCeGhFBs0H+Xum7maxCd7\nUj7JpyPpAgMBAAECggEAUjpPqc37GOlKljI6Dwq1Vrz3AvrNvUNNrOtOCZVgHI95\nsEVG4XqZs5emSYwRH3z4FIL2GrtitfMtsKkf0GK/P0PfyknZlii2CfXrUkT9Zi5r\nWCNYBKkbDhw2s8SqIYtDCNrAolWTdhgue7eCQ24aKaFjKkyox7oGX/xo6Hldg9iO\nwjbc9w3fchhHvyMvE8eNrbkEiAAoIzItQ2BFaxRY/S3EIr66FG9mUdyr1h2c+B9r\ncnOQFxkaRhx9URztb9JM5UZJF3jZ9dZZALpxoO2Qh02GOQUrN8hzI1Ew5aiy4DaH\nifM2llqT77+jfRNiRCkCUrSF4t95uI2J4YuBkITutQKBgQDbKlNTeWZ3b+VSEMq6\naGMl8y3r8Tc4o5yeEIYR5wBFKYynwG3dE+bi64GZRo2cV9O7Rm1oSDbHHmkVG6qI\nbyRplbj3g/BBE3JjjuJrenmw+qy8YA7sf69rO/2bXoRT/3IexwZYxcrypMsnh0sP\n582+IxE+9ixhobCiS82APH8KfwKBgQDWGOYv4rs2jk/CqgAhef76UeO6tuRiufjP\nk6PzcfCiL6b95zS2/8Jm/sykbWrjBg5+Wc87JQFB4WujIrCoxiLQhynuxjbIURRt\nErdNyzFCR7FeXdf0GRF0FeziuRxw0ESaA0VsnxksZEvTBeaA7M01IRaoXm2CjQSO\nulwmhhCNlwKBgCMxnMfeytGLKmwPPj7I3IMPleQ5jACQZWoMhTsCuUxh67BUek/y\nDjWKU/llFwBwKhP8rzz7u7Al9gHpu2zFTDeYT2ePzFjm4ouSOlHADSKaXnqxgjQA\nHQ8/Ru5YMy+56X1/wEkpGfn09JqYYzleo+9Qekh+B4p2CINHYOyiylPJAoGARasI\njKCNJy2cCs5jCIG4VSB8qG+HVhEKRBHZEgkLstsqzgiEgOAtFHLpiMAKPiHkaX00\nEBz0kcmWyxkov2LqRU0WehqKDRlFOlES0P/D4buOnhSPh2D46vuPgB+Yf6VmDW/v\nEW+cM3PXsK2E2oM0K4u+4b8Ih6j3yLIf9nE9xbUCgYEA0/COo45xoMX/divuESzY\n1O5cpJqu7yysv2ur/O6foqLRFuWBVhwjOHgJ5UKOduYx+J0uGPhNK6P6Rt1UCRyb\nKTNhTHAQx1tllYRKg/K4Cexn35KLLK8PKuzqXCt+/Qp8rLuzL/TI3Og/lCSkWjKd\nvMF+bNZKjoa6/0blc0fmBuk=\n-----END PRIVATE KEY-----\n",
      "client_email": "reels-528@reels-7f647.iam.gserviceaccount.com",
      "client_id": "104926516528614441414",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/reels-528%40reels-7f647.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    //  {
    //   "type": "service_account",
    //   "project_id": "reels-7f647",
    //   "private_key_id": "dc162adaa6c178f92b2d24fcabc552d2d659471f",
    //   "private_key":
    //       "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC2Rf5M+dMnyTug\nFPZxAcs+mC2yOMdH1fCpes3I0i/8qEyd0aSDA4tvaJFR1nxxQauEC+jdUsrSfR+E\niNLe1ab1di7X2tOiJw5kWj7zyvFos690RCo5oYgjkXvL+EyVPCTY3OGwxY5OnnWx\nRzDbLrHygruyOBfdo1+8U4xraPL0zXutBKyAYI0l5bKf1qihN48KI3TlXV9l/EnR\nRLbztWPvciMjVatMmLnyUSRdY3PJPCxPhm8KavyX18ptVQ82Yyfr418Rx53wELH3\nlPrX4ZQf/BY6C+r/P0UDGnzEgdK+xXM8wloRFUTmT8CQtQBNIwPMHGeWSVcfC5Nf\numfXOqiNAgMBAAECggEAAd/QLYN0h+UaVcGRbSt0pxHSh0TtMhBoBDe5wPxkUO4V\ntGbw9zkeNTv3VPn/8PwylgEdvy54Qz5uu6KnV6VzxsD7dCD3nYqJ3wwZUWsMHQsB\nkJAyecHVXNd31R4AnGVwOlvYsd2+Lytfw3E1D+ceUYOSblLRIzU1KU8X03NShQp8\nkwmTL5Svz+7hUYlk6DiOQW44rRUANKaVkQHnqYlsC+Ge1lHfQX9ajXTtmbgQYC0W\nt0u0MhYLKBk4tK/9nvnSHAT70es3tX3yZ9fBvNsksY0jwfovvE9OKd/f+Glrxja9\nbrgy+5TaBvhHg8A6pZ6WBcmOysHnomY7bjkS2vFsgQKBgQD+sa2GZ7gjcKSFXiMm\nC4CoasmoHIKeIXFhrHsvXJVKIk+dbmTrjlutNI1xtIVMFo5liQXNJFnAnzxhYfyQ\n/2VNHxwzhferFJDNwl9yQFFKPP6bNKbavnWLCY5AZwCaTwkKsrDcwD6YxWP44B79\nD00Ctf+cIqvVUPGfVh8VBDs9QQKBgQC3NUDNmfqVT3zzNHBLAL2FCXWkemsdBtqs\nu+Aukak+RLH1EmMQSfQ+/sTakSOPlFcNoOzJfF7KB5UkBFtz7syDmkG96Y1OtVas\n8IDe7vsXcNyxkK3rVJBpttOZD4TfYTgd/A7KoN2oqd1ZvdO+Y58Oz2L3UmCKKSvC\nGb/9dY48TQKBgQCMpNUr6U6X03YmZ6uFMMjlN8MP4F6Ir/MKetKzfq6592R7jSCR\nq1UYunJ5HbSWJcaQbzAS7kXZxpTzOcbc0wu/oLRUB2CSypKD7RgD4VyCYFhAoLyb\nAp2qH6a8DaUZkRdvHunnnQl0F1xzbF/wYmimXJZARC0baM1krYwQcPu9gQKBgQC1\nnJ6esZMLy/4rAMKINzWn2Za683eXEKJZNOyofVBuH57hN9bn4Me0Ys01dUbxH7Wk\nFvBjU1yLnTSkvYUCyagGlTWyUwD3Ex/W05qMZA6YUBMWGjut2uhFQy1Cv3WSEkeU\nwbbP+uOAPNLmER0D0LFt9vs9/HUiwGlWQjxlvtC+yQKBgQCrKDIhbU0lfpD44gph\nDUfdf16Bg5OVZgY1dAbvCDxI5/k0vu4sc46BXiKlpT1jEcM0AFcr4BlnQF5dp6IW\n0iUSwgEDasCV4iIbsXLT5j+3KZ29GvCTaOnXO35GNKn/BkKccmW+VOv+ulO2i3se\nXX0CEu7p4kp1yHQW70RGvyzJjg==\n-----END PRIVATE KEY-----\n",
    //   "client_email": "reels-362@reels-7f647.iam.gserviceaccount.com",
    //   "client_id": "117629217884268391656",
    //   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    //   "token_uri": "https://oauth2.googleapis.com/token",
    //   "auth_provider_x509_cert_url":
    //       "https://www.googleapis.com/oauth2/v1/certs",
    //   "client_x509_cert_url":
    //       "https://www.googleapis.com/robot/v1/metadata/x509/reels-362%40reels-7f647.iam.gserviceaccount.com",
    //   "universe_domain": "googleapis.com"
    // };

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
    try {
      final String serverAccessTokenKey = await getAccessToken();
      String endpointFirebaseCloudMessaging =
          'https://fcm.googleapis.com/v1/projects/reels-7f647/messages:send';
      final Map<String, dynamic> message = {
        'message': {
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
    } catch (e) {
      log(e.toString());
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
