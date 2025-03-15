import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reels/const/app_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  ImageService._internal();
  static final ImageService _instance = ImageService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  factory ImageService() {
    return _instance;
  }

  Future<String?> uploadImage({
    required String filePath,
    required String folderPath,
  }) async {
    try {
      final file = File(filePath);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

      final String fullPath = await _supabase.storage.from('uploads').upload(
            '$folderPath/$fileName',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return '${AppApi.supabaseURL}/storage/v1/object/public/$fullPath';
    } catch (e) {
      log('error image service upload');
      return null;
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      return await _cropImage(File(pickedFile.path));
    }
    return null;
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Chỉnh sửa ảnh',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Chỉnh sửa ảnh',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  void showImagePickerOptions({
    required BuildContext context,
    required Function(File? file) onImagePicked,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Photos'),
              onTap: () async {
                Navigator.pop(context);
                File? image = await pickImage(ImageSource.gallery);
                onImagePicked(image);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                File? image = await pickImage(ImageSource.camera);
                onImagePicked(image);
              },
            ),
          ],
        );
      },
    );
  }
}
