import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/department.dart';
import '../../theme/app_colors.dart';

class ManageDepartmentsScreen extends StatelessWidget {
  final bool embedded;

  const ManageDepartmentsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();
    final departments = provider.departments;

    Widget body = Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Bölüm Ekle'),
      ),
      body: departments.isEmpty
          ? const Center(child: Text('Henüz bölüm eklenmedi.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: departments.length,
              itemBuilder: (ctx, i) {
                final dept = departments[i];
                return _DeptTile(
                  dept: dept,
                  onEdit: () => _showAddEditDialog(context, dept),
                  onDelete: () => _confirmDelete(context, dept, provider),
                );
              },
            ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Bölüm Yönetimi')),
      body: body,
    );
  }

  void _showAddEditDialog(BuildContext context, Department? existing) {
    showDialog(
      context: context,
      builder: (_) => _DeptDialog(existing: existing),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Department dept,
    ContactsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bölümü Sil'),
        content: Text(
          '"${dept.name}" ve bağlı tüm kişiler silinecek. Devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDepartment(dept.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.emergency),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptTile extends StatelessWidget {
  final Department dept;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeptTile({
    required this.dept,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = dept.category.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(dept.category.icon, color: color, size: 22),
        ),
        title: Text(dept.name, style: theme.textTheme.titleMedium),
        subtitle: Row(
          children: [
            Text(
              dept.category.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dept.isEmergency) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emergency,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'ACİL',
                  style: TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: AppColors.emergency,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeptDialog extends StatefulWidget {
  final Department? existing;
  const _DeptDialog({this.existing});

  @override
  State<_DeptDialog> createState() => _DeptDialogState();
}

class _DeptDialogState extends State<_DeptDialog> {
  final _nameCtrl = TextEditingController();
  DepartmentCategory _category = DepartmentCategory.klinik;
  bool _isEmergency = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _category = widget.existing!.category;
      _isEmergency = widget.existing!.isEmergency;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContactsProvider>();
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Bölümü Düzenle' : 'Yeni Bölüm Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Bölüm Adı',
                prefixIcon: Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DepartmentCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: DepartmentCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 16, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _isEmergency,
              onChanged: (v) => setState(() => _isEmergency = v ?? false),
              title: const Text('Acil Birim'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            final dept = Department(
              id:
                  widget.existing?.id ??
                  'd${DateTime.now().millisecondsSinceEpoch}',
              name: _nameCtrl.text.trim(),
              category: _category,
              isEmergency: _isEmergency,
            );
            if (isEditing) {
              provider.updateDepartment(dept);
            } else {
              provider.addDepartment(dept);
            }
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Güncelle' : 'Ekle'),
        ),
      ],
    );
  }
}
