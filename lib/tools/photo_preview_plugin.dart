import 'dart:io';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';

class PhotoPreviewPlugin {
  static Widget buildPhotoPreview({
    required BuildContext context,
    required NextRoute currentRoute,
    required int selectedIndex,
    required String? imagePath,
  }) {
    switch (currentRoute) {
      case NextRoute.photoCheck:
        return Center(
          child: Image.network(
            '${DataManager.rootPath}${DataManager.dataQuickCall[2][selectedIndex]['filename']}',
          ),
        );

      default:
        return Center(
          child: (imagePath == null)
              ? const Text(
                  'Még nincs készítve fotó ehhez',
                  style: TextStyle(color: Color.fromARGB(255, 200, 200, 200)),
                )
              : Image.file(File(imagePath)),
        );
    }
  }
}