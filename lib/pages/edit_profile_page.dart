import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/models/response.dart';
import 'package:reels/providers/app_settings_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/image_service.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/loading_widget.dart';
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
        UtilsService.showSnackBar(context: context, content: res.msg);
      } else {
        UtilsService.showSnackBar(
            context: context, content: res.msg, isError: true);
      }
    } catch (e) {
      UtilsService.showSnackBar(
          context: context, content: "An error occurred: $e", isError: true);
    } finally {
      setState(() => _isUpdating = false);
    }
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: AvatarWidget(
                pathImage: userProvider.userData!.image,
                imageFile: _imageFile,
                size: 150,
                onTap: _pickImage,
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: _isNameEmpty,
              builder: (context, isEmpty, child) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isEmpty
                          ? Theme.of(context).colorScheme.onError
                          : Theme.of(context).colorScheme.surface,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      IconButtonWidget(
                        hugeIcon: HugeIcons.strokeRoundedTag01,
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
            const SizedBox(height: 30),
            Text(
              "App settings",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dark Mode"),
                Consumer<AppSettingsProvider>(
                  builder: (context, appSettings, child) {
                    return Switch(
                      value: appSettings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        appSettings.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
