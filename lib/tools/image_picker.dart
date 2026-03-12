import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:autogumi_plaza/routes/photo_preview.dart';

class ImagePicker extends StatefulWidget {
  const ImagePicker({super.key});

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  bool _isLoading = false;

  Future<void> _pickAndUploadFile() async {
    setState(() => _isLoading = true);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
      allowMultiple: false,
      withData: true,
    );

    if (!mounted) return;

    if (result == null || result.files.isEmpty) {
      Navigator.of(context).pop(null);
      return;
    }

    final file = result.files.single;
    final Uint8List? bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      Navigator.of(context).pop(null);
      return;
    }

    try {
      // same shared state used by camera/preview flow
      PhotoPreviewState.imagePath = null;
      PhotoPreviewState.imageBase64 = base64Encode(bytes);
      PhotoPreviewState.editingController.text = '';
      PhotoPreviewState.isSignature = false;

      // same save sequence as preview's save button
      await DataManager().beginProcess;
      PhotoPreviewState.editingController.text = '';
      await DataManager(quickCall: QuickCall.askPhotos).beginQuickCall;
      Global.routeBack;

      final saved = DataManager.dataQuickCall[2].isNotEmpty
          ? DataManager.dataQuickCall[2].last
          : null;

      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  @override
  void initState() {
    super.initState();
    _pickAndUploadFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kép file kiválasztása'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Feltöltés...'),
      ),
    );
  }
}