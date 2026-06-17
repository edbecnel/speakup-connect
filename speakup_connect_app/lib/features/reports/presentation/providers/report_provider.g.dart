// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportRepository)
final reportRepositoryProvider = ReportRepositoryProvider._();

final class ReportRepositoryProvider extends $FunctionalProvider<
    ReportRepository,
    ReportRepository,
    ReportRepository> with $Provider<ReportRepository> {
  ReportRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reportRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReportRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportRepository create(Ref ref) {
    return reportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportRepository>(value),
    );
  }
}

String _$reportRepositoryHash() => r'5500c26831c4485fff7594d70bb7c561e1ba93cd';

@ProviderFor(reportCategories)
final reportCategoriesProvider = ReportCategoriesProvider._();

final class ReportCategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<ReportCategoryEntity>>,
        List<ReportCategoryEntity>,
        FutureOr<List<ReportCategoryEntity>>>
    with
        $FutureModifier<List<ReportCategoryEntity>>,
        $FutureProvider<List<ReportCategoryEntity>> {
  ReportCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reportCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reportCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ReportCategoryEntity>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReportCategoryEntity>> create(Ref ref) {
    return reportCategories(ref);
  }
}

String _$reportCategoriesHash() => r'23067f1402d317489e98606ed35dab20bb58e2fd';

@ProviderFor(myReports)
final myReportsProvider = MyReportsProvider._();

final class MyReportsProvider extends $FunctionalProvider<
        AsyncValue<List<ReportEntity>>,
        List<ReportEntity>,
        Stream<List<ReportEntity>>>
    with
        $FutureModifier<List<ReportEntity>>,
        $StreamProvider<List<ReportEntity>> {
  MyReportsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myReportsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myReportsHash();

  @$internal
  @override
  $StreamProviderElement<List<ReportEntity>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ReportEntity>> create(Ref ref) {
    return myReports(ref);
  }
}

String _$myReportsHash() => r'fbb96303af7a3adddc04bd820167edf1fada0c96';

@ProviderFor(MyReportsStatusFilter)
final myReportsStatusFilterProvider = MyReportsStatusFilterProvider._();

final class MyReportsStatusFilterProvider
    extends $NotifierProvider<MyReportsStatusFilter, ReportStatus?> {
  MyReportsStatusFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'myReportsStatusFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$myReportsStatusFilterHash();

  @$internal
  @override
  MyReportsStatusFilter create() => MyReportsStatusFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportStatus? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportStatus?>(value),
    );
  }
}

String _$myReportsStatusFilterHash() =>
    r'9430feb08457d0ebddaea231ca89684c0dacc6a3';

abstract class _$MyReportsStatusFilter extends $Notifier<ReportStatus?> {
  ReportStatus? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportStatus?, ReportStatus?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ReportStatus?, ReportStatus?>,
        ReportStatus?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Holds the multi-step report form state across all 3 wizard steps.

@ProviderFor(SubmitReportFormNotifier)
final submitReportFormProvider = SubmitReportFormNotifierProvider._();

/// Holds the multi-step report form state across all 3 wizard steps.
final class SubmitReportFormNotifierProvider
    extends $NotifierProvider<SubmitReportFormNotifier, SubmitReportFormState> {
  /// Holds the multi-step report form state across all 3 wizard steps.
  SubmitReportFormNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'submitReportFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$submitReportFormNotifierHash();

  @$internal
  @override
  SubmitReportFormNotifier create() => SubmitReportFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmitReportFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmitReportFormState>(value),
    );
  }
}

String _$submitReportFormNotifierHash() =>
    r'5cbace2972e937155d0f7e128a7d69d82e9fd862';

/// Holds the multi-step report form state across all 3 wizard steps.

abstract class _$SubmitReportFormNotifier
    extends $Notifier<SubmitReportFormState> {
  SubmitReportFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SubmitReportFormState, SubmitReportFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SubmitReportFormState, SubmitReportFormState>,
        SubmitReportFormState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SubmitReportNotifier)
final submitReportProvider = SubmitReportNotifierProvider._();

final class SubmitReportNotifierProvider
    extends $NotifierProvider<SubmitReportNotifier, AsyncValue<ReportEntity?>> {
  SubmitReportNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'submitReportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$submitReportNotifierHash();

  @$internal
  @override
  SubmitReportNotifier create() => SubmitReportNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ReportEntity?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ReportEntity?>>(value),
    );
  }
}

String _$submitReportNotifierHash() =>
    r'f0981d5ec949e8e67acfcf84fdddfaa7a07df6a6';

abstract class _$SubmitReportNotifier
    extends $Notifier<AsyncValue<ReportEntity?>> {
  AsyncValue<ReportEntity?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReportEntity?>, AsyncValue<ReportEntity?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ReportEntity?>, AsyncValue<ReportEntity?>>,
        AsyncValue<ReportEntity?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
