import 'package:first_store_nodejs_flutter/views/screens/MainScreen.dart';
import 'package:first_store_nodejs_flutter/views/screens/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModel/auth_view_model.dart';
import '../screens/login_registerScreens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Afficher un indicateur de chargement pendant que l'état de l'utilisateur est vérifié
    if (authViewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Vérifier si l'utilisateur est connecté
    if (authViewModel.user != null) {
      // Utilisateur connecté : afficher le tiroir et l'écran principal
      return Scaffold(
        body: Stack(
          children: [
            DrawerScreen(),
            MainScreen(), // Supprimé const
          ],
        ),
      );
    }

    // Utilisateur non connecté : afficher l'écran de connexion
    return LoginScreen(); // Supprimé const
  }
}