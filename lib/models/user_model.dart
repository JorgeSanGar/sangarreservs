class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final String? orgId;
  final String? orgName;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.orgId,
    this.orgName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'worker',
      orgId: json['org_id'] as String?,
      orgName: json['org_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory UserModel.fromSupabaseUserData(Map<String, dynamic> json) {
    // Handle nested user data from Supabase joins
    final userData = json['users'] as Map<String, dynamic>?;
    final rawMetaData =
        userData?['raw_user_meta_data'] as Map<String, dynamic>?;

    return UserModel(
      id: json['user_id'] as String,
      email: userData?['email'] as String ?? '',
      fullName: rawMetaData?['full_name'] as String?,
      role: json['role'] as String? ?? 'worker',
      orgId: json['org_id'] as String?,
      orgName: json['org_name'] as String?,
      createdAt: DateTime.parse(json['joined_at'] as String),
      updatedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'org_id': orgId,
      'org_name': orgName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? orgId,
    String? orgName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      orgId: orgId ?? this.orgId,
      orgName: orgName ?? this.orgName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isManager => role == 'manager' || role == 'admin';
  bool get isWorker => role == 'worker';
  bool get isAdmin => role == 'admin';
}
