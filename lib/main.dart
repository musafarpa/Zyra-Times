import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/theme/app_theme.dart';
import 'package:zyraslot/core/services/location_service.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/auth/wrapper.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/features/admin/services/admin_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..initializeUser()),
        ChangeNotifierProvider(create: (_) => ShopService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        Provider(create: (_) => AdminService()),
      ],
      child: MaterialApp(
        title: 'ZyraSlot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
