import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyraslot/core/constants/app_colors.dart';

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║               ANIMATED VINTAGE SALOON WIDGETS                              ║
// ║        Premium UI Components with Western Theme Animations                 ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

/// Swinging Saloon Sign - Animated entrance sign with gentle swing
class SwingingSaloonSign extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final double? width;

  const SwingingSaloonSign({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.width,
  });

  @override
  State<SwingingSaloonSign> createState() => _SwingingSaloonSignState();
}

class _SwingingSaloonSignState extends State<SwingingSaloonSign>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _swingAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chain/Hook at top
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.gold.withValues(alpha: 0.5),
                AppColors.gold,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedBuilder(
          animation: _swingAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()..rotateZ(_swingAnimation.value),
              child: child,
            );
          },
          child: Container(
            width: widget.width ?? 280,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              gradient: AppColors.woodGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(height: 12),
                ],
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.goldGradient.createShader(bounds),
                  child: Text(
                    widget.title,
                    style: GoogleFonts.rye(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDecorativeLine(),
                      const SizedBox(width: 12),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.rye(
                          fontSize: 12,
                          color: AppColors.secondary,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildDecorativeLine(),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeLine() {
    return Container(
      width: 20,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.3),
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }
}

/// Glowing Gold Button with pulse animation
class GlowingGoldButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const GlowingGoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  State<GlowingGoldButton> createState() => _GlowingGoldButtonState();
}

class _GlowingGoldButtonState extends State<GlowingGoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? AppColors.leatherGradient
                : null,
            color: widget.onPressed == null ? AppColors.woodAccent : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: _glowAnimation.value),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: AppColors.gold, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: GoogleFonts.rye(
                              fontSize: 16,
                              color: AppColors.gold,
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
}

/// Vintage Frame with ornate corners
class VintageFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double cornerSize;

  const VintageFrame({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.cornerSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.secondary;
    return Stack(
      children: [
        Container(
          padding: padding ?? const EdgeInsets.all(20),
          margin: EdgeInsets.all(cornerSize / 2),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: child,
        ),
        // Corner ornaments
        Positioned(top: 0, left: 0, child: _buildCorner(color, 0)),
        Positioned(top: 0, right: 0, child: _buildCorner(color, 1)),
        Positioned(bottom: 0, left: 0, child: _buildCorner(color, 2)),
        Positioned(bottom: 0, right: 0, child: _buildCorner(color, 3)),
      ],
    );
  }

  Widget _buildCorner(Color color, int position) {
    return Transform.rotate(
      angle: position * math.pi / 2,
      child: Container(
        width: cornerSize,
        height: cornerSize,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color, width: 3),
            left: BorderSide(color: color, width: 3),
          ),
        ),
      ),
    );
  }
}

/// Animated Card with hover/tap scale effect
class AnimatedSaloonCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasGoldBorder;

  const AnimatedSaloonCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.hasGoldBorder = false,
  });

  @override
  State<AnimatedSaloonCard> createState() => _AnimatedSaloonCardState();
}

class _AnimatedSaloonCardState extends State<AnimatedSaloonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 8, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: AppColors.parchmentGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.hasGoldBorder ? AppColors.gold : AppColors.border,
                width: widget.hasGoldBorder ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.15),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer Loading Effect
class SaloonShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const SaloonShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<SaloonShimmer> createState() => _SaloonShimmerState();
}

class _SaloonShimmerState extends State<SaloonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.gold.withValues(alpha: 0.3),
                AppColors.surface,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Animated Counter with vintage styling
class AnimatedVintageCounter extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const AnimatedVintageCounter({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, val, child) {
              return Text(
                val.toString(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing Notification Badge
class PulsingBadge extends StatefulWidget {
  final int count;
  final Widget child;

  const PulsingBadge({
    super.key,
    required this.count,
    required this.child,
  });

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.velvetGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.velvet.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.count > 99 ? '99+' : widget.count.toString(),
                      style: GoogleFonts.crimsonText(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Vintage Divider with ornament
class VintageDivider extends StatelessWidget {
  final String? text;
  final double? indent;

  const VintageDivider({
    super.key,
    this.text,
    this.indent,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: indent ?? 0),
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.1),
              AppColors.secondary,
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.only(left: indent ?? 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.divider.withValues(alpha: 0.1),
                  AppColors.divider,
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
              _buildDiamond(),
              const SizedBox(width: 8),
              Text(
                text!,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              _buildDiamond(),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.only(right: indent ?? 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.divider,
                  AppColors.divider.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiamond() {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 6,
        height: 6,
        color: AppColors.secondary,
      ),
    );
  }
}

/// Fade In Animation Wrapper
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset? slideOffset;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered List Animation
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 100),
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: widget.baseDelay.inMilliseconds * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Rotating Loading Ornament
class VintageLoader extends StatefulWidget {
  final String? message;
  final double size;

  const VintageLoader({
    super.key,
    this.message,
    this.size = 60,
  });

  @override
  State<VintageLoader> createState() => _VintageLoaderState();
}

class _VintageLoaderState extends State<VintageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.1),
                      AppColors.gold,
                      AppColors.gold.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: widget.size - 10,
                    height: widget.size - 10,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: Icon(
                      Icons.diamond_rounded,
                      color: AppColors.gold,
                      size: widget.size / 3,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
