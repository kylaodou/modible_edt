import 'dart:convert';
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
  String _errorMessage = '';
  bool _estDelegue = false;

  String? _selectedType;
  String? _selectedSalle;
  String? _selectedEnseignant;
  String? _selectedCours;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _calculateWeekDates(); // Initialiser _weekDates immédiatement
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
        _errorMessage = 'Exception: $e';
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
      final response = await _seanceService.getEmploiDuTempsEtudiant(_weekDates.first, _weekDates.last);
      if (response.success) {
        setState(() => _seances = List<Map<String, dynamic>>.from(response.data['data'] ?? []));
        await _loadReferenceData();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReferenceData() async {
    final responses = await Future.wait([
      _seanceService.getAllSalles(),
      _seanceService.getAllCours(),
      _seanceService.getAllEnseignants(),
    ]);

    if (responses[0].success) setState(() => _salles = List<Map<String, dynamic>>.from(responses[0].data));
    if (responses[1].success) setState(() => _cours = List<Map<String, dynamic>>.from(responses[1].data));
    if (responses[2].success) setState(() => _enseignants = List<Map<String, dynamic>>.from(responses[2].data));
  }

  void _resetFilters() => setState(() {
    _selectedType = null;
    _selectedSalle = null;
    _selectedEnseignant = null;
    _selectedCours = null;
  });

  List<Map<String, dynamic>> _getFilteredSeances() {
    return _seances.where((seance) {
      final jour = seance['jour']?.toString().toLowerCase() ?? '';
      final joursMap = {
        'lundi': 1, 'mardi': 2, 'mercredi': 3, 'jeudi': 4,
        'vendredi': 5, 'samedi': 6, 'dimanche': 7
      };
      final jourSeance = joursMap[jour] ?? 0;

      return jourSeance == _selectedDate.weekday &&
          (_selectedType == null || seance['type'] == _selectedType) &&
          (_selectedSalle == null || seance['salleId'] == _selectedSalle) &&
          (_selectedCours == null || seance['coursId'] == _selectedCours) &&
          (_selectedEnseignant == null ||
              (_cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {})['enseignantId'] == _selectedEnseignant));
    }).toList();
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
    final cours = _cours.firstWhere((c) => c['id'] == seance['coursId'], orElse: () => {});
    final salle = _salles.firstWhere((s) => s['id'] == seance['salleId'], orElse: () => {});
    final enseignant = _enseignants.firstWhere((e) => e['id'] == cours['enseignantId'], orElse: () => {});

    final type = seance['type'] ?? 'COURS';
    final color = _getColorByType(type);
    final icon = _getIconByType(type);
    final bool fait = seance['fait'] == true;

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
        border: fait
            ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
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
                  color,
                  color.withOpacity(0.8),
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
                  child: Icon(icon, color: Colors.white, size: 24),
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
                          if (fait)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 18),
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
                          '${cours['code']} - $type',
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
                // Indicateur de statut si le cours est fait
                if (fait) _buildStatusIndicator(),

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
                _buildInfoRow(Icons.location_on, salle.isNotEmpty ? '${salle['batiment']} ${salle['numero']}' : 'Salle non définie'),
                _buildInfoRow(Icons.access_time, seance['creneau'] ?? 'Horaire non défini'),
                if (enseignant.isNotEmpty) _buildInfoRow(Icons.person, '${enseignant['prenom']} ${enseignant['nom']}'),

                // Bout ons d'action pour  les délégués - seulement pour aujourd'hui et si le cours n'est pas fait
                if (_estDelegue && !fait && _isToday())
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildActionButton(seance),
                  ),
                // Si le cours est fait et que l'utilisateur est délégué, afficher des boutons pour modifier ou réinitialiser
                if (_estDelegue && fait)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildModifyStatusButton(seance),
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

  Widget _buildInfoRow(IconData icon, String text) {
    final Color iconColor = const Color(0xFF51C3FE);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
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

}