import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';

class ProfileDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? etudiantData;
  final Map<String, dynamic>? classeData;
  final Map<String, dynamic>? filiereData;
  final ScrollController? scrollController;

  const ProfileDetailsBottomSheet({
    Key? key, 
    this.userData, 
    this.etudiantData, 
    this.classeData, 
    this.filiereData,
    this.scrollController,
  }) : super(key: key);

  // Extraire les données utilisateur et les détails
  Map<String, dynamic>? _getUserData() {
    if (userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure
    if (userData!['data'] != null && userData!['data']['user'] != null) {
      return userData!['data']['user'];
    }

    // Fallback vers l'ancien format
    return userData;
  }

  // Extraire les détails spécifiques basés sur le rôle
  Map<String, dynamic>? _getUserDetails() {
    if (userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure
    if (userData!['data'] != null && userData!['data']['details'] != null) {
      return userData!['data']['details'];
    }

    return null;
  }

  // Méthode pour récupérer une valeur avec fallback
  String _getValue(String key, String defaultValue) {
    // Essayer d'abord dans les données étudiant
    if (etudiantData != null && etudiantData![key] != null) {
      return etudiantData![key].toString();
    }

    // Puis dans les données classe
    if (classeData != null && classeData![key] != null) {
      return classeData![key].toString();
    }

    // Puis dans les données filière
    if (filiereData != null && filiereData![key] != null) {
      return filiereData![key].toString();
    }

    // Essayer dans les détails du rôle
    final details = _getUserDetails();
    if (details != null && details[key] != null) {
      return details[key].toString();
    }

    // Puis dans les données utilisateur
    final user = _getUserData();
    if (user != null && user[key] != null) {
      return user[key].toString();
    }

    return defaultValue;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Format invalide';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Poignée de la modal
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Titre
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Détails du profil",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Contenu scrollable
        Expanded(
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Section informations personnelles
              _buildSectionTitle("Informations personnelles", FontAwesomeIcons.userAlt),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoItem(
                  "Matricule",
                  _getValue('matricule', 'Non défini'),
                  FontAwesomeIcons.idCard,
                  const Color(0xFFF77527),
                ),
                _buildInfoItem(
                  "Nom",
                  _getValue('nom', 'Non défini'),
                  FontAwesomeIcons.user,
                  const Color(0xFF3E97FF),
                ),
                _buildInfoItem(
                  "Prénom",
                  _getValue('prenom', 'Non défini'),
                  FontAwesomeIcons.user,
                  const Color(0xFF3E97FF),
                ),
                _buildInfoItem(
                  "Sexe",
                  _getValue('sexe', 'Non défini'),
                  FontAwesomeIcons.venusMars,
                  const Color(0xFF2EB67D),
                ),
                _buildInfoItem(
                  "Date de naissance",
                  _formatDate(etudiantData?['dateNaissance']),
                  FontAwesomeIcons.calendar,
                  const Color(0xFF9966CC),
                ),
                _buildInfoItem(
                  "Lieu de naissance",
                  _getValue('lieuNaissance', 'Non défini'),
                  FontAwesomeIcons.mapMarkerAlt,
                  const Color(0xFFEB4C86),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Section informations académiques
              _buildSectionTitle("Informations académiques", FontAwesomeIcons.graduationCap),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoItem(
                  "Filière",
                  filiereData?['nom'] ?? 'Non définie',
                  FontAwesomeIcons.university,
                  const Color(0xFF1A73E8),
                ),
                _buildInfoItem(
                  "Code filière",
                  filiereData?['code'] ?? 'Non défini',
                  FontAwesomeIcons.code,
                  const Color(0xFF4CAF50),
                ),
                _buildInfoItem(
                  "Niveau",
                  classeData?['niveau'] ?? 'Non défini',
                  FontAwesomeIcons.layerGroup,
                  const Color(0xFFFFD966),
                ),
                _buildInfoItem(
                  "Classe",
                  classeData?['nom'] ?? 'Non définie',
                  FontAwesomeIcons.users,
                  const Color(0xFF9C27B0),
                ),
                _buildInfoItem(
                  "Délégué",
                  etudiantData?['estDelegue'] == true ? 'Oui' : 'Non',
                  FontAwesomeIcons.userTie,
                  const Color(0xFF607D8B),
                ),
              ]),
              
              const SizedBox(height: 24),
              
              // Section informations de contact
              _buildSectionTitle("Informations de contact", FontAwesomeIcons.addressBook),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoItem(
                  "Email",
                  _getValue('email', 'Non défini'),
                  FontAwesomeIcons.envelope,
                  const Color(0xFF3E97FF),
                ),
                _buildInfoItem(
                  "Téléphone",
                  _getValue('telephone', 'Non défini'),
                  FontAwesomeIcons.phone,
                  const Color(0xFF2EB67D),
                ),
              ]),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
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
                const SizedBox(height: 4),
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
}
