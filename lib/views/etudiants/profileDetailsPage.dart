import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/ProfileService.dart';
import 'package:intl/intl.dart';

class ProfileDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfileDetailsPage({Key? key, this.userData}) : super(key: key);

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = true;
  Map<String, dynamic>? _etudiantData;
  Map<String, dynamic>? _classeData;
  Map<String, dynamic>? _filiereData;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadEtudiantData();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
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
      _errorMessage = '';
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
          _errorMessage = response.message ?? 'Erreur lors du chargement des données';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildProfileView(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEtudiantData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar avec image de fond
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: FadeTransition(
              opacity: _animation,
              child: Text(
                _etudiantData?['nom'] != null && _etudiantData?['prenom'] != null
                    ? '${_etudiantData!['prenom']} ${_etudiantData!['nom']}'
                    : 'Profil Étudiant',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Color(0x80000000),
                    ),
                  ],
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient de fond
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A73E8),
                        Color(0xFF6C92F4),
                      ],
                    ),
                  ),
                ),
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
                  bottom: 20,
                  right: 40,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Color(0x20FFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Overlay gradient pour meilleure lisibilité du texte
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Photo de profil
                Positioned(
                  right: 20,
                  bottom: 60,
                  child: Hero(
                    tag: 'profilePhoto',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: widget.userData != null && 
                                        widget.userData!['data'] != null && 
                                        widget.userData!['data']['user'] != null && 
                                        widget.userData!['data']['user']['photoURL'] != null
                            ? NetworkImage(widget.userData!['data']['user']['photoURL'])
                            : null,
                        child: widget.userData == null || 
                               widget.userData!['data'] == null || 
                               widget.userData!['data']['user'] == null || 
                               widget.userData!['data']['user']['photoURL'] == null
                            ? const Icon(FontAwesomeIcons.user, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Contenu du profil
        SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_animation),
            child: FadeTransition(
              opacity: _animation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte d'informations personnelles
                    _buildCard(
                      title: 'Informations personnelles',
                      icon: FontAwesomeIcons.userAlt,
                      children: [
                        _buildInfoRow('Matricule', _etudiantData?['matricule'] ?? 'Non spécifié'),
                        _buildInfoRow('Nom', _etudiantData?['nom'] ?? 'Non spécifié'),
                        _buildInfoRow('Prénom', _etudiantData?['prenom'] ?? 'Non spécifié'),
                        _buildInfoRow('Sexe', _etudiantData?['sexe'] ?? 'Non spécifié'),
                        _buildInfoRow('Date de naissance', _formatDate(_etudiantData?['dateNaissance'])),
                        _buildInfoRow('Lieu de naissance', _etudiantData?['lieuNaissance'] ?? 'Non spécifié'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Carte d'informations académiques
                    _buildCard(
                      title: 'Informations académiques',
                      icon: FontAwesomeIcons.graduationCap,
                      children: [
                        _buildInfoRow('Niveau', _classeData?['niveau'] ?? 'Non spécifié'),
                        _buildInfoRow('Classe', _classeData?['nom'] ?? 'Non spécifiée'),
                        _buildInfoRow('Filière', _filiereData?['nom'] ?? 'Non spécifiée'),
                        _buildInfoRow('Code filière', _filiereData?['code'] ?? 'Non spécifié'),
                        _buildInfoRow('Délégué', _etudiantData?['estDelegue'] == true ? 'Oui' : 'Non'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Carte d'informations de contact
                    _buildCard(
                      title: 'Informations de contact',
                      icon: FontAwesomeIcons.addressBook,
                      children: [
                        _buildInfoRow('Email', _etudiantData?['email'] ?? 'Non spécifié'),
                        _buildInfoRow('Téléphone', _etudiantData?['telephone'] ?? 'Non spécifié'),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
