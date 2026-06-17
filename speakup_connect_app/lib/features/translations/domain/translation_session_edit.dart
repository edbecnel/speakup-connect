/// A single in-context edit queued for review before Firestore commit.
class TranslationSessionEdit {
  const TranslationSessionEdit({
    required this.stringKey,
    required this.sourceValue,
    required this.originalTarget,
    required this.targetValue,
    this.approve = false,
  });

  final String stringKey;
  final String sourceValue;
  final String originalTarget;
  final String targetValue;
  final bool approve;

  bool get isChanged => targetValue.trim() != originalTarget.trim();

  TranslationSessionEdit copyWith({
    String? targetValue,
    bool? approve,
  }) =>
      TranslationSessionEdit(
        stringKey: stringKey,
        sourceValue: sourceValue,
        originalTarget: originalTarget,
        targetValue: targetValue ?? this.targetValue,
        approve: approve ?? this.approve,
      );
}
