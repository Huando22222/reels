import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/pages/home_page.dart';
import 'package:reels/pages/verified_email.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/push_notification_service.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  bool isEmailVerified = false;
  final FirebaseService _authService = FirebaseService();
  int sentEmailCount = 0;
  Timer? timer;
  final pushNotificationService = PushNotificationService();

  @override
  void initState() {
    log('===============================init auth gate');
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    pushNotificationService.firebaseNotification(context: context);
    if (isEmailVerified) {
      context.read<UserProvider>().addAllListeners(context: context);
    }
  }

  Future sendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please check your email")),
      );
    }
  }

  Future checkEmailVerified() async {
    isEmailVerified = await _authService.isVerified();
    if (!mounted) return;
    setState(() {});

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      if (context.read<UserProvider>().isLoading) {
        return Scaffold(
          body: Center(
            child: Text("loading screen"),
          ),
        );
      } else {
        return HomePage();
      }
    } else {
      return VerifiedEmail(
        text: sentEmailCount == 0 ? "sent email" : "resent email",
        onTap: () {
          if (sentEmailCount < 1) {
            if (!isEmailVerified) {
              sendVerificationEmail();

              if (timer != null && timer!.isActive) timer?.cancel();
              timer = Timer.periodic(
                Duration(seconds: 3),
                (timer) {
                  checkEmailVerified();
                },
              );
            }
          }
          setState(() {
            sentEmailCount++;
          });
          return;
        },
      );
    }
  }
}
