import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/department.dart';
import '../../theme/app_colors.dart';
import '../../widgets/contact_card.dart';
import 'contact_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabController;
  int _tabIndex = 0;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final shouldShow = _searchCtrl.text.isNotEmpty;
      if (shouldShow != _showClearButton && mounted) {
        setState(() => _showClearButton = shouldShow);
      }
    });
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ContactsProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            forceElevated: inner,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                kTextTabBarHeight + 8,
              ),
              title: const Text(
                'Dahili Rehber',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              background: SafeArea(
                bottom: false,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(10),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: topInset + 10,
                        child: Text(
                          '${provider.allContacts.length} kişi kayıtlı',
                          style: TextStyle(
                            color: Colors.white.withAlpha(195),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(160),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Tümü'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Favoriler'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(12),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: provider.setSearchQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'İsim, departman veya dahili numarayla ara...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.primary.withAlpha(150),
                      size: 22,
                    ),
                    suffixIcon: _showClearButton
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Department filter chips
            if (_tabIndex == 0) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'Tümü',
                      selected: provider.selectedDepartmentId == null,
                      color: AppColors.primary,
                      onTap: () => provider.setDepartmentFilter(null),
                    ),
                    ...DepartmentCategory.values.map((cat) {
                      final hasContacts = provider.allContacts.any(
                        (c) => provider.departments
                            .where((d) => d.id == c.departmentId)
                            .any((d) => d.category == cat),
                      );
                      if (!hasContacts) return const SizedBox.shrink();
                      final depts = provider.departments
                          .where((d) => d.category == cat)
                          .toList();
                      if (depts.isEmpty) return const SizedBox.shrink();
                      return _FilterChip(
                        label: cat.label,
                        selected: depts.any(
                          (d) => d.id == provider.selectedDepartmentId,
                        ),
                        color: cat.color,
                        icon: cat.icon,
                        onTap: () => provider.setDepartmentFilter(
                          provider.selectedDepartmentId == depts.first.id
                              ? null
                              : depts.first.id,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Contact list
            Expanded(
              child: _tabIndex == 0
                  ? _buildAllContacts(provider)
                  : _buildFavorites(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllContacts(ContactsProvider provider) {
    final contacts = provider.contacts;
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (contacts.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Sonuç bulunamadı',
        subtitle: 'Farklı bir arama terimi deneyin',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: contacts.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${contacts.length} kişi',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        final c = contacts[i - 1];
        final dept = provider.departments
            .where((d) => d.id == c.departmentId)
            .firstOrNull;
        return ContactCard(
          contact: c,
          department: dept,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContactDetailScreen(contact: c, department: dept),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavorites(ContactsProvider provider) {
    final favs = provider.favorites;
    if (favs.isEmpty) {
      return const _EmptyState(
        icon: Icons.star_border_rounded,
        title: 'Favori yok',
        subtitle: 'Kişileri ⭐ ile favorilere ekleyin',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      itemCount: favs.length,
      itemBuilder: (context, i) {
        final c = favs[i];
        final dept = provider.departments
            .where((d) => d.id == c.departmentId)
            .firstOrNull;
        return ContactCard(
          contact: c,
          department: dept,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContactDetailScreen(contact: c, department: dept),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [color, color.withAlpha(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : color.withAlpha(15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.transparent : color.withAlpha(70),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withAlpha(isDark ? 30 : 15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.textSecondary.withAlpha(120),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
