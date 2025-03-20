import 'package:flutter/material.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';
import 'package:rive/rive.dart' as rive;

class VerifiedEmail extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const VerifiedEmail({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
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
            Text(
              "Verified your email",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: MediaQuery.of(context).size.width * 0.3,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
