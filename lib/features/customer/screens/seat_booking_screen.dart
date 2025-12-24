import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/seat_model.dart';
import 'package:zyraslot/models/booking_model.dart';

class SeatBookingScreen extends StatefulWidget {
  final ShopModel shop;
  final SeatModel? selectedSeat;

  const SeatBookingScreen({
    super.key,
    required this.shop,
    this.selectedSeat,
  });

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  SeatModel? _selectedSeat;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final int _durationHours = 1;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSeat = widget.selectedSeat;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    if (_selectedSeat == null || !_selectedSeat!.hasPricing) return 0;
    return _selectedSeat!.pricePerHour * _durationHours;
  }

  bool get _hasPricing => _selectedSeat?.hasPricing ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Info Header
            _buildShopHeader(),
            const SizedBox(height: 24),

            // Step 1: Select Seat
            _buildSectionHeader("1. Select Your Seat"),
            const SizedBox(height: 16),
            _buildSeatSelection(),
            const SizedBox(height: 24),

            // Step 2: Select Date
            _buildSectionHeader("2. Select Date"),
            const SizedBox(height: 16),
            _buildDateSelection(),
            const SizedBox(height: 24),

            // Step 3: Select Time
            _buildSectionHeader("3. Select Time"),
            const SizedBox(height: 16),
            _buildTimeSelection(),
            const SizedBox(height: 24),

            // Notes (Optional)
            _buildSectionHeader("4. Notes (Optional)"),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 32),

            // Booking Summary
            _buildBookingSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
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
        "Book Appointment",
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildShopHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.leatherGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.shop.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(widget.shop.imageUrl, fit: BoxFit.cover),
                  )
                : const Icon(Icons.store_rounded, color: AppColors.gold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shop.name,
                  style: GoogleFonts.rye(
                    fontSize: 18,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      widget.shop.rating.toStringAsFixed(1),
                      style: GoogleFonts.crimsonText(
                        fontSize: 13,
                        color: AppColors.rope,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_rounded, size: 14, color: AppColors.rope),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.shop.address,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: AppColors.rope,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
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

  Widget _buildSeatSelection() {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<SeatModel>>(
      stream: shopService.getSeats(widget.shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final availableSeats = snapshot.data!
            .where((s) => s.status == SeatStatus.available)
            .toList();

        if (availableSeats.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  "No seats available right now",
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableSeats.map((seat) {
            final isSelected = _selectedSeat?.id == seat.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedSeat = seat),
              child: Container(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getSeatTypeIcon(seat.type),
                      size: 28,
                      color: isSelected ? AppColors.gold : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      seat.name,
                      style: GoogleFonts.crimsonText(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.gold : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (seat.hasPricing)
                      Text(
                        "\$${seat.pricePerHour.toStringAsFixed(0)}/hr",
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: isSelected ? AppColors.gold.withValues(alpha: 0.8) : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        "Free",
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: isSelected ? AppColors.gold.withValues(alpha: 0.8) : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.2)
                            : AppColors.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSeatTypeName(seat.type),
                        style: GoogleFonts.crimsonText(
                          fontSize: 9,
                          color: isSelected ? AppColors.gold : AppColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((date) {
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;
          final isToday = date.day == today.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.secondary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: isSelected ? AppColors.gold.withValues(alpha: 0.8) : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.gold : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: GoogleFonts.crimsonText(
                      fontSize: 11,
                      color: isSelected ? AppColors.gold.withValues(alpha: 0.8) : AppColors.textTertiary,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Today",
                        style: GoogleFonts.crimsonText(
                          fontSize: 8,
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSelection() {
    final times = [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 11, minute: 0),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 15, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 17, minute: 0),
      TimeOfDay(hour: 18, minute: 0),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        final isSelected = _selectedTime.hour == time.hour && _selectedTime.minute == time.minute;
        final formattedTime = _formatTime(time);

        return GestureDetector(
          onTap: () => setState(() => _selectedTime = time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              formattedTime,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.gold : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        style: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Any special requests or notes...",
          hintStyle: GoogleFonts.crimsonText(color: AppColors.textTertiary),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 40),
            child: Icon(Icons.note_alt_outlined, color: AppColors.primary),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Booking Summary",
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          _buildSummaryRow("Shop", widget.shop.name),
          _buildSummaryRow("Seat", _selectedSeat?.name ?? "Not selected"),
          _buildSummaryRow(
            "Date",
            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
          ),
          _buildSummaryRow("Time", _formatTime(_selectedTime)),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          if (_hasPricing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "\$${_totalAmount.toStringAsFixed(0)}",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "FREE",
                    style: GoogleFonts.rye(
                      fontSize: 18,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        border: Border(
          top: BorderSide(color: AppColors.secondary, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _selectedSeat == null || _isLoading ? null : _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.gold,
            disabledBackgroundColor: AppColors.surface,
            disabledForegroundColor: AppColors.textTertiary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "CONFIRM BOOKING",
                      style: GoogleFonts.rye(fontSize: 16, letterSpacing: 1),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.check_circle_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  void _confirmBooking() async {
    if (_selectedSeat == null) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final shopService = context.read<ShopService>();
      final user = authService.currentUserModel;

      if (user == null) {
        _showError("Please login to make a booking");
        return;
      }

      // Create start time from selected date and time
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final booking = BookingModel(
        id: '',
        shopId: widget.shop.id,
        seatId: _selectedSeat!.id,
        customerId: user.uid,
        customerName: user.name,
        customerPhone: user.phone,
        startTime: startTime,
        durationHours: _durationHours,
        totalAmount: _totalAmount,
        status: BookingStatus.pending,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      await shopService.createBooking(booking);

      // Send notification to shop owner
      await shopService.sendBookingNotification(
        shopId: widget.shop.id,
        bookingId: booking.id,
        customerName: user.name,
        customerId: user.uid,
        bookingTime: startTime,
        seatName: _selectedSeat!.name,
      );

      if (mounted) {
        _showBookingSuccess();
      }
    } catch (e) {
      _showError("Failed to create booking: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBookingSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.success, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Booking Confirmed!",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your appointment has been sent to ${widget.shop.name}. You will receive a notification once it's confirmed.",
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to shop details
                  Navigator.pop(context); // Go back to shop list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "DONE",
                  style: GoogleFonts.rye(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.crimsonText()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
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
