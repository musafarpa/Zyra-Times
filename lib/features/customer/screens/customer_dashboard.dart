import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/core/services/location_service.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/customer/screens/my_bookings_screen.dart';
import 'package:zyraslot/features/shop/screens/shop_details_screen.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/booking_model.dart';
import 'package:zyraslot/widgets/animated_saloon_widgets.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ExploreTab(),
          _MyBookingsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_rounded, "Explore"),
              _buildNavItem(1, Icons.calendar_today_rounded, "Bookings"),
              _buildNavItem(2, Icons.person_rounded, "Profile"),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.goldGradient : null,
          borderRadius: BorderRadius.circular(12),
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
              size: 24,
              color: isSelected ? AppColors.woodDark : AppColors.gold.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.crimsonText(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.woodDark : AppColors.gold.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  EXPLORE TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    // Auto-request location on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    final locationService = context.read<LocationService>();
    if (!locationService.hasLocation) {
      await locationService.getCurrentLocation();
      if (mounted && locationService.hasLocation) {
        setState(() => _sortByDistance = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Animated Header
          SliverToBoxAdapter(
            child: FadeInWidget(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.woodDark,
                      AppColors.woodMedium,
                    ],
                  ),
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
                    // Diamond icon with glow
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 24,
                        color: AppColors.woodDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                      child: Text(
                        "THE ZYRA TIMES",
                        style: GoogleFonts.rye(
                          fontSize: 28,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 30, height: 1, color: AppColors.gold.withValues(alpha: 0.5)),
                        const SizedBox(width: 12),
                        Text(
                          "EST. 2024 • PREMIUM EDITION",
                          style: GoogleFonts.crimsonText(
                            fontSize: 11,
                            color: AppColors.gold.withValues(alpha: 0.8),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 30, height: 1, color: AppColors.gold.withValues(alpha: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar & Location Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.ivory,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Search establishments...",
                        hintStyle: GoogleFonts.crimsonText(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Location Filter Button
                  _buildLocationFilter(),
                ],
              ),
            ),
          ),

          // Animated Section Header
          SliverToBoxAdapter(
            child: FadeInWidget(
              delay: const Duration(milliseconds: 400),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: VintageDivider(text: "FINEST ESTABLISHMENTS"),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Shop List
          _buildShopList(),
        ],
      ),
    );
  }

  Widget _buildShopList() {
    final shopService = context.watch<ShopService>();
    final locationService = context.watch<LocationService>();

    return StreamBuilder<List<ShopModel>>(
      stream: shopService.getShops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        var shops = snapshot.data!;

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          shops = shops.where((shop) {
            return shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                shop.address.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        // Sort by distance if enabled and location is available
        if (_sortByDistance && locationService.hasLocation) {
          shops = List.from(shops);
          shops.sort((a, b) {
            final distanceA = locationService.getDistanceFromCurrentLocation(
              a.latitude,
              a.longitude,
            );
            final distanceB = locationService.getDistanceFromCurrentLocation(
              b.latitude,
              b.longitude,
            );
            if (distanceA == null && distanceB == null) return 0;
            if (distanceA == null) return 1;
            if (distanceB == null) return -1;
            return distanceA.compareTo(distanceB);
          });
        }

        if (shops.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.store_rounded, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    "No Establishments Found",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Try a different search term",
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
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
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => StaggeredListItem(
                index: index,
                baseDelay: const Duration(milliseconds: 80),
                child: _buildShopCard(shops[index], locationService),
              ),
              childCount: shops.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopCard(ShopModel shop, LocationService locationService) {
    // Calculate distance if location is available
    final distance = locationService.hasLocation
        ? locationService.getDistanceFromCurrentLocation(shop.latitude, shop.longitude)
        : null;

    return AnimatedSaloonCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop)),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with vintage overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: shop.imageUrl.isNotEmpty
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          AppColors.woodMedium.withValues(alpha: 0.2),
                          BlendMode.overlay,
                        ),
                        child: Image.network(
                          shop.imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
              // Gradient overlay at bottom of image
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.cardColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Rating badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.woodDark),
                      const SizedBox(width: 4),
                      Text(
                        shop.rating.toStringAsFixed(1),
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.woodDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Distance badge (if location available)
              if (distance != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.woodDark.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 12,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationService.formatDistance(distance),
                          style: GoogleFonts.crimsonText(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: GoogleFonts.rye(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  shop.description.isNotEmpty
                      ? shop.description
                      : "A fine establishment offering superior services.",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.chair_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${shop.totalSeats} seats",
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 20, color: AppColors.border),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.location_on_rounded, size: 16, color: AppColors.info),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: GoogleFonts.crimsonText(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: AppColors.parchmentGradient,
      ),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          size: 60,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Consumer<LocationService>(
      builder: (context, locationService, _) {
        final hasLocation = locationService.hasLocation;
        final isLoading = locationService.isLoading;
        final error = locationService.error;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Location status icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        hasLocation
                            ? Icons.my_location_rounded
                            : Icons.location_off_rounded,
                        size: 20,
                        color: hasLocation ? AppColors.success : AppColors.textTertiary,
                      ),
              ),
              const SizedBox(width: 12),
              // Location text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLocation
                          ? "Location enabled"
                          : isLoading
                              ? "Getting location..."
                              : "Location disabled",
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (error != null && !hasLocation)
                      Text(
                        error,
                        style: GoogleFonts.crimsonText(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        hasLocation
                            ? "Showing nearest establishments"
                            : "Tap to enable location",
                        style: GoogleFonts.crimsonText(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              // Sort by distance toggle
              if (hasLocation) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _sortByDistance = !_sortByDistance),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _sortByDistance ? AppColors.goldGradient : null,
                      color: _sortByDistance ? null : AppColors.ivory,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _sortByDistance ? AppColors.gold : AppColors.border,
                      ),
                      boxShadow: _sortByDistance
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 14,
                          color: _sortByDistance ? AppColors.woodDark : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Nearest",
                          style: GoogleFonts.crimsonText(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _sortByDistance ? AppColors.woodDark : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Enable location button
                GestureDetector(
                  onTap: isLoading ? null : _requestLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.woodDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Enable",
                          style: GoogleFonts.crimsonText(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.woodDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  MY BOOKINGS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _MyBookingsTab extends StatelessWidget {
  const _MyBookingsTab();

  @override
  Widget build(BuildContext context) {
    return const MyBookingsScreen(embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PROFILE TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUserModel;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.leatherGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 3),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "Guest",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: AppColors.rope,
                    ),
                  ),
                  if (user?.phone.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.phone,
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        color: AppColors.rope,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              Icons.person_outline_rounded,
              "Edit Profile",
              "Update your personal information",
              () {},
            ),
            _buildMenuItem(
              context,
              Icons.notifications_outlined,
              "Notifications",
              "Manage notification preferences",
              () {},
            ),
            _buildMenuItem(
              context,
              Icons.help_outline_rounded,
              "Help & Support",
              "Get help with your account",
              () {},
            ),
            _buildMenuItem(
              context,
              Icons.info_outline_rounded,
              "About",
              "App version and information",
              () {},
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text("LOGOUT"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
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
                          fontSize: 12,
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

  void _showLogoutDialog(BuildContext context) {
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
              "Leave Saloon",
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to logout from your account?",
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
