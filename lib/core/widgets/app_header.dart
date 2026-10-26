import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../services/auth_service.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool isDashboard;
  final UserModel? user;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;

  const AppHeader({
    super.key,
    this.title,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.isDashboard = false,
    this.user,
    this.onMenuPressed,
    this.onNotificationPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(isDashboard ? 78.0 : 56.0);

  void _showUserSwitcherDialog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Switch Active User / Persona',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Test field operations across different salesmen or switch to administrator view:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ...AuthService.systemUsers.map((u) {
                  final isSelected = appState.currentUser.id == u.id;
                  final isAdmin = u.id == 'ADM001';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryRed.withAlpha(20)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryRed
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(u.avatarUrl),
                        radius: 18,
                      ),
                      title: Text(
                        u.name,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryRed
                              : AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${u.role} • ${u.employeeId}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AppColors.primaryRed
                              : AppColors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAdmin ? 'Admin' : 'Sales Rep',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        appState.switchUser(
                          u,
                          role: isAdmin ? AppRole.admin : AppRole.salesman,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Switched profile to ${u.name} (${isAdmin ? 'Admin' : 'Sales Rep'})'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isOffline = appState.isSimulatedOffline;
    final pendingCount = appState.pendingOutboxCount;

    if (isDashboard) {
      return Container(
        color: AppColors.primaryRed,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Hamburger Menu
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onMenuPressed,
                  tooltip: 'Menu',
                ),
                const SizedBox(width: 12),

                // User Avatar with Switcher trigger
                GestureDetector(
                  onTap: () => _showUserSwitcherDialog(context, appState),
                  child: Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.white.withAlpha(50),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            user?.avatarUrl ??
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 11,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // User Greeting & Name
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showUserSwitcherDialog(context, appState),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                user?.name ?? 'Rohit Sharma',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.white, size: 16),
                          ],
                        ),
                        Text(
                          '${user?.role ?? 'Sales Executive'} • ${appState.isAdmin ? 'Admin View' : 'Field View'}',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha(210),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Offline / Online Status Pill
                GestureDetector(
                  onTap: () {
                    appState.toggleOfflineSimulation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appState.isSimulatedOffline
                            ? 'Switched to Simulated Offline Mode. Actions will queue in Outbox.'
                            : 'Connected to Network. Auto-syncing pending items...'),
                        backgroundColor: appState.isSimulatedOffline
                            ? const Color(0xFFD97706)
                            : AppColors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOffline
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOffline
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOffline
                              ? Icons.cloud_off_rounded
                              : Icons.cloud_done_rounded,
                          size: 13,
                          color: isOffline
                              ? const Color(0xFFB45309)
                              : const Color(0xFF047857),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOffline
                              ? (pendingCount > 0
                                  ? 'Offline ($pendingCount)'
                                  : 'Offline')
                              : 'Online',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isOffline
                                ? const Color(0xFFB45309)
                                : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Notification Bell with badge dot
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 24),
                      onPressed: onNotificationPressed,
                      tooltip: 'Notifications',
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.primaryRed,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : null,
      title: Text(
        title ?? '',
        style: AppTypography.headerTitle,
      ),
      actions: [
        if (actions != null) ...actions!,
        // Offline / Online Indicator in general AppBars
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              appState.toggleOfflineSimulation();
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOffline
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOffline
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOffline
                          ? Icons.cloud_off_rounded
                          : Icons.cloud_done_rounded,
                      size: 13,
                      color: isOffline
                          ? const Color(0xFFB45309)
                          : const Color(0xFF047857),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOffline
                          ? (pendingCount > 0 ? 'Offline ($pendingCount)' : 'Offline')
                          : 'Online',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isOffline
                            ? const Color(0xFFB45309)
                            : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
