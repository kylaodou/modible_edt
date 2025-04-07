import 'package:flutter/material.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/views/Onboarding.dart';
import 'package:modible_edt/views/auth/login.dart';
import 'package:modible_edt/views/auth/register.dart';
import 'package:modible_edt/views/auth/verifyCode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
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
      home: const OnboardingPage(),
    );
  }
}
