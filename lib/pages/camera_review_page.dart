import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reels/providers/post_provider.dart';
import 'package:reels/widgets/icon_button_widget.dart';

class CameraReviewPage extends StatefulWidget {
  final CameraController? cameraController;
  final List<CameraDescription> cameras;
  final Future<void> Function(int) onCameraSwitch;

  const CameraReviewPage({
    super.key,
    this.cameraController,
    required this.cameras,
    required this.onCameraSwitch,
  });

  @override
  State<CameraReviewPage> createState() => _CameraReviewPageState();
}

class _CameraReviewPageState extends State<CameraReviewPage> {
  File? _capturedImage;
  bool _isCapturing = false;
  int _currentCameraIndex = 0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _capturedImage != null
                  ? Image.file(_capturedImage!, fit: BoxFit.cover)
                  : (widget.cameraController == null ||
                          !widget.cameraController!.value.isInitialized)
                      ? const Center(child: CircularProgressIndicator())
                      : CameraPreview(widget.cameraController!),
            ),
          ),
        ),
        if (_capturedImage == null && widget.cameraController != null)
          Positioned(
            bottom: 50,
            right: 20,
            child: IconButtonWidget(
              hugeIcon: HugeIcons.strokeRoundedExchange01,
              color: Colors.grey,
              onTap: _switchCamera,
              size: 32.0,
            ),
          ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_capturedImage != null) ...[
                IconButtonWidget(
                  hugeIcon: HugeIcons.strokeRoundedImageDelete01,
                  color: Colors.grey,
                  onTap: _resetCamera,
                  size: 32.0,
                ),
                IconButtonWidget(
                  hugeIcon: HugeIcons.strokeRoundedSent,
                  color: Colors.grey,
                  onTap: () async {
                    if (_isUploading) return;
                    _isUploading = true;
                    final result = await context
                        .read<PostProvider>()
                        .createPost(
                            imagePath: _capturedImage!.path, context: context);
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('post success!')),
                      );
                      _resetCamera();
                    }
                    _isUploading = false;
                  },
                  size: 32.0,
                ),
                IconButtonWidget(
                  hugeIcon: HugeIcons.strokeRoundedDownload04,
                  color: Colors.grey,
                  onTap: _saveImage,
                  size: 32.0,
                ),
              ] else ...[
                InkWell(
                  onTap: _isCapturing ? null : _takePicture,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _switchCamera() async {
    if (widget.cameraController == null ||
        _isCapturing ||
        widget.cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
    await widget.onCameraSwitch(_currentCameraIndex);
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (widget.cameraController == null ||
        !widget.cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final XFile file = await widget.cameraController!.takePicture();
      setState(() {
        _capturedImage = File(file.path);
        _isCapturing = false;
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
      setState(() => _isCapturing = false);
    }
  }

  void _resetCamera() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _saveImage() async {
    if (_capturedImage == null) return;

    try {
      await Gal.putImage(_capturedImage!.path).then(
        (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved!')),
          );
        },
      );
    } on GalException catch (e) {
      log(e.type.message);
    }
  }
}
