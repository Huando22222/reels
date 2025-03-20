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
import 'package:reels/widgets/loading_widget.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  bool _isEmailVerified = false;
  final FirebaseService _authService = FirebaseService();
  int _sentEmailCount = 0;
  Timer? _timer;
  final _pushNotificationService = PushNotificationService();

  @override
  void initState() {
    log('===============================init auth gate');
    super.initState();
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    _pushNotificationService.firebaseNotification(context: context);
    if (_isEmailVerified) {
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
    _isEmailVerified = await _authService.isVerified();
    if (!mounted) return;
    setState(() {});

    if (_isEmailVerified) {
      _timer?.cancel();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmailVerified) {
      if (context.read<UserProvider>().isLoading) {
        return Scaffold(
          body: Center(
            child: LoadingWidget(
              duration: Duration(milliseconds: 1000),
            ),
          ),
        );
      } else {
        return HomePage();
      }
    } else {
      return VerifiedEmail(
        color:
            _sentEmailCount < 2 ? Theme.of(context).colorScheme.primary : null,
        text: _sentEmailCount == 0 ? "sent email" : "resent email",
        onTap: () {
          if (_sentEmailCount < 2) {
            if (!_isEmailVerified) {
              sendVerificationEmail();

              if (_timer != null && _timer!.isActive) _timer?.cancel();
              _timer = Timer.periodic(
                Duration(seconds: 3),
                (timer) {
                  checkEmailVerified();
                },
              );
            }
          }
          setState(() {
            _sentEmailCount++;
          });
          return;
        },
      );
    }
  }
}
