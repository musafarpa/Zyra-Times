import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/customer/screens/seat_booking_screen.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/seat_model.dart';
import 'package:zyraslot/models/service_model.dart';
import 'package:zyraslot/widgets/animated_saloon_widgets.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  ShopModel get shop => widget.shop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.cardColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with sepia overlay
                  if (shop.imageUrl.isNotEmpty)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.woodMedium.withValues(alpha: 0.3),
                        BlendMode.overlay,
                      ),
                      child: Image.network(
                        shop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  else
                    _buildPlaceholder(),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Shop Name at bottom
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: GoogleFonts.rye(
                            fontSize: 28,
                            color: AppColors.textPrimary,
                            shadows: [
                              Shadow(
                                color: AppColors.shadow.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              shop.rating.toStringAsFixed(1),
                              style: GoogleFonts.crimsonText(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text("•", style: TextStyle(color: AppColors.textTertiary)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                shop.address,
                                style: GoogleFonts.crimsonText(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
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
            ),
          ),

          // About Section with Animation
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("About"),
                    const SizedBox(height: 12),
                    Text(
                      shop.description.isNotEmpty
                          ? shop.description
                          : "A fine establishment offering superior services for distinguished patrons.",
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.chair_rounded,
                      "${shop.totalSeats}",
                      "Total Seats",
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.star_rounded,
                      shop.rating.toStringAsFixed(1),
                      "Rating",
                      AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.location_on_rounded,
                      "Local",
                      "Area",
                      AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Available Seats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSectionHeader("Available Seats"),
            ),
          ),

          // Seats Grid
          _buildSeatsGrid(context),

          // Services Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSectionHeader("Services Menu"),
            ),
          ),

          // Services Grid
          _buildServicesGrid(context),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: _buildBottomBookingBar(context),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
      ),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          size: 80,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return VintageDivider(text: title.toUpperCase());
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
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

  Widget _buildSeatsGrid(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<SeatModel>>(
      stream: shopService.getSeats(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        final seats = snapshot.data!;

        if (seats.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.chair_alt_rounded, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    "No Seats Available",
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final seat = seats[index];
                return _buildSeatCard(context, seat);
              },
              childCount: seats.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeatCard(BuildContext context, SeatModel seat) {
    final isAvailable = seat.status == SeatStatus.available;
    final statusColor = _getStatusColor(seat.status);

    return GestureDetector(
      onTap: isAvailable
          ? () => _showBookingDialog(context, seat)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable ? AppColors.cardColor : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? statusColor : AppColors.border,
            width: isAvailable ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Status indicator
            if (!isAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getSeatTypeIcon(seat.type),
                    size: 28,
                    color: isAvailable ? statusColor : AppColors.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    seat.name,
                    style: GoogleFonts.crimsonText(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${seat.pricePerHour.toStringAsFixed(0)}/hr",
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: isAvailable ? AppColors.success : AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusName(seat.status),
                      style: GoogleFonts.crimsonText(
                        fontSize: 9,
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

  Widget _buildServicesGrid(BuildContext context) {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<ServiceModel>>(
      stream: shopService.getServices(shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        // Only show active services
        final services = snapshot.data!.where((s) => s.isActive).toList();

        if (services.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.content_cut_rounded, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(
                    "No Services Available",
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = services[index];
                return _buildServiceCard(service);
              },
              childCount: services.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getServiceIcon(service.category), color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            service.name,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (service.price > 0)
            Text(
              "\$${service.price.toStringAsFixed(0)}",
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hair:
        return Icons.cut_rounded;
      case ServiceCategory.beard:
        return Icons.face_rounded;
      case ServiceCategory.face:
        return Icons.spa_rounded;
      case ServiceCategory.body:
        return Icons.self_improvement_rounded;
      case ServiceCategory.other:
        return Icons.star_rounded;
    }
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cardColor,
            AppColors.ivory,
          ],
        ),
        border: Border(
          top: BorderSide(color: AppColors.gold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: GlowingGoldButton(
          label: "BOOK APPOINTMENT",
          icon: Icons.calendar_today_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeatBookingScreen(shop: shop),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, SeatModel seat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeatBookingScreen(shop: shop, selectedSeat: seat),
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
}
