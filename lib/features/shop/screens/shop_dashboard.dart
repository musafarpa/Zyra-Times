import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/shop/screens/add_shop_screen.dart';
import 'package:zyraslot/features/shop/screens/shop_management_screen.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/core/constants/app_colors.dart';

class ShopDashboard extends StatelessWidget {
  const ShopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final shopService = context.watch<ShopService>();

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return StreamBuilder<List<ShopModel>>(
      stream: shopService.getMyShops(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: AppColors.error))),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final shops = snapshot.data!;

        if (shops.isEmpty) {
          // 404 Shop Not Found -> Redirect to Create Shop
          return const AddShopScreen(); 
        }

        // Shop Exists -> Show Management Dashboard
        return ShopManagementScreen(shop: shops.first);
      },
    );
  }
}
