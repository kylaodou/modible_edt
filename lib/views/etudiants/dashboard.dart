import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/views/etudiants/etdPage.dart';
import 'package:modible_edt/views/etudiants/homePage.dart';
import 'package:modible_edt/views/etudiants/notificationPage.dart';
import 'package:modible_edt/views/etudiants/profilePage.dart';

import '../../core/theme/colors.dart';
import '../../widgets/EtudiantBottomNavBar.dart';

class EtudiantDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EtudiantDashboardPage({super.key, this.userData});

  @override
  State<EtudiantDashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<EtudiantDashboardPage> {
  int _indexcourrant = 0;

  late List<Widget> _pages;

  // Listes pour stocker les titres et images spécifiques à chaque page
  late List<String> _pageTitles;
  late List<String> _pageImages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(userData: widget.userData),
      EdtPage(),
      NotificationPage(),
      ProfilePage(userData: widget.userData),
    ];

    // Définir les titres pour chaque page
    _pageTitles = [
      'Accueil',     // Titre pour Homepage
      'Emploie du temps', // Titre pour EdtPage
      'Notifications',   // Titre pour NotificationPage
      'Mon profil'           // Titre pour ProfilePage
    ];

    // Définir les images pour chaque page
    _pageImages = [
      "assets/images/hand.png",     // Image pour Homepage
      "assets/images/calendare.png", // Image pour EdtPage
      "assets/images/notification.png",     // Image pour NotificationPage
      "assets/images/profil.png"      // Image pour ProfilePage
    ];
  }

  void _changerPage(int index) {
    setState(() {
      _indexcourrant = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = '${widget.userData?['nom'] ?? ''} ${widget.userData?['prenom'] ?? ''}'.trim();
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
                      children: [
                        Text(
                          // Montrer le nom seulement sur la page d'accueil
                          _indexcourrant == 0 ? "$name" : _pageTitles[_indexcourrant],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        // Utiliser l'image spécifique à la page
                        Image.asset(_pageImages[_indexcourrant], height: 30,)
                      ],
                    ),
                  ],
                ),
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
                    backgroundImage: widget.userData != null &&
                        widget.userData!['photo'] != null
                        ? NetworkImage(widget.userData!['photo'])
                        : null,
                    child: widget.userData == null ||
                        widget.userData!['photo'] == null
                        ? const Icon(Icons.person, color: primaryColor)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_indexcourrant],
      bottomNavigationBar: BottomNavBarWidget(
        indexCourant: _indexcourrant,
        changerPage: _changerPage,
        primaryColor: primaryColor,
      ),
    );
  }
}