class NotificationModel {
  String? id;
  String? title;
  String? message;
  String? date;
  bool? read;
  String? userId;

  NotificationModel({
    this.id,
    this.title,
    this.message,
    this.date,
    this.read,
    this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      date: json['date'],
      read: json['read'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date,
      'read': read,
      'userId': userId,
    };
  }
}
