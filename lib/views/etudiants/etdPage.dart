import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EdtPage extends StatefulWidget {
  const EdtPage({super.key});

  @override
  State<EdtPage> createState() => _EdtPageState();
}

class _EdtPageState extends State<EdtPage> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _calculateWeekDates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateWeekDates() {
    // Find the most recent Monday
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // Scroll to top when changing dates
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _calculateWeekDates();
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _calculateWeekDates();
    });
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
            const SizedBox(height: 16),
            Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthYear = DateFormat('MMMM').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousWeek,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextWeek,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final today = DateTime.now();

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _weekDates.map((date) {
          final dayName = DateFormat('E').format(date);
          final dayNum = date.day.toString();

          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month &&
              _selectedDate.year == date.year;

          final isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          return InkWell(
            onTap: () => _selectDate(date),
            child: Container(
              width: 45,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected ?
                Border.all(color: Colors.blue, width: 1) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    dayName.substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
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
                        dayNum,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white :
                          isToday ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isToday)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleList() {
    // Events for selected date
    final events = _getEventsForSelectedDate();

    if (events.isEmpty) {
      return const Center(
        child: Text(
          "Aucun cours pour cette journée",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(ScheduleEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: event.backgroundColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: event.backgroundColor ?? Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event.icon ?? Icons.event,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title ?? "Événement",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.courseInfo != null && event.courseInfo!.isNotEmpty)
                        Text(
                          event.courseInfo!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Event details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),

                if (event.location != null && event.location!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (event.timeRange != null && event.timeRange!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          event.timeRange!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (event.participants.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            for (int i = 0; i < event.participants.length && i < 3; i++)
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      event.participants[i][0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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

  List<ScheduleEvent> _getEventsForSelectedDate() {
    // In a real app, you would fetch events from a database or API
    // This is just sample data with focus on Informatique L3 courses

    final weekday = _selectedDate.weekday;

    // Different events for different weekdays
    switch (weekday) {
      case 1: // Monday
        return [
          ScheduleEvent(
            title: "Algorithmique avancée",
            courseInfo: "L3 Informatique - CM",
            timeRange: "8:30 - 10:30",
            location: "Salle A204",
            backgroundColor: Colors.purple,
            icon: Icons.code,
            description: "Cours sur les algorithmes de graphes",
            participants: ["Prof. Dupont"],
          ),
          ScheduleEvent(
            title: "Base de données",
            courseInfo: "L3 Informatique - TP",
            timeRange: "11:00 - 12:30",
            location: "Salle Informatique B12",
            backgroundColor: Colors.orange,
            icon: Icons.storage,
            description: "TP sur les requêtes SQL avancées",
            participants: ["Prof. Martin"],
          ),
          ScheduleEvent(
            title: "Programmation Web",
            courseInfo: "L3 Informatique - TD",
            timeRange: "14:00 - 16:00",
            location: "Salle C103",
            backgroundColor: Colors.blue,
            icon: Icons.language,
            description: "TD sur JavaScript et les frameworks front-end",
            participants: ["Dr. Garcia"],
          ),
        ];
      case 2: // Tuesday
        return [
          ScheduleEvent(
            title: "Réseaux",
            courseInfo: "L3 Informatique - CM",
            timeRange: "9:00 - 11:00",
            location: "Amphi B",
            backgroundColor: Colors.blue,
            icon: Icons.wifi,
            description: "Architecture des réseaux TCP/IP",
            participants: ["Prof. Dubois"],
          ),
          ScheduleEvent(
            title: "Intelligence Artificielle",
            courseInfo: "L3 Informatique - CM + TD",
            timeRange: "13:30 - 16:30",
            location: "Salle D205",
            backgroundColor: Colors.red,
            icon: Icons.psychology,
            description: "Introduction au Machine Learning",
            participants: ["Prof. Leroux", "M. Petit"],
          ),
        ];
      case 3: // Wednesday
        return [
          ScheduleEvent(
            title: "Développement Mobile",
            courseInfo: "L3 Informatique - TP",
            timeRange: "8:00 - 12:00",
            location: "Salle info #3",
            backgroundColor: Colors.teal,
            icon: Icons.phone_android,
            description: "TP Développement d'applications Android et Flutter",
            participants: ["M. Laurent"],
          ),
          ScheduleEvent(
            title: "Anglais technique",
            courseInfo: "L3 Informatique - TD",
            timeRange: "13:30 - 15:30",
            location: "Salle des langues A12",
            backgroundColor: Colors.indigo,
            icon: Icons.language,
            participants: ["Mrs. Johnson"],
          ),
        ];
      case 4: // Thursday
        return [
          ScheduleEvent(
            title: "Compilation",
            courseInfo: "L3 Informatique - CM",
            timeRange: "10:30 - 12:30",
            location: "Salle B103",
            backgroundColor: Colors.amber,
            icon: Icons.code,
            description: "Introduction aux analyseurs lexicaux",
            participants: ["Prof. Moreau"],
          ),
          ScheduleEvent(
            title: "Projet tutoré",
            courseInfo: "L3 Informatique - Projet",
            timeRange: "14:00 - 18:00",
            location: "Laboratoire d'informatique",
            backgroundColor: Colors.green,
            icon: Icons.group,
            description: "Suivi de l'avancement du projet de groupe",
            participants: ["Dr. Blanc", "Dr. Rousseau"],
          ),
        ];
      case 5: // Friday
        return [
          ScheduleEvent(
            title: "Sécurité informatique",
            courseInfo: "L3 Informatique - CM",
            timeRange: "8:30 - 10:30",
            location: "Amphi C",
            backgroundColor: Colors.deepPurple,
            icon: Icons.security,
            description: "Cryptographie et sécurité des réseaux",
            participants: ["Prof. Bernard"],
          ),
          ScheduleEvent(
            title: "Génie Logiciel",
            courseInfo: "L3 Informatique - TD",
            timeRange: "11:00 - 13:00",
            location: "Salle D104",
            backgroundColor: Colors.pink,
            icon: Icons.build,
            description: "Méthodologies agiles et patterns de conception",
            participants: ["Dr. Lambert"],
          ),
          ScheduleEvent(
            title: "Systèmes distribués",
            courseInfo: "L3 Informatique - TP",
            timeRange: "14:30 - 17:30",
            location: "Salle Informatique A8",
            backgroundColor: Colors.cyan,
            icon: Icons.cloud,
            description: "Mise en place d'une architecture microservices",
            participants: ["M. Roux"],
          ),
        ];
      case 6: // Saturday
        return [
          ScheduleEvent(
            title: "Conférence DevOps",
            courseInfo: "L3 Informatique - Optionnel",
            timeRange: "10:00 - 12:00",
            location: "Amphi Principal",
            backgroundColor: Colors.deepOrange,
            icon: Icons.live_tv,
            description: "Conférence sur l'intégration continue et le déploiement continu",
            participants: ["Intervenant Extérieur"],
          ),
        ];
      default:
        return [];
    }
  }
}

class ScheduleEvent {
  final String? title;
  final String? courseInfo; // Ajout d'un champ pour les infos du cours (classe, type)
  final String? description;
  final String? timeRange;
  final String? location;
  final Color? backgroundColor;
  final IconData? icon;
  final List<String> participants;

  ScheduleEvent({
    this.title,
    this.courseInfo,
    this.description,
    this.timeRange,
    this.location,
    this.backgroundColor,
    this.icon,
    required this.participants,
  });
}