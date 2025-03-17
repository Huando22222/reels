import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:reels/config/extension.dart';

import 'package:reels/services/firebase_service.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';
import 'package:reels/widgets/text_field_widget.dart';

class RecoverEmailPage extends StatefulWidget {
  const RecoverEmailPage({super.key});

  @override
  State<RecoverEmailPage> createState() => _RecoverEmailPageState();
}

class _RecoverEmailPageState extends State<RecoverEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseService _authService = FirebaseService();
  bool _validEmail = true;
  bool _isLoading = false;
  bool _hasSending = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ScreenWrapperWidget(
      showBackButton: true,
      title: 'Recover Email',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFieldWidget(
              hintText: "email your want to recover",
              controller: _emailController,
              icon: HugeIcons.strokeRoundedMail01,
              isValid: _validEmail,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.2,
                  vertical: 15,
                ),
              ),
              onPressed: _hasSending
                  ? null
                  : () async {
                      if (_isLoading) return;

                      setState(() {
                        _validEmail = _emailController.text.isValidEmail();
                      });

                      if (!_validEmail) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid email address"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await _authService.sendPasswordResetEmail(
                          email: _emailController.text,
                        );
                        setState(() {
                          _hasSending = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Recovery email has been sent! Check your inbox."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${e.toString()}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    },
              child: !_isLoading
                  ? Text(
                      _hasSending ? "check your email !" : "Recover Email",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.onError,
                      size: 23,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
