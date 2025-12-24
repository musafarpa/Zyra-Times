import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/admin/services/admin_service.dart';
import 'package:zyraslot/models/user_model.dart';
import 'package:zyraslot/widgets/animated_saloon_widgets.dart';

class AdminUserList extends StatelessWidget {
  const AdminUserList({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = context.read<AdminService>();

    return StreamBuilder<List<UserModel>>(
      stream: adminService.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VintageLoader(size: 50),
                const SizedBox(height: 16),
                Text(
                  "Loading Citizens...",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data!;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No Citizens",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The town is empty",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        // Count users by role
        final customers = users.where((u) => u.role == UserRole.customer).length;
        final shopOwners = users.where((u) => u.role == UserRole.shopr).length;
        final admins = users.where((u) => u.role == UserRole.admin).length;

        return Column(
          children: [
            // Stats Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.parchmentGradient,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.people_rounded, "${users.length}", "Total"),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _buildStatItem(Icons.person_rounded, "$customers", "Customers"),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _buildStatItem(Icons.store_rounded, "$shopOwners", "Owners"),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _buildStatItem(Icons.shield_rounded, "$admins", "Admins"),
                ],
              ),
            ),

            // User List
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return StaggeredListItem(
                    index: index,
                    baseDelay: const Duration(milliseconds: 50),
                    child: _buildUserCard(context, user, adminService),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.crimsonText(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, AdminService adminService) {
    final roleColor = _getRoleColor(user.role);
    final roleIcon = _getRoleIcon(user.role);

    return AnimatedSaloonCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  roleColor,
                  roleColor.withValues(alpha: 0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: roleColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                style: GoogleFonts.rye(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.email_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 12, color: roleColor),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleName(user.role),
                        style: GoogleFonts.crimsonText(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Delete Button (don't show for admins)
          if (user.role != UserRole.admin)
            GestureDetector(
              onTap: () => _showDeleteDialog(context, user, adminService),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.gold;
      case UserRole.shopr:
        return AppColors.info;
      case UserRole.customer:
        return AppColors.success;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield_rounded;
      case UserRole.shopr:
        return Icons.store_rounded;
      case UserRole.customer:
        return Icons.person_rounded;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return "SHERIFF";
      case UserRole.shopr:
        return "PROPRIETOR";
      case UserRole.customer:
        return "CITIZEN";
    }
  }

  void _showDeleteDialog(BuildContext context, UserModel user, AdminService adminService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Remove Citizen",
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to remove:",
              style: GoogleFonts.crimsonText(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: GoogleFonts.rye(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.crimsonText(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "This action cannot be undone.",
              style: GoogleFonts.crimsonText(
                color: AppColors.error,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              adminService.deleteUser(user.uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Remove", style: GoogleFonts.rye(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
