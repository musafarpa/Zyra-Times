import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      // If Shop Owner, navigate to shop details page
      if (_selectedRole == UserRole.shopr) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ShopOwnerDetailsScreen(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
        );
        // If shop details were submitted successfully, pop back to login
        if (result == true && mounted) {
          Navigator.pop(context);
        }
        return;
      }

      // Customer signup - proceed directly
      setState(() => _isLoading = true);
      try {
        await context.read<AuthService>().signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              role: _selectedRole,
            );
        if (mounted) Navigator.pop(context);
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom Art Deco App Bar
                _buildAppBar(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header with Art Deco styling
                        _buildHeader(),

                        const SizedBox(height: 28),

                        // Form Card with Art Deco borders
                        _buildFormCard(size),

                        const SizedBox(height: 24),

                        // Footer
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button with Art Deco styling
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.gold,
              iconSize: 24,
            ),
          ),
          const Spacer(),
          // Decorative diamond
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
            "REGISTRATION",
            style: GoogleFonts.rye(
              fontSize: 18,
              color: AppColors.gold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 8,
              height: 8,
              color: AppColors.gold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Icon with Art Deco sunburst
        Stack(
          alignment: Alignment.center,
          children: [
            // Sunburst rays
            CustomPaint(
              size: const Size(140, 140),
              painter: _DecoRaysPainter(color: AppColors.gold),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDark, width: 3),
                boxShadow: AppColors.goldGlow,
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 42,
                color: AppColors.woodDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
          child: Text(
            "Create Account",
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Decorative line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecoLine(50),
            const SizedBox(width: 10),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 8,
                height: 8,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            _buildDecoLine(50),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Join our prestigious establishment",
          style: GoogleFonts.crimsonText(
            fontSize: 16,
            color: AppColors.rope,
            fontStyle: FontStyle.italic,
          ),
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

  Widget _buildFormCard(Size size) {
    return Container(
      width: size.width > 450 ? 450 : double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        children: [
          // Art Deco top border
          _buildDecoTopBorder(),

          // Form content
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Personal Information Section
                  _buildSectionHeader("Personal Information", Icons.person_outline),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 18),

                  _buildInputField(
                    controller: _phoneController,
                    label: "Phone Number",
                    hint: "Enter your phone number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 28),

                  // Account Section
                  _buildSectionHeader("Account Details", Icons.account_circle_outlined),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  _buildInputField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Create a strong password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildInputField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Re-enter your password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "This field is required";
                      }
                      if (val != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Role Selection - Simple Text Choice
                  _buildSectionHeader("I want to", Icons.category_outlined),
                  const SizedBox(height: 16),

                  _buildRoleChoice(),

                  const SizedBox(height: 32),

                  // Submit Button with Art Deco styling
                  _buildGoldButton(
                    onPressed: _isLoading ? null : _signUp,
                    isLoading: _isLoading,
                    label: _selectedRole == UserRole.shopr ? "CONTINUE" : "CREATE ACCOUNT",
                    icon: _selectedRole == UserRole.shopr
                        ? Icons.arrow_forward_rounded
                        : Icons.how_to_reg_rounded,
                  ),

                  const SizedBox(height: 20),

                  // Login Link with Art Deco divider
                  _buildDecoDivider(),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.crimsonText(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Sign In",
                              style: GoogleFonts.crimsonText(
                                fontSize: 15,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
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

          // Art Deco bottom border
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
      children: List.generate(9, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: CustomPaint(
            size: const Size(10, 10),
            painter: _ChevronPainter(color: AppColors.gold),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
            obscureText: isPassword && obscureText,
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
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 22,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator ??
                (val) {
                  if (val == null || val.isEmpty) {
                    return "This field is required";
                  }
                  if (label.contains("Email") && !val.contains('@')) {
                    return "Please enter a valid email";
                  }
                  if (isPassword && val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
          ),
        ),
      ],
    );
  }

  // Simple text-based role choice
  Widget _buildRoleChoice() {
    return Column(
      children: [
        // Customer Option
        _buildRoleOption(
          role: UserRole.customer,
          icon: Icons.person_outline,
          title: "Book Appointments",
          subtitle: "Find and book at barbershops near you",
        ),
        const SizedBox(height: 12),
        // Shop Owner Option
        _buildRoleOption(
          role: UserRole.shopr,
          icon: Icons.store_outlined,
          title: "Manage My Shop",
          subtitle: "Register your barbershop and manage bookings",
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.ivory,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio-style indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Icon
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.gold : AppColors.textTertiary,
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow for shop owner
            if (role == UserRole.shopr && isSelected)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.gold,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String label,
    required IconData icon,
  }) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: AppColors.bronze,
                  ),
                ),
              );
            }),
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
        Text(
          "By creating an account, you agree to our",
          style: GoogleFonts.crimsonText(
            fontSize: 12,
            color: AppColors.rope,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Terms of Service",
                style: GoogleFonts.crimsonText(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              " & ",
              style: GoogleFonts.crimsonText(
                fontSize: 12,
                color: AppColors.rope,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Privacy Policy",
                style: GoogleFonts.crimsonText(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHOP OWNER DETAILS SCREEN - SEPARATE PAGE
// ═══════════════════════════════════════════════════════════════════════════

class ShopOwnerDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const ShopOwnerDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<ShopOwnerDetailsScreen> createState() => _ShopOwnerDetailsScreenState();
}

class _ShopOwnerDetailsScreenState extends State<ShopOwnerDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _shopCityController = TextEditingController();

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopDescriptionController.dispose();
    _shopCityController.dispose();
    super.dispose();
  }

  Future<void> _createShopOwnerAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Create user account
        await context.read<AuthService>().signUp(
              email: widget.email,
              password: widget.password,
              name: widget.name,
              phone: widget.phone,
              role: UserRole.shopr,
            );

        // TODO: Save shop details to Firestore
        // This would typically be done in the AuthService or a ShopService

        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // App Bar
                _buildAppBar(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),

                        const SizedBox(height: 28),

                        // Form Card
                        _buildFormCard(size),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.gold,
              iconSize: 24,
            ),
          ),
          const Spacer(),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 8, height: 8, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Text(
            "SHOP DETAILS",
            style: GoogleFonts.rye(
              fontSize: 18,
              color: AppColors.gold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 8, height: 8, color: AppColors.gold),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon with sunburst
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(120, 120),
              painter: _DecoRaysPainter(color: AppColors.gold),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldDark, width: 3),
                boxShadow: AppColors.goldGlow,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 38,
                color: AppColors.woodDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
          child: Text(
            "Your Shop",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tell us about your establishment",
          style: GoogleFonts.crimsonText(
            fontSize: 15,
            color: AppColors.rope,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(Size size) {
    return Container(
      width: size.width > 450 ? 450 : double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        children: [
          // Top border
          Container(
            height: 24,
            decoration: const BoxDecoration(
              gradient: AppColors.leatherGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(9, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: CustomPaint(
                    size: const Size(10, 10),
                    painter: _ChevronPainter(color: AppColors.gold),
                  ),
                );
              }),
            ),
          ),

          // Form
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.goldDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Complete your shop profile to start receiving bookings",
                            style: GoogleFonts.crimsonText(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shop Name
                  _buildInputField(
                    controller: _shopNameController,
                    label: "Shop Name",
                    hint: "Enter your shop name",
                    icon: Icons.store_outlined,
                  ),

                  const SizedBox(height: 18),

                  // City
                  _buildInputField(
                    controller: _shopCityController,
                    label: "City",
                    hint: "Enter your city",
                    icon: Icons.location_city_outlined,
                  ),

                  const SizedBox(height: 18),

                  // Address
                  _buildInputField(
                    controller: _shopAddressController,
                    label: "Shop Address",
                    hint: "Enter full shop address",
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 18),

                  // Description
                  _buildTextAreaField(
                    controller: _shopDescriptionController,
                    label: "Shop Description",
                    hint: "Describe your shop and services offered...",
                    icon: Icons.description_outlined,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  _buildGoldButton(),

                  const SizedBox(height: 16),

                  // Back link
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Go Back",
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom border
          Container(
            height: 8,
            decoration: const BoxDecoration(
              gradient: AppColors.bronzeGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
            maxLines: 4,
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
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
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
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoldButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: !_isLoading ? AppColors.goldGradient : null,
        color: _isLoading ? AppColors.woodAccent : null,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.goldDark, width: 2),
        boxShadow: !_isLoading ? AppColors.goldGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _createShopOwnerAccount,
          borderRadius: BorderRadius.circular(2),
          child: Center(
            child: _isLoading
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
                      const Icon(Icons.check_circle_outline, color: AppColors.woodDark, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        "CREATE SHOP ACCOUNT",
                        style: GoogleFonts.rye(
                          fontSize: 14,
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
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS FOR ART DECO PATTERNS
// ═══════════════════════════════════════════════════════════════════════════

class _DecoRaysPainter extends CustomPainter {
  final Color color;

  _DecoRaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw rays
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8);
      final opacity = 0.15 + (i % 2) * 0.1;
      paint.color = color.withValues(alpha: opacity);

      final innerRadius = maxRadius * 0.5;
      final outerRadius = maxRadius * (0.85 + (i % 2) * 0.1);

      final startX = center.dx + math.cos(angle) * innerRadius;
      final startY = center.dy + math.sin(angle) * innerRadius;
      final endX = center.dx + math.cos(angle) * outerRadius;
      final endY = center.dy + math.sin(angle) * outerRadius;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DecoRaysPainter oldDelegate) => false;
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
