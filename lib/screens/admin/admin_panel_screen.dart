import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/duty_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/contact.dart';
import '../../models/duty_person.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_header.dart';
import 'add_edit_contact_screen.dart';
import 'add_edit_duty_screen.dart';
import 'manage_departments_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Paneli')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'Bu alana erişim yetkiniz yok.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Admin hesabıyla giriş yapın.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('🔐 Admin Paneli'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Kişiler'),
            Tab(text: 'Nöbet'),
            Tab(text: 'Bölümler'),
          ],
          indicatorColor: AppColors.primaryLight,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _ContactsAdminTab(),
          _DutyAdminTab(),
          ManageDepartmentsScreen(embedded: true),
        ],
      ),
    );
  }
}

// ─── Contacts Admin Tab ──────────────────────────────────────────────────────
class _ContactsAdminTab extends StatelessWidget {
  const _ContactsAdminTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();
    final contacts = provider.allContacts;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddContact(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kişi Ekle'),
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('Henüz kişi eklenmedi.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: contacts.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return SectionHeader(
                    title: '${contacts.length} Kişi',
                    icon: Icons.contacts_rounded,
                    iconColor: AppColors.primary,
                  );
                }
                final c = contacts[i - 1];
                return _AdminContactTile(
                  contact: c,
                  onEdit: () => _openAddContact(context, c),
                  onDelete: () => _confirmDelete(context, c.name, () {
                    provider.deleteContact(c.id);
                  }),
                );
              },
            ),
    );
  }

  void _openAddContact(BuildContext context, Contact? existing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(existing: existing),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String name,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kişiyi Sil'),
        content: Text('"$name" silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
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

class _AdminContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withAlpha(30),
          child: Text(
            contact.initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(contact.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${contact.departmentName} • Dahili: ${contact.internalNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
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

// ─── Duty Admin Tab ───────────────────────────────────────────────────────────
class _DutyAdminTab extends StatelessWidget {
  const _DutyAdminTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DutyProvider>();
    final duties = provider.allDuties;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDuty(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nöbet Ekle'),
      ),
      body: duties.isEmpty
          ? const Center(child: Text('Henüz nöbet eklenmedi.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: duties.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return SectionHeader(
                    title: '${duties.length} Nöbet Kaydı',
                    icon: Icons.badge_rounded,
                    iconColor: AppColors.accent,
                  );
                }
                final d = duties[i - 1];
                return _AdminDutyTile(
                  duty: d,
                  onEdit: () => _openAddDuty(context, d),
                  onDelete: () => _confirmDelete(context, d.name, () {
                    provider.deleteDuty(d.id);
                  }),
                );
              },
            ),
    );
  }

  void _openAddDuty(BuildContext context, DutyPerson? existing) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditDutyScreen(existing: existing)),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String name,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nöbeti Sil'),
        content: Text('"$name" nöbet kaydı silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
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

class _AdminDutyTile extends StatelessWidget {
  final DutyPerson duty;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminDutyTile({
    required this.duty,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (duty.isCriticalUnit ? AppColors.emergency : AppColors.accent)
                  .withAlpha(30),
          child: Text(
            duty.initials,
            style: TextStyle(
              color: duty.isCriticalUnit
                  ? AppColors.emergency
                  : AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(duty.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${duty.role.label} • ${duty.departmentName}\n'
          '${duty.dutyDate.day}.${duty.dutyDate.month}.${duty.dutyDate.year}',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (duty.isCriticalUnit)
              const Icon(
                Icons.priority_high_rounded,
                color: AppColors.emergency,
                size: 16,
              ),
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
