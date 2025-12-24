import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/shop/screens/shop_details_screen.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/user_model.dart';

class ShoprShopList extends StatelessWidget {
  const ShoprShopList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final shopService = context.watch<ShopService>();

    if (user == null) return const Center(child: Text("Not Logged In"));

    return StreamBuilder<List<ShopModel>>(
      stream: shopService.getMyShops(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final shops = snapshot.data!;

        if (shops.isEmpty) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.store, size: 64, color: AppColors.textSecondary),
                 const SizedBox(height: 16),
                 Text(
                   "No Shops Added Yet",
                   style: Theme.of(context).textTheme.headlineSmall,
                 ),
                 const SizedBox(height: 8),
                 const Text("Click + to add your saloon"),
               ],
             ),
           );
        }

        return ListView.builder(
          itemCount: shops.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Card(
              child: ListTile(
                leading: shop.imageUrl.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(shop.imageUrl))
                    : const CircleAvatar(child: Icon(Icons.store)),
                title: Text(shop.name, style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text(shop.address),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => ShopDetailsScreen(shop: shop)),
                   );
                },
              ),
            );
          },
        );
      },
    );
  }
}
