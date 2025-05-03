import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/core/routes.dart';
import '../../services/SeanceService.dart';
import '../../services/SeanceFaiteService.dart';
import '../../services/UserSessionService.dart';
import '../../models/apiResponse.dart';
import '../../models/seanceFaiteDto.dart';

class EdtPage extends StatefulWidget {
  const EdtPage({super.key});

  @override
  State<EdtPage> createState() => _EdtPageState();
}

class _EdtPageState extends State<EdtPage> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDates = [];
  final ScrollController _scrollController = ScrollController();
  final SeanceService _seanceService = SeanceService();
  final SeanceFaiteService _seanceFaiteService = SeanceFaiteService();
  final UserSessionService _userSessionService = UserSessionService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _seances = [];
  List<Map<String, dynamic>> _cours = [];
  List<Map<String, dynamic>> _salles = [];
  List<Map<String, dynamic>> _enseignants = [];
  List<Map<String, dynamic>> _classes = [];
  String _errorMessage = '';
  bool _estDelegue = false;

  String? _selectedType;
  String? _selectedSalle;
  String? _selectedEnseignant;
  String? _selectedCours;
  bool _showFilters = false;

  // Cache pour stocker les informations des classes déjà récupérées
  final Map<String, Map<String, dynamic>> _classeCache = {};

  // Méthode pour récupérer les informations d'une classe avec cache
  Future<Map<String, dynamic>> _getClasseInfo(String? classeId) async {
    if (classeId == null || classeId.isEmpty) {
      dev.log("ClasseId est null ou vide");
      return {};
    }

    // Vérifier si la classe est déjà dans le cache
    if (_classeCache.containsKey(classeId)) {
      dev.log("Classe $classeId trouvée dans le cache");
      return _classeCache[classeId]!;
    }

    // Vérifier si la classe est déjà dans la liste des classes chargées
    final classeFromList = _classes.firstWhere(
      (c) => c['id'] == classeId,
      orElse: () => {},
    );

    if (classeFromList.isNotEmpty) {
      dev.log("Classe $classeId trouvée dans la liste des classes");
      _classeCache[classeId] = classeFromList;
      return classeFromList;
    }

    // Si la classe n'est pas dans le cache ni dans la liste, faire un appel API
    dev.log("Récupération de la classe $classeId depuis l'API");
    final response = await _seanceService.getClasseById(classeId);
    
    if (response.success && response.data != null) {
      final classeData = response.data;
      _classeCache[classeId] = classeData;
      return classeData;
    } else {
      dev.log("Erreur lors de la récupération de la classe: ${response.message}");
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateWeekDates(); //  Initialiser _weekDates immédiatement
    initializeDateFormatting('fr_FR', null).then((_) {
      _checkUserRole();
      _loadData();
    });
  }
  void showMarquerSeanceFaiteDialog(Map<String, dynamic> seance) {
    final TextEditingController commentaireController = TextEditingController();
    final bool fait = seance['fait'] == true;
    final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
    final String coursTitle = cours['intitule'] ?? 'Cours inconnu';
    final String coursCode = cours['code'] ?? '';
    final String type = seance['type'] ?? 'COURS';
    final Color color = _getColorByType(type);

    if (seance['commentaire'] != null && seance['commentaire'].toString().isNotEmpty) {
      commentaireController.text = seance['commentaire'];
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIconByType(type), color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fait ? 'Modifier le statut du cours' : 'Marquer le cours comme fait',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$coursTitle ($coursCode)',
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (fait)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cette séance est déjà marquée comme faite',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                'Commentaire',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentaireController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire sur cette séance',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (fait)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        reinitialiserSeanceFaite(seance);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Réi nitialiser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      marquerSeanceFaite(seance, commentaireController.text);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

// Fonction pour marquer une séance comme faite
  void marquerSeanceFaite(Map<String, dynamic> seance, String commentaire) async {
    try {
      final url = Uri.parse('${ApiRoutes.baseURL}/seance-faite/${seance['id']}');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'commentaire': commentaire,
      });

      setState(() {
        _isLoading = true;
      });

      final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
      final String coursTitle = cours['intitule'] ?? 'Cours';

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
        if (apiResponse.success) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cours marqué comme fait',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          coursTitle,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(8),
              duration: const Duration(seconds: 3),
            ),
          );
          _loadData();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = apiResponse.message ?? 'Une erreur est survenue';
          });
          _showErrorSnackBar(_errorMessage);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur serveur: ${response.statusCode}';
        });
        _showErrorSnackBar(_errorMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: $e';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

// Fonction pour réinitialiser le statut d'une séance
  void reinitialiserSeanceFaite(Map<String, dynamic> seance) async {
    try {
      final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
      final String coursTitle = cours['intitule'] ?? 'Cours';

      final response = await _seanceFaiteService.reinitialiserSeanceFaite(seance['id']);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut du cours réinitialisé',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        coursTitle,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
          ),
        );
        _loadData();
      } else {
        _showErrorSnackBar(response.message ?? 'Une erreur est survenue');
      }
    } catch (e) {
      _showErrorSnackBar('Exception: $e');
    }
  }
  Future<void> _checkUserRole() async {
    Map<String, dynamic>? userData = await _userSessionService.getUserData();
    if (userData?['data']?['details']?['estDelegue'] != null) {
      setState(() => _estDelegue = userData!['data']['details']['estDelegue']);
    }
  }

  void _calculateWeekDates() {
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _selectDate(DateTime date) {
    setState(() {
      _isLoading = true;
      _seances = []; // Vider les séances avant de charger les nouvelles
      _selectedDate = date;
      _resetFilters();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    _loadData(); // Charger les nouvelles séances pour la date sélectionnée
  }

  void _previousWeek() {
    setState(() {
      _isLoading = true;
      _seances = []; // Vider les séances avant de charger les nouvelles
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _calculateWeekDates();
    });
    _loadData(); // Charger les nouvelles séances
  }

  void _nextWeek() {
    setState(() {
      _isLoading = true;
      _seances = []; // Vider les séances avant de charger les nouvelles
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _calculateWeekDates();
    });
    _loadData(); // Charger les nouvelles séances
  }

  Future<void> _marquerSeanceFaite(Map<String, dynamic> seance, String commentaire) async {
    setState(() => _isLoading = true);
    try {
      final response = await _seanceFaiteService.marquerSeanceFaite(
          seance['id'],
          SeanceFaiteDto(commentaire: commentaire.isEmpty ? null : commentaire)
      );
      if (response.success) {
        setState(() {
          _seances = _seances.map((s) => s['id'] == seance['id']
              ? {...s, 'fait': true, 'commentaire': commentaire}
              : s).toList();
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reinitialiserSeanceFaite(Map<String, dynamic> seance) async {
    setState(() => _isLoading = true);
    try {
      final response = await _seanceFaiteService.reinitialiserSeanceFaite(seance['id']);
      if (response.success) {
        setState(() {
          _seances = _seances.map((s) => s['id'] == seance['id']
              ? {...s, 'fait': false, 'commentaire': null}
              : s).toList();
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _seances = [];
    });

    try {
      // Récupérer l'ID de l'enseignant connecté
      final userSession = await _userSessionService.getUserSession();
      if (userSession == null || userSession.details == null || userSession.details.id == null) {
        setState(() => _errorMessage = 'Impossible de récupérer les informations de l\'enseignant');
        return;
      }

      // Formater les dates au format YYYY-MM-DD
      String debutFormatted = "${_weekDates.first.year}-${_weekDates.first.month.toString().padLeft(2, '0')}-${_weekDates.first.day.toString().padLeft(2, '0')}";
      String finFormatted = "${_weekDates.last.year}-${_weekDates.last.month.toString().padLeft(2, '0')}-${_weekDates.last.day.toString().padLeft(2, '0')}";

      dev.log("Récupération des séances pour l'enseignant ${userSession.details.id} du $debutFormatted au $finFormatted");

      // Récupérer les séances de l'enseignant pour la période spécifiée
      final response = await _seanceService.getSeancesByEnseignantAndDateRange(
          userSession.details.id,
          debutFormatted,
          finFormatted
      );

      if (response.success) {
        dev.log("Nombre de séances récupérées: ${(response.data['data'] ?? []).length}");
        setState(() => _seances = List<Map<String, dynamic>>.from(response.data['data'] ?? []));
        await _loadReferenceData();
      } else {
        setState(() => _errorMessage = response.message ?? 'Erreur lors de la récupération des séances');
      }
    } catch (e) {
      dev.log("Exception dans _loadData: ${e.toString()}", error: e);
      setState(() => _errorMessage = 'Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReferenceData() async {
    dev.log("Chargement des données de référence");

    // Récupérer les IDs des classes à partir des séances
    Set<String> classeIds = {};
    for (var seance in _seances) {
      if (seance['classeId'] != null) {
        classeIds.add(seance['classeId']);
        dev.log("ClasseID trouvé dans une séance: ${seance['classeId']}");
      }
    }

    dev.log("Nombre de classeIds trouvés: ${classeIds.length}");

    final responses = await Future.wait([
      _seanceService.getAllSalles(),
      _seanceService.getAllCours(),
      _seanceService.getAllEnseignants(),
      classeIds.isNotEmpty ? _seanceService.getClassesByIds(classeIds.toList()) : _seanceService.getAllClasses(),
    ]);

    if (responses[0].success) {
      setState(() => _salles = List<Map<String, dynamic>>.from(responses[0].data));
      dev.log("Salles récupérées: ${_salles.length}");
    }
    if (responses[1].success) {
      setState(() => _cours = List<Map<String, dynamic>>.from(responses[1].data));
      dev.log("Cours récupérés: ${_cours.length}");
    }
    if (responses[2].success) {
      setState(() => _enseignants = List<Map<String, dynamic>>.from(responses[2].data));
      dev.log("Enseignants récupérés: ${_enseignants.length}");
    }
    if (responses[3].success) {
      setState(() => _classes = List<Map<String, dynamic>>.from(responses[3].data));
      dev.log("Classes récupérées: ${_classes.length}");
      // Afficher les IDs des classes récupérées pour le débogage
      for (var classe in _classes) {
        dev.log("Classe ID: ${classe['id']}, Nom: ${classe['nom']}");
      }
    }
  }

  void _resetFilters() => setState(() {
    _selectedType = null;
    _selectedSalle = null;
    _selectedEnseignant = null;
    _selectedCours = null;
  });

  List<Map<String, dynamic>> _getFilteredSeances() {
    dev.log("Filtrage des séances. Nombre total: ${_seances.length}");
    dev.log("Date sélectionnée: ${_selectedDate.weekday} (${DateFormat('EEEE', 'fr_FR').format(_selectedDate)})");
    
    final filteredSeances = _seances.where((seance) {
      final jour = seance['jour']?.toString().toLowerCase() ?? '';
      dev.log("Séance jour: $jour");
      
      // Mapping français des jours de la semaine
      final joursMap = {
        'lundi': 1, 
        'mardi': 2, 
        'mercredi': 3, 
        'jeudi': 4,
        'vendredi': 5, 
        'samedi': 6, 
        'dimanche': 7
      };
      
      final jourSeance = joursMap[jour];
      dev.log("Jour séance mappé: $jourSeance, jour sélectionné: ${_selectedDate.weekday}");
      
      final bool jourMatch = jourSeance == _selectedDate.weekday;
      final bool typeMatch = _selectedType == null || seance['type'] == _selectedType;
      final bool salleMatch = _selectedSalle == null || seance['salleId'] == _selectedSalle;
      final bool coursMatch = _selectedCours == null || seance['coursId'] == _selectedCours;
      
      final bool enseignantMatch = _selectedEnseignant == null ||
          (_cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {})['enseignantId'] == _selectedEnseignant);
      
      dev.log("Séance ${seance['id']}: jourMatch=$jourMatch, typeMatch=$typeMatch, salleMatch=$salleMatch, coursMatch=$coursMatch, enseignantMatch=$enseignantMatch");
      
      return jourMatch && typeMatch && salleMatch && coursMatch && enseignantMatch;
    }).toList();
    
    dev.log("Nombre de séances après filtrage: ${filteredSeances.length}");
    return filteredSeances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendarStrip(),
            if (_showFilters) _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                  : _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateFormat('MMMM yyyy', 'fr_FR').format(_selectedDate),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.filter_list), onPressed: () => setState(() => _showFilters = !_showFilters)),
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousWeek),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextWeek),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _weekDates.map((date) => _buildDateItem(date)).toList(),
      ),
    );
  }

  Widget _buildDateItem(DateTime date) {
    final isSelected = _selectedDate.difference(date).inDays == 0;
    final isToday = date.difference(DateTime.now()).inDays == 0;

    return InkWell(
      onTap: () => _selectDate(date),
      child: Container(
        width: 45,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isToday && !isSelected ? Border.all(color: Colors.blue) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E', 'fr_FR').format(date).substring(0, 3),
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 13),
            ),//hh
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isToday ? Colors.blue : Colors.black),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 200 : 0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDropdown<String>(
                          'Type de séance',
                          _selectedType,
                          ['CM', 'TD', 'TP'],
                              (value) => setState(() => _selectedType = value)
                      ),
                      _buildDropdown<String>(
                          'Salle',
                          _selectedSalle,
                          _salles.map((s) => s['id'] as String).toList(),
                              (value) => setState(() => _selectedSalle = value),
                          display: (s) => '${_salles.firstWhere((e) => e['id'] == s)['batiment']} ${_salles.firstWhere((e) => e['id'] == s)['numero']}'
                      ),
                      _buildDropdown<String>(
                          'Enseignant',
                          _selectedEnseignant,
                          _enseignants.map((e) => e['id'] as String).toList(),
                              (value) => setState(() => _selectedEnseignant = value),
                          display: (e) => '${_enseignants.firstWhere((a) => a['id'] == e)['nom']}'
                      ),
                      _buildDropdown<String>(
                          'Cours',
                          _selectedCours,
                          _cours.map((c) => c['id'] as String).toList(),
                              (value) => setState(() => _selectedCours = value),
                          display: (c) => _cours.firstWhere((a) => a['id'] == c)['intitule']
                      ),
                      ElevatedButton(
                        onPressed: _resetFilters,
                        child: const Text('Réinitialiser les filtres'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T? value, List<T> items, ValueChanged<T?> onChanged, {String Function(T)? display}) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: value,
      items: items.map((e) => DropdownMenuItem(
        value: e,
        child: Text(display != null ? display(e) : e.toString()),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildScheduleList() {
    final seances = _getFilteredSeances();

    if (seances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                'assets/lotties/calendar.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune séance cette journée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Essayez de sélectionner un autre jour ou de modifier vos filtres',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: seances.length,
      itemBuilder: (context, index) => _buildEventCard(seances[index]),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> seance) {
    // Récupérer les informations nécessaires
    final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
    final salle = _salles.firstWhere((s) => s['id'] == seance['salleId'], orElse: () => {});
    final enseignant = _enseignants.firstWhere((e) => e['id'] == cours['enseignantId'], orElse: () => {});

    // Récupération de l'ID de la classe avec log détaillé
    String? classeId = seance['classeId'];
    dev.log("Recherche de la classe avec ID: $classeId");
    dev.log("Nombre total de classes disponibles: ${_classes.length}");

    final type = seance['type'] ?? 'COURS';
    final color = _getColorByType(type);
    final icon = _getIconByType(type);
    final bool fait = seance['fait'] == true;
    final String statut = seance['statut'] ?? 'PLANIFIÉ';
    final String justification = seance['justification'] ?? '';

    // Vérifier si la séance est passée (date antérieure à aujourd'hui)
    bool estPassee = false;
    if (seance['jour'] != null && seance['debutSemaine'] != null) {
      final String jour = seance['jour'].toLowerCase();
      final List<String> jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
      final int jourIndex = jours.indexOf(jour);

      if (jourIndex != -1) {
        final DateTime debutSemaine = DateTime.parse(seance['debutSemaine'].toString().split('T')[0]);
        final DateTime dateSeance = debutSemaine.add(Duration(days: jourIndex));
        estPassee = dateSeance.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          )
        ],
        border: statut == 'CONFIRMÉ'
            ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
            : statut == 'ANNULÉ'
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
            : Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // En-tête du cours avec gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statut == 'CONFIRMÉ' ? Colors.green :
                  statut == 'ANNULÉ' ? Colors.red : color,
                  statut == 'CONFIRMÉ' ? Colors.green.withOpacity(0.8) :
                  statut == 'ANNULÉ' ? Colors.red.withOpacity(0.8) : color.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Icône du type de cours
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(
                      statut == 'CONFIRMÉ' ? Icons.check_circle :
                      statut == 'ANNULÉ' ? Icons.cancel : icon,
                      color: Colors.white,
                      size: 24
                  ),
                ),
                const SizedBox(width: 16),
                // Titre et code du cours
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cours['intitule'] ?? 'Cours inconnu',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (statut == 'CONFIRMÉ')
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 18),
                            ),
                          if (statut == 'ANNULÉ')
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Badge pour le code et type de cours
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          '${cours['code'] ?? ''} - $type',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu du cours
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicateur de statut
                if (statut == 'CONFIRMÉ')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade500,
                          Colors.green.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cours confirmé',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (statut == 'ANNULÉ')
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade500,
                          Colors.red.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.cancel, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cours annulé',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Affichage de la justification si le cours est annulé
                if (statut == 'ANNULÉ' && justification.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Justification:',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red[700], fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          justification,
                          style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                // Affichage du commentaire s'il existe
                if (seance['commentaire'] != null && seance['commentaire'].toString().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment, size: 18, color: color),
                            const SizedBox(width: 8),
                            Text(
                              'Commentaire:',
                              style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          seance['commentaire'],
                          style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                // Informations sur le cours
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on, salle.isNotEmpty ? '${salle['batiment'] ?? ''} ${salle['numero'] ?? ''}' : 'Salle non définie'),
                _buildInfoRow(Icons.access_time, seance['creneau'] ?? 'Horaire non défini'),
                
                // Utiliser FutureBuilder pour charger les informations de la classe de manière asynchrone
                FutureBuilder<Map<String, dynamic>>(
                  future: _getClasseInfo(classeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildInfoRow(
                        Icons.groups,
                        'Chargement de la classe...',
                        color: Colors.blue[700]
                      );
                    } else if (snapshot.hasError) {
                      dev.log("Erreur lors du chargement de la classe: ${snapshot.error}");
                      return _buildInfoRow(
                        Icons.error_outline,
                        'Erreur de chargement',
                        color: Colors.red[700]
                      );
                    } else {
                      final classe = snapshot.data ?? {};
                      return _buildInfoRow(
                        Icons.groups,
                        classe.isNotEmpty ? '${classe['nom'] ?? ''}' : 'Classe non définie',
                        color: Colors.blue[700]
                      );
                    }
                  },
                ),
                
                if (enseignant.isNotEmpty) _buildInfoRow(Icons.person, '${enseignant['prenom'] ?? ''} ${enseignant['nom'] ?? ''}'),

                // Boutons d'action pour confirmer ou annuler le cours - seulement si le cours n'est pas passé
                if (!estPassee && statut != 'CONFIRMÉ' && statut != 'ANNULÉ')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmerSeance(seance),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text('Confirmer ma venue'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              shadowColor: Colors.green.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _annulerSeance(seance),
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: const Text('Annuler le cours'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              shadowColor: Colors.red.withOpacity(0.4),
                            ),
                          ),
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

  Widget _buildModifyStatusButton(Map<String, dynamic> seance) {
    return Row(
      children: [
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade500,
            Colors.green.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Cours fait',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: color ?? Colors.grey[800],
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> seance) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => showMarquerSeanceFaiteDialog(seance),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text('Marquer comme fait'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          shadowColor: Colors.green.withOpacity(0.4),
        ),
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'cm': return Colors.blue;
      case 'td': return Colors.orange;
      case 'tp': return Colors.green;
      case 'ct': return const Color(0xFF51C3FE);
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

  // Vérifie si la date sélectionnée est aujourd'hui
  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _confirmerSeance(Map<String, dynamic> seance) async {
    try {
      final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
      final String coursTitle = cours['intitule'] ?? 'Cours';

      final response = await _seanceFaiteService.confirmerSeance(seance['id']);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cours confirmé',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        coursTitle,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
          ),
        );
        _loadData();
      } else {
        _showErrorSnackBar(response.message ?? 'Une erreur est survenue');
      }
    } catch (e) {
      _showErrorSnackBar('Exception: $e');
    }
  }

  void _annulerSeance(Map<String, dynamic> seance) async {
    try {
      final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
      final String coursTitle = cours['intitule'] ?? 'Cours';

      // Afficher une boîte de dialogue pour demander une justification
      final TextEditingController justificationController = TextEditingController();

      final bool? result = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Annuler le cours',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coursTitle,
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Veuillez fournir une justification pour l\'annulation de ce cours :',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: justificationController,
                  decoration: InputDecoration(
                    hintText: 'Exemple : Absence pour raison médicale...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (justificationController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez fournir une justification'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirmer l\'annulation'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (result == true) {
        final response = await _seanceService.annulerSeance(seance['id'], justificationController.text);

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cours annulé',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          coursTitle,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(8),
              duration: const Duration(seconds: 3),
            ),
          );
          _loadData();
        } else {
          _showErrorSnackBar(response.message ?? 'Une erreur est survenue');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Exception: $e');
    }
  }
}