import 'package:modible_edt/models/scheduleModel.dart';

class DashboardModel {
  int? coursesToday;
  int? totalCourses;
  int? upcomingExams;
  int? notifications;
  double? attendanceRate;
  List<ScheduleModel>? recentCourses;

  DashboardModel({
    this.coursesToday,
    this.totalCourses,
    this.upcomingExams,
    this.notifications,
    this.attendanceRate,
    this.recentCourses,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    List<ScheduleModel>? recentCourses;
    if (json['recentCourses'] != null) {
      recentCourses = List<ScheduleModel>.from(
        json['recentCourses'].map((x) => ScheduleModel.fromJson(x)),
      );
    }

    return DashboardModel(
      coursesToday: json['coursesToday'],
      totalCourses: json['totalCourses'],
      upcomingExams: json['upcomingExams'],
      notifications: json['notifications'],
      attendanceRate: json['attendanceRate']?.toDouble(),
      recentCourses: recentCourses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coursesToday': coursesToday,
      'totalCourses': totalCourses,
      'upcomingExams': upcomingExams,
      'notifications': notifications,
      'attendanceRate': attendanceRate,
      'recentCourses': recentCourses?.map((x) => x.toJson()).toList(),
    };
  }
}
