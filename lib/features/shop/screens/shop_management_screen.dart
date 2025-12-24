import 'dart:math' as math;
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

class ShopManagementScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopManagementScreen({super.key, required this.shop});

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _headerAnimController;
  late AnimationController _shimmerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.saloonBg),
        child: SafeArea(
          child: Column(
            children: [
              // Art Deco App Bar
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.woodGradient,
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Shop Icon with Art Deco sunburst
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(60, 60),
                        painter: _SunburstPainter(
                          progress: _shimmerController.value,
                          color: AppColors.gold,
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.goldDark, width: 2),
                      boxShadow: AppColors.softGoldGlow,
                    ),
                    child: widget.shop.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(2),
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
                ],
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
                        _buildStatBadge(
                          Icons.star_rounded,
                          widget.shop.rating.toStringAsFixed(1),
                          AppColors.gold,
                        ),
                        const SizedBox(width: 8),
                        _buildStatBadge(
                          Icons.chair_rounded,
                          "${widget.shop.totalSeats}",
                          AppColors.rope,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Notification Bell
              _buildNotificationBell(),

              // Logout
              GestureDetector(
                onTap: () => _showLogoutDialog(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Art Deco decorative row
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.gold.withValues(alpha: 0.5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.crimsonText(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
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
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.woodDark, width: 1.5),
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
        decoration: BoxDecoration(
          gradient: AppColors.parchmentGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          border: Border.all(color: AppColors.gold, width: 2),
        ),
        child: Column(
          children: [
            // Art Deco handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bronze,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
        gradient: AppColors.woodGradient,
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
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: AppColors.goldDark, width: 1)
              : null,
          boxShadow: isSelected ? AppColors.softGoldGlow : null,
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
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.gold, width: 2),
        ),
        title: Column(
          children: [
            // Decorative top
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDecoLine(40),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(width: 8, height: 8, color: AppColors.gold),
                ),
                const SizedBox(width: 8),
                _buildDecoLine(40),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.woodDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Leave Establishment",
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from your establishment?",
          textAlign: TextAlign.center,
          style: GoogleFonts.crimsonText(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: _buildOutlinedButton(
                  label: "STAY",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoldButton(
                  label: "LOGOUT",
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthService>().logout();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecoLine(double width) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0),
            AppColors.gold.withValues(alpha: 0.5),
            AppColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldDark, width: 2),
        boxShadow: AppColors.softGoldGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.woodDark, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.rye(
                  fontSize: 13,
                  color: AppColors.woodDark,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

class _SunburstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SunburstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) + (progress * math.pi * 2 * 0.1);
      final opacity = 0.1 + (math.sin(progress * math.pi * 2 + i) * 0.08);
      paint.color = color.withValues(alpha: opacity.clamp(0.05, 0.2));

      final innerRadius = maxRadius * 0.5;
      final outerRadius = maxRadius * (0.8 + (i % 2) * 0.15);

      final startX = center.dx + math.cos(angle) * innerRadius;
      final startY = center.dy + math.sin(angle) * innerRadius;
      final endX = center.dx + math.cos(angle) * outerRadius;
      final endY = center.dy + math.sin(angle) * outerRadius;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) {
    return oldDelegate.progress != progress;
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
          onRefresh: () async {},
          color: AppColors.gold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
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
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldGradient.createShader(bounds),
                      child: Text(
                        "Proprietor",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.goldGlow,
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  size: 36,
                  color: AppColors.woodDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Decorative diamonds
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 8,
            height: 8,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold,
                  AppColors.gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
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
                  borderRadius: BorderRadius.circular(4),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.parchmentGradient,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
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
              gradient: AppColors.parchmentGradient,
              borderRadius: BorderRadius.circular(4),
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
                gradient: AppColors.parchmentGradient,
                borderRadius: BorderRadius.circular(4),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Navigate to Bookings tab to create new booking",
          style: GoogleFonts.crimsonText(),
        ),
        backgroundColor: AppColors.woodMedium,
      ),
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
          _buildSectionHeader("Establishment Details"),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 24),
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
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 8,
            height: 8,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold,
                  AppColors.gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.parchmentGradient,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
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
          borderRadius: BorderRadius.circular(4),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text("Delete", style: GoogleFonts.rye(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
