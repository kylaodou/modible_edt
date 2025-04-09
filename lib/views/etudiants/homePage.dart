import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class Homepage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const Homepage({super.key, required this.userData});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    String name = widget.userData?['nom'];
    return Scaffold(
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

              // Current Week Schedule
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
                          child:
                              Icon(Icons.calendar_today, color: primaryColor),
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
                    _buildScheduleItem('08:00 - 12:00', 'Développement Mobile',
                        'Salle 103', 'Prof: Dr. Ouattara'),
                    Divider(),
                    _buildScheduleItem(
                        '14:00 - 18:00',
                        'Base de données avancées',
                        'Salle 205',
                        'Prof: Dr. Traoré'),
                  ],
                ),
              ),

              // EDT de la semaine
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cette semaine',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Action pour voir tout l'EDT
                    },
                    child: Text('Voir tout'),
                  ),
                ],
              ),

              // Schedule filters
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(
                        'Tous', Icons.calendar_view_week, primaryColor, true),
                    SizedBox(width: 10),
                    _buildFilterPill(
                        'Cours', Icons.school, Colors.green, false),
                    SizedBox(width: 10),
                    _buildFilterPill('TD', Icons.groups, Colors.orange, false),
                    SizedBox(width: 10),
                    _buildFilterPill(
                        'TP', Icons.computer, Colors.purple, false),
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
                      'Systèmes Distribués',
                      Icons.school,
                    ),
                    _buildScheduleCard(
                      'Mardi',
                      Colors.green.shade100,
                      '14:00 - 18:00',
                      'Intelligence Artificielle',
                      Icons.psychology,
                    ),
                    _buildScheduleCard(
                      'Jeudi',
                      Colors.orange.shade100,
                      '08:00 - 12:00',
                      'Sécurité Informatique',
                      Icons.security,
                    ),
                    _buildScheduleCard(
                      'Vendredi',
                      Colors.purple.shade100,
                      '14:00 - 18:00',
                      'Projet Mobile',
                      Icons.phone_android,
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

  Widget _buildScheduleItem(
      String time, String course, String room, String professor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue,
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
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(room, style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 12),
                    Icon(Icons.person, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(professor, style: TextStyle(color: Colors.grey)),
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
      String courseName, IconData icon) {
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
            Expanded(
              child: Text(
                courseName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
