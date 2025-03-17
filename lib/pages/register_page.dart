import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:reels/config/extension.dart';
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
  bool _validEmail = true;
  bool _validPassword = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

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
                Spacer(),
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
                  hintText: "password",
                  isValid: _validPassword,
                ),
                const Spacer(),
                TextFieldWidget(
                  controller: _confirmPasswordController,
                  icon: HugeIcons.strokeRoundedLockPassword,
                  hintText: "confirm password",
                  isValid: _validPassword,
                ),
                const Spacer(),
                SizedBox(
                  width: size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 5,
                    ),
                    onPressed: () async {
                      setState(() {
                        _validEmail = _emailController.text.isNotEmpty &&
                            _emailController.text.isValidEmail();
                        _validPassword = _isValidPassword(
                          _passwordController.text,
                          _confirmPasswordController.text,
                        );
                      });
                      if (!_validEmail || !_validPassword) return;
                      setState(() {
                        _isLoading = true;
                      });
                      final res =
                          await _authService.createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text);
                      if (res != null) {
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Email or password is invalid\nOr your email have already been created. \ntry recover it")),
                        );
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: !_isLoading
                        ? Text(
                            "Register",
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
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

//////////////////////////
//  TextFieldWidget(
//                 controller: _emailController,
//                 icon: HugeIcons.strokeRoundedMail01,
//                 hintText: "Email",
//                 isValid: _validEmail,
//               ),
//               TextFieldWidget(
//                 controller: _passwordController,
//                 icon: HugeIcons.strokeRoundedLockPassword,
//                 hintText: "password",
//                 isValid: _validPassword,
//               ),
//               TextFieldWidget(
//                 controller: _confirmPasswordController,
//                 icon: HugeIcons.strokeRoundedLockPassword,
//                 hintText: "confirm password",
//                 isValid: _validPassword,
//               ),
//               SizedBox(
//                 width: size.width * 0.8,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(
//                       vertical: 16,
//                     ),
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     elevation: 5,
//                   ),
//                   onPressed: () async {
//                     setState(() {
//                       _validEmail = _emailController.text.isNotEmpty &&
//                           _emailController.text.isValidEmail();
//                       _validPassword = _isValidPassword(
//                         _passwordController.text,
//                         _confirmPasswordController.text,
//                       );
//                     });
//                     if (!_validEmail || !_validPassword) return;
//                     setState(() {
//                       _isLoading = true;
//                     });
//                     final res =
//                         await _authService.createUserWithEmailAndPassword(
//                             email: _emailController.text,
//                             password: _passwordController.text);
//                     if (res != null) {
//                       Navigator.of(context).pop();
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                             content: Text(
//                                 "Email or password is invalid\nOr your email have already been created. \ntry recover it")),
//                       );
//                     }
//                     setState(() {
//                       _isLoading = false;
//                     });
//                   },
//                   child: !_isLoading
//                       ? Text(
//                           "Register",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Theme.of(context).colorScheme.onPrimary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : SpinKitThreeBounce(
//                           color: Theme.of(context).colorScheme.onError,
//                           size: 23,
//                         ),
//                 ),
//               ),
  bool _isValidPassword(String password, String confirmPassword) {
    return password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        password.length >= 6;
  }
}
