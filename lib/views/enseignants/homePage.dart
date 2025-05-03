import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modible_edt/views/etudiants/etdPage.dart';

import '../../core/theme/colors.dart';
import '../../services/HomeService.dart';
import '../../services/UserSessionService.dart';
import '../../models/apiResponse.dart';
import '../../models/userSessionModel.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final HomeService _homeService = HomeService();
  final UserSessionService _userSessionService = UserSessionService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _seancesDuJour = [];
  List<Map<String, dynamic>> _seancesSemaine = []; // Nouvelle liste pour les séances de la semaine
  List<Map<String, dynamic>> _cours = [];
  List<Map<String, dynamic>> _salles = [];
  List<Map<String, dynamic>> _enseignants = [];
  List<Map<String, dynamic>> _classes = []; // Liste dédiée pour les classes
  String _jourFormate = '';
  UserSessionModel? _userSession;
  Set<String> _coursIds = {}; // Pour stocker les IDs des cours de la semaine
  Set<String> _salleIds = {}; // Pour stocker les IDs des salles de la semaine
  Set<String> _classeIds = {}; // Pour stocker les IDs des classes de la semaine

  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      _loadUserData();
      _loadData();
      _formatDate();
    });
  }

  Future<void> _loadUserData() async {
    try {
      UserSessionModel? userSession = await _userSessionService.getUserSession();
      if (userSession != null) {
        setState(() {
          _userSession = userSession;
        });
      }
    } catch (e) {
      dev.log("Erreur lors du chargement des données utilisateur: ${e.toString()}", error: e);
    }
  }

  void _formatDate() {
    DateTime now = DateTime.now();
    _jourFormate = DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(now);
    _jourFormate = _jourFormate[0].toUpperCase() + _jourFormate.substring(1);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Récupérer l'ID de l'enseignant connecté
      if (_userSession == null || _userSession!.details == null) {
        await _loadUserData(); // Essayer de charger les données utilisateur si elles ne sont pas disponibles
        if (_userSession == null || _userSession!.details == null) {
          setState(() {
            _errorMessage = 'Impossible de récupérer les informations de l\'enseignant';
          });
          return;
        }
      }

      // Récupérer l'ID de l'enseignant
      String enseignantId = _userSession!.details.id;
      dev.log("ID de l'enseignant connecté: $enseignantId");
      
      // Récupérer les séances de l'enseignant pour aujourd'hui
      DateTime now = DateTime.now();
      String dateFormatted = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      ApiResponse seancesResponse = await _homeService.getSeancesByEnseignantAndDate(enseignantId, dateFormatted);
      dev.log("Réponse de getSeancesByEnseignantAndDate: ${seancesResponse.success}, nombre de séances: ${seancesResponse.data?['data']?.length ?? 0}");

      if (seancesResponse.success && seancesResponse.data != null) {
        var seances = seancesResponse.data['data'] ?? [];
        if (seances is List) {
          setState(() {
            _seancesDuJour = List<Map<String, dynamic>>.from(seances);
          });
          dev.log("Nombre de séances du jour: ${_seancesDuJour.length}");

          Set<String> coursIds = {};
          Set<String> salleIds = {};
          Set<String> enseignantIds = {enseignantId}; // Ajouter l'ID de l'enseignant connecté

          for (var seance in _seancesDuJour) {
            if (seance['coursId'] != null) coursIds.add(seance['coursId']);
            if (seance['salleId'] != null) salleIds.add(seance['salleId']);
          }

          // Récupérer les séances de la semaine pour l'enseignant
          await _loadWeeklySeances(enseignantId);

          if (coursIds.isNotEmpty) {
            ApiResponse coursResponse = await _homeService.getCoursByIds(coursIds.toList());
            if (coursResponse.success && coursResponse.data != null) {
              setState(() {
                _cours = List<Map<String, dynamic>>.from(coursResponse.data);
              });
              dev.log("Nombre de cours récupérés: ${_cours.length}");
            }
          }

          if (salleIds.isNotEmpty) {
            ApiResponse sallesResponse = await _homeService.getSallesByIds(salleIds.toList());
            if (sallesResponse.success && sallesResponse.data != null) {
              setState(() {
                _salles = List<Map<String, dynamic>>.from(sallesResponse.data);
              });
              dev.log("Nombre de salles récupérées: ${_salles.length}");
            }
          }

          if (enseignantIds.isNotEmpty) {
            ApiResponse enseignantsResponse = await _homeService.getEnseignantsByIds(enseignantIds.toList());
            if (enseignantsResponse.success && enseignantsResponse.data != null) {
              setState(() {
                _enseignants = List<Map<String, dynamic>>.from(enseignantsResponse.data);
              });
              dev.log("Nombre d'enseignants récupérés: ${_enseignants.length}");
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
      dev.log("Exception dans _loadData: ${e.toString()}", error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Nouvelle méthode pour charger les séances de la semaine
  Future<void> _loadWeeklySeances(String enseignantId) async {
    try {
      // Déterminer les dates de la semaine actuelle
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      _seancesSemaine = [];
      
      // Pour chaque jour de la semaine
      for (int i = 0; i < 7; i++) {
        DateTime currentDay = startOfWeek.add(Duration(days: i));
        String dateFormatted = "${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}";
        
        // Récupérer les séances pour ce jour
        ApiResponse seancesResponse = await _homeService.getSeancesByEnseignantAndDate(enseignantId, dateFormatted);
        
        if (seancesResponse.success && seancesResponse.data != null) {
          var seances = seancesResponse.data['data'] ?? [];
          if (seances is List && seances.isNotEmpty) {
            for (var seance in seances) {
              _seancesSemaine.add(Map<String, dynamic>.from(seance));
              
              // Ajouter les IDs des cours et salles pour les récupérer plus tard
              if (seance['coursId'] != null) _coursIds.add(seance['coursId']);
              if (seance['salleId'] != null) _salleIds.add(seance['salleId']);
              if (seance['classeId'] != null) _classeIds.add(seance['classeId']);
            }
          }
        }
      }
      
      dev.log("Nombre total de séances de la semaine: ${_seancesSemaine.length}");
      
      // Récupérer les informations des cours et salles si nécessaire
      if (_coursIds.isNotEmpty) {
        ApiResponse coursResponse = await _homeService.getCoursByIds(_coursIds.toList());
        if (coursResponse.success && coursResponse.data != null) {
          setState(() {
            // Ajouter les nouveaux cours sans dupliquer
            for (var cours in List<Map<String, dynamic>>.from(coursResponse.data)) {
              if (!_cours.any((c) => c['id'] == cours['id'])) {
                _cours.add(cours);
              }
            }
          });
        }
      }
      
      if (_salleIds.isNotEmpty) {
        ApiResponse sallesResponse = await _homeService.getSallesByIds(_salleIds.toList());
        if (sallesResponse.success && sallesResponse.data != null) {
          setState(() {
            // Ajouter les nouvelles salles sans dupliquer
            for (var salle in List<Map<String, dynamic>>.from(sallesResponse.data)) {
              if (!_salles.any((s) => s['id'] == salle['id'])) {
                _salles.add(salle);
              }
            }
          });
        }
      }
      
      // Récupérer les informations des classes
      if (_classeIds.isNotEmpty) {
        ApiResponse classesResponse = await _homeService.getClassesByIds(_classeIds.toList());
        if (classesResponse.success && classesResponse.data != null) {
          setState(() {
            // Ajouter les nouvelles classes sans dupliquer
            for (var classe in List<Map<String, dynamic>>.from(classesResponse.data)) {
              if (!_classes.any((c) => c['id'] == classe['id'])) {
                _classes.add(classe);
              }
            }
          });
        }
      }
    } catch (e) {
      dev.log("Erreur lors du chargement des séances de la semaine: ${e.toString()}", error: e);
    }
  }

  Map<String, dynamic> _getCoursInfo(String coursId) {
    return _cours.firstWhere(
            (cours) => cours['id'] == coursId,
        orElse: () => {'intitule': 'Cours inconnu', 'code': ''}
    );
  }

  Map<String, dynamic> _getSalleInfo(String salleId) {
    return _salles.firstWhere(
            (salle) => salle['id'] == salleId,
        orElse: () => {'batiment': '', 'numero': 'Salle inconnue'}
    );
  }

  Map<String, dynamic> _getEnseignantInfo(String enseignantId) {
    return _enseignants.firstWhere(
            (enseignant) => enseignant['id'] == enseignantId,
        orElse: () => {'nom': 'Enseignant inconnu', 'prenom': ''}
    );
  }

  Map<String, dynamic> _getClasseInfo(String classeId) {
    try {
      dev.log("Recherche de la classe avec ID: $classeId");
      dev.log("Nombre total de classes disponibles: ${_classes.length}");
      
      Map<String, dynamic> classe = _classes.firstWhere(
        (c) => c['id'] == classeId, 
        orElse: () => {'nom': 'Classe non définie', 'id': classeId}
      );
      
      dev.log("Classe trouvée: ${classe['nom'] ?? 'Non définie'}");
      return classe;
    } catch (e) {
      dev.log("Erreur lors de la récupération de la classe: ${e.toString()}", error: e);
      return {'nom': 'Classe non définie', 'id': classeId};
    }
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'cm': return Colors.blue;
      case 'td': return Colors.orange;
      case 'tp': return Colors.green;
      case 'ct': return Color(0xFF51C3FE);
      default: return Colors.purple;
    }
  }

  IconData _getIconByType(String type) {
    switch (type.toLowerCase()) {
      case 'cm': return Icons.menu_book;
      case 'td': return Icons.groups;
      case 'tp': return Icons.computer;
      case 'ct': return Icons.school;
      default: return Icons.school;
    }
  }

  List<Map<String, dynamic>> _getFilteredSeances() {
    final DateTime now = DateTime.now();
    final String jourActuel = DateFormat('EEEE', 'fr_FR').format(now).toLowerCase();

    final seancesDuJour = _seancesDuJour.where((seance) =>
    seance['jour'] != null &&
        seance['jour'].toString().toLowerCase() == jourActuel
    ).toList();

    if (_selectedFilter == 'Tous') return seancesDuJour;

    return seancesDuJour.where((seance) =>
    seance['type'] != null &&
        seance['type'].toString().toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  // Récupère tous les cours regroupés par jour pour la semaine
  Map<String, List<Map<String, dynamic>>> _getWeeklySeancesGrouped() {
    final List<String> jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    Map<String, List<Map<String, dynamic>>> seancesByDay = {};

    // Initialiser la map avec des listes vides pour chaque jour
    for (String jour in jours) {
      seancesByDay[jour] = [];
    }

    // Regrouper les séances par jour
    for (var seance in _seancesSemaine) { // Utiliser _seancesSemaine au lieu de _seancesDuJour
      final jour = seance['jour']?.toString().toLowerCase() ?? '';
      if (jours.contains(jour)) {
        // Ajouter des informations supplémentaires pour l'affichage
        Map<String, dynamic> seanceEnrichi = {...seance};
        
        // Ajouter les informations du cours
        if (seance['coursId'] != null) {
          final cours = _getCoursInfo(seance['coursId']);
          if (cours.isNotEmpty) {
            seanceEnrichi['course'] = cours['intitule'] ?? 'Cours inconnu';
            seanceEnrichi['code'] = cours['code'] ?? '';
          }
        }
        
        // Ajouter les informations de la salle
        if (seance['salleId'] != null) {
          final salle = _getSalleInfo(seance['salleId']);
          if (salle.isNotEmpty) {
            seanceEnrichi['room'] = '${salle['batiment'] ?? ''} ${salle['numero'] ?? 'Salle inconnue'}'.trim();
          }
        }
        
        // Ajouter les informations de l a classe
        if (seance['classeId'] != null) {
          final classe = _getClasseInfo(seance['classeId']);
          if (classe.isNotEmpty) {
            seanceEnrichi['classe'] = classe['nom'] ?? 'Classe inconnue';
          } else {
            seanceEnrichi['classe'] = 'Classe inconnue';
          }
        } else {
          seanceEnrichi['classe'] = 'Classe inconnue';
        }
        
        // Ajouter les informations du professeur (l'enseignant connecté)
        if (_userSession != null && _userSession!.details != null) {
          seanceEnrichi['professor'] = _userSession!.nomComplet;
        }
        
        seancesByDay[jour]!.add(seanceEnrichi);
      }
    }

    return seancesByDay;
  }

  List<Map<String, dynamic>> _getWeeklySeances() {
    final List<String> jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    List<Map<String, dynamic>> weeklySeances = [];

    for (String jour in jours) {
      // Récupérer toutes les séances pour ce jour
      final seancesDuJour = _seancesSemaine.where( // Utiliser _seancesSemaine au lieu de _seancesDuJour
            (s) => s['jour'] != null && s['jour'].toString().toLowerCase() == jour,
      ).toList();

      // Ajouter chaque séance avec une information sur le jour
      for (var seance in seancesDuJour) {
        // Enrichir la séance avec des informations supplémentaires
        Map<String, dynamic> seanceEnrichi = {
          ...seance,
          'jourFormatted': jour[0].toUpperCase() + jour.substring(1).toLowerCase(),
        };
        
        // Ajouter les informations du cours
        if (seance['coursId'] != null) {
          final cours = _getCoursInfo(seance['coursId']);
          if (cours.isNotEmpty) {
            seanceEnrichi['course'] = cours['intitule'] ?? 'Cours inconnu';
            seanceEnrichi['code'] = cours['code'] ?? '';
          }
        }
        
        // Ajouter les informations de la salle
        if (seance['salleId'] != null) {
          final salle = _getSalleInfo(seance['salleId']);
          if (salle.isNotEmpty) {
            seanceEnrichi['room'] = '${salle['batiment'] ?? ''} ${salle['numero'] ?? 'Salle inconnue'}'.trim();
          }
        }
        
        // Ajouter les informations de la classe
        if (seance['classeId'] != null) {
          final classe = _getClasseInfo(seance['classeId']);
          if (classe.isNotEmpty) {
            seanceEnrichi['classe'] = classe['nom'] ?? 'Classe inconnue';
          } else {
            seanceEnrichi['classe'] = 'Classe inconnue';
          }
        } else {
          seanceEnrichi['classe'] = 'Classe inconnue';
        }
        
        weeklySeances.add(seanceEnrichi);
      }
    }

    return weeklySeances;
  }

  @override
  Widget build(BuildContext context) {
    final todaySeances = _getFilteredSeances();
    final weeklySeances = _getWeeklySeances();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [// g
                  const SizedBox(height: 10),
                  const Text(
                    'Aujo urd\'hui',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today, color: primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _jourFormate,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_errorMessage.isNotEmpty)
                          Center(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (todaySeances.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Lottie.asset(
                                  'assets/lotties/calendar.json',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                                const Text(
                                  'Aucun cours aujourd\'hui',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: todaySeances.map((seance) {
                              final cours = _getCoursInfo(seance['coursId'] ?? '');
                              final salle = _getSalleInfo(seance['salleId'] ?? '');
                              String enseignantNom = '';
                              if (cours.isNotEmpty && cours['enseignantId'] != null) {
                                final enseignant = _getEnseignantInfo(cours['enseignantId']);
                                enseignantNom = '${enseignant['titre'] ?? ''} ${enseignant['nom'] ?? ''} ${enseignant['prenom'] ?? ''}'.trim();
                                if (enseignantNom.isNotEmpty) enseignantNom = 'Prof: $enseignantNom';
                              }
                              final salleNom = '${salle['batiment'] ?? ''} ${salle['numero'] ?? 'Salle inconnue'}'.trim();
                              final classe = _getClasseInfo(seance['classeId'] ?? '');

                              return Column(
                                children: [
                                  _buildScheduleItem(
                                      seance['creneau'] ?? '',
                                      cours['intitule'] ?? 'Cours inconnu',
                                      salleNom.isEmpty ? 'Salle inconnue' : salleNom,
                                      enseignantNom.isEmpty ? 'Enseignant inconnu' : enseignantNom,
                                      classe['nom'] ?? 'Classe inconnue'
                                  ),
                                  if (todaySeances.indexOf(seance) < todaySeances.length - 1)
                                    const Divider(color: Color(0xFF51C3FE)),
                                ],
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),//hh
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cette semaine',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('Tous', Icons.calendar_view_week, primaryColor, _selectedFilter == 'Tous'),
                        const SizedBox(width: 10),
                        _buildFilterPill('CM', Icons.menu_book, Colors.blue, _selectedFilter == 'CM'),
                        const SizedBox(width: 10),
                        _buildFilterPill('TD', Icons.groups, Colors.orange, _selectedFilter == 'TD'),
                        const SizedBox(width: 10),
                        _buildFilterPill('TP', Icons.computer, Colors.green, _selectedFilter == 'TP'),
                        const SizedBox(width: 10),
                        _buildFilterPill('CT', Icons.school, Color(0xFF51C3FE), _selectedFilter == 'CT'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Récupérer les séances regroupées par jour
                  Builder(builder: (context) {
                    final seancesByDay = _getWeeklySeancesGrouped();
                    final hasAnyCourse = seancesByDay.values.any((list) => list.isNotEmpty);

                    if (!hasAnyCourse) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'Aucun cours cette semaine',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    // Afficher les jours qui ont des cours
                    return SizedBox(
                      height: 400, // Hauteur augmentée pour accommoder plusieurs cours
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: seancesByDay.entries.length,
                        itemBuilder: (context, index) {
                          final entry = seancesByDay.entries.elementAt(index);
                          final jour = entry.key;
                          final seancesDuJour = entry.value;

                          // Ne pas afficher les jours sans cours
                          if (seancesDuJour.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final jourFormatted = jour[0].toUpperCase() + jour.substring(1).toLowerCase();

                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Container(
                              width: 240, // Largeur augmentée pour éviter les débordements
                              child: _buildWeeklyScheduleCard(
                                jourFormatted,
                                DateFormat('dd/MM').format(DateTime.now()), // Date actuelle simplifiée
                                seancesDuJour.map((seance) {
                                  final cours = _getCoursInfo(seance['coursId'] ?? '');
                                  final salle = _getSalleInfo(seance['salleId'] ?? '');
                                  final enseignant = _getEnseignantInfo(cours['enseignantId'] ?? '');
                                  final classe = _getClasseInfo(seance['classeId'] ?? '');

                                  return {
                                    'time': seance['creneau'] ?? '',
                                    'course': cours['intitule'] ?? 'Cours inconnu',
                                    'room': "${salle['batiment'] ?? ''} ${salle['numero'] ?? ''}".trim(),
                                    'professor': "${enseignant['prenom'] ?? ''} ${enseignant['nom'] ?? ''}".trim(),
                                    'classe': classe['nom'] ?? 'Classe inconnue',
                                  };
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String course, String room, String professor, String classe) {
    // Parse the time to display it better
    final String startTime = time.split(' - ')[0];
    final String endTime = time.contains(' - ') ? time.split(' - ')[1] : '';

    // Get screen width for dynamic sizing
    final double screenWidth = MediaQuery.of(context).size.width;

    // Blue color palette to match the theme
    final List<Color> colorPalette = [
      const Color(0xFF51C3FE), // Primary Blue
      const Color(0xFF4E6CFF), // Royal Blue
      const Color(0xFF2196F3), // Material Blue
      const Color(0xFF1976D2), // Darker Blue
    ];
    final Color cardColor = colorPalette[DateTime.now().millisecond % colorPalette.length];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time column with gradient background
            Container(
              width: 70, // Fixed width for time display
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor,
                    cardColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (endTime.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        endTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            // Course details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title and icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.2,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school, color: primaryColor, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Room and professor info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          // Room info
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  room,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Professor info
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  professor,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Classe info
                          Row(
                            children: [
                              const Icon(Icons.groups, size: 16, color: primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  classe,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }// h

  Widget _buildFilterPill(String title, IconData icon, Color color, bool isSelected) {
    // Use blue tones for the filter pills to match the theme
    final Color pillColor = const Color(0xFF51C3FE);

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? pillColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? pillColor : Colors.grey.shade300),
          boxShadow: isSelected ? [
            BoxShadow(
              color: pillColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                icon,
                color: isSelected ? Colors.white : pillColor,
                size: 16
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String day, Color bgColor, String time, String courseName, IconData icon) {
    // Extract room and professor information if available
    String roomInfo = "";
    String professorInfo = "";

    // Check if courseName contains room information
    final Map<String, dynamic>? seance = _getWeeklySeances().cast<Map<String, dynamic>?>().firstWhere(
          (s) => s?['creneau'] == time && _getCoursInfo(s?['coursId'] ?? '')['intitule'] == courseName,
      orElse: () => null,
    );

    if (seance != null) {
      final cours = _getCoursInfo(seance['coursId']);
      final salle = _getSalleInfo(seance['salleId']);
      final enseignant = _getEnseignantInfo(cours['enseignantId']);

      if (salle.isNotEmpty) {
        roomInfo = "${salle['batiment']} ${salle['numero']}";
      }

      if (enseignant.isNotEmpty) {
        professorInfo = "${enseignant['prenom']} ${enseignant['nom']}";
      }
    }

    // Enhanced blue color palette for the app theme
    final Map<String, Color> dayColors = {
      'Lundi': const Color(0xFF51C3FE),     // Primary Blue
      'Mardi': const Color(0xFFFFB24E),     // Royal Blue
      'Mercredi': const Color(0xFF2196F3),  // Material Blue
      'Jeudi': const Color(0xFFF82DCF),     // Darker Blue
      'Vendredi': const Color(0xFFFDA70E),  // Deep Blue
      'Samedi': const Color(0xFF4FB56C),    // Light Blue 900
      'Dimanche': const Color(0xFF0288D1),  // Light Blue 700
    };

    final Map<String, IconData> dayIcons = {
      'Lundi': Icons.wb_sunny_outlined,      // Sun for Monday (start of week)
      'Mardi': Icons.psychology_outlined,    // Brain for Tuesday (focus day)
      'Mercredi': Icons.auto_awesome,        // Sparkle for Wednesday (middle of week)
      'Jeudi': Icons.lightbulb_outline,      // Lightbulb for Thursday (ideas)
      'Vendredi': Icons.celebration,         // Celebration for Friday (end of week)
      'Samedi': Icons.weekend,               // Weekend icon for Saturday
      'Dimanche': Icons.self_improvement,    // Relaxation for Sunday
    };

    // Use the day-specific color or fallback to the provided bgColor
    final Color cardColor = dayColors[day] ?? const Color(0xFF51C3FE);
    final IconData cardIcon = dayIcons[day] ?? icon;

    // Parse the time to display it better
    final String formattedTime = time.contains('-') ? time : "$time";

    // Get screen width to make sizes dynamic
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 48) / 2; // For 2 cards per row with padding

    return Container(
      height: 180, // Fixed height to prevent overflow
      width: cardWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements for visual interest
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day and icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cardIcon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Time with enhanced styling
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Course name with better styling
                Text(
                  courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Room and professor info in a container for better visibility
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Room info
                      if (roomInfo.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Salle $roomInfo",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Add spacing between room and professor if both exist
                      if (roomInfo.isNotEmpty && professorInfo.isNotEmpty)
                        const SizedBox(height: 4),

                      // Professor info
                      if (professorInfo.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                professorInfo,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard(String day, String date, List<Map<String, dynamic>> scheduleItems) {
    // Defin     e day-specific colors in blue tones to match the theme
    final Map<String, Color> dayColors = {
      'Lundi': const Color(0xFF51C3FE),      // Light Blue
      'Mardi': const Color(0xFFFFB24E),      // Royal Blue
      'Mercredi': const Color(0xFF2196F3),   // Material Blue
      'Jeudi': const Color(0xFFF82DCF),      // Darker Blue
      'Vendredi': const Color(0xFFFDA70E),   // Deep Blue
      'Samedi': const Color(0xFF4FB56C),     // Light Blue 900
      'Dimanche': const Color(0xFF0288D1),   // Light Blue 700
    };

    // Day-specific icons that represent the day's character
    final Map<String, IconData> dayIcons = {
      'Lundi': Icons.wb_sunny_outlined,         // Start of the week
      'Mardi': Icons.school_outlined,          // Learning day
      'Mercredi': Icons.auto_stories_outlined,  // Mid-week study
      'Jeudi': Icons.psychology_outlined,      // Thinking day
      'Vendredi': Icons.celebration_outlined,   // Almost weekend
      'Samedi': Icons.weekend_outlined,        // Weekend
      'Dimanche': Icons.self_improvement_outlined, // Rest day
    };

    final Color cardColor = dayColors[day] ?? const Color(0xFF51C3FE);
    final IconData dayIcon = dayIcons[day] ?? Icons.calendar_today;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day header with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardColor,
                  cardColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max, // Assure que la Row prend tout l'espace disponible
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(dayIcon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Course count indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${scheduleItems.length} cours',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Schedule items
          if (scheduleItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun cours prévu',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: scheduleItems.length,
                separatorBuilder: (context, index) => Divider(
                  height: 24,
                  color: Colors.grey[200],
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final item = scheduleItems[index];
                  final String startTime = (item['time'] ?? '').toString().split(' - ')[0];
                  final String endTime = (item['time'] ?? '').toString().contains(' - ') ? (item['time'] ?? '').toString().split(' - ')[1] : '';

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time container
                      Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              startTime,
                              style: TextStyle(
                                color: cardColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (endTime.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  endTime,
                                  style: TextStyle(
                                    color: cardColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Course details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['course'] ?? 'Cours inconnu').toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Room and professor info in a container
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                children: [
                                  // Room info
                                  if ((item['room'] ?? '').toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: cardColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            (item['room'] ?? '').toString(),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if ((item['room'] ?? '').toString().isNotEmpty)
                                    const SizedBox(height: 6),

                                  // Classe info
                                  if ((item['classe'] ?? '').toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.groups, size: 14, color: cardColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            (item['classe'] ?? '').toString(),
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if ((item['classe'] ?? '').toString().isNotEmpty && (item['professor'] ?? '').toString().isNotEmpty)
                                    const SizedBox(height: 6),

                                  // Professo r info
                                  if ((item['professor'] ?? '').toString().isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 14, color: cardColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            (item['professor'] ?? '').toString(),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

      ),
    );
  }
}