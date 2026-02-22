import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: '保存到相册',
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图片文件不存在'), behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }
      final bytes = await file.readAsBytes();
      final ext = imagePath.split('.').last.toLowerCase();
      final xFile = XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: 'image/$ext',
        name: 'shiba_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await xFile.saveTo(imagePath);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('图片已保存'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
