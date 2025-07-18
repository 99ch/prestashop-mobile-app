import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koutonou/providers/auth_provider.dart';
import 'package:koutonou/providers/product_provider.dart';
import 'package:koutonou/providers/cart_provider.dart';
import 'package:koutonou/providers/vendor_provider.dart';
import 'package:koutonou/views/home/widgets/app_header.dart';
import 'package:koutonou/views/home/widgets/category_bar.dart';
import 'package:koutonou/views/home/widgets/product_carousel.dart';
import 'package:koutonou/views/home/widgets/vendor_highlights.dart';
import 'package:koutonou/views/cart/cart_screen.dart';
import 'package:koutonou/views/products/product_listing_screen.dart';
import 'package:koutonou/views/profile/profile_screen.dart';
import 'package:koutonou/views/vendors/vendor_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();
    final vendorProvider = context.read<VendorProvider>();

    if (authProvider.currentCustomer != null) {
      await cartProvider.loadCart(authProvider.currentCustomer!.id);
    }

    await Future.wait([
      productProvider.loadCategories(),
      productProvider.loadFeaturedProducts(),
      productProvider.loadBestSellers(),
      vendorProvider.loadVendors(),
    ]);
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          const ProductListingScreen(),
          const VendorListingScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 16),
              const CategoryBar(),
              const SizedBox(height: 24),
              ProductCarousel(
                title: 'Featured Products',
                products: context.watch<ProductProvider>().featuredProducts,
                isLoading: context.watch<ProductProvider>().isLoading,
              ),
              const SizedBox(height: 24),
              ProductCarousel(
                title: 'Best Sellers',
                products: context.watch<ProductProvider>().bestSellers,
                isLoading: context.watch<ProductProvider>().isLoading,
              ),
              const SizedBox(height: 24),
              const VendorHighlights(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}