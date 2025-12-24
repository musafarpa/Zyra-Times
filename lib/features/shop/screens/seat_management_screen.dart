import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/seat_model.dart';

class SeatManagementScreen extends StatefulWidget {
  final ShopModel shop;
  final bool embedded;

  const SeatManagementScreen({
    super.key,
    required this.shop,
    this.embedded = false,
  });

  @override
  State<SeatManagementScreen> createState() => _SeatManagementScreenState();
}

class _SeatManagementScreenState extends State<SeatManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    final content = StreamBuilder<List<SeatModel>>(
      stream: shopService.getSeats(widget.shop.id),
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

        final seats = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            // Header Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeatStats(seats),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Seating Arrangement"),
                  ],
                ),
              ),
            ),

            // Seat Grid
            if (seats.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSeatCard(seats[index]),
                    childCount: seats.length,
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
        "Seat Management",
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSeatStats(List<SeatModel> seats) {
    final available = seats.where((s) => s.status == SeatStatus.available).length;
    final occupied = seats.where((s) => s.status == SeatStatus.occupied).length;
    final reserved = seats.where((s) => s.status == SeatStatus.reserved).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard("Available", "$available", AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard("Occupied", "$occupied", AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard("Reserved", "$reserved", AppColors.info),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: color,
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
          Icon(Icons.chair_alt_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            "No Seats Added",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add seats to start managing your establishment",
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

  Widget _buildSeatCard(SeatModel seat) {
    final statusColor = _getStatusColor(seat.status);
    final statusIcon = _getStatusIcon(seat.status);

    return GestureDetector(
      onTap: () => _showSeatOptions(seat),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Status Indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, size: 16, color: statusColor),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Seat Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSeatTypeIcon(seat.type),
                      size: 32,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Seat Name
                  Text(
                    seat.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Type & Price
                  Text(
                    seat.hasPricing
                        ? "${_getSeatTypeName(seat.type)} • \$${seat.pricePerHour.toStringAsFixed(0)}/hr"
                        : _getSeatTypeName(seat.type),
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusName(seat.status),
                      style: GoogleFonts.crimsonText(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAddSeatDialog,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.gold,
      icon: const Icon(Icons.add_rounded),
      label: Text("Add Seat", style: GoogleFonts.rye(fontSize: 14)),
    );
  }

  void _showAddSeatDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: "10");
    SeatType selectedType = SeatType.standard;
    bool hasPricing = false;

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
                  "Add New Seat",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name
                _buildTextField(nameController, "Seat Name", Icons.chair_rounded),
                const SizedBox(height: 16),

                // Price Toggle Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            color: hasPricing ? AppColors.success : AppColors.textTertiary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enable Pricing",
                                style: GoogleFonts.crimsonText(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                hasPricing ? "Price will be shown" : "No price display",
                                style: GoogleFonts.crimsonText(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: hasPricing,
                        onChanged: (value) => setModalState(() => hasPricing = value),
                        activeColor: AppColors.gold,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: AppColors.textTertiary,
                        inactiveTrackColor: AppColors.border,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price Field (only shown when pricing is enabled)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      _buildTextField(
                        priceController,
                        "Price per Hour (\$)",
                        Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  crossFadeState: hasPricing
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),

                // Type Selection
                Text(
                  "Select Type",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: SeatType.values.map((type) {
                    final isSelected = selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedType = type),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: type != SeatType.values.last ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getSeatTypeIcon(type),
                                size: 28,
                                color: isSelected ? AppColors.gold : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getSeatTypeName(type),
                                style: GoogleFonts.crimsonText(
                                  fontSize: 12,
                                  color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter seat name")),
                      );
                      return;
                    }

                    // Get current seat count for seat number
                    final shopService = context.read<ShopService>();

                    final seat = SeatModel(
                      id: '',
                      shopId: widget.shop.id,
                      name: nameController.text.trim(),
                      type: selectedType,
                      pricePerHour: hasPricing ? (double.tryParse(priceController.text) ?? 0) : 0,
                      hasPricing: hasPricing,
                      seatNumber: widget.shop.totalSeats + 1,
                      createdAt: DateTime.now(),
                    );

                    await shopService.addSeat(seat);
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
                    "ADD SEAT",
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

  void _showSeatOptions(SeatModel seat) {
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

            // Seat Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(seat.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSeatTypeIcon(seat.type),
                    size: 40,
                    color: _getStatusColor(seat.status),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seat.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          seat.hasPricing
                              ? "${_getSeatTypeName(seat.type)} • \$${seat.pricePerHour.toStringAsFixed(0)}/hr"
                              : _getSeatTypeName(seat.type),
                          style: GoogleFonts.crimsonText(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(seat.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusName(seat.status),
                      style: GoogleFonts.crimsonText(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Change Options
            Text(
              "Change Status",
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SeatStatus.values.map((status) {
                final isSelected = seat.status == status;
                final color = _getStatusColor(status);
                return GestureDetector(
                  onTap: isSelected
                      ? null
                      : () {
                          Navigator.pop(context);
                          context.read<ShopService>().updateSeatStatus(
                                widget.shop.id,
                                seat.id,
                                status,
                              );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 18,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusName(status),
                          style: GoogleFonts.crimsonText(
                            fontSize: 14,
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Delete Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteSeat(seat);
              },
              icon: const Icon(Icons.delete_rounded),
              label: const Text("Delete Seat"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSeat(SeatModel seat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Text(
          "Delete Seat",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ${seat.name}?",
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
              context.read<ShopService>().deleteSeat(widget.shop.id, seat.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete", style: GoogleFonts.rye(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return AppColors.success;
      case SeatStatus.occupied:
        return AppColors.warning;
      case SeatStatus.reserved:
        return AppColors.info;
      case SeatStatus.maintenance:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return Icons.check_circle_rounded;
      case SeatStatus.occupied:
        return Icons.person_rounded;
      case SeatStatus.reserved:
        return Icons.schedule_rounded;
      case SeatStatus.maintenance:
        return Icons.build_rounded;
    }
  }

  String _getStatusName(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return "Available";
      case SeatStatus.occupied:
        return "Occupied";
      case SeatStatus.reserved:
        return "Reserved";
      case SeatStatus.maintenance:
        return "Maintenance";
    }
  }

  IconData _getSeatTypeIcon(SeatType type) {
    switch (type) {
      case SeatType.standard:
        return Icons.chair_rounded;
      case SeatType.premium:
        return Icons.chair_alt_rounded;
      case SeatType.vip:
        return Icons.weekend_rounded;
    }
  }

  String _getSeatTypeName(SeatType type) {
    switch (type) {
      case SeatType.standard:
        return "Standard";
      case SeatType.premium:
        return "Premium";
      case SeatType.vip:
        return "VIP";
    }
  }
}
