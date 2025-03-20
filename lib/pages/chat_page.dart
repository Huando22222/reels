import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/models/message.dart';
import 'package:reels/models/user.dart';
import 'package:reels/pages/image_view_page.dart';
import 'package:reels/providers/chat_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/image_service.dart';
import 'package:reels/services/push_notification_service.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  UserModel? _otherUserData;
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<bool> _hasText = ValueNotifier(false);
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_otherUserData == null) {
      _otherUserData = ModalRoute.of(context)!.settings.arguments as UserModel;
      context
          .read<ChatProvider>()
          .listenForMessage(receiverId: _otherUserData!.uid);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    context.read<ChatProvider>().dispose();
    _hasText.dispose();
    super.dispose();
  }

  Future<void> handleSendImage() async {
    if (_isSending) return;

    final ImageService imageService = ImageService();
    imageService.showImagePickerOptions(
      context: context,
      onImagePicked: (file) async {
        if (file != null) {
          setState(() {
            _isSending = true;
          });

          try {
            final success = await context.read<ChatProvider>().addImageMessage(
                  filePath: file.path,
                  receiverId: _otherUserData!.uid.trim(),
                  receiverEmail: _otherUserData!.email,
                );
            if (success) {
              _pushNotificationService.sendNotificationToSelectedUser(
                deviceToken: _otherUserData!.token,
                context: context,
                title: _otherUserData!.name,
                body: "Sent an image",
                data: {},
              );
            } else {
              UtilsService.showSnackBar(
                context: context,
                content: 'Can\'t send Image now',
                isError: true,
              );
            }
          } finally {
            setState(() {
              _isSending = false;
            });
          }
        }
      },
    );
  }

  Future<void> handleSendMessage() async {
    if (!_hasText.value || _isSending || _messageController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final success = await context.read<ChatProvider>().addTextMessage(
            content: _messageController.text,
            receiverId: _otherUserData!.uid.trim(),
          );
      if (mounted) {
        if (success) {
          _pushNotificationService.sendNotificationToSelectedUser(
            deviceToken: _otherUserData!.token,
            context: context,
            title: _otherUserData!.name,
            body: _messageController.text,
            data: {},
          );
          _messageController.clear();
          _hasText.value = false;
        } else {
          UtilsService.showSnackBar(
            context: context,
            content: 'Can\'t send message now',
            isError: true,
          );
        }

        FocusScope.of(context).unfocus();
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapperWidget(
      showBackButton: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 10),
          child: AvatarWidget(
            pathImage: _otherUserData!.image,
            size: 50,
          ),
        ),
      ],
      title: _otherUserData!.name,
      child: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.separated(
                  controller: chatProvider.scrollController,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final bool isAuthMessage =
                        chatProvider.messages[index].senderId ==
                            context.read<UserProvider>().userData!.uid;

                    if (chatProvider.messages[index].messageType ==
                        MessageType.text) {
                      return _buildTextMessage(
                          content: chatProvider.messages[index].content,
                          isAuthMessage: isAuthMessage,
                          textType: chatProvider.messages[index].messageType,
                          context: context);
                    }
                    if (chatProvider.messages[index].messageType ==
                        MessageType.image) {
                      return _buildImageMessage(
                          content: chatProvider.messages[index].content,
                          isAuthMessage: isAuthMessage,
                          textType: chatProvider.messages[index].messageType,
                          context: context);
                    }
                    if (chatProvider.messages[index].messageType ==
                        MessageType.reactPost) {
                      return _buildReactPostMessage(
                          contentReactPost:
                              chatProvider.messages[index].contentReactPost!,
                          content: chatProvider.messages[index].content,
                          isAuthMessage: isAuthMessage,
                          textType: chatProvider.messages[index].messageType,
                          context: context);
                    }
                    return null;
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 4.0),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (text) {
                      _hasText.value = text.trim().isNotEmpty;
                    },
                    decoration: InputDecoration(
                      hintText: "Aa",
                      hintStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButtonWidget(
                  onTap: handleSendImage,
                  hugeIcon: HugeIcons.strokeRoundedAlbum01,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _hasText,
                  builder: (context, hasText, child) {
                    return IconButtonWidget(
                      onTap: handleSendMessage,
                      hugeIcon: HugeIcons.strokeRoundedSent,
                      color: hasText
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerMessage({
    required Widget child,
    required bool isAuthMessage,
    required MessageType textType,
    required BuildContext context,
  }) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: isAuthMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.7),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: textType == MessageType.text
            ? EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              )
            : EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: isAuthMessage
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextMessage({
    required String content,
    required bool isAuthMessage,
    required MessageType textType,
    required BuildContext context,
  }) {
    return _buildContainerMessage(
      isAuthMessage: isAuthMessage,
      textType: textType,
      context: context,
      child: Text(
        content,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _buildImageMessage({
    required String content,
    required bool isAuthMessage,
    required MessageType textType,
    required BuildContext context,
  }) {
    final size = MediaQuery.of(context).size;
    return _buildContainerMessage(
      isAuthMessage: isAuthMessage,
      textType: textType,
      context: context,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewPage(
                imageUrl: content,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            content,
            width: textType == MessageType.image
                ? size.width * 0.5
                : size.width * 0.25,
            height: textType == MessageType.image
                ? size.width * 0.5
                : size.width * 0.25,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                decoration: BoxDecoration(),
                width: textType == MessageType.image
                    ? size.width * 0.5
                    : size.width * 0.25,
                height: textType == MessageType.image
                    ? size.width * 0.5
                    : size.width * 0.25,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: textType == MessageType.image
                    ? size.width * 0.5
                    : size.width * 0.25,
                height: textType == MessageType.image
                    ? size.width * 0.5
                    : size.width * 0.25,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReactPostMessage({
    required String content,
    required String contentReactPost,
    required bool isAuthMessage,
    required MessageType textType,
    required BuildContext context,
  }) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        _buildImageMessage(
            content: content,
            isAuthMessage: isAuthMessage,
            textType: textType,
            context: context),
        _buildTextMessage(
            content: contentReactPost,
            isAuthMessage: isAuthMessage,
            textType: textType,
            context: context),
      ],
    );
  }
}
