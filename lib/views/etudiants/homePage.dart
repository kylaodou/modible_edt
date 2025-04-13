import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Current Week Schedule
              const SizedBox(height: 10),
              const Text(
                'Aujourd\'hui',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                          child:
                          const Icon(Icons.calendar_today, color: primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Mercredi, 9 Avril 2025',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildScheduleItem('08:00 - 12:00', 'Développement Mobile',
                        'Salle 103', 'Prof: Dr. Ouattara'),
                    const Divider(color: Color(0xFF51C3FE),),
                    _buildScheduleItem(
                        '14:00 - 18:00',
                        'Base de données avancées',
                        'Salle 205',
                        'Prof: Dr. Traoré'),
                  ],
                ),
              ),

              // EDT de la semaine
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                    child: const Text('Voir tout'),
                  ),
                ],
              ),

              // Schedule filters
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(
                        'Tous', Icons.calendar_view_week, primaryColor, true),
                    const SizedBox(width: 10),
                    _buildFilterPill(
                        'Cours', Icons.school, Colors.green, false),
                    const SizedBox(width: 10),
                    _buildFilterPill('TD', Icons.groups, Colors.orange, false),
                    const SizedBox(width: 10),
                    _buildFilterPill(
                        'TP', Icons.computer, Colors.purple, false),
                  ],
                ),
              ),

              // Weekly schedule cards
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final items = [
                      {
                        'day': 'Lundi',
                        'color': Color(0xFF51C3FE),
                        'time': '08:00 - 12:00',
                        'course': 'Systèmes Distribués',
                        'icon': Icons.school,
                      },
                      {
                        'day': 'Mardi',
                        'color': Color(0xFFf6ae29),
                        'time': '14:00 - 18:00',
                        'course': 'Intelligence Artificielle',
                        'icon': Icons.psychology,
                      },
                      {
                        'day': 'Jeudi',
                        'color': Color(0xFF56A060),
                        'time': '08:00 - 12:00',
                        'course': 'Sécurité Informatique',
                        'icon': Icons.security,
                      },
                      {
                        'day': 'Vendredi',
                        'color': Color(0xFF57982ba), // Note: cette couleur a un format incorrect, devrait être 0xFF7982ba
                        'time': '14:00 - 18:00',
                        'course': 'Projet Mobile',
                        'icon': Icons.phone_android,
                      },
                    ];

                    final item = items[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 180, // Définir une largeur fixe pour chaque carte
                        child: _buildScheduleCard(
                          item['day'] as String,
                          item['color'] as Color,
                          item['time'] as String,
                          item['course'] as String,
                          item['icon'] as IconData,
                        ),
                      ),
                    );
                  },
                ),
              )
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFF51C3FE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time.split(' - ')[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(room, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(professor, style: const TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(width: 6),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                  ),
                ),
                Icon(
                  icon,
                  color: Colors.white,
                ),
              ],
            ),
            const Divider(color: Colors.white,),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                courseName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
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