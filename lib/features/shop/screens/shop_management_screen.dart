import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/features/shop/screens/staff_management_screen.dart';
import 'package:zyraslot/features/shop/screens/seat_management_screen.dart';
import 'package:zyraslot/features/shop/screens/booking_management_screen.dart';
import 'package:zyraslot/features/shop/screens/service_management_screen.dart';
import 'package:zyraslot/features/shop/screens/notification_screen.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/booking_model.dart';
import 'package:zyraslot/widgets/animated_saloon_widgets.dart';

class ShopManagementScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopManagementScreen({super.key, required this.shop});

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Custom App Bar
            FadeTransition(
              opacity: _headerAnimation,
              child: _buildAppBar(),
            ),

            // Content
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _OverviewTab(shop: widget.shop),
                  _ServicesTab(shop: widget.shop),
                  _SeatsTab(shop: widget.shop),
                  _StaffTab(shop: widget.shop),
                  _BookingsTab(shop: widget.shop),
                  _SettingsTab(shop: widget.shop),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.woodDark,
            AppColors.woodMedium,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shop Icon with Glow
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: widget.shop.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.shop.imageUrl,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.store_rounded,
                        color: AppColors.woodDark,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.store_rounded,
                    color: AppColors.woodDark,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),

          // Shop Info
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            widget.shop.rating.toStringAsFixed(1),
                            style: GoogleFonts.crimsonText(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.rope.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chair_rounded, size: 12, color: AppColors.rope),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.shop.totalSeats}",
                            style: GoogleFonts.crimsonText(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.rope,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification Bell with Badge
          _buildNotificationBell(),

          // Logout
          GestureDetector(
            onTap: () => _showLogoutDialog(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<int>(
      stream: shopService.getUnreadNotificationCount(widget.shop.id),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () => _showNotifications(),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: GoogleFonts.crimsonText(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Notification Screen
            Expanded(
              child: NotificationScreen(shop: widget.shop, embedded: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.woodMedium,
            AppColors.woodDark,
          ],
        ),
        border: Border(
          top: BorderSide(color: AppColors.gold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, "Overview"),
              _buildNavItem(1, Icons.spa_rounded, "Services"),
              _buildNavItem(2, Icons.chair_alt_rounded, "Seats"),
              _buildNavItem(3, Icons.people_rounded, "Staff"),
              _buildNavItem(4, Icons.book_rounded, "Bookings"),
              _buildNavItem(5, Icons.settings_rounded, "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.goldGradient : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.woodDark : AppColors.gold.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.crimsonText(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.woodDark : AppColors.gold.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Leave Establishment",
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from your establishment?",
          style: GoogleFonts.crimsonText(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Stay",
              style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
            ),
          ),
          GlowingGoldButton(
            label: "LOGOUT",
            icon: Icons.logout_rounded,
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().logout();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final ShopModel shop;
  const _OverviewTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return FutureBuilder<Map<String, dynamic>>(
      future: shopService.getShopStats(shop.id),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {
          'totalSeats': 0,
          'availableSeats': 0,
          'occupiedSeats': 0,
          'activeStaff': 0,
          'todayBookings': 0,
          'todayRevenue': 0.0,
        };

        return RefreshIndicator(
          onRefresh: () async {
            // Trigger rebuild
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeCard(),

                const SizedBox(height: 24),

                // Quick Stats
                _buildSectionHeader("Today's Overview"),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Revenue",
                        "\$${(stats['todayRevenue'] as double).toStringAsFixed(0)}",
                        Icons.attach_money_rounded,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "Bookings",
                        "${stats['todayBookings']}",
                        Icons.calendar_today_rounded,
                        AppColors.info,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Available",
                        "${stats['availableSeats']}",
                        Icons.event_seat_rounded,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "Occupied",
                        "${stats['occupiedSeats']}",
                        Icons.person_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                _buildSectionHeader("Quick Actions"),
                const SizedBox(height: 16),

                _buildQuickAction(
                  context,
                  "New Booking",
                  "Create a walk-in booking",
                  Icons.add_circle_outline_rounded,
                  AppColors.success,
                  () => _showNewBookingDialog(context),
                ),

                _buildQuickAction(
                  context,
                  "Manage Seats",
                  "Update seat availability",
                  Icons.chair_alt_rounded,
                  AppColors.info,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeatManagementScreen(shop: shop),
                    ),
                  ),
                ),

                _buildQuickAction(
                  context,
                  "View Staff",
                  "Check staff schedule",
                  Icons.people_rounded,
                  AppColors.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffManagementScreen(shop: shop),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Active Bookings
                _buildSectionHeader("Active Sessions"),
                const SizedBox(height: 16),

                _buildActiveBookings(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    if (hour >= 17) greeting = "Good Evening";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.leatherGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.rope,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Proprietor",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your establishment awaits",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.rope,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.diamond_rounded,
              size: 40,
              color: AppColors.gold,
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
          child: Container(
            height: 1,
            color: AppColors.divider,
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
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.crimsonText(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.crimsonText(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookings(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<BookingModel>>(
      stream: shopService.getActiveBookings(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  "No Active Sessions",
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: snapshot.data!.take(3).map((booking) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: GoogleFonts.crimsonText(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          "Seat #${booking.seatId.substring(0, 6)}",
                          style: GoogleFonts.crimsonText(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\$${booking.totalAmount.toStringAsFixed(0)}",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showNewBookingDialog(BuildContext context) {
    // Navigate to booking screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigate to Bookings tab to create new booking")),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SERVICES TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ServicesTab extends StatelessWidget {
  final ShopModel shop;
  const _ServicesTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return ServiceManagementScreen(shop: shop, embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SEATS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _SeatsTab extends StatelessWidget {
  final ShopModel shop;
  const _SeatsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SeatManagementScreen(shop: shop, embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STAFF TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _StaffTab extends StatelessWidget {
  final ShopModel shop;
  const _StaffTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return StaffManagementScreen(shop: shop, embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BOOKINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _BookingsTab extends StatelessWidget {
  final ShopModel shop;
  const _BookingsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return BookingManagementScreen(shop: shop, embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SETTINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _SettingsTab extends StatelessWidget {
  final ShopModel shop;
  const _SettingsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Info Section
          _buildSectionHeader("Establishment Details"),
          const SizedBox(height: 16),

          _buildInfoCard(),

          const SizedBox(height: 24),

          // Actions Section
          _buildSectionHeader("Actions"),
          const SizedBox(height: 16),

          _buildSettingItem(
            context,
            "Edit Shop Details",
            "Update name, description, address",
            Icons.edit_rounded,
            AppColors.primary,
            () {},
          ),

          _buildSettingItem(
            context,
            "Operating Hours",
            "Set your business hours",
            Icons.schedule_rounded,
            AppColors.info,
            () {},
          ),

          _buildSettingItem(
            context,
            "Pricing",
            "Manage seat pricing",
            Icons.attach_money_rounded,
            AppColors.success,
            () {},
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader("Danger Zone"),
          const SizedBox(height: 16),

          _buildDangerAction(context),
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
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildInfoRow("Name", shop.name),
          const Divider(height: 24, color: AppColors.divider),
          _buildInfoRow("Address", shop.address),
          const Divider(height: 24, color: AppColors.divider),
          _buildInfoRow("Total Seats", "${shop.totalSeats}"),
          const Divider(height: 24, color: AppColors.divider),
          _buildInfoRow("Rating", "${shop.rating.toStringAsFixed(1)} / 5.0"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.crimsonText(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.crimsonText(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delete Establishment",
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  "This action cannot be undone",
                  style: GoogleFonts.crimsonText(
                    fontSize: 13,
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showDeleteDialog(context),
            child: Text(
              "DELETE",
              style: GoogleFonts.rye(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Text(
          "Delete Establishment",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(
          "Are you sure you want to delete ${shop.name}? This will remove all seats, staff, and booking records. This action cannot be undone.",
          style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
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
              context.read<ShopService>().deleteShop(shop.id);
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
}
