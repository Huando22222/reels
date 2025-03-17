import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/const/app_colors.dart';
import 'package:reels/models/response.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/image_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  final FirebaseService _authService = FirebaseService();
  final ImageService _imageService = ImageService();
  final ValueNotifier<bool> _isNameEmpty = ValueNotifier(false);
  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<UserProvider>().userData!.name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _isNameEmpty.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(UserProvider userProvider) async {
    if (_isUpdating || _nameController.text.isEmpty) return;

    setState(() => _isUpdating = true);

    try {
      String? imageUrl = userProvider.userData?.image;
      if (_imageFile != null) {
        imageUrl = await _imageService.uploadImage(
          filePath: _imageFile!.path,
          folderPath: "users/${userProvider.userData!.email}",
        );
      }

      final updatedUser = userProvider.userData!.copyWith(
        image: imageUrl,
        name: _nameController.text.trim(),
      );

      final ResponseModel res =
          await _authService.upsertUser(user: updatedUser);
      if (res.success) {
        await userProvider.getUserData();
        _showSnackBar(res.msg, isError: false);
      } else {
        _showSnackBar(res.msg, isError: true);
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e", isError: true);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.darkError : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _pickImage() {
    _imageService.showImagePickerOptions(
      context: context,
      onImagePicked: (file) {
        if (file != null) {
          setState(() => _imageFile = file);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return ScreenWrapperWidget(
      title: "Edit Profile",
      actions: [
        IconButtonWidget(
          hugeIcon: HugeIcons.strokeRoundedAllBookmark,
          onTap: _isUpdating ? null : () => _updateProfile(userProvider),
          color: _isUpdating ? Colors.grey : null,
        ),
      ],
      child: Column(
        children: [
          const SizedBox(height: 20),
          AvatarWidget(
            pathImage: userProvider.userData!.image,
            imageFile: _imageFile,
            size: 150,
            isCircle: true,
            onTap: _pickImage,
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _isNameEmpty,
            builder: (context, isEmpty, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isEmpty ? AppColors.darkError : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedTag01,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your name",
                        ),
                        onChanged: (value) =>
                            _isNameEmpty.value = value.isEmpty,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
