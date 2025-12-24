import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/widgets/animated_saloon_widgets.dart';

class AdminShopList extends StatelessWidget {
  const AdminShopList({super.key});

  @override
  Widget build(BuildContext context) {
    final shopService = context.read<ShopService>();

    return StreamBuilder<List<ShopModel>>(
      stream: shopService.getShops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VintageLoader(size: 50),
                const SizedBox(height: 16),
                Text(
                  "Loading Registry...",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        final shops = snapshot.data!;

        if (shops.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No Establishments",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The registry is empty",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Stats Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.parchmentGradient,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.store_rounded, "${shops.length}", "Total"),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _buildStatItem(Icons.star_rounded, _calculateAvgRating(shops), "Avg Rating"),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _buildStatItem(Icons.chair_rounded, _calculateTotalSeats(shops), "Seats"),
                ],
              ),
            ),

            // Shop List
            Expanded(
              child: ListView.builder(
                itemCount: shops.length,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return StaggeredListItem(
                    index: index,
                    baseDelay: const Duration(milliseconds: 50),
                    child: _buildShopCard(context, shop, shopService),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.crimsonText(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _calculateAvgRating(List<ShopModel> shops) {
    if (shops.isEmpty) return "0.0";
    final avg = shops.map((s) => s.rating).reduce((a, b) => a + b) / shops.length;
    return avg.toStringAsFixed(1);
  }

  String _calculateTotalSeats(List<ShopModel> shops) {
    if (shops.isEmpty) return "0";
    return shops.map((s) => s.totalSeats).reduce((a, b) => a + b).toString();
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop, ShopService shopService) {
    return AnimatedSaloonCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Shop Image/Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.leatherGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary),
            ),
            child: shop.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      shop.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.store_rounded,
                        color: AppColors.gold,
                        size: 28,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.store_rounded,
                    color: AppColors.gold,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),

          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shop.address,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildMiniStat(Icons.star_rounded, shop.rating.toStringAsFixed(1), AppColors.gold),
                    const SizedBox(width: 12),
                    _buildMiniStat(Icons.chair_rounded, "${shop.totalSeats}", AppColors.info),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          GestureDetector(
            onTap: () => _showDeleteDialog(context, shop, shopService),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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

  void _showDeleteDialog(BuildContext context, ShopModel shop, ShopService shopService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Remove Establishment",
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to remove:",
              style: GoogleFonts.crimsonText(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.store_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      shop.name,
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "This action cannot be undone.",
              style: GoogleFonts.crimsonText(
                color: AppColors.error,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
              shopService.deleteShop(shop.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Remove", style: GoogleFonts.rye(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
