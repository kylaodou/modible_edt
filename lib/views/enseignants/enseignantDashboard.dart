import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/views/enseignants/homePage.dart';
import 'package:modible_edt/views/enseignants/edtPage.dart';
import 'package:modible_edt/views/enseignants/notificationPage.dart';
import 'package:modible_edt/views/enseignants/profilePage.dart';

import '../../core/theme/colors.dart';
import '../../widgets/EnseignantBottomNavBar.dart';
import '../../services/UserSessionService.dart';
import '../../models/userSessionModel.dart';

class EnseignantDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EnseignantDashboardPage({super.key, this.userData});

  @override
  State<EnseignantDashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<EnseignantDashboardPage> {
  int _indexcourrant = 0;
  final UserSessionService _userSessionService = UserSessionService();
  UserSessionModel? _userSession;
  String? _photoURL;
  bool _isLoading = false;

  late List<Widget> _pages;

  // Listes pour stocker les titres et images spécifiques à chaque page
  late List<String> _pageTitles;
  late List<String> _pageImages;

  // Méthodes pour extraire les données utilisateur
  Map<String, dynamic>? _getUserData() {
    if (widget.userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure (avec user et details)
    if (widget.userData!['data'] != null && widget.userData!['data']['user'] != null) {
      return widget.userData!['data']['user'];
    }

    // Fallback vers l'ancien format ou utilisateur direct
    return widget.userData;
  }

  Map<String, dynamic>? _getUserDetails() {
    if (widget.userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure
    if (widget.userData!['data'] != null && widget.userData!['data']['details'] != null) {
      return widget.userData!['data']['details'];
    }

    return null;
  }

  // Méthode pour obtenir le nom d'affichage
  String _getDisplayName() {
    final user = _getUserData();
    final details = _getUserDetails();

    // Priorité aux détails spécifiques au rôle
    if (details != null) {
      if (details['nom'] != null && details['prenom'] != null) {
        return "${details['prenom']} ${details['nom']}";
      }
    }

    // Ensuite essayer avec les données utilisateur
    if (user != null) {
      if (user['nom'] != null && user['prenom'] != null) {
        return "${user['prenom']} ${user['nom']}";
      }

      // Si on a seulement un displayName
      if (user['displayName'] != null) {
        return user['displayName'];
      }
    }

    // Valeur par défaut
    return "Enseignant";
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _pages = [
      Homepage(),
      EdtPage(),
      NotificationPage(),
      ProfilePage(userData: widget.userData),
    ];

    // Définir les titres pour chaque page
    _pageTitles = [
      'Accueil', // Titre pour Homepage
      'Emploie du temps', // Titre pour EdtPage
      'Notifications', // Titre pour NotificationPage
      'Mon profil' // Titre pour ProfilePage
    ];

    // Définir les images pour chaque page
    _pageImages = [
      "assets/images/hand.png", // Image pour Homepage
      "assets/images/calendare.png", // Image pour EdtPage
      "assets/images/notification.png", // Image pour NotificationPage
      "assets/images/profil.png" // Image pour ProfilePage
    ];
  }

  // Charger les données utilisateur depuis le service
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer les données utilisateur à jour
      // Utiliser getUserData au lieu de refreshUserData qui n'existe pas
      Map<String, dynamic>? userData = await _userSessionService.getUserData();

      // Récupérer les données utilisateur à jour
      UserSessionModel? userSession = await _userSessionService.getUserSession();

      if (userSession != null) {
        setState(() {
          _userSession = userSession;

          // Récupérer l'URL de la photo
          if (userSession.user.photo != null) {
            _photoURL = userSession.user.photo;
          } else {
            // Essayer de récupérer depuis les anciennes structures
            final user = _getUserData();
            if (user != null && user['photoURL'] != null) {
              _photoURL = user['photoURL'];
            }
          }
        });
        dev.log("Données utilisateur chargées avec succès dans le dashboard");
      } else {
        dev.log("Aucune donnée utilisateur trouvée dans le dashboard");
      }
    } catch (e) {
      dev.log("Erreur lors du chargement des données utilisateur dans le dashboard: ${e.toString()}", error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changerPage(int index) {
    setState(() {
      _indexcourrant = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser les données de l'utilisateur depuis UserSessionModel si disponible
    final String name = _userSession != null ? _userSession!.nomComplet : _getDisplayName();

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Utilisez le titre spécifique à la page
                      _indexcourrant == 0 ? 'Bienvenue,' : 'Onglet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            // Montrer le nom seulement sur la page d'accueil
                            _indexcourrant == 0 ? name : _pageTitles[_indexcourrant],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Utiliser l'image spécifique à la page
                        Image.asset(_pageImages[_indexcourrant], height: 30)
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _loadUserData, // Rafraîchir les données utilisateur au tap sur l'avatar
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: _photoURL == null
                              ? const Icon(Icons.person, color: primaryColor)
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              _photoURL!,
                              fit: BoxFit.cover,
                              width: 44,
                              height: 44,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, color: primaryColor);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Rafraîchir les données utilisateur
          await _loadUserData();

          // Si la page actuelle est HomePage ou EdtPage, rafraîchir également ces pages
          if (_indexcourrant == 0 && _pages[0] is Homepage) {
            // Pour HomePage, nous devons recréer l'instance pour forcer le rafraîchissement
            setState(() {
              _pages[0] = Homepage();
            });
          } else if (_indexcourrant == 1 && _pages[1] is EdtPage) {
            // Pour EdtPage, nous devons recréer l'instance pour forcer le rafraîchissement
            setState(() {
              _pages[1] = EdtPage();
            });
          }
        },
        child: _pages[_indexcourrant],
      ),
      bottomNavigationBar: EnseignantBottomNavBarWidget(
        indexCourant: _indexcourrant,
        changerPage: _changerPage,
        primaryColor: primaryColor,
      ),
    );
  }
}