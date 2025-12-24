import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/seat_model.dart';
import 'package:zyraslot/models/booking_model.dart';

class BookingManagementScreen extends StatefulWidget {
  final ShopModel shop;
  final bool embedded;

  const BookingManagementScreen({
    super.key,
    required this.shop,
    this.embedded = false,
  });

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorPadding: const EdgeInsets.all(4),
            labelStyle: GoogleFonts.crimsonText(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Today"),
              Tab(text: "History"),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ActiveBookingsTab(shop: widget.shop),
              _TodayBookingsTab(shop: widget.shop),
              _AllBookingsTab(shop: widget.shop),
            ],
          ),
        ),
      ],
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
        "Bookings",
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateBookingDialog(context),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.gold,
      icon: const Icon(Icons.add_rounded),
      label: Text("New Booking", style: GoogleFonts.rye(fontSize: 14)),
    );
  }

  void _showCreateBookingDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final hoursController = TextEditingController(text: "1");
    SeatModel? selectedSeat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final shopService = context.watch<ShopService>();

          return Container(
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
                    "Create New Booking",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Customer Name
                  _buildTextField(nameController, "Customer Name", Icons.person_outline),
                  const SizedBox(height: 16),

                  // Phone
                  _buildTextField(phoneController, "Phone Number", Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // Duration
                  _buildTextField(hoursController, "Duration (Hours)", Icons.schedule_outlined,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),

                  // Select Seat
                  Text(
                    "Select Available Seat",
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<SeatModel>>(
                    stream: shopService.getSeats(widget.shop.id),
                    builder: (context, snapshot) {
                      final availableSeats = (snapshot.data ?? [])
                          .where((s) => s.status == SeatStatus.available)
                          .toList();

                      if (availableSeats.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            "No available seats",
                            style: GoogleFonts.crimsonText(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableSeats.map((seat) {
                          final isSelected = selectedSeat?.id == seat.id;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedSeat = seat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
                                    Icons.chair_rounded,
                                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    seat.name,
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 12,
                                      color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    "\$${seat.pricePerHour.toStringAsFixed(0)}/hr",
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 10,
                                      color: isSelected
                                          ? AppColors.gold.withValues(alpha: 0.8)
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  if (selectedSeat != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: GoogleFonts.crimsonText(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "\$${(selectedSeat!.pricePerHour * (int.tryParse(hoursController.text) ?? 1)).toStringAsFixed(0)}",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty ||
                          selectedSeat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields and select a seat")),
                        );
                        return;
                      }

                      final hours = int.tryParse(hoursController.text) ?? 1;
                      final totalAmount = selectedSeat!.pricePerHour * hours;

                      final booking = BookingModel(
                        id: '',
                        shopId: widget.shop.id,
                        seatId: selectedSeat!.id,
                        customerId: 'walk-in',
                        customerName: nameController.text.trim(),
                        customerPhone: phoneController.text.trim(),
                        startTime: DateTime.now(),
                        durationHours: hours,
                        totalAmount: totalAmount,
                        createdAt: DateTime.now(),
                      );

                      await shopService.createBooking(booking);
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
                      "CREATE BOOKING",
                      style: GoogleFonts.rye(fontSize: 16, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ACTIVE BOOKINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ActiveBookingsTab extends StatelessWidget {
  final ShopModel shop;
  const _ActiveBookingsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<BookingModel>>(
      stream: shopService.getActiveBookings(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bookings = snapshot.data!;

        if (bookings.isEmpty) {
          return _buildEmptyState("No Active Bookings", "All seats are currently free");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookings.length,
          itemBuilder: (context, index) => _BookingCard(
            booking: bookings[index],
            shop: shop,
            showActions: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  TODAY BOOKINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _TodayBookingsTab extends StatelessWidget {
  final ShopModel shop;
  const _TodayBookingsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<BookingModel>>(
      stream: shopService.getTodayBookings(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bookings = snapshot.data!;

        if (bookings.isEmpty) {
          return _buildEmptyState("No Bookings Today", "Start accepting customers");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookings.length,
          itemBuilder: (context, index) => _BookingCard(
            booking: bookings[index],
            shop: shop,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.today_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ALL BOOKINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _AllBookingsTab extends StatelessWidget {
  final ShopModel shop;
  const _AllBookingsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<BookingModel>>(
      stream: shopService.getBookings(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final bookings = snapshot.data!;

        if (bookings.isEmpty) {
          return _buildEmptyState("No Booking History", "Your bookings will appear here");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookings.length,
          itemBuilder: (context, index) => _BookingCard(
            booking: bookings[index],
            shop: shop,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BOOKING CARD WIDGET WITH AUTO-APPROVE TIMER
// ═══════════════════════════════════════════════════════════════════════════════

class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final ShopModel shop;
  final bool showActions;

  const _BookingCard({
    required this.booking,
    required this.shop,
    this.showActions = false,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  late Duration _remainingTime;
  bool _isAutoApproved = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    if (widget.booking.isPending) {
      _startAutoApproveTimer();
    }
  }

  void _calculateRemainingTime() {
    final autoApproveTime = widget.booking.createdAt.add(const Duration(minutes: 30));
    final now = DateTime.now();
    _remainingTime = autoApproveTime.difference(now);
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  void _startAutoApproveTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (widget.booking.isPending && !_isAutoApproved) {
        _calculateRemainingTime();
        if (_remainingTime <= Duration.zero) {
          _autoApprove();
        } else {
          setState(() {});
          _startAutoApproveTimer();
        }
      }
    });
  }

  Future<void> _autoApprove() async {
    if (_isAutoApproved) return;
    _isAutoApproved = true;
    final shopService = context.read<ShopService>();
    await shopService.approveBooking(
      widget.shop.id,
      widget.booking.id,
      widget.booking.seatId,
    );
  }

  String _formatRemainingTime() {
    if (_remainingTime <= Duration.zero) return "Auto-approving...";
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return "${minutes}m ${seconds.toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.booking.status);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Auto-approve countdown for pending bookings
          if (widget.booking.isPending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    "Auto-approve in: ",
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                  Text(
                    _formatRemainingTime(),
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
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
                            widget.booking.customerName,
                            style: GoogleFonts.crimsonText(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getStatusName(widget.booking.status),
                              style: GoogleFonts.crimsonText(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.booking.customerPhone,
                        style: GoogleFonts.crimsonText(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(widget.booking.startTime),
                            style: GoogleFonts.crimsonText(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.timer_rounded, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.booking.durationHours}h",
                            style: GoogleFonts.crimsonText(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${widget.booking.totalAmount.toStringAsFixed(0)}",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions for PENDING bookings - Approve/Reject
          if (widget.showActions && widget.booking.isPending)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<ShopService>().cancelBooking(
                              widget.shop.id,
                              widget.booking.id,
                              widget.booking.seatId,
                            );
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text("Reject"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<ShopService>().approveBooking(
                              widget.shop.id,
                              widget.booking.id,
                              widget.booking.seatId,
                            );
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Actions for CONFIRMED bookings - Cancel/Complete
          if (widget.showActions && (widget.booking.isConfirmed || widget.booking.isInProgress))
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<ShopService>().cancelBooking(
                              widget.shop.id,
                              widget.booking.id,
                              widget.booking.seatId,
                            );
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<ShopService>().completeBooking(
                              widget.shop.id,
                              widget.booking.id,
                              widget.booking.seatId,
                            );
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text("Complete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.info;
      case BookingStatus.inProgress:
        return AppColors.success;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusName(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return "Pending";
      case BookingStatus.confirmed:
        return "Confirmed";
      case BookingStatus.inProgress:
        return "In Progress";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
    }
  }
}
