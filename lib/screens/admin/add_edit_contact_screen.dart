import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contact.dart';
import '../../models/department.dart';
import '../../theme/app_colors.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? existing;
  const AddEditContactScreen({super.key, this.existing});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _internalCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _emailCtrl;
  Department? _selectedDept;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _internalCtrl = TextEditingController(text: c?.internalNumber ?? '');
    _mobileCtrl = TextEditingController(text: c?.mobileNumber ?? '');
    _roleCtrl = TextEditingController(text: c?.role ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    if (c != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ContactsProvider>();
        setState(() {
          _selectedDept = provider.departments
              .where((d) => d.id == c.departmentId)
              .firstOrNull;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _internalCtrl.dispose();
    _mobileCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
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
    final provider = context.read<ContactsProvider>();
    final contact = Contact(
      id: widget.existing?.id ?? 'c${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      departmentId: _selectedDept!.id,
      departmentName: _selectedDept!.name,
      internalNumber: _internalCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim().isEmpty
          ? null
          : _mobileCtrl.text.trim(),
      role: _roleCtrl.text.trim().isEmpty ? null : _roleCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    );
    if (isEditing) {
      provider.updateContact(contact);
    } else {
      provider.addContact(contact);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Kişi güncellendi' : 'Kişi eklendi'),
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
        title: Text(isEditing ? 'Kişiyi Düzenle' : 'Yeni Kişi Ekle'),
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
              _field(
                _nameCtrl,
                'Ad Soyad',
                Icons.person_outline_rounded,
                required: true,
              ),
              const SizedBox(height: 16),
              // Department dropdown
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
                onChanged: (v) => setState(() => _selectedDept = v),
                validator: (v) => v == null ? 'Bölüm seçin' : null,
              ),
              const SizedBox(height: 16),
              _field(
                _internalCtrl,
                'Dahili Numara',
                Icons.dialpad_rounded,
                keyboard: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 16),
              _field(
                _mobileCtrl,
                'Cep Telefonu (opsiyonel)',
                Icons.smartphone_rounded,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _field(
                _roleCtrl,
                'Ünvan / Görev (opsiyonel)',
                Icons.work_outline_rounded,
              ),
              const SizedBox(height: 16),
              _field(
                _emailCtrl,
                'E-posta (opsiyonel)',
                Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
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
                  label: Text(isEditing ? 'Güncelle' : 'Kişi Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label gerekli' : null
          : null,
    );
  }
}
