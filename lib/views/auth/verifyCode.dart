import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/colors.dart';

class VerifyCode extends StatefulWidget {
  final String email;

  const VerifyCode({super.key, required this.email});
  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  // Liste pour stocker les contrôleurs des champs de code
  List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  // Liste pour stocker les noeuds de focus sur les 04 blocs
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  // Variables pour le timer de l'expiration du code
  int _start = 60; // 1 minute comme tu me l'a dit
  bool _isExpired = false;
  late Stream<int>
      _timerStream; // Stream pour le timer ( un stream permet de faire de l'async , plusieur ecouteurs a la fois) )

  void _verifyCode(String code) {
    // code pour verifeir le code
  }

  //  pour renvoyer le code en cas dexpiration
  void _resendCode() {
    setState(() {
      _isExpired = false;
      _start = 60;
      // Recréer le stream de timer à nous puis quil es deja expirer
      _timerStream =
          Stream.periodic(Duration(seconds: 1), (count) => _start - count)
              .take(_start + 1)
              .asBroadcastStream();

      _timerStream.listen((count) {
        if (count == 0) {
          setState(() {
            _isExpired = true;
          });
        }
      } //
          );
    });

    // reste de la logique pour renvoyer un nouveau code
  }

  bool _isCodeComplete() {
    // Vérifie si les 4 chiffres sont saisis
    return _controllers.every((controller) => controller.text
        .isNotEmpty); // on va parcoourir chaque controller et verifier si il est vide ou paq
  }

  @override
  void initState() {
    super.initState();

    // Créer le stream de timer
    _timerStream =
        Stream.periodic(Duration(seconds: 1), (count) => _start - count)
            .take(_start + 1)
            .asBroadcastStream();

    // Écouter le stream pour détecter quand le timer atteint 0
    _timerStream.listen((count) {
      if (count == 0) {
        setState(() {
          _isExpired = true;
        });
      }
    });

    // Configurer les contrôleurs pour passer au champ suivant
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 3) {
          focusNodes[i].unfocus();
          focusNodes[i + 1].requestFocus();
        }
        // Mettre à jour l'état pour activer/désactiver le bouton
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    // Libérer les ressources
    // ici on va supprimer les contrôleurs et les noeuds de focus pour
    // eviter les fuites de mmoire d'apres chat gpt, il dit que c'est important de faire comme cela
    // sinon on va avoir des fuites de mmoire (l'application va se fermer seulement), je navais pas mis mais bon
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // le meme email qu'on a recuperer de register , j'ai mis mon mail(orazackdev@gmail.com) en dur pour le moment
    final email = widget.email;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // conteneur de l'image lottie
              Container(
                alignment: Alignment.centerRight,
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(50)),
                  color: primaryColor,
                ),
                child: Center(
                    child: Lottie.asset("assets/lotties/verifycode.json",
                        height: MediaQuery.of(context).size.height * 0.22)),
              ),
              // pour le reste de la page
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // tu poura changer le style ca plutart pour bien faire jolis
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Code Verification",
                            style: TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text:
                                      "Un code de vérification a été envoyé sur votre mail ",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),

                                // là ou on va vraiment afficher le mail de l'utilisateur
                                TextSpan(
                                  text: email,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ce composant se trouve en bas , c'est lui qui se charge d'afficher le timer
                        buildTimer(),
                        SizedBox(height: 30),
                        // les quatres blocs de saisie du code de verification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // ca j'ai deja expliquer
                          children: List.generate(
                            4,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 6),
                              height: 70,
                              width: 70,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _controllers[index].text.isNotEmpty
                                      ? primaryColor
                                      : Colors.grey.shade300,
                                  width: 2.5,
                                ),
                                boxShadow: _controllers[index].text.isNotEmpty
                                    ? [
                                        BoxShadow(
                                          color: primaryColor,
                                          blurRadius: 0,
                                          spreadRadius: 0,
                                          offset: Offset(-4,
                                              4), // Ombre uniquement sur les côtés gauche et bas
                                        ),
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                          offset: Offset(-2, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: TextFormField(
                                cursorColor: primaryColor,
                                cursorHeight: 35,
                                cursorWidth: 3,
                                cursorRadius: Radius.circular(10),
                                controller: _controllers[index],
                                maxLength: 1,
                                focusNode: focusNodes[index],
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {});
                                  if (value.length == 1 && index < 3) {
                                    focusNodes[index].unfocus();
                                    focusNodes[index + 1].requestFocus();
                                  }
                                },
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  height: 1.5,
                                ),
                                enabled: !_isExpired, // Désactiver si expiré
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Bouton pour renvoyer(optionnel que si le code est expire ) le code si expiré
                        // Ahhh tu va bien arranger le style et les couleur que tu veux là demain
                        if (_isExpired)
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh, color: Colors.white),
                            label: Text('Renvoyer le code',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _resendCode,
                          ),

                        SizedBox(height: 20),

                        // Bouton de verification
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 50),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // Désactiver le bouton si code incomplet ou expiré
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          onPressed: (_isCodeComplete() && !_isExpired)
                              ? () async {
                                  String code = _controllers
                                      .map((controller) => controller.text)
                                      .join();
                                  // verifier le code de verification
                                  _verifyCode(code);
                                }
                              : null, // Bouton désactivé si conditions non remplies
                          child: Text('Vérifier',
                              style: TextStyle(
                                  color: (_isCodeComplete() && !_isExpired)
                                      ? Colors.white
                                      : Colors.grey.shade700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTimer() {
    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! > 0) {
          Duration duration = Duration(seconds: snapshot.data!);
          String minutes = duration.inMinutes.toString().padLeft(2, '0');
          String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              // icones de claude comme tu connais  , tu peux changer apres pour des vrais icones de flutter
              '🔒 Expire dans $minutes:$seconds s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 1,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Code expiré ❌',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          );
        }
      },
    );
  }
}
