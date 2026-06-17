/// How members may leave a group (configured per group by admin/leader).
enum MemberLeavePolicy {
  /// Member can leave immediately from My Groups.
  voluntary('voluntary'),

  /// Member must submit a reason and wait for leader/admin approval.
  requestRequired('request_required');

  const MemberLeavePolicy(this.value);

  final String value;

  static MemberLeavePolicy fromValue(String? raw) {
    for (final policy in MemberLeavePolicy.values) {
      if (policy.value == raw) return policy;
    }
    return MemberLeavePolicy.requestRequired;
  }

  String get label => switch (this) {
        MemberLeavePolicy.voluntary => 'Leave anytime',
        MemberLeavePolicy.requestRequired => 'Must request to leave',
      };
}

/// Status of a join or leave request document.
enum GroupMembershipRequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  withdrawn('withdrawn');

  const GroupMembershipRequestStatus(this.value);

  final String value;

  static GroupMembershipRequestStatus fromValue(String? raw) {
    for (final status in GroupMembershipRequestStatus.values) {
      if (status.value == raw) return status;
    }
    return GroupMembershipRequestStatus.pending;
  }

  bool get isPending => this == GroupMembershipRequestStatus.pending;
}
