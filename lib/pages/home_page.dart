import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/const/app_colors.dart';
import 'package:reels/pages/camera_review_page.dart';
import 'package:reels/pages/chat_list_page.dart';
import 'package:reels/providers/chat_provider.dart';
import 'package:reels/providers/post_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/gradient_background.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/post_widget.dart';
import 'package:reels/widgets/surface_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late PageController _pageCameraController;
  final _commentController = TextEditingController();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  late ValueNotifier<int> _currentHorizontalPageNotifier;
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isFocusedTextField = ValueNotifier(false);
  final ValueNotifier<bool> _canShowCommentBox = ValueNotifier(false);
  final ValueNotifier<bool> _hasTextInComment = ValueNotifier(false);
  final ValueNotifier<String> _hintTextNotifier =
      ValueNotifier("say something about it");
  late StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageCameraController = PageController();
    _currentHorizontalPageNotifier = ValueNotifier<int>(0);
    _pageCameraController.addListener(_onPageChanged);
    _focusNode.addListener(_onFocusChanged);
    var keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      _isFocusedTextField.value = visible;
    });
    _hintTextNotifier.value = "say something about it";
    _commentController.addListener(() {
      _hasTextInComment.value = _commentController.text.isNotEmpty;
    });
    _initializeCamera();
  }

  void _onFocusChanged() {
    _isFocusedTextField.value = _focusNode.hasFocus;
    final currentPage = _pageCameraController.page?.round() ?? 0;

    if (_focusNode.hasFocus && currentPage > 0) {
      final postProvider = context.read<PostProvider>();
      if (postProvider.listPosts.isNotEmpty &&
          currentPage - 1 < postProvider.listPosts.length) {
        final currentPost = postProvider.listPosts[currentPage - 1];
        _hintTextNotifier.value = "send to ${currentPost.owner.name}";
      }
    } else {
      _hintTextNotifier.value = "say something about it";
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      if (mounted) setState(() {});
    }
  }

  void _onPageChanged() {
    final currentPage = _pageCameraController.page?.round() ?? 0;
    _currentHorizontalPageNotifier.value = currentPage;
    log("${_currentHorizontalPageNotifier.value.toString()}== $currentPage");
    _commentController.clear();
    if (currentPage != 0) {
      _cameraController?.dispose();
      _cameraController = null;
      _canShowCommentBox.value =
          context.read<PostProvider>().listPosts[currentPage - 1].owner.uid !=
              context.read<UserProvider>().userData!.uid;
      setState(() {});
    } else if (_cameraController == null) {
      _initializeCamera();
    }
  }

  Future<void> _updateCameraController(int cameraIndex) async {
    if (_cameras.isEmpty) return;
    await _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log("AppLifecycleState: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        log("App is in foreground");
        break;
      case AppLifecycleState.inactive:
        log("App is inactive");
        context.read<UserProvider>().setStatusActivity(isOnline: true);
        break;
      case AppLifecycleState.paused:
        log("App is in background");
        context.read<UserProvider>().setStatusActivity(isOnline: false);
        break;
      case AppLifecycleState.detached:
        log("App is detached (may be terminating)");
        break;
      case AppLifecycleState.hidden:
        log("App is detached (may be terminating)");
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageCameraController.removeListener(_onPageChanged);
    _pageCameraController.dispose();
    _currentHorizontalPageNotifier.dispose();
    _cameraController?.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _keyboardSubscription.cancel();
    _hasTextInComment.dispose();
    _canShowCommentBox.dispose();
    _hintTextNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: GradientBackground(),
          ),
          Positioned(
            child: PageView.builder(
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
                                  cameras: _cameras,
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
                              valueListenable: _currentHorizontalPageNotifier,
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
                                                color:
                                                    Colors.black.withAlpha(150),
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
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    _canShowCommentBox,
                                                builder:
                                                    (context, value, child) {
                                                  if (value == false) {
                                                    return SizedBox.shrink();
                                                  }
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: Colors.grey
                                                          .withAlpha(100),
                                                    ),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    height: 50,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child:
                                                        ValueListenableBuilder<
                                                            String>(
                                                      valueListenable:
                                                          _hintTextNotifier,
                                                      builder: (context,
                                                          hintText, child) {
                                                        return ValueListenableBuilder<
                                                            bool>(
                                                          valueListenable:
                                                              _hasTextInComment,
                                                          builder: (context,
                                                              hasText, child) {
                                                            return TextField(
                                                              focusNode:
                                                                  _focusNode,
                                                              controller:
                                                                  _commentController,
                                                              onSubmitted:
                                                                  (value) {
                                                                _focusNode
                                                                    .unfocus();
                                                              },
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .done,
                                                              style: TextStyle(
                                                                color: _isFocusedTextField
                                                                        .value
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                              cursorColor:
                                                                  _isFocusedTextField
                                                                          .value
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .grey,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    hintText,
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                                suffixIcon: hasText
                                                                    ? IconButtonWidget(
                                                                        onTap:
                                                                            () async {
                                                                          final res = await context.read<ChatProvider>().addTextReactPost(
                                                                              content: context.read<PostProvider>().listPosts[currentPage - 1].image,
                                                                              contentReactPost: _commentController.text,
                                                                              receiverId: context.read<PostProvider>().listPosts[currentPage - 1].owner.uid);
                                                                          if (res) {
                                                                            UtilsService.showSnackBar(
                                                                                context: context,
                                                                                content: "has sent react");
                                                                            _commentController.clear();
                                                                            _focusNode.unfocus();
                                                                          }
                                                                        },
                                                                        hugeIcon:
                                                                            HugeIcons.strokeRoundedSent,
                                                                        color: Colors
                                                                            .blue,
                                                                      )
                                                                    : null,
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                              if (!isFocused)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
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
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          curve:
                                                              Curves.easeInOut,
                                                        );
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey,
                                                            shape:
                                                                BoxShape.circle,
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
                                                      onTap: () {
                                                        UtilsService.saveImageFromUrl(
                                                            context: context,
                                                            url: context
                                                                .read<
                                                                    PostProvider>()
                                                                .listPosts[
                                                                    _currentHorizontalPageNotifier
                                                                            .value -
                                                                        1]
                                                                .image);
                                                      },
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
                          Positioned(
                            top: MediaQuery.of(context).padding.top,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SurfaceWidget(
                                    child: AvatarWidget(
                                      pathImage: context
                                          .read<UserProvider>()
                                          .userData!
                                          .image,
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushNamed(AppRoute.profile);
                                      },
                                      size: 50,
                                    ),
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      SurfaceWidget(
                                        child: IconButtonWidget(
                                          hugeIcon:
                                              HugeIcons.strokeRoundedSearch01,
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushNamed(AppRoute.search);
                                          },
                                        ),
                                      ),
                                      SurfaceWidget(
                                        child: IconButtonWidget(
                                          hugeIcon: HugeIcons
                                              .strokeRoundedNotification01,
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                AppRoute.notification);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const ChatListPage();
              },
            ),
          ),
        ],
      ),
    );
  }
}
