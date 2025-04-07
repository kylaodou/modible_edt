import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/registerService.dart';

import '../../models/loginModel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _textCacher = true;

  bool _isLoading = false;

// Méthode pour l'inscription
  Future<void> _inscription() async {
    // Créer un objet LoginModel
    LoginModel login = LoginModel(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() {
      _isLoading = true;
    });
    try {
      ApiResponse response = await inscription(login);
      setState(() {
        _isLoading = false;
      });
      if (response.success) {
        // Afficher un message de succès personnalisé
        _showCustomSnackBar(
          context: context,
          title: 'Information',
          message: response.message ?? 'Inscription réussie',
          isSuccess: true,
        );
        // Rediriger vers la page de vérification
        Navigator.pushNamed(context, '/verifyCode', arguments: login.email);
      } else {
        // Afficher un message d'erreur personnalisé
        _showCustomSnackBar(
          context: context,
          title: 'Erreur',
          message: response.message ?? 'Erreur lors de l\'inscription',
          isSuccess: false,
        );
        if (response.errors != null && response.errors is Map) {
          print(response.errors);
        }
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

// Fonction pour afficher une SnackBar personnalisée
  void _showCustomSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
  }) {
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
              // En-tête bleu avec texte blanc
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
              // Corps avec le message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: isSuccess ? Border.all(color: primaryColor) : Border.all(color: errorColor)
                ),
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
                child: Lottie.asset("assets/lotties/register.json"),
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
                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    label: Text(
                                      'Entrez votre email',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
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
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
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
                                        borderRadius: BorderRadius.circular(50),
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
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
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
                                height: 30,
                              ),
                              TextFormField(
                                obscuringCharacter: "*",
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                    label: Text(
                                      'Confirmer votre mot de passe',
                                      style: TextStyle(color: Colors.black26),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
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
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
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
                                  if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    return '* Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _inscription();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width *
                                            0.85,
                                        50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "S'inscrire",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
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
                    child: Text('OU'),
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
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    child: Row(
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
                    onPressed: () {},
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                Text('Vous aviez déja un compte ?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Connectez-vous",
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
