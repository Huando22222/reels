import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/pages/camera_review_page.dart';
import 'package:reels/pages/chat_list_page.dart';
import 'package:reels/providers/post_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/post_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageCameraController;
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  late ValueNotifier<int> _currentPageNotifier;
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isFocusedTextField = ValueNotifier(false);
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _pageCameraController = PageController();
    _currentPageNotifier = ValueNotifier<int>(0);
    _pageCameraController.addListener(_onPageChanged);
    _focusNode.addListener(_onFocusChanged);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      _isFocusedTextField.value = visible;
      log('Keyboard visibility update. Is visible: $visible');
    });
    _initializeCamera();
  }

  void _onFocusChanged() {
    _isFocusedTextField.value = _focusNode.hasFocus;
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      if (mounted) setState(() {});
    }
  }

  void _onPageChanged() {
    final currentPage = _pageCameraController.page?.round() ?? 0;
    _currentPageNotifier.value = currentPage;
    if (currentPage != 0) {
      _cameraController?.dispose();
      _cameraController = null;
      setState(() {});
    } else if (_cameraController == null) {
      _initializeCamera();
    }
  }

  Future<void> _updateCameraController(int cameraIndex) async {
    if (cameras.isEmpty) return;
    await _cameraController?.dispose();
    _cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageCameraController.removeListener(_onPageChanged);
    _pageCameraController.dispose();
    _currentPageNotifier.dispose();
    _cameraController?.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: AvatarWidget(
            pathImage: context.read<UserProvider>().userData!.image,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoute.profile);
            },
            size: 50,
          ),
        ),
        actions: [
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedSearchArea,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoute.search);
            },
          ),
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedNotification01,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoute.notification);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Consumer<PostProvider>(
              builder: (context, value, child) {
                return Stack(
                  children: [
                    PageView.builder(
                      controller: _pageCameraController,
                      scrollDirection: Axis.vertical,
                      itemCount: value.listPosts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return CameraReviewPage(
                            cameraController: _cameraController,
                            cameras: cameras,
                            onCameraSwitch: _updateCameraController,
                          );
                        }
                        if (value.listPosts.isNotEmpty) {
                          return PostWidget(
                            post: value.listPosts[index - 1],
                          );
                        } else {
                          return const Center(
                              child: Text("No posts available"));
                        }
                      },
                    ),
                    ValueListenableBuilder(
                        valueListenable: _currentPageNotifier,
                        builder: (context, isFocused, child) {
                          final currentPage =
                              _pageCameraController.page?.round() ?? 0;
                          if (currentPage == 0) {
                            return const SizedBox.shrink();
                          }
                          return ValueListenableBuilder(
                            valueListenable: _isFocusedTextField,
                            builder: (context, isFocused, child) {
                              return Stack(
                                children: [
                                  if (isFocused)
                                    GestureDetector(
                                      onTap: () {
                                        _focusNode.unfocus();
                                      },
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 1,
                                          sigmaY: 1,
                                        ),
                                        child: Container(
                                          color: Colors.black.withAlpha(150),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        10,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.grey.withAlpha(100),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextField(
                                            focusNode: _focusNode,
                                            onSubmitted: (value) {
                                              _focusNode.unfocus();
                                            },
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "say something about it",
                                              border: InputBorder.none,
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        if (!isFocused)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButtonWidget(
                                                hugeIcon: HugeIcons
                                                    .strokeRoundedArtboard,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _pageCameraController
                                                      .animateTo(
                                                    0,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.red,
                                                        width: 4,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButtonWidget(
                                                hugeIcon: HugeIcons
                                                    .strokeRoundedDownload04,
                                                color: Colors.grey,
                                                onTap: () {},
                                                size: 32.0,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                  ],
                );
              },
            );
          }
          return const ChatListPage();
        },
      ),
    );
  }
}
