import 'package:equatable/equatable.dart';

/// Chapter data model — simplified: just title + duration
class ChapterModel extends Equatable {
  final String id;
  final String title;
  final int durationMinutes;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
  });

  @override
  List<Object> get props => [id, title];
}

/// Course data model — aligned with Internee.pk real course data
class CourseModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String category;
  final String level;
  final String duration;
  final bool includesVideo;
  final String courseUrl;
  final List<ChapterModel> chapters;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    required this.level,
    required this.duration,
    this.includesVideo = true,
    required this.courseUrl,
    this.chapters = const [],
  });

  /// Get total number of chapters
  int get chapterCount => chapters.length;

  /// Get total duration in minutes
  int get totalMinutes => chapters.fold(0, (sum, ch) => sum + ch.durationMinutes);

  @override
  List<Object?> get props => [id, title, category];
}

/// Category data model
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int courseCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.courseCount,
  });

  @override
  List<Object> get props => [id, name];
}
