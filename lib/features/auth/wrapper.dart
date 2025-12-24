import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/admin/screens/admin_dashboard.dart';
import 'package:zyraslot/features/auth/screens/login_screen.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/customer/screens/customer_dashboard.dart';
import 'package:zyraslot/features/shop/screens/shop_dashboard.dart';
import 'package:zyraslot/models/user_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final userModel = authService.currentUserModel;

    if (user == null) {
      return const LoginScreen();
    }

    if (userModel == null) {
       debugPrint("AuthWrapper: User is ${user?.uid}, but UserModel is NULL. Loading...");
       return Scaffold(
         backgroundColor: AppColors.background,
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               CircularProgressIndicator(color: AppColors.primary),
               const SizedBox(height: 16),
               SizedBox(
                 width: 200,
                 child: Text(
                   "LOADING PROFILE...", 
                   textAlign: TextAlign.center,
                   style: TextStyle(color: AppColors.primary, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                 ),
               ),
             ],
           ),
         ),
       );
    }

    debugPrint("AuthWrapper: User Role is ${userModel.role}");

    switch (userModel.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.shopr:
        return const ShopDashboard();
      case UserRole.customer:
        return const CustomerDashboard();
    }
  }
}
