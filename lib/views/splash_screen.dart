import 'package:flutter/material.dart';
import 'package:modible_edt/services/AuthService.dart';
import 'package:modible_edt/core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    // Ajouter un délai pour afficher le SplashScreen (optionnel)
    await Future.delayed(const Duration(seconds: 2));

    // Vérifier si l'utilisateur est déjà connecté
    final userData = await _authService.getCurrentUser();

    if (userData != null) {
      // L'utilisateur est connecté, le rediriger vers son tableau de bord
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: userData,
      );
    } else {
      // L'utilisateur n'est pas connecté, le rediriger vers l'onboarding
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            Image.asset(
              'assets/images/splash.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
