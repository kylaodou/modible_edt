class AttendanceModel {
  int? totalCourses;
  int? attended;
  int? absent;
  double? attendanceRate;
  List<MonthlyAttendance>? monthlyStats;

  AttendanceModel({
    this.totalCourses,
    this.attended,
    this.absent,
    this.attendanceRate,
    this.monthlyStats,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    List<MonthlyAttendance>? monthlyStats;
    if (json['monthlyStats'] != null) {
      monthlyStats = List<MonthlyAttendance>.from(
        json['monthlyStats'].map((x) => MonthlyAttendance.fromJson(x)),
      );
    }

    return AttendanceModel(
      totalCourses: json['totalCourses'],
      attended: json['attended'],
      absent: json['absent'],
      attendanceRate: json['attendanceRate']?.toDouble(),
      monthlyStats: monthlyStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCourses': totalCourses,
      'attended': attended,
      'absent': absent,
      'attendanceRate': attendanceRate,
      'monthlyStats': monthlyStats?.map((x) => x.toJson()).toList(),
    };
  }
}

class MonthlyAttendance {
  String? month;
  double? rate;

  MonthlyAttendance({
    this.month,
    this.rate,
  });

  factory MonthlyAttendance.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendance(
      month: json['month'],
      rate: json['rate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'rate': rate,
    };
  }
}
