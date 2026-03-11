// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:ota_update/ota_update.dart';
import 'package:autogumi_plaza/data_manager.dart';

class OtaPlugin {
  Future<void> tryOtaUpdate({
    required void Function(int progress) onProgress,
  }) async {
    try {
      final ota = OtaUpdate();

      if (kDebugMode) {
        final abi = await ota.getAbi();
        print('ABI Platform: $abi');
      }

      ota.execute(
        'https://app.mosaic.hu/ota/szerviz_mezandmol/${DataManager.actualVersion}/app-release.apk',
        destinationFilename: 'app-release.apk',
      ).listen((event) {
        final value = event.value;
        if (value == null || value.isEmpty) return;

        final progress = int.tryParse(value) ?? 0;
        onProgress(progress);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to make OTA update. Details: $e');
      }
    }
  }
}