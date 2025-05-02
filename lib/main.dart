import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modible_edt/core/constants.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/views/Onboarding.dart';
import 'package:modible_edt/views/auth/login.dart';
import 'package:modible_edt/views/auth/register.dart';
import 'package:modible_edt/views/auth/verifyCode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modible_edt/views/dashboard.dart';
import 'package:modible_edt/views/enseignants/enseignantDashboard.dart';
import 'package:modible_edt/views/etudiants/dashboard.dart';
import 'package:modible_edt/views/etudiants/profileDetailsPage.dart';
import 'package:modible_edt/views/splash_screen.dart';
import 'package:modible_edt/services/userSessionService.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true, // À utiliser uniquement en développement
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => OnboardingPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/verifyCode':
            final email = settings.arguments as String?;
            return MaterialPageRoute(
                builder: (_) => VerifyCode(email: email ?? ''));
          case '/dashboard':
            final userData = settings.arguments as Map<String, dynamic>?;

            print('[DASHBOARD_ROUTING] Données utilisateur reçues:');
            print(userData);

            if (userData != null && userData['user'] != null) {
              final role = userData['user']['role'].toString().toUpperCase();
              print('[DASHBOARD_ROUTING] Rôle détecté: $role');

              switch (role) {
                case 'ENSEIGNANT':
                  print('[DASHBOARD_ROUTING] Redirection vers dashboard enseignant');
                  return MaterialPageRoute(
                      builder: (_) => EnseignantDashboardPage(userData: userData));
                case 'ETUDIANT':
                  print('[DASHBOARD_ROUTING] Redirection vers dashboard étudiant');
                  return MaterialPageRoute(
                      builder: (_) => EtudiantDashboardPage(userData: userData));
                case 'SUPERADMIN':
                  print('[DASHBOARD_ROUTING] Redirection vers dashboard admin');
                  return MaterialPageRoute(
                      builder: (_) => DashboardPage(userData: userData));
                default:
                  print('[DASHBOARD_ROUTING] Rôle non reconnu: $role');
              }
            }

            print('[DASHBOARD_ROUTING] Redirection par défaut');
            return MaterialPageRoute(
                builder: (_) => OnboardingPage());

        }
      },
      debugShowCheckedModeBanner: false,
      title: 'EDT mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
    );
  }
}