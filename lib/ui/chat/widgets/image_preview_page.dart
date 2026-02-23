import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shiba/l10n/app_localizations.dart';

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
            tooltip: S.of(context).saveImageCopy,
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
            SnackBar(content: Text(S.of(context).imageNotExist), behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }

      // Save a copy to a user-accessible directory (Downloads or Documents)
      final saveDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Pictures/Shiba')
          : await getApplicationDocumentsDirectory();

      if (Platform.isAndroid && !await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final ext = p.extension(imagePath).isNotEmpty
          ? p.extension(imagePath)
          : '.jpg';
      final destName = 'shiba_${DateTime.now().millisecondsSinceEpoch}$ext';
      final destPath = p.join(
        Platform.isAndroid ? saveDir.path : saveDir.path,
        destName,
      );

      await file.copy(destPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Platform.isAndroid
                ? S.of(context).imageSavedAndroid
                : S.of(context).imageSavedIos(destName)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).saveFailed('$e')), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
