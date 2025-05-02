import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/colors.dart';
import '../../services/ProfileService.dart';
import '../../models/apiResponse.dart';
import 'profileDetailsPage.dart';
import 'dart:ui';
import 'profileDetailsBottomSheet.dart';
import 'editProfilePhotoPage.dart';
import 'changePasswordPage.dart';
import 'notificationSettingsPage.dart';
import '../../views/auth/loginPage.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  Map<String, dynamic>? _etudiantData;
  Map<String, dynamic>? _classeData;
  Map<String, dynamic>? _filiereData;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadEtudiantData();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEtudiantData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await _profileService.getEtudiantComplet();

      if (response.success && response.data != null) {
        setState(() {
          _etudiantData = response.data['etudiant'];
          _classeData = response.data['classe'];
          _filiereData = response.data['filiere'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Extraire les données utilisateur et les détails
  Map<String, dynamic>? _getUserData() {
    if (widget.userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure (avec user et details)
    if (widget.userData!['data'] != null && widget.userData!['data']['user'] != null) {
      return widget.userData!['data']['user'];
    }

    // Fallback vers l'ancien format ou utilisateur direct
    return widget.userData;
  }

  // Extraire les détails spécifiques basés sur le rôle
  Map<String, dynamic>? _getUserDetails() {
    if (widget.userData == null) return null;

    // Vérifier si les données respectent la nouvelle structure
    if (widget.userData!['data'] != null && widget.userData!['data']['details'] != null) {
      return widget.userData!['data']['details'];
    }

    return null;
  }
  
  void _showProfileDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ProfileDetailsBottomSheet(
              userData: widget.userData,
              etudiantData: _etudiantData,
              classeData: _classeData,
              filiereData: _filiereData,
              scrollController: scrollController,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUserData();
    final details = _getUserDetails();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
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
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A73E8),
                                  Color(0xFF6C92F4),
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
                            child: Hero(
                              tag: 'profilePhoto',
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
                                  backgroundImage: user != null && user['photoURL'] != null && user['photoURL'].toString().isNotEmpty
                                      ? NetworkImage(user['photoURL'])
                                      : null,
                                  child: user == null || user['photoURL'] == null || user['photoURL'].toString().isEmpty
                                      ? const Icon(FontAwesomeIcons.user, size: 40, color: Colors.grey)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          // Nom et prénom
                          Positioned(
                            bottom: 70,
                            child: Text(
                              _getDisplayName(user, details),
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Color(0x40000000),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Informations académiques (filière et niveau)
                          Positioned(
                            bottom: 45,
                            child: _isLoading 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _getAcademicInfo(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                        color: Color(0x40000000),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                          Positioned(
                            bottom: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.8),
                                    primaryColor.withOpacity(0.6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.userGraduate,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user != null && user['role'] != null
                                        ? user['role'].toString()
                                        : 'Étudiant',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Contenu de la carte
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Boutons d'action
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: FontAwesomeIcons.idCard,
                                    label: 'Voir profil',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileDetailsPage(userData: widget.userData),
                                        ),
                                      );
                                    },
                                    color: const Color(0xFF1A73E8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: FontAwesomeIcons.eye,
                                    label: 'Aperçu rapide',
                                    onTap: _showProfileDetailsModal,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: FontAwesomeIcons.userEdit,
                          title: 'Modifier ma photo',
                          subtitle: 'Changer votre photo de profil',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePhotoPage(userData: widget.userData),
                              ),
                            ).then((updated) {
                              if (updated == true) {
                                // Recharger les données si la photo a été mise à jour
                                _loadEtudiantData();
                              }
                            });
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.lock,
                          title: 'Sécurité',
                          subtitle: 'Modifier votre mot de passe',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.bell,
                          title: 'Notifications',
                          subtitle: 'Gérer vos préférences de notification',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationSettingsPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.signOutAlt,
                          title: 'Déconnexion',
                          subtitle: 'Se déconnecter de l\'application',
                          onTap: _showLogoutConfirmationDialog,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(Map<String, dynamic>? user, Map<String, dynamic>? details) {
    // Si nous avons des détails spécifiques, les utiliser en priorité
    if (details != null) {
      final nom = details['nom'];
      final prenom = details['prenom'];
      if (nom != null && prenom != null) {
        return '$prenom $nom';
      }
    }

    // Si nous avons des données étudiant, les utiliser
    if (_etudiantData != null) {
      final nom = _etudiantData!['nom'];
      final prenom = _etudiantData!['prenom'];
      if (nom != null && prenom != null) {
        return '$prenom $nom';
      }
    }

    // Fallback sur les données utilisateur
    if (user != null) {
      final email = user['email'];
      if (email != null) {
        // Extraire le nom d'utilisateur de l'email
        return email.toString().split('@')[0];
      }
    }

    return 'Utilisateur';
  }

  String _getAcademicInfo() {
    if (_filiereData != null && _classeData != null) {
      final filiere = _filiereData!['nom'] ?? '';
      final niveau = _classeData!['niveau'] ?? '';
      return '$filiere - $niveau';
    } else if (_classeData != null) {
      return _classeData!['niveau'] ?? '';
    } else if (_etudiantData != null) {
      return 'Étudiant';
    }
    return '';
  }

  // Afficher une boîte de dialogue de confirmation pour la déconnexion
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Déconnexion'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour se déconnecter
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse response = await _profileService.logout();

      if (response.success) {
        // Rediriger vers la page de connexion
        if (mounted) {
          Navigator.pushNamed(context, "/login");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors de la déconnexion'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}