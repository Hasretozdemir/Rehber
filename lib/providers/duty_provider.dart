import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../models/duty_person.dart';

class DutyProvider extends ChangeNotifier {
  List<DutyPerson> _dutyList = [];
  DateTime _selectedDate = DateTime.now();
  String? _selectedDepartmentId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  String? get selectedDepartmentId => _selectedDepartmentId;
  List<DutyPerson> get allDuties => _dutyList;

  List<DutyPerson> get todayDuties {
    final now = DateTime.now();
    return _dutyList.where((d) {
      return d.dutyDate.year == now.year &&
          d.dutyDate.month == now.month &&
          d.dutyDate.day == now.day;
    }).toList();
  }

  List<DutyPerson> get selectedDateDuties {
    return _dutyList.where((d) {
      return d.dutyDate.year == _selectedDate.year &&
          d.dutyDate.month == _selectedDate.month &&
          d.dutyDate.day == _selectedDate.day;
    }).toList();
  }

  List<DutyPerson> get filteredDuties {
    List<DutyPerson> result = selectedDateDuties;
    if (_selectedDepartmentId != null) {
      result = result
          .where((d) => d.departmentId == _selectedDepartmentId)
          .toList();
    }
    // sort: critical first
    result.sort((a, b) {
      if (a.isCriticalUnit && !b.isCriticalUnit) return -1;
      if (!a.isCriticalUnit && b.isCriticalUnit) return 1;
      return a.departmentName.compareTo(b.departmentName);
    });
    return result;
  }

  List<DutyPerson> get criticalDuties =>
      filteredDuties.where((d) => d.isCriticalUnit).toList();

  Map<String, List<DutyPerson>> get dutiesByDepartment {
    final map = <String, List<DutyPerson>>{};
    for (final duty in filteredDuties) {
      map.putIfAbsent(duty.departmentName, () => []).add(duty);
    }
    return map;
  }

  /// Returns duties for each day of the current week (Mon-Sun)
  Map<DateTime, List<DutyPerson>> get weeklyDuties {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final map = <DateTime, List<DutyPerson>>{};
    for (int i = 0; i < 7; i++) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      map[day] = _dutyList.where((d) {
        return d.dutyDate.year == day.year &&
            d.dutyDate.month == day.month &&
            d.dutyDate.day == day.day;
      }).toList();
    }
    return map;
  }

  DutyProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    await AppDatabase.instance.ensureSeeded();
    _dutyList = await AppDatabase.instance.getDuties();
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDepartmentFilter(String? departmentId) {
    _selectedDepartmentId = departmentId;
    notifyListeners();
  }

  Future<void> addDuty(DutyPerson duty) async {
    _dutyList.add(duty);
    await AppDatabase.instance.insertDuty(duty);
    notifyListeners();
  }

  Future<void> updateDuty(DutyPerson duty) async {
    final idx = _dutyList.indexWhere((d) => d.id == duty.id);
    if (idx != -1) {
      _dutyList[idx] = duty;
      await AppDatabase.instance.updateDuty(duty);
      notifyListeners();
    }
  }

  Future<void> deleteDuty(String id) async {
    _dutyList.removeWhere((d) => d.id == id);
    await AppDatabase.instance.deleteDuty(id);
    notifyListeners();
  }

  bool hasDutyOnDate(DateTime date) {
    return _dutyList.any(
      (d) =>
          d.dutyDate.year == date.year &&
          d.dutyDate.month == date.month &&
          d.dutyDate.day == date.day,
    );
  }
}
