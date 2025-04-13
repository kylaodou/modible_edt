import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Card principale du profil avec l'avatar et les infos
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header avec background coloré et avatar
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Background coloré avec design moderne
                        Container(
                          height: 310,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00A8FF), // vert foncé
                                const Color(0xFF00A8FF), // rouge
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Formes décoratives
                              Positioned(
                                top: -20,
                                left: 40,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0x30FFFFFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -20,
                                right: 40,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0x30FFFFFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -30,
                                right: 60,
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: const BoxDecoration(
                                    color: Color(0x20FFFFFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 60,
                                right: 60,
                                child: Container(
                                  height: 130,
                                  width: 130,
                                  decoration: const BoxDecoration(
                                    color: Color(0x20FFFFFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 100,
                                left: 20,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0x20FFFFFF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Photo de profil
                        Positioned(
                          top: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: widget.userData != null &&
                                      widget.userData!['photo'] != null
                                  ? NetworkImage(widget.userData!['photo'])
                                  : null,
                              child: widget.userData == null ||
                                      widget.userData!['photo'] == null
                                  ? const Icon(FontAwesomeIcons.camera,
                                      color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),
                        // Nom et prénom
                        Positioned(
                          bottom: 70,
                          child: Text(
                            "${widget.userData?['nom']} ${widget.userData?['prenom']}",
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.8),
                                  primaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "${widget.userData?['email'] ?? 'email@example.com'}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Section menu
              Container(
                margin: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      "Voir mon profil",
                      Icons.person_outline,
                      const Color(0xFF3E97FF),
                        (){
                        Navigator.pushNamed(context, "/profilDetails", arguments: widget.userData);
                        }
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      "Paramètres",
                      Icons.settings_outlined,
                      const Color(0xFF2EB67D),
                            (){}
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      "À propos",
                      Icons.info_outline,
                      const Color(0xFFF77527),
                            (){}
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      "Déconnexion",
                      Icons.logout_outlined,
                      const Color(0xFFEB4C86),
                            (){}
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les éléments du menu
  Widget _buildMenuItem(String text, IconData icon, Color color, GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Ligne de séparation
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }
}
