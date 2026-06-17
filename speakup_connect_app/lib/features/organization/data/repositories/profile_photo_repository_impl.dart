import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/organization/domain/repositories/profile_photo_repository.dart';
import 'package:uuid/uuid.dart';

class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  ProfilePhotoRepositoryImpl({
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  static String _imageContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<String> _uploadFile({
    required String storageBasePath,
    required String localPath,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw const DatabaseException(
        message: 'Image file not found. Try selecting the photo again.',
      );
    }
    final ext = switch (_imageContentType(localPath)) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => 'jpg',
    };
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.$ext';
    final storageRef = _storage.ref().child(storageBasePath).child(fileName);

    await storageRef.putFile(
      file,
      SettableMetadata(contentType: _imageContentType(localPath)),
    );
    return storageRef.getDownloadURL();
  }

  Future<void> _callUploadMemberAvatar({
    required String orgId,
    required String localPath,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw const DatabaseException(
        message: 'Image file not found. Try selecting the photo again.',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const DatabaseException(
        message: 'Could not read that image. Try another photo.',
      );
    }

    try {
      await _functions.httpsCallable('uploadMemberAvatar').call<Map<String, dynamic>>({
        'orgId': orgId,
        'imageBase64': base64Encode(bytes),
        'contentType': _imageContentType(localPath),
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionException(
          message: e.message ?? 'Permission denied',
        );
      }
      if (e.code == 'not-found') {
        throw DatabaseException(
          message:
              'Profile photo upload is not available yet. Ask an admin to deploy the latest cloud functions.',
          code: e.code,
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to upload profile photo',
        code: e.code,
      );
    }
  }

  Future<void> _callSetMemberAvatarUrl({
    required String orgId,
    String? imageUrl,
    bool clear = false,
  }) async {
    try {
      await _functions.httpsCallable('setMemberAvatarUrl').call<Map<String, dynamic>>({
        'orgId': orgId,
        if (clear) 'clearImageUrl': true,
        if (!clear && imageUrl != null) 'imageUrl': imageUrl,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionException(
          message: e.message ?? 'Permission denied',
        );
      }
      if (e.code == 'not-found') {
        throw DatabaseException(
          message:
              'Profile photo service is not available yet. Ask an admin to deploy the latest cloud functions.',
          code: e.code,
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to update profile photo',
        code: e.code,
      );
    }
  }

  Future<void> _callSetOfficialPhotoUrl({
    required String orgId,
    String? studentId,
    String? userId,
    String? imageUrl,
    bool clear = false,
  }) async {
    try {
      await _functions.httpsCallable('setOfficialPhotoUrl').call<Map<String, dynamic>>({
        'orgId': orgId,
        if (studentId != null && studentId.isNotEmpty) 'studentId': studentId,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (clear) 'clearImageUrl': true,
        if (!clear && imageUrl != null) 'imageUrl': imageUrl,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw PermissionException(
          message: e.message ?? 'Permission denied',
        );
      }
      if (e.code == 'not-found') {
        throw DatabaseException(
          message:
              'Official photo service is not available yet. Ask an admin to deploy the latest cloud functions.',
          code: e.code,
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to update official photo',
        code: e.code,
      );
    }
  }

  @override
  Future<void> uploadMemberAvatar({
    required String orgId,
    required String userId,
    required String localPath,
  }) async {
    try {
      await _callUploadMemberAvatar(orgId: orgId, localPath: localPath);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<void> clearMemberAvatar({required String orgId}) async {
    await _callSetMemberAvatarUrl(orgId: orgId, clear: true);
  }

  @override
  Future<void> uploadOfficialPhoto({
    required String orgId,
    required String localPath,
    String? studentId,
    String? userId,
  }) async {
    if ((studentId == null || studentId.isEmpty) &&
        (userId == null || userId.isEmpty)) {
      throw const DatabaseException(
        message: 'Student ID or member account is required.',
      );
    }

    try {
      final basePath = userId != null && userId.isNotEmpty
          ? AppConstants.userOfficialPhotoStoragePath(orgId, userId)
          : AppConstants.rosterOfficialPhotoStoragePath(orgId, studentId!);
      final url = await _uploadFile(
        storageBasePath: basePath,
        localPath: localPath,
      );
      await _callSetOfficialPhotoUrl(
        orgId: orgId,
        studentId: studentId,
        userId: userId,
        imageUrl: url,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unauthorized') {
        throw PermissionException(
          message: e.message ?? 'You do not have permission to upload official photos.',
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to upload official photo',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<void> clearOfficialPhoto({
    required String orgId,
    String? studentId,
    String? userId,
  }) async {
    await _callSetOfficialPhotoUrl(
      orgId: orgId,
      studentId: studentId,
      userId: userId,
      clear: true,
    );
  }
}
