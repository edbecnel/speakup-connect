import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

String _suffixForName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return '.png';
  if (lower.endsWith('.webp')) return '.webp';
  if (lower.endsWith('.gif')) return '.gif';
  return '.jpg';
}

/// Copies a gallery/camera pick to a stable temp path for preview and upload.
Future<String?> persistPickedImage(XFile picked) async {
  final suffix = _suffixForName(picked.name);
  final dest = File(
    '${Directory.systemTemp.path}/picked_${DateTime.now().millisecondsSinceEpoch}$suffix',
  );

  try {
    await picked.saveTo(dest.path);
    if (await dest.exists() && await dest.length() > 0) {
      return dest.path;
    }
  } catch (e, st) {
    debugPrint('persistPickedImage saveTo failed: $e\n$st');
  }

  try {
    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) return null;
    await dest.writeAsBytes(bytes, flush: true);
    if (await dest.exists() && await dest.length() > 0) {
      return dest.path;
    }
  } catch (e, st) {
    debugPrint('persistPickedImage readAsBytes failed: $e\n$st');
  }

  return null;
}
