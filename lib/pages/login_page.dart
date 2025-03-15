import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/config/extension.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/widgets/text_field_widget.dart';
import 'package:rive/rive.dart' as rive;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
// with SingleTickerProviderStateMixin
{
  final FirebaseService _authService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _validEmail = true;
  bool _validPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // AnimatedBackground(
          //   vsync: this,
          //   behaviour: RandomParticleBehaviour(
          //     options: ParticleOptions(
          //       spawnMaxRadius: 300,
          //       spawnMinRadius: 50,
          //       particleCount: 3,
          //       spawnMinSpeed: 15,
          //       spawnMaxSpeed: 40,
          //       baseColor: Colors.blue,
          //     ),
          //   ),
          //   child: Container(
          //     color: Colors.transparent,
          //   ),
          // ),
          // Positioned.fill(
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          //     child: SizedBox(),
          //   ),
          // ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: size.height,
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
                    const Spacer(),
                    Container(
                      constraints:
                          BoxConstraints(maxHeight: size.height * 0.25),
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
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                      ),
                    ),
                    Spacer(),
                    TextFieldWidget(
                      controller: _emailController,
                      hintText: "Email",
                      isValid: _validEmail,
                      icon: HugeIcons.strokeRoundedMail01,
                    ),
                    Spacer(),
                    TextFieldWidget(
                      controller: _passwordController,
                      hintText: "password",
                      isValid: _validPassword,
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AppRoute.recoverEmail);
                        },
                        child: Text(
                          "Forgot?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      icon: HugeIcons.strokeRoundedLockPassword,
                    ),
                    Spacer(),
                    SizedBox(
                      width: size.width * 0.8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 5,
                        ),
                        onPressed: () async {
                          final auth =
                              await _authService.signInWithEmailPassword(
                            // email: 'huando.work@gmail.com',
                            email: 'huando22222@gmail.com',
                            password: '123456',
                          );
                          setState(() {
                            _validEmail = _emailController.text.isNotEmpty &&
                                _emailController.text.isValidEmail();
                            _validPassword =
                                _passwordController.text.isNotEmpty;
                          });

                          if (!_validEmail || !_validPassword) return;

                          setState(() {
                            _isLoading = true;
                          });

                          // final auth =
                          //     await _authService.signInWithEmailPassword(
                          //   email: _emailController.text,
                          //   password: _passwordController.text,
                          // );

                          setState(() {
                            _isLoading = false;
                          });

                          if (auth == null) {
                            //
                          }
                        },
                        child: !_isLoading
                            ? Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoute.register);
                          },
                          child: Text(
                            "Register",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    // fontWeight: FontWeight.bold,
                                    // fontSize: 32,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.dotted,
                                    fontStyle: FontStyle.italic),
                          ),
                        ),
                        Text(
                          "Or, login with ...",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              elevation: 7,
                            ),
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Image.asset("assets/icons/google.png"),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              elevation: 7,
                            ),
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Image.asset("assets/icons/facebook.png"),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              elevation: 7,
                            ),
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Image.asset("assets/icons/apple.png"),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
