import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum DepartmentCategory {
  acilServis,
  yogunBakim,
  ameliyathane,
  laboratuvar,
  radyoloji,
  klinik,
  idari,
  teknik,
  diger,
}

extension DepartmentCategoryExt on DepartmentCategory {
  String get label {
    switch (this) {
      case DepartmentCategory.acilServis:
        return 'Acil Servis';
      case DepartmentCategory.yogunBakim:
        return 'Yoğun Bakım';
      case DepartmentCategory.ameliyathane:
        return 'Ameliyathane';
      case DepartmentCategory.laboratuvar:
        return 'Laboratuvar';
      case DepartmentCategory.radyoloji:
        return 'Radyoloji';
      case DepartmentCategory.klinik:
        return 'Klinik';
      case DepartmentCategory.idari:
        return 'İdari';
      case DepartmentCategory.teknik:
        return 'Teknik';
      case DepartmentCategory.diger:
        return 'Diğer';
    }
  }

  Color get color {
    switch (this) {
      case DepartmentCategory.acilServis:
        return AppColors.acil;
      case DepartmentCategory.yogunBakim:
        return AppColors.yogunBakim;
      case DepartmentCategory.ameliyathane:
        return AppColors.ameliyathane;
      case DepartmentCategory.laboratuvar:
        return AppColors.lab;
      case DepartmentCategory.radyoloji:
        return AppColors.radyoloji;
      case DepartmentCategory.klinik:
        return AppColors.klinik;
      case DepartmentCategory.idari:
        return AppColors.idari;
      case DepartmentCategory.teknik:
        return AppColors.info;
      case DepartmentCategory.diger:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case DepartmentCategory.acilServis:
        return Icons.emergency_rounded;
      case DepartmentCategory.yogunBakim:
        return Icons.monitor_heart_rounded;
      case DepartmentCategory.ameliyathane:
        return Icons.medical_services_rounded;
      case DepartmentCategory.laboratuvar:
        return Icons.science_rounded;
      case DepartmentCategory.radyoloji:
        return Icons.biotech_rounded;
      case DepartmentCategory.klinik:
        return Icons.local_hospital_rounded;
      case DepartmentCategory.idari:
        return Icons.admin_panel_settings_rounded;
      case DepartmentCategory.teknik:
        return Icons.build_rounded;
      case DepartmentCategory.diger:
        return Icons.more_horiz_rounded;
    }
  }

  bool get isCritical {
    return this == DepartmentCategory.acilServis ||
        this == DepartmentCategory.yogunBakim ||
        this == DepartmentCategory.ameliyathane;
  }
}

class Department {
  final String id;
  final String name;
  final DepartmentCategory category;
  final String? description;
  final bool isEmergency;

  const Department({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.isEmergency = false,
  });

  Department copyWith({
    String? id,
    String? name,
    DepartmentCategory? category,
    String? description,
    bool? isEmergency,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'description': description,
      'isEmergency': isEmergency,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    final rawEmergency = map['isEmergency'];
    return Department(
      id: map['id'],
      name: map['name'],
      category: DepartmentCategory.values[map['category']],
      description: map['description'],
      isEmergency: rawEmergency == true || rawEmergency == 1,
    );
  }
}
