import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: hasNotifications
          ? _buildNotificationsList()
          : _buildEmptyState(),
    );
  }

  final bool hasNotifications = true;

  Widget _buildNotificationsList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDateHeader("Aujourd'hui"),
        const SizedBox(height: 12),
        _buildNotificationItem(
          icon: Icons.computer,
          iconColor: Colors.blue,
          title: 'Rappel: Cours de Programmation',
          time: '23 min',
          message: 'Cours de Java aujourd\'hui à 14h30, salle B204. N\'oubliez pas d\'apporter votre projet.',
          actions: ['Marquer comme lu', 'Voir détails'],
          isUnread: true,
        ),
        const SizedBox(height: 16),
        _buildNotificationItem(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          title: 'Modifications d\'emploi du temps',
          time: '2 hr',
          message: 'Le cours de Réseaux de demain est déplacé de 10h à 13h en salle C305.',
          actions: ['Voir modifications'],
          isUnread: true,
        ),
        const SizedBox(height: 16),
        _buildDateHeader("Hier"),
        const SizedBox(height: 12),
        _buildNotificationItem(
          icon: Icons.assignment_outlined,
          iconColor: Colors.purple,
          title: 'Nouvelle tâche: Projet Base de Données',
          time: '1 jour',
          message: 'Remise du projet SQL le 20 avril. Les consignes sont disponibles sur la plateforme.',
          actions: ['Ajouter à mes tâches', 'Ignorer'],
          isUnread: false,
        ),
        const SizedBox(height: 16),
        _buildDateHeader("Cette semaine"),
        const SizedBox(height: 12),
        _buildNotificationItem(
          icon: Icons.event_note,
          iconColor: Colors.green,
          title: 'Rappel: TD Algorithmes',
          time: '1 sem',
          message: 'N\'oubliez pas de préparer les exercices 3 à 5 pour le TD de demain.',
          actions: ['Voir', 'Fait'],
          isUnread: false,
        ),
        const SizedBox(height: 16),
        _buildNotificationItem(
          icon: Icons.computer,
          iconColor: Colors.blue,
          title: 'Nouveau cours: Intelligence Artificielle',
          time: '1 sem',
          message: 'Un nouveau cours d\'IA a été ajouté à votre emploi du temps le vendredi à 15h.',
          actions: ['Voir détails'],
          isUnread: false,
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        date,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  spreadRadius: 8,
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Vous êtes à jour",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              "Revenez plus tard pour les notifications concernant vos cours, devoirs et modifications d'emploi du temps",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Actualiser",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String message,
    required List<String> actions,
    required bool isUnread,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUnread
            ? Border.all(color: iconColor.withOpacity(0.3), width: 1.5)
            : Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 16,
                              color: isUnread ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUnread ? iconColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isUnread ? iconColor : Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isUnread ? Colors.black87 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: actions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: iconColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: iconColor.withOpacity(0.3)),
                              ),
                              backgroundColor: iconColor.withOpacity(0.05),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              action,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
}