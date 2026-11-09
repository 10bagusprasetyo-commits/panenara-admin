// lib/features/admin_web/shared/presentation/widgets/sidebar_shell.dart
// Layout utama: sidebar 268px kiri + konten kanan.
// Di bawah 900px: sidebar jadi Drawer (responsif).

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';
import 'panenara_logo.dart';
import 'avatar_initials.dart';

class SidebarMenuItem {
  const SidebarMenuItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class SidebarShell extends StatefulWidget {
  const SidebarShell({
    super.key,
    required this.panelTitle,
    required this.roleChip,
    required this.menuItems,
    required this.activeItemId,
    required this.onMenuItemTap,
    required this.userName,
    required this.userRole,
    required this.breadcrumb,
    required this.child,
    this.topActions = const [],
  });

  final String panelTitle;
  final String roleChip;
  final List<SidebarMenuItem> menuItems;
  final String activeItemId;
  final ValueChanged<String> onMenuItemTap;
  final String userName;
  final String userRole;
  final Widget breadcrumb;
  final Widget child;
  final List<Widget> topActions;

  @override
  State<SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<SidebarShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < _breakpoint;

    if (isNarrow) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.adminBg,
        drawer: Drawer(
          child: _SidebarContent(
            panelTitle: widget.panelTitle,
            roleChip: widget.roleChip,
            menuItems: widget.menuItems,
            activeItemId: widget.activeItemId,
            onMenuItemTap: (id) {
              Navigator.of(context).pop();
              widget.onMenuItemTap(id);
            },
            userName: widget.userName,
            userRole: widget.userRole,
          ),
        ),
        appBar: AppBar(
          backgroundColor: context.adminBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Row(
            children: [
              PanenaraLogo(width: 20, height: 30),
              const SizedBox(width: 8),
              Text(
                'Panenara',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.sidebarText,
                ),
              ),
            ],
          ),
          actions: [
            ...widget.topActions,
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          child: widget.child,
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.adminBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 268,
            child: _SidebarContent(
              panelTitle: widget.panelTitle,
              roleChip: widget.roleChip,
              menuItems: widget.menuItems,
              activeItemId: widget.activeItemId,
              onMenuItemTap: widget.onMenuItemTap,
              userName: widget.userName,
              userRole: widget.userRole,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 22, 30, 0),
                    child: Row(
                      children: [
                        Expanded(child: widget.breadcrumb),
                        ...widget.topActions,
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar Content ─────────────────────────────────────────────────────────

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.panelTitle,
    required this.roleChip,
    required this.menuItems,
    required this.activeItemId,
    required this.onMenuItemTap,
    required this.userName,
    required this.userRole,
  });

  final String panelTitle;
  final String roleChip;
  final List<SidebarMenuItem> menuItems;
  final String activeItemId;
  final ValueChanged<String> onMenuItemTap;
  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final sidebarText = context.sidebarText;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.sidebarStart, context.sidebarEnd],
          transform: const GradientRotation(2.97), // ~170 deg
        ),
        border: Border(
          right: BorderSide(
            color: isDark ? AdminColors.lineDark : AdminColors.lineLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          PanenaraLogo(),
                          const SizedBox(width: 10),
                          PanenBrand(
                            subtitle: panelTitle,
                            onDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Role chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AdminColors.cardDark
                            : AdminColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleChip,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? AdminColors.okTxDark
                              : AdminColors.okTxLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Menu
                    ...menuItems.map(
                      (item) => _MenuItem(
                        item: item,
                        isActive: item.id == activeItemId,
                        sidebarText: sidebarText,
                        onTap: () => onMenuItemTap(item.id),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            // User profile card at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AdminColors.cardDark : AdminColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    AvatarInitials(name: userName),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark
                                  ? AdminColors.txDark
                                  : AdminColors.txLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            userRole,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: (isDark
                                      ? AdminColors.txDark
                                      : AdminColors.txLight)
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.isActive,
    required this.sidebarText,
    required this.onTap,
  });

  final SidebarMenuItem item;
  final bool isActive;
  final Color sidebarText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: const Color(0x242f9a5c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isActive ? AdminColors.g6 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? Colors.white : sidebarText,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isActive ? Colors.white : sidebarText,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Breadcrumb widget for the topbar
class AdminBreadcrumb extends StatelessWidget {
  const AdminBreadcrumb({
    super.key,
    required this.panelName,
    required this.currentPage,
  });

  final String panelName;
  final String currentPage;

  @override
  Widget build(BuildContext context) {
    final muted =
        context.isDark ? AdminColors.mutDark : AdminColors.mutLight;
    final tx = context.isDark ? AdminColors.txDark : AdminColors.txLight;
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 13, color: muted),
        children: [
          TextSpan(text: 'Dashboard $panelName › '),
          TextSpan(
            text: currentPage,
            style: TextStyle(fontWeight: FontWeight.w700, color: tx),
          ),
        ],
      ),
    );
  }
}
