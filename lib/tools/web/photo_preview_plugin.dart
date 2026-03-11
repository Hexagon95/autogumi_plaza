import 'package:flutter/material.dart';
import 'package:autogumi_plaza/global.dart';

class PhotoPreviewPlugin {
  static Widget buildPhotoPreview({
    required BuildContext context,
    required NextRoute currentRoute,
    required int selectedIndex,
    required String? imagePath,
  }) {
    return const Center(
      child: Text(
        'Fotó előnézet weben jelenleg nem elérhető.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}