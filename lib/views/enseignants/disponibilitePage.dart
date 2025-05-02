import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/colors.dart';
import '../../models/DisponibiliteModel.dart';
import '../../models/apiResponse.dart';
import '../../services/DisponibiliteService.dart';
import '../../services/UserSessionService.dart';
import '../../services/SeanceService.dart';

class DisponibilitePage extends StatefulWidget {
  const DisponibilitePage({super.key});

  @override
  State<DisponibilitePage> createState() => _DisponibilitePageState();
}

class _DisponibilitePageState extends State<DisponibilitePage> {
  final DisponibiliteService _disponibiliteService = DisponibiliteService();
  final UserSessionService _userSessionService = UserSessionService();
  final SeanceService _seanceService = SeanceService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  String? _enseignantId;
  
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDates = [];
  
  List<Map<String, dynamic>> _creneaux = [];
  Map<String, List<DisponibiliteModel>> _disponibilites = {};
  
  final List<String> _jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      _calculateWeekDates();
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userSession = await _userSessionService.getUserSession();
      if (userSession != null) {
        setState(() {
          _enseignantId = userSession.id;
        });
        await _loadCreneaux();
        await _loadDisponibilites();
      }
    } catch (e) {
      dev.log("Erreur lors du chargement des données utilisateur: ${e.toString()}", error: e);
    }
  }

  void _calculateWeekDates() {
    // Trouver le lundi de la semaine courante
    DateTime monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  Future<void> _loadCreneaux() async {
    try {
      ApiResponse response = await _seanceService.getAllCreneaux();
      if (response.success && response.data != null) {
        setState(() {
          _creneaux = List<Map<String, dynamic>>.from(response.data);
          // Trier les créneaux par heure de début
          _creneaux.sort((a, b) {
            final aHeure = a['heureDebut']?.toString() ?? '';
            final bHeure = b['heureDebut']?.toString() ?? '';
            return aHeure.compareTo(bHeure);
          });
        });
      }
    } catch (e) {
      dev.log('Erreur lors du chargement des créneaux: ${e.toString()}', error: e);
    }
  }

  Future<void> _loadDisponibilites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_enseignantId != null) {
        final formatter = DateFormat('yyyy-MM-dd');
        final debutSemaine = formatter.format(_weekDates.first);
        final finSemaine = formatter.format(_weekDates.last);

        ApiResponse response = await _disponibiliteService.getDisponibilitesByEnseignantAndSemaine(
          _enseignantId!,
          _weekDates.first,
          _weekDates.last,
        );

        if (response.success && response.data != null) {
          List<dynamic> disponibilitesData = response.data;
          List<DisponibiliteModel> disponibilitesList = disponibilitesData
              .map((data) => DisponibiliteModel.fromJson(data))
              .toList();

          // Organiser les disponibilités par jour
          Map<String, List<DisponibiliteModel>> disponibilitesByDay = {};
          for (String jour in _jours) {
            disponibilitesByDay[jour] = [];
          }

          for (var disponibilite in disponibilitesList) {
            if (disponibilite.jour != null && disponibilitesByDay.containsKey(disponibilite.jour!.toLowerCase())) {
              disponibilitesByDay[disponibilite.jour!.toLowerCase()]!.add(disponibilite);
            }
          }

          setState(() {
            _disponibilites = disponibilitesByDay;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
      dev.log('Erreur lors du chargement des disponibilités: ${e.toString()}', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7));
      _calculateWeekDates();
    });
    _loadDisponibilites();
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7));
      _calculateWeekDates();
    });
    _loadDisponibilites();
  }

  Future<void> _updateDisponibilite(String jour, String creneauId, bool disponible, [String? id, String? commentaire]) async {
    try {
      if (_enseignantId == null) return;

      DisponibiliteModel disponibilite = DisponibiliteModel(
        id: id,
        jour: jour,
        creneauId: creneauId,
        enseignantId: _enseignantId,
        disponible: disponible,
        commentaire: commentaire,
        debutSemaine: _weekDates.first,
        finSemaine: _weekDates.last,
      );

      ApiResponse response;
      if (id != null) {
        response = await _disponibiliteService.updateDisponibilite(id, disponibilite);
      } else {
        response = await _disponibiliteService.createDisponibilite(disponibilite);
      }

      if (response.success) {
        // Recharger les disponibilités
        await _loadDisponibilites();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disponibilité mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour de la disponibilité'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      dev.log('Erreur lors de la mise à jour de la disponibilité: ${e.toString()}', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCommentDialog(String jour, String creneauId, bool disponible, [String? id, String? commentaire]) {
    final TextEditingController commentaireController = TextEditingController(text: commentaire);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un commentaire'),
        content: TextField(
          controller: commentaireController,
          decoration: InputDecoration(
            hintText: 'Commentaire (optionnel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateDisponibilite(jour, creneauId, disponible, id, commentaireController.text);
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  DisponibiliteModel? _getDisponibilite(String jour, String creneauId) {
    if (_disponibilites.containsKey(jour)) {
      return _disponibilites[jour]!.firstWhere(
        (d) => d.creneauId == creneauId,
        orElse: () => DisponibiliteModel(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disponibilités'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDisponibilites,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Lottie.asset(
          'assets/animations/loading.json',
          width: 200,
          height: 200,
        ),
      )
          : Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _previousWeek,
                ),
                Text(
                  'Semaine du ${DateFormat('d MMM', 'fr_FR').format(_weekDates.first)} au ${DateFormat('d MMM', 'fr_FR').format(_weekDates.last)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),
          Expanded(
            child: _errorMessage.isNotEmpty
                ? Center(
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            )
                : _creneaux.isEmpty
                ? Center(
              child: Text('Aucun créneau disponible'),
            )
                : RefreshIndicator(
              onRefresh: _loadDisponibilites,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _jours.length,
                itemBuilder: (context, index) {
                  final jour = _jours[index];
                  final jourFormate = jour[0].toUpperCase() + jour.substring(1);
                  
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jourFormate,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ...List.generate(_creneaux.length, (creneauIndex) {
                            final creneau = _creneaux[creneauIndex];
                            final creneauId = creneau['id'];
                            final heureDebut = creneau['heureDebut'];
                            final heureFin = creneau['heureFin'];
                            
                            final disponibilite = _getDisponibilite(jour, creneauId);
                            final bool estDisponible = disponibilite?.disponible ?? false;
                            final String? commentaire = disponibilite?.commentaire;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '$heureDebut - $heureFin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Switch(
                                          value: estDisponible,
                                          onChanged: (value) {
                                            _updateDisponibilite(
                                              jour,
                                              creneauId,
                                              value,
                                              disponibilite?.id,
                                              commentaire,
                                            );
                                          },
                                          activeColor: Colors.blue,
                                        ),
                                        Text(
                                          estDisponible ? 'Disponible' : 'Non disponible',
                                          style: TextStyle(
                                            color: estDisponible ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.comment,
                                      color: commentaire != null && commentaire.isNotEmpty
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _showCommentDialog(
                                        jour,
                                        creneauId,
                                        estDisponible,
                                        disponibilite?.id,
                                        commentaire,
                                      );
                                    },
                                    tooltip: 'Ajouter un commentaire',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
