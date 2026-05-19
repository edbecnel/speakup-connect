import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/domain/repositories/report_repository.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _reportsRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.reportsCollection);

  CollectionReference<Map<String, dynamic>> _categoriesRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.categoriesCollection);

  @override
  Future<ReportEntity> submitReport(SubmitReportParams params) async {
    try {
      final reportId = const Uuid().v4();
      final now = DateTime.now();

      // Upload photos first
      final photoUrls = await _uploadPhotos(
        orgId: params.organizationId,
        reportId: reportId,
        photoPaths: params.photoPaths,
      );

      // Generate reference number via Firestore transaction
      final referenceNumber = await _generateReferenceNumber(
        params.organizationId,
      );

      final reportData = {
        'reportId': reportId,
        AppConstants.fieldOrganizationId: params.organizationId,
        'title': params.title,
        'description': params.description,
        AppConstants.fieldCategoryId: params.categoryId,
        AppConstants.fieldStatus: AppConstants.statusSubmitted,
        'priority': ReportPriority.medium.value,
        AppConstants.fieldIsAnonymous: params.isAnonymous,
        'submittedBy': params.isAnonymous ? null : params.submittedBy,
        'submitterDisplayName':
            params.isAnonymous ? null : params.submitterDisplayName,
        'referenceNumber': referenceNumber,
        'photoUrls': photoUrls,
        'adminNotes': [],
        'statusHistory': [
          {
            'fromStatus': null,
            'toStatus': AppConstants.statusSubmitted,
            'changedBy': params.submittedBy ?? 'anonymous',
            'changedAt': FieldValue.serverTimestamp(),
            'note': null,
          }
        ],
        'assignedTo': null,
        'location': null,
        AppConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
        'resolvedAt': null,
      };

      await _reportsRef(params.organizationId).doc(reportId).set(reportData);

      return ReportEntity(
        reportId: reportId,
        organizationId: params.organizationId,
        title: params.title,
        description: params.description,
        categoryId: params.categoryId,
        status: ReportStatus.submitted,
        isAnonymous: params.isAnonymous,
        referenceNumber: referenceNumber,
        photoUrls: photoUrls,
        submittedBy: params.isAnonymous ? null : params.submittedBy,
        submitterDisplayName:
            params.isAnonymous ? null : params.submitterDisplayName,
        createdAt: now,
        updatedAt: now,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(message: e.message, code: e.code);
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Stream<List<ReportEntity>> watchMyReports({
    required String organizationId,
    required String userId,
  }) {
    return _reportsRef(organizationId)
        .where('submittedBy', isEqualTo: userId)
        .orderBy(AppConstants.fieldCreatedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_documentToEntity).toList());
  }

  @override
  Future<ReportEntity> getReportById({
    required String organizationId,
    required String reportId,
  }) async {
    try {
      final doc =
          await _reportsRef(organizationId).doc(reportId).get();
      if (!doc.exists) {
        throw NotFoundException(message: 'Report not found');
      }
      return _documentToEntity(doc);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DatabaseException(message: e.message, code: e.code);
    }
  }

  @override
  Future<List<ReportCategoryEntity>> getCategories(String organizationId) async {
    try {
      final snap = await _categoriesRef(organizationId)
          .where(AppConstants.fieldIsActive, isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return ReportCategoryEntity(
          categoryId: data['categoryId'] as String,
          label: data['label'] as String,
          iconName: data['icon'] as String? ?? 'report',
          colorHex: data['color'] as String?,
          requiresPhoto: data['requiresPhoto'] as bool? ?? false,
          isActive: data['isActive'] as bool? ?? true,
          sortOrder: data['sortOrder'] as int? ?? 99,
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(message: e.message, code: e.code);
    }
  }

  @override
  Stream<List<ReportEntity>> watchAllReports({
    required String organizationId,
    ReportStatus? filterStatus,
    String? filterCategoryId,
  }) {
    Query<Map<String, dynamic>> query = _reportsRef(organizationId)
        .orderBy(AppConstants.fieldCreatedAt, descending: true);

    if (filterStatus != null) {
      query = query.where(AppConstants.fieldStatus, isEqualTo: filterStatus.value);
    }
    if (filterCategoryId != null) {
      query = query.where(AppConstants.fieldCategoryId, isEqualTo: filterCategoryId);
    }

    return query.snapshots().map(
          (snap) => snap.docs.map(_documentToEntity).toList(),
        );
  }

  @override
  Future<void> updateReportStatus({
    required String organizationId,
    required String reportId,
    required ReportStatus newStatus,
    required String changedByUid,
    String? note,
  }) async {
    try {
      final docRef = _reportsRef(organizationId).doc(reportId);
      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        if (!snap.exists) throw NotFoundException(message: 'Report not found');

        final historyEntry = {
          'fromStatus': snap.data()?[AppConstants.fieldStatus],
          'toStatus': newStatus.value,
          'changedBy': changedByUid,
          'changedAt': Timestamp.now(),
          'note': note,
        };

        transaction.update(docRef, {
          AppConstants.fieldStatus: newStatus.value,
          AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
          if (newStatus == ReportStatus.resolved || newStatus == ReportStatus.closed)
            'resolvedAt': FieldValue.serverTimestamp(),
          'statusHistory': FieldValue.arrayUnion([historyEntry]),
        });
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(message: e.message, code: e.code);
    }
  }

  @override
  Future<void> addAdminNote({
    required String organizationId,
    required String reportId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    try {
      final note = {
        'noteId': const Uuid().v4(),
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'createdAt': Timestamp.now(),
      };

      await _reportsRef(organizationId).doc(reportId).update({
        'adminNotes': FieldValue.arrayUnion([note]),
        AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(message: e.message, code: e.code);
    }
  }

  @override
  Future<void> assignReport({
    required String organizationId,
    required String reportId,
    required String adminUid,
  }) async {
    try {
      await _reportsRef(organizationId).doc(reportId).update({
        'assignedTo': adminUid,
        AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(message: e.message, code: e.code);
    }
  }

  // --- Private Helpers ---

  Future<List<String>> _uploadPhotos({
    required String orgId,
    required String reportId,
    required List<String> photoPaths,
  }) async {
    if (photoPaths.isEmpty) return [];

    final urls = <String>[];
    for (final path in photoPaths) {
      try {
        final file = File(path);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.jpg';
        final storageRef = _storage.ref().child(
              AppConstants.reportPhotosStoragePath(orgId, reportId),
            ).child(fileName);

        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();
        urls.add(url);
      } catch (e) {
        // Log but don't fail the entire submission for a photo error
        debugPrint('Photo upload failed: $e');
      }
    }
    return urls;
  }

  /// Generates the next reference number using a Firestore transaction
  /// to ensure uniqueness even under concurrent submissions.
  /// Format: {ORG_CODE}-{YEAR}-{SEQUENCE}
  Future<String> _generateReferenceNumber(String organizationId) async {
    final year = DateTime.now().year;
    final counterDocRef = _firestore
        .collection(AppConstants.organizationsCollection)
        .doc(organizationId)
        .collection('counters')
        .doc('report_$year');

    int sequence = 1;

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(counterDocRef);
      if (snap.exists) {
        sequence = ((snap.data()?['sequence'] as int?) ?? 0) + 1;
      }
      transaction.set(counterDocRef, {'sequence': sequence});
    });

    // Org code comes from the org config — we fetch it directly here
    // to avoid a circular dependency. In production this could be cached.
    final orgDoc = await _firestore
        .collection(AppConstants.organizationsCollection)
        .doc(organizationId)
        .get();
    final orgCode =
        orgDoc.data()?['reportCodePrefix'] as String? ?? 'ORG';

    return AppConstants.formatReferenceNumber(orgCode, year, sequence);
  }

  ReportEntity _documentToEntity(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    DateTime toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    final statusHistory = (data['statusHistory'] as List<dynamic>? ?? [])
        .map((e) => StatusHistoryEntry(
              fromStatus: e['fromStatus'] != null
                  ? ReportStatus.fromValue(e['fromStatus'] as String)
                  : null,
              toStatus: ReportStatus.fromValue(e['toStatus'] as String),
              changedBy: e['changedBy'] as String? ?? '',
              changedAt: toDateTime(e['changedAt']),
              note: e['note'] as String?,
            ))
        .toList();

    final adminNotes = (data['adminNotes'] as List<dynamic>? ?? [])
        .map((e) => AdminNote(
              noteId: e['noteId'] as String,
              authorId: e['authorId'] as String,
              authorName: e['authorName'] as String,
              content: e['content'] as String,
              createdAt: toDateTime(e['createdAt']),
            ))
        .toList();

    return ReportEntity(
      reportId: data['reportId'] as String? ?? doc.id,
      organizationId: data[AppConstants.fieldOrganizationId] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      categoryId: data[AppConstants.fieldCategoryId] as String,
      status: ReportStatus.fromValue(data[AppConstants.fieldStatus] as String),
      priority: ReportPriority.fromValue(data['priority'] as String? ?? 'medium'),
      isAnonymous: data[AppConstants.fieldIsAnonymous] as bool? ?? false,
      submittedBy: data['submittedBy'] as String?,
      submitterDisplayName: data['submitterDisplayName'] as String?,
      referenceNumber: data['referenceNumber'] as String?,
      photoUrls: List<String>.from(data['photoUrls'] as List? ?? []),
      adminNotes: adminNotes,
      statusHistory: statusHistory,
      assignedTo: data['assignedTo'] as String?,
      createdAt: toDateTime(data[AppConstants.fieldCreatedAt]),
      updatedAt: toDateTime(data[AppConstants.fieldUpdatedAt]),
      resolvedAt: data['resolvedAt'] != null
          ? toDateTime(data['resolvedAt'])
          : null,
    );
  }
}
