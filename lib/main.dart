import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketnest/theme.dart';
import 'package:marketnest/providers/auth_provider.dart';
import 'package:marketnest/providers/product_provider.dart';
import 'package:marketnest/providers/cart_provider.dart';
import 'package:marketnest/providers/vendor_provider.dart';
import 'package:marketnest/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => VendorProvider()),
      ],
      child: MaterialApp(
        title: 'MarketNest',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
