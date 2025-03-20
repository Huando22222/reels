import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:reels/config/extension.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/loading_widget.dart';
import 'package:rive/rive.dart' as rive;
import 'package:reels/services/firebase_service.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';
import 'package:reels/widgets/text_field_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseService _authService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _validEmail = false;
  bool _validPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time validation
    _emailController.addListener(() {
      setState(() {
        _validEmail = _emailController.text.trim().isValidEmail();
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _validPassword = _isValidPassword(
          _passwordController.text.trim(),
          _confirmPasswordController.text.trim(),
        );
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _validPassword = _isValidPassword(
          _passwordController.text.trim(),
          _confirmPasswordController.text.trim(),
        );
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String password, String confirmPassword) {
    return password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        password.isValidPassword();
  }

  bool get _isFormValid => _validEmail && _validPassword;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ScreenWrapperWidget(
      showBackButton: true,
      title: "Register",
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: size.height - MediaQuery.of(context).padding.top,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).padding.top + 20,
              horizontal: size.width * 0.06,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: rive.RiveAnimation.asset(
                    'assets/riv/cat.riv',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Register",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                  ),
                ),
                const Spacer(),
                TextFieldWidget(
                  controller: _emailController,
                  icon: HugeIcons.strokeRoundedMail01,
                  hintText: "Email",
                  isValid: _validEmail,
                ),
                const Spacer(),
                TextFieldWidget(
                    controller: _passwordController,
                    icon: HugeIcons.strokeRoundedLockPassword,
                    hintText: "Password",
                    isValid: _validPassword,
                    trailing: IconButtonWidget(
                      onTap: () {
                        UtilsService.showSnackBar(
                            context: context,
                            content:
                                "The password must contain at least 8 characters.");
                      },
                      hugeIcon: HugeIcons.strokeRoundedStickyNote01,
                    )),
                const Spacer(),
                TextFieldWidget(
                  controller: _confirmPasswordController,
                  icon: HugeIcons.strokeRoundedLockPassword,
                  hintText: "Confirm Password",
                  isValid: _validPassword,
                ),
                const Spacer(),
                SizedBox(
                  width: size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 5,
                    ),
                    onPressed: (!_isFormValid || _isLoading)
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            final res = await _authService
                                .createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            if (res != null) {
                              Navigator.of(context).pop();
                            } else {
                              UtilsService.showSnackBar(
                                context: context,
                                isError: true,
                                content:
                                    "Email or password is invalid\nOr your email has already been created.\nTry recovering it.",
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: LoadingWidget(),
                          )
                        : Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
