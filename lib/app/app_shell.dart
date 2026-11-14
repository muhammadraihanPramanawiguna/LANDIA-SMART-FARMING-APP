import 'package:flutter/material.dart';

import '../features/settings/presentation/settings_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/cost/presentation/cost_page.dart';
import '../features/irrigation/presentation/irrigation_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/monitoring/presentation/monitoring_page.dart';
import '../features/devices/presentation/pages/devices_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const int _desktopBreakpoint = 800;
  static const int _wideBreakpoint = 1100;

  static const List<_AppDestination> _destinations = [
    _AppDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AppDestination(
      label: 'Monitoring',
      icon: Icons.sensors_outlined,
      selectedIcon: Icons.sensors,
    ),
    _AppDestination(
      label: 'Penyiraman',
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop,
    ),
    _AppDestination(
      label: 'Biaya Air',
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments,
    ),
    _AppDestination(
      label: 'Histori',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
    ),
    _AppDestination(
      label: 'Laporan',
      icon: Icons.insert_chart_outlined,
      selectedIcon: Icons.insert_chart,
    ),
    _AppDestination(
      label: 'Perangkat',
      icon: Icons.devices_outlined,
      selectedIcon: Icons.devices,
    ),
    _AppDestination(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  // Urutan halaman harus sesuai dengan indeks navigasi.
  static const List<Widget> _pages = [
    DashboardPage(),
    MonitoringPage(),
    IrrigationPage(),
    CostPage(),
    HistoryPage(),
    ReportsPage(),
    DevicesPage(),
    SettingsPage(),
  ];

  // Menu utama bottom navigation mobile.
  static const List<int> _mobileDestinations = [0, 1, 2, 4];

  void _selectPage(int index) {
    if (index < 0 || index >= _pages.length) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isMobile ? 12 : 20,
        title: Row(
          children: [
            const Icon(Icons.eco_outlined),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isMobile ? 'LANDIA FARM' : 'LANDIA FARM APP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (isMobile)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Mode Demo',
                child: Icon(Icons.cloud_off, size: 20),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 15),
                      SizedBox(width: 6),
                      Text('Mode Demo', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= _desktopBreakpoint) {
            final isWide = width >= _wideBreakpoint;

            return Row(
              children: [
                _buildDesktopSidebar(isWide: isWide),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPageContent()),
              ],
            );
          }

          return _buildPageContent();
        },
      ),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _desktopBreakpoint) {
            return const SizedBox.shrink();
          }

          final mobileIndex = _mobileDestinations.indexOf(_selectedIndex);

          return NavigationBar(
            selectedIndex: mobileIndex == -1 ? 4 : mobileIndex,
            onDestinationSelected: (index) {
              if (index < _mobileDestinations.length) {
                _selectPage(_mobileDestinations[index]);
              } else {
                _showMoreMenu(context);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.sensors_outlined),
                selectedIcon: Icon(Icons.sensors),
                label: 'Sensor',
              ),
              NavigationDestination(
                icon: Icon(Icons.water_drop_outlined),
                selectedIcon: Icon(Icons.water_drop),
                label: 'Air',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'Histori',
              ),
              NavigationDestination(icon: Icon(Icons.menu), label: 'Lainnya'),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP SIDEBAR
  // ============================================================

  Widget _buildDesktopSidebar({required bool isWide}) {
    final sidebarWidth = isWide ? 240.0 : 88.0;

    return SizedBox(
      width: sidebarWidth,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: isWide
                ? const Row(
                    children: [
                      Icon(Icons.eco, size: 30, color: Color(0xFF397A52)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Landia Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.eco, size: 32, color: Color(0xFF397A52)),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                final destination = _destinations[index];
                final isSelected = _selectedIndex == index;
                final colorScheme = Theme.of(context).colorScheme;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Tooltip(
                    message: isWide ? '' : destination.label,
                    child: Material(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _selectPage(index),
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                child: Icon(
                                  isSelected
                                      ? destination.selectedIcon
                                      : destination.icon,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (isWide)
                                Expanded(
                                  child: Text(
                                    destination.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(12),
            child: isWide
                ? const Row(
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 18,
                        color: Color(0xFF397A52),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Smart Farming',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.eco_outlined, color: Color(0xFF397A52)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE CONTENT
  // ============================================================

  Widget _buildPageContent() {
    return IndexedStack(index: _selectedIndex, children: _pages);
  }

  // ============================================================
  // MOBILE MORE MENU
  // ============================================================

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Menu Lainnya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _MoreMenuItem(
                icon: Icons.payments_outlined,
                title: 'Biaya Air',
                onTap: () => _selectFromMenu(sheetContext, 3),
              ),
              _MoreMenuItem(
                icon: Icons.insert_chart_outlined,
                title: 'Laporan',
                onTap: () => _selectFromMenu(sheetContext, 5),
              ),
              _MoreMenuItem(
                icon: Icons.devices_outlined,
                title: 'Perangkat',
                onTap: () => _selectFromMenu(sheetContext, 6),
              ),
              _MoreMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () => _selectFromMenu(sheetContext, 7),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectFromMenu(BuildContext context, int index) {
    Navigator.pop(context);
    _selectPage(index);
  }
}

// ============================================================
// NAVIGATION DESTINATION MODEL
// ============================================================

class _AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

// ============================================================
// PLACEHOLDER FOR UNIMPLEMENTED PAGES
// ============================================================

// ============================================================
// MOBILE MORE MENU ITEM
// ============================================================

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
