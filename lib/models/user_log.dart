import 'package:hive/hive.dart';

part 'user_log.g.dart';

@HiveType(typeId: 0)
class UserLog {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String eventType;
  
  @HiveField(2)
  final Map<String, dynamic> details;
  
  @HiveField(3)
  final DateTime timestamp;

  UserLog({
    required this.userId,
    required this.eventType,
    required this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventType': eventType,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      userId: json['userId'],
      eventType: json['eventType'],
      details: Map<String, dynamic>.from(json['details']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
