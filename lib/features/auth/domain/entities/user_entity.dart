import 'package:equatable/equatable.dart';

/// User entity (domain layer)
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? joinDate;
  final int coursesCompleted;
  final int certificatesEarned;
  final int totalHoursLearned;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.joinDate,
    this.coursesCompleted = 0,
    this.certificatesEarned = 0,
    this.totalHoursLearned = 0,
  });

  @override
  List<Object?> get props => [id, name, email];
}
