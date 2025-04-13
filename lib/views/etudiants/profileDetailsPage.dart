import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/colors.dart';

class ProfileDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileDetailsPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: primaryColor, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Détails du profil",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Card principale du profil avec l'avatar et les infos - identique à ProfilePage
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
                              backgroundImage: userData != null &&
                                  userData!['photo'] != null
                                  ? NetworkImage(userData!['photo'])
                                  : null,
                              child: userData == null ||
                                  userData!['photo'] == null
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
                            "${userData?['nom']} ${userData?['prenom']}",
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
                              "${userData?['email'] ?? 'email@example.com'}",
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

              // Nouvelle section pour les détails du profil
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
                    _buildInfoItem(
                      "Matricule",
                      userData?['matricule'] ?? 'ETU2023457',
                      Icons.credit_card_outlined,
                      const Color(0xFFF77527),
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      "Téléphone",
                      userData?['telephone'] ?? '+33 6 12 34 56 78',
                      Icons.phone_outlined,
                      const Color(0xFF3E97FF),
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      "Sexe",
                      userData?['sexe'] ?? 'Masculin',
                      Icons.person_outline,
                      const Color(0xFF2EB67D),
                    ),

                    _buildDivider(),
                    _buildInfoItem(
                      "Filière",
                      userData?['filiere'] ?? 'MIAGE',
                      Icons.school,
                      const Color(0xFFEB4C86),
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      "Niveau",
                      userData?['niveau'] ?? 'Licence 2',
                      Icons.rocket_launch,
                      const Color(0xFF9966CC),
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      "Statut",
                      userData?['niveau'] ?? 'Etudiant',
                      Icons.person,
                      const Color(0xFFFFD966),
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

  // Widget pour les éléments d'information du profil
  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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