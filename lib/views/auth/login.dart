import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/core/theme/colors.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../models/apiResponse.dart';
import '../../services/AuthService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isGoogleLoading = false; // Pour l' état de chargement du bouton Google
  bool _isFacebookLoading = false;
  bool _textCacher = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Nouvelle méthode pour l'inscription avec Google
  Future<void> _signInWithGoogle() async {
    await _authService.signOut();
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      ApiResponse response = await _authService.signInWithGoogle();

      setState(() {
        _isGoogleLoading = false;
      });

      if (response.success) {
        // Stocker les informations utilisateur dans le stockage local si nécessaire
        // Par exemple, utiliser shared_preferences pour stocker le token et les infos utilisateur

        _showCustomSnackBar(
          context: context,
          title: 'Bienvenue',
          message: 'Bienvenue, ${response.data['nom'] ?? 'utilisateur'}',
          isSuccess: true,
        );

        // Rediriger vers la page d'accueil avec les données utilisateur
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: response.data, // Passer les données utilisateur à la page dashboard
        );
      } else {
        // Gérer les différents états d'erreur
        _showCustomSnackBar(
          context: context,
          title: 'Information',
          message: response.message ?? 'Erreur lors de la connexion',
          isSuccess: false,
        );

        // Si l'utilisateur n'existe pas, proposer l'inscription
        if (response.status == 'NOT_FOUND') {
          // Optionnel: Navigation vers la page d'inscription
          Navigator.pushNamed(context, '/register');
        }
      }
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
      });
      _showCustomSnackBar(
        context: context,
        title: 'Erreur',
        message: 'Erreur: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
  // Dans votre _RegisterPageState, ajoutez cette nouvelle méthode:
  Future<void> _signInWithFacebook() async {
    await _authService.signOut();
    await FacebookAuth.instance.logOut();
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      ApiResponse response = await _authService.signInWithFacebook();

      setState(() {
        _isFacebookLoading = false;
      });

      if (response.success) {
        // Stocker les informations utilisateur dans le stockage local si nécessaire
        // Par exemple, utiliser shared_preferences pour stocker le token et les infos utilisateur

        _showCustomSnackBar(
          context: context,
          title: 'Bienvenue',
          message: 'Bienvenue, ${response.data['nom'] ?? 'utilisateur'}',
          isSuccess: true,
        );

        // Rediriger vers la page d'accueil avec les données utilisateur
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: response.data, // Passer les données utilisateur à la page dashboard
        );
      } else {
        // Gérer les différents états d'erreur
        _showCustomSnackBar(
          context: context,
          title: 'Information',
          message: response.message ?? 'Erreur lors de la connexion',
          isSuccess: false,
        );

        // Si l'utilisateur n'existe pas, proposer l'inscription
        if (response.status == 'NOT_FOUND') {
          // Optionnel: Navigation vers la page d'inscription
          Navigator.pushNamed(context, '/register');
        }
      }
    } catch (e) {
      setState(() {
        _isFacebookLoading = false;
      });
      _showCustomSnackBar(
        context: context,
        title: 'Erreur',
        message: 'Erreur: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
  // Fonction pour afficher une SnackBar personnalisée (inchangée)
  void _showCustomSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    // Votre code de SnackBar existant
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSuccess ? primaryColor : errorColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: isSuccess ? Border.all(color: primaryColor) : Border.all(color: errorColor)
                ),
                width: double.infinity,
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(50)),
                  color: primaryColor,
                ),
                child: Lottie.asset("assets/lotties/login.json"),
              ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(50)),
                    ),
                    child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    label: Text(
                                      'Entrez votre email',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: primaryColor,
                                    ),
                                    filled: true,
                                    fillColor: primaryColor.withOpacity(0.3),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: errorColor)),
                                    errorStyle: TextStyle(
                                        color: errorColor, fontSize: 15)),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '* Le champ email est obligateaoire';
                                  }
                                  if (!value.contains("@gmail.com")) {
                                    return '* Le champ email doit contenir @gmail.com';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                obscuringCharacter: "*",
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    label: Text(
                                      'Entrez votre mot de passe',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: primaryColor,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        //
                                        setState(() {
                                          _textCacher = !_textCacher;
                                        });
                                      },
                                      icon: _textCacher
                                          ? Icon(Icons.visibility_off)
                                          : Icon(Icons.remove_red_eye),
                                      color: primaryColor,
                                    ),
                                    filled: true,
                                    fillColor: primaryColor.withOpacity(0.3),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: errorColor)),
                                    errorStyle: TextStyle(
                                        color: errorColor, fontSize: 15)),
                                keyboardType: TextInputType.emailAddress,
                                obscureText: _textCacher,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '* Le champ password est obligateaoire';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Mot de passe oublier ?",
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                              // Remplacez votre bouton de connexion existant par celui-ci
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Afficher un indicateur de chargement
                                    setState(() {
                                      _isLoading = true; // Ajoutez cette variable d'état
                                    });

                                    try {
                                      ApiResponse response = await _authService.signInWithEmailPassword(
                                        _emailController.text,
                                        _passwordController.text,
                                      );

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (response.success) {
                                        _showCustomSnackBar(
                                          context: context,
                                          title: 'Bienvenue',
                                          message: 'Bienvenue, ${response.data['nom'] ?? 'utilisateur'}',
                                          isSuccess: true,
                                        );

                                        // Rediriger vers la page d'accueil avec les données utilisateur
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/dashboard',
                                          arguments: response.data,
                                        );
                                      } else {
                                        // Afficher le message d'erreur spécifique
                                        _showCustomSnackBar(
                                          context: context,
                                          title: 'Erreur de connexion',
                                          message: response.message ?? 'Identifiants incorrects',
                                          isSuccess: false,
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      _showCustomSnackBar(
                                        context: context,
                                        title: 'Erreur',
                                        message: 'Erreur: ${e.toString()}',
                                        isSuccess: false,
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.85,
                                    50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  "Connexion",
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('OU CONTINUEZ AVEC'),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    child: _isGoogleLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                        : Row(
                      children: [
                        Image.asset(
                          "assets/images/google.png",
                          height: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Google",
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _isFacebookLoading ? null : _signInWithFacebook,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    child: _isFacebookLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                        : Row(
                      children: [
                        Image.asset(
                          "assets/images/facebook.png",
                          height: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Facebook",
                          style: TextStyle(fontSize: 17),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Vous n'avez pas de compte ?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    "Inscrivez-vous",
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
