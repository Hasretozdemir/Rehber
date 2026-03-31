class Contact {
  final String id;
  final String name;
  final String departmentId;
  final String departmentName;
  final String internalNumber;
  final String? mobileNumber;
  final String? role;
  final String? email;
  final String? avatarInitials;
  bool isFavorite;

  Contact({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
    required this.internalNumber,
    this.mobileNumber,
    this.role,
    this.email,
    this.avatarInitials,
    this.isFavorite = false,
  });

  String get initials {
    if (avatarInitials != null) return avatarInitials!;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Contact copyWith({
    String? id,
    String? name,
    String? departmentId,
    String? departmentName,
    String? internalNumber,
    String? mobileNumber,
    String? role,
    String? email,
    String? avatarInitials,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      internalNumber: internalNumber ?? this.internalNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'internalNumber': internalNumber,
      'mobileNumber': mobileNumber,
      'role': role,
      'email': email,
      'avatarInitials': avatarInitials,
      'isFavorite': isFavorite,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    final rawFavorite = map['isFavorite'];
    return Contact(
      id: map['id'],
      name: map['name'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      internalNumber: map['internalNumber'],
      mobileNumber: map['mobileNumber'],
      role: map['role'],
      email: map['email'],
      avatarInitials: map['avatarInitials'],
      isFavorite: rawFavorite == true || rawFavorite == 1,
    );
  }
}
