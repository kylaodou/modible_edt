import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/core/theme/colors.dart';

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
                  Expanded(
                    child: Container(
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
                                    if (_passwordController.text ==
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
                                    if (_formKey.currentState!.validate()) {}
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
                                  child: Text(
                                    "S'inscrire",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
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
                    height: 100,
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
