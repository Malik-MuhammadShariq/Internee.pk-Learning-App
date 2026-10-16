import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course_model.dart';
import '../../../../core/data/mock_data_service.dart';

/// Course state
class CourseState {
  final List<CourseModel> courses;
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;
  final String selectedCategory;

  const CourseState({
    this.courses = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'All',
  });

  CourseState copyWith({
    List<CourseModel>? courses,
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Course notifier
class CourseNotifier extends StateNotifier<CourseState> {
  final MockDataService _mockData;

  CourseNotifier(this._mockData) : super(const CourseState()) {
    loadCourses();
  }

  /// Load all courses from mock data
  Future<void> loadCourses() async {
    state = state.copyWith(isLoading: true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(
      courses: _mockData.allCourses,
      categories: _mockData.categories,
      isLoading: false,
    );
  }

  /// Filter by category
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Get filtered courses
  List<CourseModel> get filteredCourses {
    if (state.selectedCategory == 'All') {
      return state.courses;
    }
    return state.courses
        .where((c) => c.category == state.selectedCategory)
        .toList();
  }

  /// Search courses by title, instructor, or category
  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return state.courses;
    final lowerQuery = query.toLowerCase();
    return state.courses.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.instructor.toLowerCase().contains(lowerQuery) ||
          c.category.toLowerCase().contains(lowerQuery) ||
          c.level.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get course by ID
  CourseModel? getCourseById(String id) {
    try {
      return state.courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Course provider
final courseProvider = StateNotifierProvider<CourseNotifier, CourseState>((ref) {
  return CourseNotifier(MockDataService());
});

/// Filtered courses provider
final filteredCoursesProvider = Provider<List<CourseModel>>((ref) {
  final notifier = ref.watch(courseProvider.notifier);
  return notifier.filteredCourses;
});

/// Course by ID provider
final courseByIdProvider =
    Provider.family<CourseModel?, String>((ref, courseId) {
  final notifier = ref.watch(courseProvider.notifier);
  return notifier.getCourseById(courseId);
});

/// Mock data service provider
final mockDataProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});
