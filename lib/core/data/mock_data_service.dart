import '../../features/dashboard/data/models/course_model.dart';
import '../../features/quizzes/data/models/quiz_model.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// Mock data service — provides Internee.pk course data for offline development
/// EXACTLY 4 real courses, nothing more, nothing less
class MockDataService {
  // Singleton
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Current logged-in user
  UserEntity? _currentUser;

  // ==================== USER ====================

  UserEntity get currentUser =>
      _currentUser ??
      const UserEntity(
        id: 'user_001',
        name: 'User',
        email: '',
        joinDate: null,
        coursesCompleted: 0,
        certificatesEarned: 0,
        totalHoursLearned: 0,
      );

  void setCurrentUser(UserEntity user) {
    _currentUser = user;
  }

  // ==================== CATEGORIES (3 total) ====================

  List<CategoryModel> get categories => const [
        CategoryModel(
          id: 'cat_all',
          name: 'All',
          icon: '📚',
          courseCount: 4,
        ),
        CategoryModel(
          id: 'cat_programming',
          name: 'Programming',
          icon: '💻',
          courseCount: 3,
        ),
        CategoryModel(
          id: 'cat_technology',
          name: 'Technology',
          icon: '☁️',
          courseCount: 1,
        ),
      ];

  // ==================== EXACTLY 4 REAL COURSES ====================

  List<CourseModel> get allCourses => const [
        // Course 1 — Programming, Advanced
        CourseModel(
          id: 'course_1',
          title: 'Mastering Advanced Recommendation Systems',
          description:
              'Dive deep into advanced recommendation system algorithms, collaborative filtering, content-based filtering, and hybrid approaches. Build production-ready recommender systems used by top tech companies.',
          instructor: 'BROTHER_ GAMING',
          category: 'Programming',
          level: 'Advanced',
          duration: 'More than 3 Hours',
          includesVideo: true,
          courseUrl:
              'https://www.internee.pk/aicourse/course/34c539e4-b7de-4d35-9877-8c1b9ffe395be',
          chapters: [
            ChapterModel(
              id: 'ch_1_1',
              title: 'Introduction to Recommendation Systems',
              durationMinutes: 25,
            ),
            ChapterModel(
              id: 'ch_1_2',
              title: 'Collaborative Filtering Techniques',
              durationMinutes: 35,
            ),
            ChapterModel(
              id: 'ch_1_3',
              title: 'Content-Based Filtering',
              durationMinutes: 30,
            ),
            ChapterModel(
              id: 'ch_1_4',
              title: 'Hybrid & Deep Learning Approaches',
              durationMinutes: 40,
            ),
            ChapterModel(
              id: 'ch_1_5',
              title: 'Building Production Recommenders',
              durationMinutes: 45,
            ),
          ],
        ),

        // Course 2 — Technology, Intermediate
        CourseModel(
          id: 'course_2',
          title: 'Mastering Cloud Infrastructure: An Intermediate Guide',
          description:
              'Master cloud infrastructure concepts including virtualization, containerization, orchestration, serverless computing, and multi-cloud strategies. Hands-on with AWS, Azure, and GCP.',
          instructor: 'Internee.pk Instructor',
          category: 'Technology',
          level: 'Intermediate',
          duration: 'More than 3 hours',
          includesVideo: true,
          courseUrl:
              'https://www.internee.pk/aicourse/course/1ba4b2ae-f1c9-45c3-9a39-b8aded2f71bd',
          chapters: [
            ChapterModel(
              id: 'ch_2_1',
              title: 'Cloud Computing Fundamentals',
              durationMinutes: 20,
            ),
            ChapterModel(
              id: 'ch_2_2',
              title: 'Virtualization & Containers',
              durationMinutes: 30,
            ),
            ChapterModel(
              id: 'ch_2_3',
              title: 'Orchestration with Kubernetes',
              durationMinutes: 40,
            ),
            ChapterModel(
              id: 'ch_2_4',
              title: 'Serverless & Multi-Cloud',
              durationMinutes: 35,
            ),
            ChapterModel(
              id: 'ch_2_5',
              title: 'Cloud Security & Best Practices',
              durationMinutes: 25,
            ),
          ],
        ),

        // Course 3 — Programming, Intermediate
        CourseModel(
          id: 'course_3',
          title: 'Intermediate Data Fetching Techniques',
          description:
              'Level up your data fetching skills with advanced REST patterns, GraphQL, WebSocket real-time data, caching strategies, and error handling for robust applications.',
          instructor: 'BROTHER_ GAMING',
          category: 'Programming',
          level: 'Intermediate',
          duration: '2 hours',
          includesVideo: true,
          courseUrl:
              'https://www.internee.pk/aicourse/course/f7e40463-237c-4bcc-84e2-e9d0ddc3e220',
          chapters: [
            ChapterModel(
              id: 'ch_3_1',
              title: 'REST API Patterns & Best Practices',
              durationMinutes: 15,
            ),
            ChapterModel(
              id: 'ch_3_2',
              title: 'GraphQL Queries & Mutations',
              durationMinutes: 20,
            ),
            ChapterModel(
              id: 'ch_3_3',
              title: 'WebSocket & Real-Time Data',
              durationMinutes: 18,
            ),
            ChapterModel(
              id: 'ch_3_4',
              title: 'Caching & Optimistic Updates',
              durationMinutes: 22,
            ),
            ChapterModel(
              id: 'ch_3_5',
              title: 'Error Handling & Retry Logic',
              durationMinutes: 25,
            ),
          ],
        ),

        // Course 4 — Programming, Intermediate
        CourseModel(
          id: 'course_4',
          title: 'Building Modern Web Apps with React.js',
          description:
              'Build modern, performant web applications with React.js. Covers hooks, context, state management, routing, testing, and deployment strategies for production apps.',
          instructor: 'Najam balghari',
          category: 'Programming',
          level: 'Intermediate',
          duration: 'More than 3 Hours',
          includesVideo: true,
          courseUrl:
              'https://www.internee.pk/aicourse/course/26e80cfe-d069-4ab2-b49a-4ede1526643a',
          chapters: [
            ChapterModel(
              id: 'ch_4_1',
              title: 'React Fundamentals & JSX',
              durationMinutes: 20,
            ),
            ChapterModel(
              id: 'ch_4_2',
              title: 'Hooks Deep Dive',
              durationMinutes: 30,
            ),
            ChapterModel(
              id: 'ch_4_3',
              title: 'State Management & Context',
              durationMinutes: 35,
            ),
            ChapterModel(
              id: 'ch_4_4',
              title: 'Routing & Navigation',
              durationMinutes: 25,
            ),
            ChapterModel(
              id: 'ch_4_5',
              title: 'Testing & Deployment',
              durationMinutes: 30,
            ),
          ],
        ),
      ];

  /// Get course by ID
  CourseModel? getCourseById(String id) {
    try {
      return allCourses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get chapters for a course (now inline on CourseModel)
  List<ChapterModel> getChaptersForCourse(String courseId) {
    final course = getCourseById(courseId);
    return course?.chapters ?? [];
  }

  // ==================== QUIZZES (4 quizzes, one per course) ====================

  List<QuizModel> get quizzes => [
        // Quiz for Course 1 — Recommendation Systems
        QuizModel(
          id: 'quiz_course_1',
          title: 'Recommendation Systems Quiz',
          courseId: 'course_1',
          totalQuestions: 5,
          timeLimitMinutes: 10,
          passingScore: 60,
          questions: [
            QuestionModel(
              id: 'q1_1',
              question:
                  'Which filtering method relies on user behavior and preferences?',
              options: [
                const QuizOption(id: 'a', text: 'Content-Based Filtering'),
                const QuizOption(id: 'b', text: 'Collaborative Filtering'),
                const QuizOption(id: 'c', text: 'Demographic Filtering'),
                const QuizOption(id: 'd', text: 'Knowledge-Based Filtering'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Collaborative filtering uses user-item interaction patterns to recommend items based on similar users.',
            ),
            QuestionModel(
              id: 'q1_2',
              question: 'What is the cold start problem in recommendation systems?',
              options: [
                const QuizOption(id: 'a', text: 'Server cooling issues'),
                const QuizOption(
                    id: 'b',
                    text: 'Difficulty recommending for new users/items'),
                const QuizOption(id: 'c', text: 'Data encryption problem'),
                const QuizOption(id: 'd', text: 'Network latency'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'The cold start problem occurs when there is insufficient data about new users or items to make accurate recommendations.',
            ),
            QuestionModel(
              id: 'q1_3',
              question: 'Which technique uses item attributes for recommendations?',
              options: [
                const QuizOption(id: 'a', text: 'Matrix Factorization'),
                const QuizOption(id: 'b', text: 'Content-Based Filtering'),
                const QuizOption(id: 'c', text: 'K-Means Clustering'),
                const QuizOption(id: 'd', text: 'Neural Networks'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Content-based filtering recommends items similar to those a user liked before, based on item features/attributes.',
            ),
            QuestionModel(
              id: 'q1_4',
              question: 'What does a hybrid recommender combine?',
              options: [
                const QuizOption(id: 'a', text: 'Multiple data sources'),
                const QuizOption(
                    id: 'b', text: 'Multiple recommendation techniques'),
                const QuizOption(id: 'c', text: 'Multiple databases'),
                const QuizOption(id: 'd', text: 'Multiple user interfaces'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Hybrid recommenders combine multiple techniques (e.g., collaborative + content-based) to improve accuracy.',
            ),
            QuestionModel(
              id: 'q1_5',
              question:
                  'Which metric measures recommendation ranking quality?',
              options: [
                const QuizOption(id: 'a', text: 'RMSE'),
                const QuizOption(id: 'b', text: 'Precision@K / NDCG'),
                const QuizOption(id: 'c', text: 'Accuracy'),
                const QuizOption(id: 'd', text: 'F1 Score'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Precision@K and NDCG (Normalized Discounted Cumulative Gain) evaluate the quality of ranked recommendation lists.',
            ),
          ],
        ),

        // Quiz for Course 2 — Cloud Infrastructure
        QuizModel(
          id: 'quiz_course_2',
          title: 'Cloud Infrastructure Quiz',
          courseId: 'course_2',
          totalQuestions: 5,
          timeLimitMinutes: 10,
          passingScore: 60,
          questions: [
            QuestionModel(
              id: 'q2_1',
              question: 'What is the primary benefit of cloud computing?',
              options: [
                const QuizOption(id: 'a', text: 'Fixed hardware costs'),
                const QuizOption(
                    id: 'b', text: 'On-demand scalability and pay-per-use'),
                const QuizOption(id: 'c', text: 'No internet required'),
                const QuizOption(id: 'd', text: 'Unlimited free storage'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Cloud computing provides on-demand resources with pay-per-use pricing, eliminating upfront hardware costs.',
            ),
            QuestionModel(
              id: 'q2_2',
              question: 'What is container orchestration?',
              options: [
                const QuizOption(id: 'a', text: 'Writing Dockerfiles'),
                const QuizOption(
                    id: 'b',
                    text: 'Managing and scaling container deployments'),
                const QuizOption(id: 'c', text: 'Creating virtual machines'),
                const QuizOption(id: 'd', text: 'Configuring firewalls'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Container orchestration automates deployment, scaling, and management of containerized applications.',
            ),
            QuestionModel(
              id: 'q2_3',
              question: 'Which service is serverless computing on AWS?',
              options: [
                const QuizOption(id: 'a', text: 'EC2'),
                const QuizOption(id: 'b', text: 'Lambda'),
                const QuizOption(id: 'c', text: 'ECS'),
                const QuizOption(id: 'd', text: 'Lightsail'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'AWS Lambda is a serverless compute service that runs code without provisioning or managing servers.',
            ),
            QuestionModel(
              id: 'q2_4',
              question: 'What is a multi-cloud strategy?',
              options: [
                const QuizOption(id: 'a', text: 'Using one cloud provider'),
                const QuizOption(
                    id: 'b',
                    text: 'Using multiple cloud providers for different services'),
                const QuizOption(id: 'c', text: 'Avoiding cloud entirely'),
                const QuizOption(id: 'd', text: 'Building private data centers'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Multi-cloud uses services from multiple cloud providers to avoid vendor lock-in and optimize costs.',
            ),
            QuestionModel(
              id: 'q2_5',
              question: 'What does IaC stand for in cloud computing?',
              options: [
                const QuizOption(id: 'a', text: 'Infrastructure as Code'),
                const QuizOption(id: 'b', text: 'Integration as Cloud'),
                const QuizOption(id: 'c', text: 'Internet and Compute'),
                const QuizOption(id: 'd', text: 'Internal access Control'),
              ],
              correctOptionIndex: 0,
              explanation:
                  'Infrastructure as Code (IaC) manages and provisions cloud resources through machine-readable configuration files.',
            ),
          ],
        ),

        // Quiz for Course 3 — Data Fetching
        QuizModel(
          id: 'quiz_course_3',
          title: 'Data Fetching Techniques Quiz',
          courseId: 'course_3',
          totalQuestions: 5,
          timeLimitMinutes: 8,
          passingScore: 70,
          questions: [
            QuestionModel(
              id: 'q3_1',
              question: 'What is the main advantage of GraphQL over REST?',
              options: [
                const QuizOption(id: 'a', text: 'It is faster by default'),
                const QuizOption(
                    id: 'b', text: 'Client specifies exactly what data it needs'),
                const QuizOption(id: 'c', text: 'It uses less bandwidth'),
                const QuizOption(id: 'd', text: 'It requires no server'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'GraphQL lets clients request exactly the fields they need, reducing over-fetching and under-fetching.',
            ),
            QuestionModel(
              id: 'q3_2',
              question: 'What protocol does WebSocket use?',
              options: [
                const QuizOption(id: 'a', text: 'HTTP only'),
                const QuizOption(id: 'b', text: 'Full-duplex TCP connection'),
                const QuizOption(id: 'c', text: 'UDP broadcast'),
                const QuizOption(id: 'd', text: 'FTP'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'WebSocket provides full-duplex communication over a single TCP connection, enabling real-time data flow.',
            ),
            QuestionModel(
              id: 'q3_3',
              question: 'What is optimistic updating?',
              options: [
                const QuizOption(id: 'a', text: 'Waiting for server response'),
                const QuizOption(
                    id: 'b',
                    text: 'Updating UI immediately, rolling back on error'),
                const QuizOption(id: 'c', text: 'Caching all responses'),
                const QuizOption(id: 'd', text: 'Retrying failed requests'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Optimistic updates show changes instantly in UI, then roll back if the server request fails.',
            ),
            QuestionModel(
              id: 'q3_4',
              question: 'What HTTP method is idempotent?',
              options: [
                const QuizOption(id: 'a', text: 'POST'),
                const QuizOption(id: 'b', text: 'PUT'),
                const QuizOption(id: 'c', text: 'PATCH'),
                const QuizOption(id: 'd', text: 'CONNECT'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'PUT is idempotent — calling it multiple times produces the same result as calling it once.',
            ),
            QuestionModel(
              id: 'q3_5',
              question: 'What is a common retry strategy for failed requests?',
              options: [
                const QuizOption(id: 'a', text: 'Immediate retry'),
                const QuizOption(id: 'b', text: 'Exponential backoff'),
                const QuizOption(id: 'c', text: 'Random delay'),
                const QuizOption(id: 'd', text: 'No retry'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'Exponential backoff increases the wait time between retries, reducing load on struggling servers.',
            ),
          ],
        ),

        // Quiz for Course 4 — React.js
        QuizModel(
          id: 'quiz_course_4',
          title: 'React.js Web Apps Quiz',
          courseId: 'course_4',
          totalQuestions: 5,
          timeLimitMinutes: 10,
          passingScore: 60,
          questions: [
            QuestionModel(
              id: 'q4_1',
              question: 'What is the virtual DOM in React?',
              options: [
                const QuizOption(id: 'a', text: 'A browser plugin'),
                const QuizOption(
                    id: 'b',
                    text: 'A lightweight copy of the real DOM in memory'),
                const QuizOption(id: 'c', text: 'A CSS framework'),
                const QuizOption(id: 'd', text: 'A testing library'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'The virtual DOM is a JavaScript representation of the real DOM that React uses to optimize updates.',
            ),
            QuestionModel(
              id: 'q4_2',
              question: 'Which hook is used for side effects in React?',
              options: [
                const QuizOption(id: 'a', text: 'useState'),
                const QuizOption(id: 'b', text: 'useEffect'),
                const QuizOption(id: 'c', text: 'useContext'),
                const QuizOption(id: 'd', text: 'useReducer'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'useEffect handles side effects like data fetching, subscriptions, and DOM manipulation.',
            ),
            QuestionModel(
              id: 'q4_3',
              question: 'What is the purpose of React Context?',
              options: [
                const QuizOption(id: 'a', text: 'Styling components'),
                const QuizOption(
                    id: 'b',
                    text: 'Sharing data without prop drilling'),
                const QuizOption(id: 'c', text: 'Routing between pages'),
                const QuizOption(id: 'd', text: 'Testing components'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'React Context provides a way to share values between components without passing props through every level.',
            ),
            QuestionModel(
              id: 'q4_4',
              question: 'What does React Router handle?',
              options: [
                const QuizOption(id: 'a', text: 'State management'),
                const QuizOption(id: 'b', text: 'Client-side navigation/routing'),
                const QuizOption(id: 'c', text: 'API calls'),
                const QuizOption(id: 'd', text: 'Form validation'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'React Router enables client-side routing, allowing navigation without full page reloads.',
            ),
            QuestionModel(
              id: 'q4_5',
              question: 'Which library is commonly used for React testing?',
              options: [
                const QuizOption(id: 'a', text: 'Selenium'),
                const QuizOption(id: 'b', text: 'React Testing Library'),
                const QuizOption(id: 'c', text: 'Cypress only'),
                const QuizOption(id: 'd', text: 'Puppeteer'),
              ],
              correctOptionIndex: 1,
              explanation:
                  'React Testing Library provides utilities to test React components in a way that resembles how users interact.',
            ),
          ],
        ),
      ];

  QuizModel? getQuizById(String quizId) {
    try {
      return quizzes.firstWhere((q) => q.id == quizId);
    } catch (_) {
      return null;
    }
  }

  /// Get quiz for a specific course
  QuizModel? getQuizForCourse(String courseId) {
    try {
      return quizzes.firstWhere((q) => q.courseId == courseId);
    } catch (_) {
      return null;
    }
  }

  // ==================== ONBOARDING ====================

  List<Map<String, dynamic>> get onboardingSlides => [
        {
          'title': 'Explore Top Courses',
          'description':
              'Access Programming, Technology courses from Internee.pk — anytime, anywhere.',
          'image': 'assets/images/onboarding_1.png',
          'lottie': 'assets/animations/learning.json',
        },
        {
          'title': 'Learn by Doing',
          'description':
              'Interactive lessons, quizzes, and hands-on projects with progress tracking.',
          'image': 'assets/images/onboarding_2.png',
          'lottie': 'assets/animations/video.json',
        },
        {
          'title': 'Track Your Growth',
          'description':
              'Monitor your progress, complete chapters, and earn certificates.',
          'image': 'assets/images/onboarding_3.png',
          'lottie': 'assets/animations/progress.json',
        },
      ];
}
