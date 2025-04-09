import 'package:flutter/material.dart';
import 'package:modible_edt/core/constants.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/views/Onboarding.dart';
import 'package:modible_edt/views/auth/login.dart';
import 'package:modible_edt/views/auth/register.dart';
import 'package:modible_edt/views/auth/verifyCode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modible_edt/views/dashboard.dart';
import 'package:modible_edt/views/enseignants/dashboard.dart';
import 'package:modible_edt/views/etudiants/dashboard.dart';
import 'package:modible_edt/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//
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

            if (userData != null && userData['roleIds'] != null) {
              List<String> roles = List<String>.from(userData['roleIds']);

              if (roles.contains(UserRoles.EtudiantRoleId)) {
                return MaterialPageRoute(
                    builder: (_) => EtudiantDashboardPage(userData: userData));
              } else if (roles.contains(UserRoles.EnseignantRoleId)) {
                return MaterialPageRoute(
                    builder: (_) =>
                        EnseignantDashboardPage(userData: userData));
              }
            }
            return MaterialPageRoute(
                builder: (_) => DashboardPage(userData: userData));
          default:
            return MaterialPageRoute(builder: (_) => OnboardingPage());
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
