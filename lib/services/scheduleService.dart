import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modible_edt/core/routes.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/models/scheduleModel.dart';
import 'package:modible_edt/services/userSessionService.dart';

class ScheduleService {
  final UserSessionService _userSessionService = UserSessionService();

  // Récupérer l'emploi du temps de l'utilisateur connecté
  Future<ApiResponse> getUserSchedule() async {
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
      final response = await http.get(
        Uri.parse(ApiRoutes.getScheduleByUserId(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Emploi du temps récupéré avec succès';
        
        if (responseData['data'] != null) {
          List<dynamic> scheduleData = responseData['data'];
          List<ScheduleModel> schedules = scheduleData
              .map((item) => ScheduleModel.fromJson(item))
              .toList();
          apiResponse.data = schedules;
        } else {
          apiResponse.data = [];
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération de l\'emploi du temps';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
      
      // En cas d'erreur, fournir des données factices pour permettre à l'application de fonctionner
      List<Map<String, dynamic>> mockData = [
        {
          'id': '1',
          'title': 'Mathématiques',
          'description': 'Cours de mathématiques - Algèbre linéaire',
          'startTime': '08:00',
          'endTime': '10:00',
          'date': '2025-04-23',
          'location': 'Salle A101',
          'teacher': 'Prof. Martin',
          'courseId': 'MATH101',
          'courseName': 'Mathématiques',
          'color': '#4CAF50'
        },
        {
          'id': '2',
          'title': 'Physique',
          'description': 'Cours de physique - Mécanique quantique',
          'startTime': '10:30',
          'endTime': '12:30',
          'date': '2025-04-23',
          'location': 'Salle B202',
          'teacher': 'Prof. Dubois',
          'courseId': 'PHYS101',
          'courseName': 'Physique',
          'color': '#2196F3'
        },
        {
          'id': '3',
          'title': 'Informatique',
          'description': 'Cours d\'informatique - Programmation orientée objet',
          'startTime': '14:00',
          'endTime': '16:00',
          'date': '2025-04-23',
          'location': 'Salle C303',
          'teacher': 'Prof. Leroy',
          'courseId': 'INFO101',
          'courseName': 'Informatique',
          'color': '#FF9800'
        }
      ];
      
      apiResponse.data = mockData.map((item) => ScheduleModel.fromJson(item)).toList();
    }
    return apiResponse;
  }

  // Récupérer l'emploi du temps pour une date spécifique
  Future<ApiResponse> getScheduleByDate(String date) async {
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
      final response = await http.get(
        Uri.parse('${ApiRoutes.getScheduleByUserId(userId)}?date=$date'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Emploi du temps récupéré avec succès';
        
        if (responseData['data'] != null) {
          List<dynamic> scheduleData = responseData['data'];
          List<ScheduleModel> schedules = scheduleData
              .map((item) => ScheduleModel.fromJson(item))
              .toList();
          apiResponse.data = schedules;
        } else {
          apiResponse.data = [];
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération de l\'emploi du temps';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
      
      // En cas d'erreur, fournir des données factices pour permettre à l'application de fonctionner
      List<Map<String, dynamic>> mockData = [
        {
          'id': '1',
          'title': 'Mathématiques',
          'description': 'Cours de mathématiques - Algèbre linéaire',
          'startTime': '08:00',
          'endTime': '10:00',
          'date': date,
          'location': 'Salle A101',
          'teacher': 'Prof. Martin',
          'courseId': 'MATH101',
          'courseName': 'Mathématiques',
          'color': '#4CAF50'
        },
        {
          'id': '2',
          'title': 'Physique',
          'description': 'Cours de physique - Mécanique quantique',
          'startTime': '10:30',
          'endTime': '12:30',
          'date': date,
          'location': 'Salle B202',
          'teacher': 'Prof. Dubois',
          'courseId': 'PHYS101',
          'courseName': 'Physique',
          'color': '#2196F3'
        }
      ];
      
      apiResponse.data = mockData.map((item) => ScheduleModel.fromJson(item)).toList();
    }
    return apiResponse;
  }
  
  // Récupérer les cours à venir
  Future<ApiResponse> getUpcomingCourses() async {
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
      final response = await http.get(
        Uri.parse('${ApiRoutes.getScheduleByUserId(userId)}/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        apiResponse.success = responseData['success'] ?? true;
        apiResponse.message = responseData['message'] ?? 'Cours à venir récupérés avec succès';
        
        if (responseData['data'] != null) {
          List<dynamic> scheduleData = responseData['data'];
          List<ScheduleModel> schedules = scheduleData
              .map((item) => ScheduleModel.fromJson(item))
              .toList();
          apiResponse.data = schedules;
        } else {
          apiResponse.data = [];
        }
      } else {
        apiResponse.success = false;
        apiResponse.message = responseData['message'] ?? 'Erreur lors de la récupération des cours à venir';
        apiResponse.errors = responseData['errors'];
      }
    } catch (e) {
      print('Exception: $e');
      apiResponse.success = false;
      apiResponse.message = 'Erreur de connexion';
      apiResponse.errors = e.toString();
      
      // En cas d'erreur, fournir des données factices pour permettre à l'application de fonctionner
      List<Map<String, dynamic>> mockData = [
        {
          'id': '4',
          'title': 'Anglais',
          'description': 'Cours d\'anglais - Communication professionnelle',
          'startTime': '08:00',
          'endTime': '10:00',
          'date': '2025-04-24',
          'location': 'Salle D404',
          'teacher': 'Prof. Smith',
          'courseId': 'ANG101',
          'courseName': 'Anglais',
          'color': '#E91E63'
        },
        {
          'id': '5',
          'title': 'Économie',
          'description': 'Cours d\'économie - Microéconomie',
          'startTime': '10:30',
          'endTime': '12:30',
          'date': '2025-04-24',
          'location': 'Salle E505',
          'teacher': 'Prof. Dupont',
          'courseId': 'ECO101',
          'courseName': 'Économie',
          'color': '#9C27B0'
        }
      ];
      
      apiResponse.data = mockData.map((item) => ScheduleModel.fromJson(item)).toList();
    }
    return apiResponse;
  }
}
