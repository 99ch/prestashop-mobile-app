import 'package:first_store_nodejs_flutter/utils/constants.dart';
import 'package:first_store_nodejs_flutter/views/widgets/auth_wrapper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewModel/auth_view_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showLoginErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur de connexion"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showLoginErrorDialog('Veuillez remplir tous les champs.');
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.login(email, password);

    if (!mounted) return;

    if (authViewModel.user != null) {
      Constants.checkDebug('Connexion réussie, navigation vers AuthWrapper');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    } else {
      _showLoginErrorDialog(authViewModel.errorMessage ?? 'Identifiants invalides.');
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
                SvgPicture.asset('assets/login-.svg', width: 300, height: 300),
                const SizedBox(height: 20),
                const Text('Connexion', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: authViewModel.isLoading ? null : _login,
                        child: authViewModel.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Se connecter'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('OU'),
                      socialLoginButtons(),
                      registerButton(context),
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

  Widget socialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.facebook),
          onPressed: () {
            Constants.checkDebug('Clic sur connexion via Facebook');
            /* Facebook login */
          },
        ),
        IconButton(
          icon: const Icon(Icons.g_mobiledata),
          onPressed: () {
            Constants.checkDebug('Clic sur connexion via Google');
            /* Google login */
          },
        ),
        IconButton(
          icon: const Icon(Icons.apple),
          onPressed: () {
            Constants.checkDebug('Clic sur connexion via Apple');
            /* Apple login */
          },
        ),
      ],
    );
  }

  Widget registerButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Constants.checkDebug('Navigation vers RegisterScreen');
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
      },
      child: const Text('Besoin d’un compte ? Inscrivez-vous'),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}