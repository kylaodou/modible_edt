import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/services/registerService.dart';

import '../../core/theme/colors.dart';
import 'package:gif_view/gif_view.dart';

import '../../models/apiResponse.dart';



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
  // Permet de changer automatiquement de champ quand on écrit.
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  // Variables pour le timer de l'expiration du code
  int _start = 60; // 1 minute comme tu me l'a dit
  bool _isExpired = false;
  //Un Stream est un flux d’événements asynchrones.
  // Ici, tu vas recevoir un nombre chaque seconde, de 60 jusqu’à 0.
  // Le mot late veut dire : "je vais l’initialiser plus tard, mais il sera non nul".
  late Stream<int>
      _timerStream; // Stream pour le timer ( un stream permet de faire de l'async , plusieur ecouteurs a la fois) )
  bool _isLoading = false;
  void _verifyCode(String email, String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await verifyCode(email, code);

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // Afficher un message de succès personnalisé
        _showCustomSnackBar(
          context: context,
          title: 'Information',
          message: response.message ?? 'Vérification réussie',
          isSuccess: true,
        );
        // Rediriger vers la page de connexion
        Navigator.pushNamed(context, '/login');
      } else {
        // Construire un message d'erreur plus détaillé
        String errorMessage = response.message ?? 'Erreur lors de la vérification';

        // Ajouter les détails des erreurs s'ils existent
        if (response.errors != null) {
          if (response.errors is Map) {
            // Parcourir toutes les erreurs et les ajouter au message
            String detailedErrors = '';
            (response.errors as Map).forEach((key, value) {
              detailedErrors += '\n• $key: $value';
            });

            if (detailedErrors.isNotEmpty) {
              errorMessage += detailedErrors;
            }
          } else if (response.errors is String) {
            // Si errors est une simple chaîne, l'ajouter directement
            errorMessage += '\n• ${response.errors}';
          }
        }

        // Afficher le message d'erreur détaillé avec la SnackBar personnalisée
        _showCustomSnackBar(
          context: context,
          title: 'Erreur',
          message: errorMessage,
          isSuccess: false,
          duration: const Duration(seconds: 5), // Augmenter la durée pour les messages plus longs
        );

        // Également afficher dans la console pour le débogage
        print('Erreur complète: $errorMessage');
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

  void _resendVerifyCode(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await resendVerifyCode(email);

      setState(() {
        _isLoading = false;
        // Réinitialiser les contrôleurs de texte
        for (var controller in _controllers) {
          controller.clear();
        }

        // Placer le focus sur le premier champ
        if (focusNodes.isNotEmpty) {
          focusNodes[0].requestFocus();
        }

        _isExpired = false;
        _start = 60;
        // Recréer le stream de timer à nous puis qu'il est déjà expiré
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
        });
      });

      if (response.success) {
        // Afficher un message de succès personnalisé
        _showCustomSnackBar(
          context: context,
          title: 'Information',
          message: response.message ?? 'Vérification réussie',
          isSuccess: true,
        );
      } else {
        // Construire un message d'erreur plus détaillé
        String errorMessage = response.message ?? 'Erreur lors de la vérification';

        // Ajouter les détails des erreurs s'ils existent
        if (response.errors != null) {
          if (response.errors is Map) {
            // Parcourir toutes les erreurs et les ajouter au message
            String detailedErrors = '';
            (response.errors as Map).forEach((key, value) {
              detailedErrors += '\n• $key: $value';
            });

            if (detailedErrors.isNotEmpty) {
              errorMessage += detailedErrors;
            }
          } else if (response.errors is String) {
            // Si errors est une simple chaîne, l'ajouter directement
            errorMessage += '\n• ${response.errors}';
          }
        }

        // Afficher le message d'erreur détaillé avec la SnackBar personnalisée
        _showCustomSnackBar(
          context: context,
          title: 'Erreur',
          message: errorMessage,
          isSuccess: false,
          duration: const Duration(seconds: 5), // Augmenter la durée pour les messages plus longs
        );

        // Également afficher dans la console pour le débogage
        print('Erreur complète: $errorMessage');
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
  void _handleResendCode() {
    // Récupérez les valeurs d'email et de code à partir de l'état actuel
    String email = widget.email; // Ou toute autre source pour l'email
    _resendVerifyCode(email);
  }
// Fonction pour afficher une SnackBar personnalisée
  void _showCustomSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
    Duration duration = const Duration(seconds: 4),
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
                    const Spacer(),
                    // Bouton pour fermer la SnackBar
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Corps avec le message
              Container(
                width: double.infinity,
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
        duration: duration,
      ),
    );
  }
  //  pour renvoyer le code en cas dexpiration


  bool _isCodeComplete() {
    // Vérifie si les 4 chiffres sont saisis
    return _controllers.every((controller) => controller.text
        .isNotEmpty); // on va parcoourir chaque controller et verifier si il est vide ou paq
  }

  @override
  void initState() {
    super.initState();

    // Stream.periodic(...) : crée un flux de données qui s’actualise chaque seconde
    // .take(_start + 1) : le stream ne va envoyer que 61 valeurs (de 60 à 0 inclus).
    //.asBroadcastStream() : permet que plusieurs widgets (comme StreamBuilder) puissent écouter en même temps.
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
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: primaryColor
                            ),
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
                            onPressed: _handleResendCode,
                          ),

                        SizedBox(height: 20),

                        // Bouton de verification
                        GestureDetector(
                          onTap: (_isCodeComplete() && !_isExpired)
                              ? () async {
                            String code = _controllers.map((controller) => controller.text).join();
                            _verifyCode(email ,code);
                          }
                              : null,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (_isCodeComplete() && !_isExpired) ? primaryColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (_isCodeComplete() && !_isExpired) ? primaryColor : Colors.grey.shade300,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                  offset: Offset(-4, 4),
                                ),
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(-2, 2),
                                )
                              ],
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                color: Colors.white)
                                : Text(
                              'Vérifier',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: (_isCodeComplete() && !_isExpired) ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        )
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GifView.asset(
                  'assets/gifs/iconTime.gif',
                  height: 50,
                  frameRate: 15, // Contrôle la vitesse
                ),
                Text(
                  // icones de claude comme tu connais  , tu peux changer apres pour des vrais icones de flutter
                  'Expire dans $minutes:$seconds s',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Code expiré',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: errorColor,
                  ),
                ),
                GifView.asset(
                  'assets/gifs/iconError.gif',
                  height: 50,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
