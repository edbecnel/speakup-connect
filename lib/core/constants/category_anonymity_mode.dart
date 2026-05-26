/// Controls how the report submission form handles reporter identity for a
/// given report category.
///
/// Configured per-category by the org admin. See DATABASE_DESIGN.md for the
/// full design rationale.
///
/// **Design note:** A fourth mode where the counselor can silently unmask an
/// anonymous reporter was explicitly rejected — it destroys trust when the
/// counselor initiates contact and students learn the anonymous label was false.
/// Only these three modes are valid.
enum CategoryAnonymityMode {
  /// Reporter freely chooses Anonymous or Identified.
  ///
  /// The anonymous toggle is shown as normal. Default for most categories
  /// (bullying, harassment, safety, suggestions, etc.).
  open,

  /// Anonymous option is disabled. Reporter must submit with their identity.
  ///
  /// The anonymous toggle is hidden. A notice is shown explaining why
  /// identification is required (e.g. "Your name will be shared with the
  /// guidance counselor so they can support you directly."). Use for
  /// categories where the assigned counselor must follow up in person.
  identified,

  /// Report is genuinely anonymous. An optional counselor contact opt-in is
  /// offered after submission.
  ///
  /// The anonymous toggle is hidden (all submissions are anonymous). After
  /// a successful submit, a `VoluntaryContactSheet` is shown offering the
  /// reporter the option to leave their name for the counselor to reach out
  /// privately. The opt-in is stored as a separate
  /// `counselorContactRequests/{requestId}` document with no link to the
  /// report. Use for mental health and personal concern categories where
  /// maintaining full trust is critical.
  voluntaryContact;

  // ── Serialization ──────────────────────────────────────────────────────────

  /// The string stored in the Firestore category document.
  String get key => switch (this) {
        CategoryAnonymityMode.open => 'open',
        CategoryAnonymityMode.identified => 'identified',
        CategoryAnonymityMode.voluntaryContact => 'voluntary_contact',
      };

  /// Deserializes a Firestore string back to a [CategoryAnonymityMode].
  /// Returns [open] for unknown or null values (safe default).
  static CategoryAnonymityMode fromKey(String? key) => switch (key) {
        'identified' => CategoryAnonymityMode.identified,
        'voluntary_contact' => CategoryAnonymityMode.voluntaryContact,
        _ => CategoryAnonymityMode.open,
      };
}
