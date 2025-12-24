import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/staff_model.dart';

class StaffManagementScreen extends StatefulWidget {
  final ShopModel shop;
  final bool embedded;

  const StaffManagementScreen({
    super.key,
    required this.shop,
    this.embedded = false,
  });

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    final content = StreamBuilder<List<StaffModel>>(
      stream: shopService.getStaff(widget.shop.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: GoogleFonts.crimsonText(color: AppColors.error),
            ),
          );
        }

        final staff = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            // Header Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaffStats(staff),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Staff Members"),
                  ],
                ),
              ),
            ),

            // Staff List
            if (staff.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildStaffCard(staff[index]),
                    childCount: staff.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: content,
        floatingActionButton: _buildFAB(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: content,
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        color: AppColors.primary,
      ),
      title: Text(
        "Staff Management",
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStaffStats(List<StaffModel> staff) {
    final activeCount = staff.where((s) => s.isActive).length;
    final totalSalary = staff.fold(0.0, (sum, s) => sum + s.salary);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total Staff",
            "${staff.length}",
            Icons.people_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Active",
            "$activeCount",
            Icons.check_circle_rounded,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Payroll",
            "\$${totalSalary.toStringAsFixed(0)}",
            Icons.attach_money_rounded,
            AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: AppColors.divider),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            "No Staff Members",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first staff member to get started",
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffModel staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: staff.isActive ? AppColors.border : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showStaffDetails(staff),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getRoleColor(staff.role).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getRoleIcon(staff.role),
                    color: _getRoleColor(staff.role),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            staff.name,
                            style: GoogleFonts.crimsonText(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (!staff.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Inactive",
                                style: GoogleFonts.crimsonText(
                                  fontSize: 10,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRoleName(staff.role),
                        style: GoogleFonts.crimsonText(
                          fontSize: 13,
                          color: _getRoleColor(staff.role),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staff.phone,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Salary
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${staff.salary.toStringAsFixed(0)}",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      "/month",
                      style: GoogleFonts.crimsonText(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddStaffDialog,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.gold,
      icon: const Icon(Icons.person_add_rounded),
      label: Text("Add Staff", style: GoogleFonts.rye(fontSize: 14)),
    );
  }

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final salaryController = TextEditingController();
    StaffRole selectedRole = StaffRole.attendant;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "Add New Staff",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name
                _buildTextField(nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(phoneController, "Phone Number", Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),

                // Email
                _buildTextField(emailController, "Email Address", Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // Salary
                _buildTextField(salaryController, "Monthly Salary", Icons.attach_money_rounded,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),

                // Role Selection
                Text(
                  "Select Role",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: StaffRole.values.map((role) {
                    final isSelected = selectedRole == role;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedRole = role),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.secondary : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              size: 18,
                              color: isSelected ? AppColors.gold : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getRoleName(role),
                              style: GoogleFonts.crimsonText(
                                fontSize: 14,
                                color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill required fields")),
                      );
                      return;
                    }

                    final staff = StaffModel(
                      id: '',
                      shopId: widget.shop.id,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      role: selectedRole,
                      salary: double.tryParse(salaryController.text) ?? 0,
                      joinedAt: DateTime.now(),
                    );

                    await context.read<ShopService>().addStaff(staff);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "ADD STAFF",
                    style: GoogleFonts.rye(fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.crimsonText(color: AppColors.textTertiary),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _showStaffDetails(StaffModel staff) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getRoleColor(staff.role).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(staff.role),
                color: _getRoleColor(staff.role),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              staff.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // Role Badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(staff.role).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRoleName(staff.role),
                style: GoogleFonts.crimsonText(
                  fontSize: 14,
                  color: _getRoleColor(staff.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailRow(Icons.phone_rounded, staff.phone),
            _buildDetailRow(Icons.email_rounded, staff.email),
            _buildDetailRow(Icons.attach_money_rounded, "\$${staff.salary.toStringAsFixed(0)}/month"),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ShopService>().toggleStaffStatus(
                            widget.shop.id,
                            staff.id,
                            !staff.isActive,
                          );
                    },
                    icon: Icon(
                      staff.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(staff.isActive ? "Deactivate" : "Activate"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: staff.isActive ? AppColors.warning : AppColors.success,
                      side: BorderSide(
                        color: staff.isActive ? AppColors.warning : AppColors.success,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteStaff(staff);
                    },
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text("Remove"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStaff(StaffModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Text(
          "Remove Staff",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(
          "Are you sure you want to remove ${staff.name}?",
          style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.crimsonText()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ShopService>().deleteStaff(widget.shop.id, staff.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Remove", style: GoogleFonts.rye(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.manager:
        return AppColors.velvet;
      case StaffRole.attendant:
        return AppColors.primary;
      case StaffRole.cleaner:
        return AppColors.info;
      case StaffRole.cashier:
        return AppColors.success;
    }
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.manager:
        return Icons.manage_accounts_rounded;
      case StaffRole.attendant:
        return Icons.support_agent_rounded;
      case StaffRole.cleaner:
        return Icons.cleaning_services_rounded;
      case StaffRole.cashier:
        return Icons.point_of_sale_rounded;
    }
  }

  String _getRoleName(StaffRole role) {
    switch (role) {
      case StaffRole.manager:
        return "Manager";
      case StaffRole.attendant:
        return "Attendant";
      case StaffRole.cleaner:
        return "Cleaner";
      case StaffRole.cashier:
        return "Cashier";
    }
  }
}
