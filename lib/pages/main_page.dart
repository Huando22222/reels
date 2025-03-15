// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/pages/auth_gate_page.dart';
import 'package:reels/pages/login_page.dart';
import 'package:reels/providers/user_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, authProvider, child) {
        // if (authProvider.user == null) {
        //   Future.microtask(() {
        //     Navigator.popUntil(context, (route) => route.isFirst);
        //   });
        // }

        return authProvider.user != null ? AuthGatePage() : LoginPage();
      },
    );
  }
}
