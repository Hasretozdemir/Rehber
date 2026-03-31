enum UserRole { admin, user }

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.user,
    this.avatarUrl,
  });

  bool get isAdmin => role == UserRole.admin;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.index,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      role: UserRole.values[map['role'] ?? 1],
      avatarUrl: map['avatarUrl'],
    );
  }
}
