import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../viewModel/auth_view_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur d'inscription"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog("Tous les champs sont obligatoires.");
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog("Les mots de passe ne correspondent pas.");
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.register(name, email, password);

    if (!mounted) return;

    if (authViewModel.user != null) {
      Constants.checkDebug('Inscription réussie, navigation vers LoginScreen');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      _showErrorDialog(authViewModel.errorMessage ?? "Une erreur s'est produite.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/Signup-.svg',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Adresse e-mail',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: authViewModel.isLoading ? null : _register,
                        child: authViewModel.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("S'inscrire"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('OU'),
                      const SizedBox(height: 20),
                      socialMediaIcons(),
                      alreadyHaveAnAccount(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget socialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(FontAwesome5.facebook),
          onPressed: () {
            Constants.checkDebug('Clic sur inscription via Facebook');
            /* TODO: Implémenter la connexion via Facebook */
          },
        ),
        IconButton(
          icon: const Icon(FontAwesome5.google),
          onPressed: () {
            Constants.checkDebug('Clic sur inscription via Google');
            /* TODO: Implémenter la connexion via Google */
          },
        ),
        IconButton(
          icon: const Icon(FontAwesome5.apple),
          onPressed: () {
            Constants.checkDebug('Clic sur inscription via Apple');
            /* TODO: Implémenter la connexion via Apple */
          },
        ),
      ],
    );
  }

  Widget alreadyHaveAnAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Déjà inscrit ?'),
        TextButton(
          onPressed: () {
            Constants.checkDebug('Navigation vers LoginScreen');
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: const Text('Se connecter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}