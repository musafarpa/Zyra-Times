import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/admin/screens/admin_shop_list.dart';
import 'package:zyraslot/features/admin/screens/admin_user_list.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
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
              // Art Deco Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildHeader(),
              ),

              // Tab Bar with Art Deco styling
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTabBar(),
              ),

              // Content Area
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.parchmentGradient,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.gold, width: 2),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        // Decorative top border
                        _buildDecoTopBorder(),

                        // Tab content
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(2),
                            ),
                            child: TabBarView(
                              controller: _tabController,
                              children: const [
                                AdminShopList(),
                                AdminUserList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.woodGradient,
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Art Deco Badge with sunburst
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated sunburst
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(70, 70),
                        painter: _SunburstPainter(
                          progress: _shimmerController.value,
                          color: AppColors.gold,
                        ),
                      );
                    },
                  ),
                  // Badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldDark, width: 2),
                      boxShadow: AppColors.goldGlow,
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 28,
                      color: AppColors.woodDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldGradient.createShader(bounds),
                      child: Text(
                        "SHERIFF'S OFFICE",
                        style: GoogleFonts.rye(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDecoLine(30),
                        const SizedBox(width: 8),
                        Text(
                          "Administration & Oversight",
                          style: GoogleFonts.crimsonText(
                            fontSize: 13,
                            color: AppColors.gold.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildDecoLine(30),
                      ],
                    ),
                  ],
                ),
              ),

              // Logout Button with Art Deco styling
              GestureDetector(
                onTap: () => _showLogoutDialog(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          // Art Deco decorative bottom pattern
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChevronRow(5),
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

  Widget _buildChevronRow(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.6),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textTertiary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: AppColors.leatherGradient,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppColors.gold, width: 1.5),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: GoogleFonts.rye(fontSize: 13, letterSpacing: 1),
        unselectedLabelStyle: GoogleFonts.crimsonText(fontSize: 14),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.store_rounded, size: 18),
                const SizedBox(width: 8),
                const Text("REGISTRY"),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.people_rounded, size: 18),
                const SizedBox(width: 8),
                const Text("CITIZENS"),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoTopBorder() {
    return Container(
      height: 16,
      decoration: const BoxDecoration(
        gradient: AppColors.bronzeGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(11, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomPaint(
              size: const Size(8, 8),
              painter: _DiamondPainter(color: AppColors.gold),
            ),
          );
        }),
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
            Container(
              height: 20,
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDecoLine(40),
                  const SizedBox(width: 8),
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildDecoLine(40),
                ],
              ),
            ),
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
                  "Leave Office",
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from the Sheriff's Office?",
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

// ═══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS FOR ART DECO PATTERNS
// ═══════════════════════════════════════════════════════════════════════════

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

    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) + (progress * math.pi * 2 * 0.1);
      final opacity = 0.1 + (math.sin(progress * math.pi * 2 + i) * 0.08);
      paint.color = color.withValues(alpha: opacity.clamp(0.05, 0.25));

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

class _DiamondPainter extends CustomPainter {
  final Color color;

  _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondPainter oldDelegate) => false;
}
