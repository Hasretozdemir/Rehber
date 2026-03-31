import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_database.dart';
import '../models/contact.dart';
import '../models/department.dart';

class ContactsProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  List<Department> _departments = [];
  String _searchQuery = '';
  String? _selectedDepartmentId;
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  List<Contact> get contacts => _filteredContacts;
  List<Contact> get allContacts => _contacts;
  List<Department> get departments => _departments;
  String get searchQuery => _searchQuery;
  String? get selectedDepartmentId => _selectedDepartmentId;
  bool get isLoading => _isLoading;

  List<Contact> get favorites =>
      _contacts.where((c) => _favoriteIds.contains(c.id)).toList();

  List<Contact> get emergencyContacts => _contacts
      .where((c) => ['c1', 'c3', 'c5', 'c8', 'c15'].contains(c.id))
      .toList();

  List<Contact> get _filteredContacts {
    List<Contact> result = List.from(_contacts);

    if (_selectedDepartmentId != null) {
      result = result
          .where((c) => c.departmentId == _selectedDepartmentId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.internalNumber.contains(q) ||
            c.departmentName.toLowerCase().contains(q) ||
            (c.role?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  ContactsProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    await _loadFavorites();
    await AppDatabase.instance.ensureSeeded();
    _contacts = await AppDatabase.instance.getContacts();
    _departments = await AppDatabase.instance.getDepartments();
    for (var c in _contacts) {
      c.isFavorite = _favoriteIds.contains(c.id);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = (prefs.getStringList('favorites') ?? []).toSet();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds.toList());
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDepartmentFilter(String? departmentId) {
    _selectedDepartmentId = departmentId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartmentId = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(String contactId) async {
    if (_favoriteIds.contains(contactId)) {
      _favoriteIds.remove(contactId);
    } else {
      _favoriteIds.add(contactId);
    }
    for (var c in _contacts) {
      if (c.id == contactId) c.isFavorite = _favoriteIds.contains(contactId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String contactId) => _favoriteIds.contains(contactId);

  Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    await AppDatabase.instance.insertContact(contact);
    notifyListeners();
  }

  Future<void> updateContact(Contact contact) async {
    final idx = _contacts.indexWhere((c) => c.id == contact.id);
    if (idx != -1) {
      _contacts[idx] = contact;
      await AppDatabase.instance.updateContact(contact);
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    _favoriteIds.remove(id);
    await AppDatabase.instance.deleteContact(id);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addDepartment(Department dept) async {
    _departments.add(dept);
    await AppDatabase.instance.insertDepartment(dept);
    notifyListeners();
  }

  Future<void> updateDepartment(Department dept) async {
    final idx = _departments.indexWhere((d) => d.id == dept.id);
    if (idx != -1) {
      _departments[idx] = dept;
      await AppDatabase.instance.updateDepartment(dept);
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(String id) async {
    _departments.removeWhere((d) => d.id == id);
    _contacts.removeWhere((c) => c.departmentId == id);
    await AppDatabase.instance.deleteDepartment(id);
    notifyListeners();
  }
}
