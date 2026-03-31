import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/duty_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/duty_person.dart';
import '../../models/department.dart';
import '../../theme/app_colors.dart';

class AddEditDutyScreen extends StatefulWidget {
  final DutyPerson? existing;
  const AddEditDutyScreen({super.key, this.existing});

  @override
  State<AddEditDutyScreen> createState() => _AddEditDutyScreenState();
}

class _AddEditDutyScreenState extends State<AddEditDutyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _notesCtrl;
  PersonnelRole _role = PersonnelRole.doktor;
  Department? _selectedDept;
  DateTime _selectedDate = DateTime.now();
  bool _isCritical = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    if (p != null) {
      _role = p.role;
      _selectedDate = p.dutyDate;
      _isCritical = p.isCriticalUnit;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ContactsProvider>();
        setState(() {
          _selectedDept = provider.departments
              .where((d) => d.id == p.departmentId)
              .firstOrNull;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDept == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir bölüm seçin')));
      return;
    }
    final dutyProv = context.read<DutyProvider>();
    final duty = DutyPerson(
      id: widget.existing?.id ?? 'dp${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      departmentId: _selectedDept!.id,
      departmentName: _selectedDept!.name,
      role: _role,
      phone: _phoneCtrl.text.trim(),
      dutyDate: _selectedDate,
      dutyStartTime: '08:00',
      dutyEndTime: '08:00 (+1)',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      isCriticalUnit: _isCritical,
    );
    if (isEditing) {
      dutyProv.updateDuty(duty);
    } else {
      dutyProv.addDuty(duty);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Nöbet güncellendi' : 'Nöbet eklendi'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final departments = context.watch<ContactsProvider>().departments;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Nöbeti Düzenle' : 'Yeni Nöbet Ekle'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'KAYDET',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ad Soyad gerekli' : null,
              ),
              const SizedBox(height: 16),
              // Department
              DropdownButtonFormField<Department>(
                initialValue: _selectedDept,
                decoration: const InputDecoration(
                  labelText: 'Bölüm',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                items: departments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Row(
                          children: [
                            Icon(
                              d.category.icon,
                              size: 16,
                              color: d.category.color,
                            ),
                            const SizedBox(width: 8),
                            Text(d.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedDept = v;
                  _isCritical = v?.isEmergency ?? false;
                }),
                validator: (v) => v == null ? 'Bölüm seçin' : null,
              ),
              const SizedBox(height: 16),
              // Role
              DropdownButtonFormField<PersonnelRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Görev',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                items: PersonnelRole.values
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text('${r.emoji} ${r.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? _role),
              ),
              const SizedBox(height: 16),
              // Phone
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Telefon gerekli' : null,
              ),
              const SizedBox(height: 16),
              // Date picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Nöbet Tarihi',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    DateFormat(
                      'dd MMMM yyyy, EEEE',
                      'tr_TR',
                    ).format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Critical toggle
              SwitchListTile(
                value: _isCritical,
                onChanged: (v) => setState(() => _isCritical = v),
                title: const Text('Kritik Birim'),
                subtitle: const Text('Acil, YBÜ, Ameliyathane vb.'),
                activeThumbColor: AppColors.emergency,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(
                    isEditing ? Icons.save_rounded : Icons.add_rounded,
                  ),
                  label: Text(isEditing ? 'Güncelle' : 'Nöbet Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
