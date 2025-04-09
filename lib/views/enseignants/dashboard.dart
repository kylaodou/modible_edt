import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/core/theme/colors.dart';

import '../../core/theme/colors.dart';


class EnseignantDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EnseignantDashboardPage({super.key, this.userData});

  @override
  State<EnseignantDashboardPage> createState() =>
      _EnseignantDashboardPageState();
}

class _EnseignantDashboardPageState extends State<EnseignantDashboardPage> {
  int _indexcourrant = 0;
  bool _estDisponible = true;

  void _changerPage(int index) {
    setState(() {
      _indexcourrant = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.userData != null
        ? widget.userData!['nom'] ?? 'Utilisateur'
        : 'Prof. Diallo';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with greeting and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.userData != null &&
                              widget.userData!['photo'] != null
                          ? NetworkImage(widget.userData!['photo'])
                          : null,
                      child: widget.userData == null ||
                              widget.userData!['photo'] == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                  ),
                ],
              ),

              // Disponibilité toggle
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _estDisponible ? Icons.check_circle : Icons.cancel,
                          color: _estDisponible ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Statut: ${_estDisponible ? 'Disponible' : 'Indisponible'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _estDisponible,
                      onChanged: (value) {
                        setState(() {
                          _estDisponible = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),

              // Planning du jour
              SizedBox(height: 20),
              Text(
                'Aujourd\'hui',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.calendar_today, color: Colors.blue),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Mercredi, 9 Avril 2025',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildCourseItem('08:00 - 12:00', 'Développement Mobile',
                        'L3 Informatique', 'Salle 103', true),
                    Divider(),
                    _buildCourseItem('14:00 - 18:00', 'Architecture Logicielle',
                        'M1 Génie Logiciel', 'Salle 205', false),
                  ],
                ),
              ),

              // Déclarer indisponibilité
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes cours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Action pour ajouter une indisponibilité
                    },
                    child: Text('Voir tout'),
                  ),
                ],
              ),

              // Filters
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('Cette semaine', Icons.calendar_today,
                        Colors.blue, true),
                    SizedBox(width: 10),
                    _buildFilterPill(
                        'Indisponibilités', Icons.block, Colors.red, false),
                    SizedBox(width: 10),
                    _buildFilterPill('Cours validés', Icons.check_circle,
                        Colors.green, false),
                    SizedBox(width: 10),
                    _buildFilterPill(
                        'À venir', Icons.upcoming, Colors.orange, false),
                  ],
                ),
              ),

              // Weekly schedule cards
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildScheduleCard(
                        'Lundi',
                        Colors.blue.shade100,
                        '08:00 - 12:00',
                        'Sécurité Informatique',
                        'M2 Cybersécurité',
                        Icons.security,
                        true),
                    _buildScheduleCard(
                        'Mardi',
                        Colors.green.shade100,
                        '14:00 - 18:00',
                        'Intelligence Artificielle',
                        'L3 Informatique',
                        Icons.psychology,
                        true),
                    _buildScheduleCard(
                        'Jeudi',
                        Colors.orange.shade100,
                        '08:00 - 12:00',
                        'Big Data',
                        'M1 Data Science',
                        Icons.data_usage,
                        false),
                    _buildScheduleCard(
                        'Vendredi',
                        Colors.purple.shade100,
                        '14:00 - 18:00',
                        'Programmation Réseau',
                        'L3 Réseaux',
                        Icons.router,
                        false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(60)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50,
              offset: const Offset(0, 2),
              spreadRadius: 5,
              blurRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Action pour ajouter une indisponibilité ou marquer un cours comme fait
            _showAddIndisponibiliteModal(context);
          },
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          backgroundColor: Colors.lightBlueAccent,
          child: const Icon(
            Icons.edit_calendar,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GNav(
              selectedIndex: _indexcourrant,
              onTabChange: _changerPage,
              color: Colors.lightBlueAccent,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.lightBlueAccent,
              padding: const EdgeInsets.all(10),
              gap: 5,
              tabs: const [
                GButton(
                  icon: CupertinoIcons.home,
                  text: "Accueil",
                ),
                GButton(
                  icon: CupertinoIcons.calendar,
                  text: "Emploi du temps",
                ),
                GButton(
                  icon: CupertinoIcons.clock,
                  text: "Indisponibilités",
                ),
                GButton(
                  icon: FontAwesomeIcons.user,
                  iconSize: 22,
                  text: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddIndisponibiliteModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Déclarer une indisponibilité',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('9 Avril 2025'),
                  Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Créneau horaire',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('08:00'),
                        Icon(Icons.access_time, size: 20, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('12:00'),
                        Icon(Icons.access_time, size: 20, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Motif',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Raison de l\'indisponibilité...',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirmer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(
      String time, String course, String classe, String room, bool isUpcoming) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUpcoming ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time.split(' - ')[0],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.group, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(classe, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(room, style: TextStyle(color: Colors.grey)),
                    Spacer(),
                    if (!isUpcoming)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 12, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Effectué',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
      String title, IconData icon, Color color, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : color,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String day, Color bgColor, String time,
      String courseName, String classe, IconData icon, bool isUpcoming) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.black54,
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              classe,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "Salle 101",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!isUpcoming)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 12, color: Colors.green),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
