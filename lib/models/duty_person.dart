enum PersonnelRole {
  doktor,
  hemsire,
  saglikMemuru,
  sekreter,
  teknisyen,
  guvenlik,
  temizlik,
  diger,
}

extension PersonnelRoleExt on PersonnelRole {
  String get label {
    switch (this) {
      case PersonnelRole.doktor:
        return 'Doktor';
      case PersonnelRole.hemsire:
        return 'Hemşire';
      case PersonnelRole.saglikMemuru:
        return 'Sağlık Memuru';
      case PersonnelRole.sekreter:
        return 'Sekreter';
      case PersonnelRole.teknisyen:
        return 'Teknisyen';
      case PersonnelRole.guvenlik:
        return 'Güvenlik';
      case PersonnelRole.temizlik:
        return 'Temizlik';
      case PersonnelRole.diger:
        return 'Diğer';
    }
  }

  String get emoji {
    switch (this) {
      case PersonnelRole.doktor:
        return '👨‍⚕️';
      case PersonnelRole.hemsire:
        return '👩‍⚕️';
      case PersonnelRole.saglikMemuru:
        return '🏥';
      case PersonnelRole.sekreter:
        return '💼';
      case PersonnelRole.teknisyen:
        return '🔧';
      case PersonnelRole.guvenlik:
        return '🛡️';
      case PersonnelRole.temizlik:
        return '🧹';
      case PersonnelRole.diger:
        return '👤';
    }
  }
}

class DutyPerson {
  final String id;
  final String name;
  final String departmentId;
  final String departmentName;
  final PersonnelRole role;
  final String phone;
  final DateTime dutyDate;
  final String? dutyStartTime;
  final String? dutyEndTime;
  final String? notes;
  final bool isCriticalUnit;

  DutyPerson({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.departmentName,
    required this.role,
    required this.phone,
    required this.dutyDate,
    this.dutyStartTime,
    this.dutyEndTime,
    this.notes,
    this.isCriticalUnit = false,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool isToday() {
    final now = DateTime.now();
    return dutyDate.year == now.year &&
        dutyDate.month == now.month &&
        dutyDate.day == now.day;
  }

  bool isWeekend() {
    return dutyDate.weekday == DateTime.saturday ||
        dutyDate.weekday == DateTime.sunday;
  }

  bool isHoliday() {
    // Extend with real holiday list / Firebase data
    return false;
  }

  DutyPerson copyWith({
    String? id,
    String? name,
    String? departmentId,
    String? departmentName,
    PersonnelRole? role,
    String? phone,
    DateTime? dutyDate,
    String? dutyStartTime,
    String? dutyEndTime,
    String? notes,
    bool? isCriticalUnit,
  }) {
    return DutyPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      dutyDate: dutyDate ?? this.dutyDate,
      dutyStartTime: dutyStartTime ?? this.dutyStartTime,
      dutyEndTime: dutyEndTime ?? this.dutyEndTime,
      notes: notes ?? this.notes,
      isCriticalUnit: isCriticalUnit ?? this.isCriticalUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'role': role.index,
      'phone': phone,
      'dutyDate': dutyDate.toIso8601String(),
      'dutyStartTime': dutyStartTime,
      'dutyEndTime': dutyEndTime,
      'notes': notes,
      'isCriticalUnit': isCriticalUnit,
    };
  }

  factory DutyPerson.fromMap(Map<String, dynamic> map) {
    final rawCritical = map['isCriticalUnit'];
    return DutyPerson(
      id: map['id'],
      name: map['name'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      role: PersonnelRole.values[map['role']],
      phone: map['phone'],
      dutyDate: DateTime.parse(map['dutyDate']),
      dutyStartTime: map['dutyStartTime'],
      dutyEndTime: map['dutyEndTime'],
      notes: map['notes'],
      isCriticalUnit: rawCritical == true || rawCritical == 1,
    );
  }
}
