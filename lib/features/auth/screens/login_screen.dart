import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/screens/signup_screen.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _shimmerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthService>().login(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$e"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.saloonBg),
        child: Stack(
          children: [
            // Art Deco geometric background pattern
            Positioned.fill(child: _buildArtDecoPattern()),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Art Deco Logo/Header
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildArtDecoHeader(),
                      ),

                      const SizedBox(height: 40),

                      // Login Card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildLoginCard(size),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFooter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtDecoPattern() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ArtDecoPatternPainter(
            progress: _shimmerController.value,
            color: AppColors.gold.withValues(alpha: 0.05),
          ),
        );
      },
    );
  }

  Widget _buildArtDecoHeader() {
    return Column(
      children: [
        // Art Deco sunburst behind logo
        Stack(
          alignment: Alignment.center,
          children: [
            // Sunburst rays
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(180, 180),
                  painter: _SunburstPainter(
                    progress: _shimmerController.value,
                    color: AppColors.gold,
                  ),
                );
              },
            ),
            // Center medallion
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDark, width: 3),
                boxShadow: AppColors.goldGlow,
              ),
              child: const Icon(
                Icons.diamond_rounded,
                size: 48,
                color: AppColors.woodDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Title with Art Deco styling
        ShaderMask(
          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
          child: Text(
            "ZYRA SLOT",
            style: GoogleFonts.rye(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Decorative line with diamonds
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecoLine(60),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 10,
                height: 10,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "SALOON",
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                color: AppColors.gold,
                letterSpacing: 6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 10,
                height: 10,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            _buildDecoLine(60),
          ],
        ),
      ],
    );
  }

  Widget _buildDecoLine(double width) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0),
            AppColors.gold,
            AppColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(Size size) {
    return Container(
      width: size.width > 420 ? 420 : double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        children: [
          // Art Deco top border decoration
          _buildDecoTopBorder(),

          // Form content
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Sign in to continue",
                          style: GoogleFonts.crimsonText(
                            fontSize: 15,
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email Field
                  _buildInputField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildInputField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Login Button
                  _buildGoldButton(
                    label: "SIGN IN",
                    icon: Icons.login_rounded,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _login,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  _buildDecoDivider(),

                  const SizedBox(height: 24),

                  // Register Button
                  _buildOutlinedButton(
                    label: "CREATE NEW ACCOUNT",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Art Deco bottom border decoration
          _buildDecoBottomBorder(),
        ],
      ),
    );
  }

  Widget _buildDecoTopBorder() {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        gradient: AppColors.leatherGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChevronPattern(),
        ],
      ),
    );
  }

  Widget _buildDecoBottomBorder() {
    return Container(
      height: 8,
      decoration: const BoxDecoration(
        gradient: AppColors.bronzeGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
      ),
    );
  }

  Widget _buildChevronPattern() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomPaint(
            size: const Size(12, 12),
            painter: _ChevronPainter(color: AppColors.gold),
          ),
        );
      }),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.crimsonText(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: AppColors.innerShadow,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            keyboardType: keyboardType,
            style: GoogleFonts.crimsonText(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.crimsonText(
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "This field is required";
              }
              if (!isPassword && !val.contains('@')) {
                return "Please enter a valid email";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoldButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback? onPressed,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? AppColors.goldGradient
                : LinearGradient(
                    colors: [AppColors.woodAccent, AppColors.woodAccent],
                  ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.goldDark, width: 2),
            boxShadow: onPressed != null ? AppColors.goldGlow : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(2),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.woodDark,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: AppColors.woodDark, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: GoogleFonts.rye(
                              fontSize: 15,
                              color: AppColors.woodDark,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.rye(
                fontSize: 14,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecoDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border.withValues(alpha: 0),
                  AppColors.border,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 6,
                  height: 6,
                  color: AppColors.bronze,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "OR",
                style: GoogleFonts.crimsonText(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 6,
                  height: 6,
                  color: AppColors.bronze,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border,
                  AppColors.border.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: AppColors.rope),
            const SizedBox(width: 6),
            Text(
              "Secure & Encrypted",
              style: GoogleFonts.crimsonText(
                fontSize: 12,
                color: AppColors.rope,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Play Responsibly",
          style: GoogleFonts.crimsonText(
            fontSize: 11,
            color: AppColors.rope.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS FOR ART DECO PATTERNS
// ═══════════════════════════════════════════════════════════════════════════

class _ArtDecoPatternPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArtDecoPatternPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw Art Deco fan/sunburst pattern in corners
    _drawCornerFan(canvas, Offset.zero, size.width * 0.3, paint, 0);
    _drawCornerFan(canvas, Offset(size.width, 0), size.width * 0.3, paint, 1);
    _drawCornerFan(canvas, Offset(0, size.height), size.width * 0.3, paint, 2);
    _drawCornerFan(canvas, Offset(size.width, size.height), size.width * 0.3, paint, 3);
  }

  void _drawCornerFan(Canvas canvas, Offset corner, double radius, Paint paint, int quadrant) {
    final startAngle = quadrant * (math.pi / 2);
    for (int i = 0; i < 8; i++) {
      final angle = startAngle + (i * math.pi / 16);
      final endX = corner.dx + math.cos(angle) * radius;
      final endY = corner.dy + math.sin(angle) * radius;
      canvas.drawLine(corner, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArtDecoPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

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
      ..strokeWidth = 1.5;

    // Draw animated rays
    for (int i = 0; i < 24; i++) {
      final angle = (i * math.pi / 12) + (progress * math.pi * 2 * 0.05);
      final opacity = 0.15 + (math.sin(progress * math.pi * 2 + i) * 0.1);
      paint.color = color.withValues(alpha: opacity.clamp(0.05, 0.3));

      final innerRadius = maxRadius * 0.4;
      final outerRadius = maxRadius * (0.7 + (i % 2) * 0.15);

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

class _ChevronPainter extends CustomPainter {
  final Color color;

  _ChevronPainter({required this.color});

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
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) => false;
}
