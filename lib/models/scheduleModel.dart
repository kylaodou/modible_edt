class ScheduleModel {
  String? id;
  String? title;
  String? description;
  String? startTime;
  String? endTime;
  String? date;
  String? location;
  String? teacher;
  String? courseId;
  String? courseName;
  String? color;

  ScheduleModel({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.date,
    this.location,
    this.teacher,
    this.courseId,
    this.courseName,
    this.color,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      date: json['date'],
      location: json['location'],
      teacher: json['teacher'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'date': date,
      'location': location,
      'teacher': teacher,
      'courseId': courseId,
      'courseName': courseName,
      'color': color,
    };
  }
}
