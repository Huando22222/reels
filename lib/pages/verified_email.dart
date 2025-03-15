import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rive/rive.dart' as rive;

class VerifiedEmail extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const VerifiedEmail({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService authService = FirebaseService();
    final size = MediaQuery.of(context).size;
    return ScreenWrapperWidget(
      showBackButton: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.1,
              child: rive.RiveAnimation.asset('assets/riv/fingerPrint.riv'),
            ),
            Text("Verified your email"),
            ElevatedButton(
              onPressed: onTap,
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            ElevatedButton(
              onPressed: () {
                authService.signOut();
              },
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
