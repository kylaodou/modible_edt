import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/ProfileService.dart';
import 'package:modible_edt/services/userSessionService.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final ProfileService _profileService = ProfileService();
  final UserSessionService _userSessionService = UserSessionService();
  
  bool _isLoading = true;
  String? _errorMessage;
  bool _notificationsEnabled = true;
  Map<String, bool> _notificationTypes = {
    'emploiDuTemps': true,
    'examens': true,
    'devoirs': true,
    'annonces': true,
    'notes': true,
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer les données de l'utilisateur
      final userData = await _userSessionService.getUserData();
      
      if (userData != null && 
          userData['data'] != null && 
          userData['data']['user'] != null) {
        
        // Récupérer l'état des notifications
        final notificationsEnabled = userData['data']['user']['notificationsEnabled'];
        
        setState(() {
          _notificationsEnabled = notificationsEnabled ?? true;
          
          // Récupérer les préférences spécifiques si elles existent
          final notificationPrefs = userData['data']['user']['notificationPreferences'];
          if (notificationPrefs != null) {
            if (notificationPrefs['emploiDuTemps'] != null) {
              _notificationTypes['emploiDuTemps'] = notificationPrefs['emploiDuTemps'];
            }
            if (notificationPrefs['examens'] != null) {
              _notificationTypes['examens'] = notificationPrefs['examens'];
            }
            if (notificationPrefs['devoirs'] != null) {
              _notificationTypes['devoirs'] = notificationPrefs['devoirs'];
            }
            if (notificationPrefs['annonces'] != null) {
              _notificationTypes['annonces'] = notificationPrefs['annonces'];
            }
            if (notificationPrefs['notes'] != null) {
              _notificationTypes['notes'] = notificationPrefs['notes'];
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des paramètres: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mettre à jour l'état global des notifications
      ApiResponse response = await _profileService.updateNotificationPreferences(_notificationsEnabled);

      if (response.success) {
        // Mettre à jour les préférences spécifiques
        // Note: Cette partie dépend de l'API, il faudrait ajouter une méthode spécifique
        // dans le service pour gérer les préférences détaillées
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Préférences de notification mises à jour'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors de la mise à jour des préférences';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de notification'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Icône et titre
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.bell,
                        color: primaryColor,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Paramètres de notification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Personnalisez vos préférences de notification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Afficher un message d'erreur s'il y en a un
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Switch principal pour activer/désactiver toutes les notifications
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.bell,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Notifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Activer ou désactiver toutes les notifications',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            activeColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Types de notifications spécifiques
                  if (_notificationsEnabled)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Types de notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildNotificationTypeSwitch(
                              'Emploi du temps',
                              'Modifications de l\'emploi du temps',
                              FontAwesomeIcons.calendar,
                              'emploiDuTemps',
                            ),
                            const Divider(),
                            _buildNotificationTypeSwitch(
                              'Examens',
                              'Nouveaux examens et modifications',
                              FontAwesomeIcons.fileAlt,
                              'examens',
                            ),
                            const Divider(),
                            _buildNotificationTypeSwitch(
                              'Devoirs',
                              'Nouveaux devoirs et échéances',
                              FontAwesomeIcons.book,
                              'devoirs',
                            ),
                            const Divider(),
                            _buildNotificationTypeSwitch(
                              'Annonces',
                              'Annonces importantes',
                              FontAwesomeIcons.bullhorn,
                              'annonces',
                            ),
                            const Divider(),
                            _buildNotificationTypeSwitch(
                              'Notes',
                              'Publication des notes',
                              FontAwesomeIcons.chartBar,
                              'notes',
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  
                  // Bouton pour enregistrer les modifications
                  ElevatedButton(
                    onPressed: _updateNotificationSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationTypeSwitch(
    String title,
    String subtitle,
    IconData icon,
    String key,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _notificationTypes[key] ?? true,
            onChanged: (value) {
              setState(() {
                _notificationTypes[key] = value;
              });
            },
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
