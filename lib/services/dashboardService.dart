import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/models/attendanceModel.dart';
import 'package:modible_edt/models/dashboardModel.dart';
import 'package:modible_edt/models/notificationModel.dart';
import 'package:modible_edt/models/scheduleModel.dart';
import 'package:modible_edt/services/userSessionService.dart';

class DashboardService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer les statistiques et données du dashboard
  Future<ApiResponse> getDashboardData() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Récupérer les données de l'utilisateur connecté
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['id'] == null) {
        apiResponse.success = false;
        apiResponse.message = 'Utilisateur non connecté';
        return apiResponse;
      }

      final userId = userData['id'];
      // Supposons qu'il y a un endpoint pour les données du dashboard
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/dashboard/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Données récupérées avec succès';
        
        if (responseData['data'] != null) {
          DashboardModel dashboard = DashboardModel.fromJson(responseData['data']);
          apiResponse.data = dashboard;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération des données';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
      
      // En cas d'erreur, fournir des données factices pour permettre à l'application de fonctionner
      Map<String, dynamic> mockData = {
        'coursesToday': 3,
        'totalCourses': 25,
        'upcomingExams': 2,
        'notifications': 5,
        'attendanceRate': 92,
        'recentCourses': [
          {
            'id': '1',
            'title': 'Mathématiques',
            'startTime': '08:00',
            'endTime': '10:00',
            'date': '2025-04-23',
            'location': 'Salle A101',
            'teacher': 'Prof. Martin'
          },
          {
            'id': '2',
            'title': 'Physique',
            'startTime': '10:30',
            'endTime': '12:30',
            'date': '2025-04-23',
            'location': 'Salle B202',
            'teacher': 'Prof. Dubois'
          },
          {
            'id': '3',
            'title': 'Informatique',
            'startTime': '14:00',
            'endTime': '16:00',
            'date': '2025-04-23',
            'location': 'Salle C303',
            'teacher': 'Prof. Leroy'
          }
        ]
      };
      
      apiResponse.data = DashboardModel.fromJson(mockData);
    }
    return apiResponse;
  }
  

  // Récupérer les notifications d'un utilisateur
  Future<ApiResponse> getNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/notifications/user/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Notifications récupérées avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la récupération des notifications',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Mettre à jour le statut d'une notification (lue/non lue)
  Future<ApiResponse> updateNotificationStatus(String notificationId, bool read) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiRoutes.baseURL}/notifications/$notificationId/status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'read': read}),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Statut de la notification mis à jour avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la mise à jour du statut de la notification',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Supprimer une notification
  Future<ApiResponse> removeNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiRoutes.baseURL}/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Notification supprimée avec succès',
          data: data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la suppression de la notification',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erreur: ${e.toString()}',
      );
    }
  }
  
  // Récupérer les statistiques de présence
  Future<ApiResponse> getAttendanceStats() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      // Récupérer les données de l'utilisateur connecté
      final userData = await _userSessionService.getUserData();
      if (userData == null || userData['id'] == null) {
        apiResponse.success = false;
        apiResponse.message = 'Utilisateur non connecté';
        return apiResponse;
      }

      final userId = userData['id'];
      // Supposons qu'il y a un endpoint pour les statistiques de présence
      final response = await http.get(
        Uri.parse('${ApiRoutes.baseURL}/attendance/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Statistiques récupérées avec succès';
        
        if (responseData['data'] != null) {
          AttendanceModel attendance = AttendanceModel.fromJson(responseData['data']);
          apiResponse.data = attendance;
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération des statistiques';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
      
      // En cas d'erreur, fournir des données factices pour permettre à l'application de fonctionner
      Map<String, dynamic> mockData = {
        'totalCourses': 120,
        'attended': 110,
        'absent': 10,
        'attendanceRate': 92,
        'monthlyStats': [
          {'month': 'Jan', 'rate': 95},
          {'month': 'Fév', 'rate': 90},
          {'month': 'Mar', 'rate': 88},
          {'month': 'Avr', 'rate': 92}
        ]
      };
      
      apiResponse.data = AttendanceModel.fromJson(mockData);
    }
    return apiResponse;
  }
}
