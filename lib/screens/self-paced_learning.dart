import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/class_model.dart';
import 'package:navyoga_academy/models/selfpaces_course_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/self_paced_classes_screen.dart';
import 'package:navyoga_academy/screens/self_paced_lesson_screen.dart';
import 'package:navyoga_academy/services/self_paced_progress_service.dart';
import 'package:navyoga_academy/services/self_paced_service.dart';
import 'package:navyoga_academy/services/subscription_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class SelfPacedLearningScreen extends StatefulWidget {
  const SelfPacedLearningScreen({super.key});

  @override
  State<SelfPacedLearningScreen> createState() =>
      _SelfPacedLearningScreenState();
}

class _SelfPacedLearningScreenState extends State<SelfPacedLearningScreen> {
  final SelfPacedService _selfPacedService = SelfPacedService();
  final SelfPacedProgressService _progressService =
      SelfPacedProgressService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  bool hasActiveSubscription = false;

  String searchQuery = '';
  String? selectedPlanId;
  String activePlanName = 'Not Enrolled';

  int totalClasses = 0;
  double overallProgress = 0;

  List<CourseModel> courses = [];

  final Map<String, double> courseProgress = {};
  final Map<String, bool> courseCompleted = {};

  List<CourseModel> get filteredCourses {
    if (searchQuery.trim().isEmpty) {
      return courses;
    }

    final query = searchQuery.trim().toLowerCase();

    return courses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.description.toLowerCase().contains(query) ||
          course.instructor.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadScreenData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScreenData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        return;
      }


      final responses = await Future.wait([
        _subscriptionService.getMySubscription(token),
        _selfPacedService.getCourses(token),
        _selfPacedService.getPlans(token),
      ]);

      final subscriptionResponse = responses[0];
      final modulesResponse = responses[1];
      final plansResponse = responses[2];

      await _parseSubscription(subscriptionResponse);
      _parsePlans(plansResponse);
      await _parseModules(token, modulesResponse);
    } catch (error, stackTrace) {
      debugPrint('SELF-PACED SCREEN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        AppSnackbar.showError(
          context,
          'Unable to load self-paced classes',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _parseSubscription(
    dynamic subscriptionResponse,
  ) async {
    final response = Map<String, dynamic>.from(
      subscriptionResponse as Map,
    );

    final data = response['data'];

    if (response['success'] != true || data is! Map) {
      hasActiveSubscription = false;
      activePlanName = 'Not Enrolled';
      return;
    }

    final subscriptionData = Map<String, dynamic>.from(data);
    final enrolled = subscriptionData['enrolled'] == true;
    final subscription = subscriptionData['subscription'];

    hasActiveSubscription = enrolled;

    if (!enrolled || subscription == null) {
      activePlanName = 'Not Enrolled';
      return;
    }

    if (subscription is Map) {
      final subscriptionMap = Map<String, dynamic>.from(subscription);

      final plan = subscriptionMap['plan'];

      if (plan is Map) {
        final planMap = Map<String, dynamic>.from(plan);

        activePlanName =
            planMap['name']?.toString().trim().isNotEmpty == true
            ? planMap['name'].toString()
            : 'Active';
      } else {
        activePlanName =
            subscriptionMap['planName']?.toString().trim().isNotEmpty ==
                true
            ? subscriptionMap['planName'].toString()
            : 'Active';
      }
    } else {
      activePlanName = 'Active';
    }
  }

  void _parsePlans(dynamic plansResponse) {
    final response = Map<String, dynamic>.from(plansResponse as Map);

    if (response['success'] != true) {
      return;
    }

    final data = response['data'];

    if (data is List && data.isNotEmpty) {
      final firstPlan = data.first;

      if (firstPlan is Map && firstPlan['id'] != null) {
        selectedPlanId = firstPlan['id'].toString();
      }
    }
  }

  Future<void> _parseModules(
    String token,
    dynamic modulesResponse,
  ) async {
    final response = Map<String, dynamic>.from(modulesResponse as Map);

    if (!ApiHelper.isSuccess(response)) {
      throw Exception(
        response['message'] ?? 'Unable to load modules',
      );
    }

    final data = response['data'];

    if (data is! List || data.isEmpty) {
      courses = [];
      totalClasses = 0;
      overallProgress = 0;
      courseProgress.clear();
      courseCompleted.clear();
      return;
    }

    courses = data
        .whereType<Map>()
        .map(
          (item) => CourseModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();


    if (!hasActiveSubscription || courses.isEmpty) {
      totalClasses = 0;
      overallProgress = 0;
      return;
    }

    await _loadCourseProgress(token);
  }

  Future<void> _loadCourseProgress(String token) async {
    try {
      final progressResponse =
          await _progressService.getMyProgress(token);

      final rawProgress = progressResponse['data'];
      final progressList = rawProgress is List ? rawProgress : [];

      courseProgress.clear();
      courseCompleted.clear();

      int classesCount = 0;
      int completedClassesCount = 0;

      for (final course in courses) {
        final classesResponse = await _selfPacedService.getClasses(
          token,
          course.id,
        );

        final rawClasses = classesResponse['data'];
        final classes = rawClasses is List ? rawClasses : [];

        classesCount += classes.length;

        if (classes.isEmpty) {
          courseProgress[course.id] = 0;
          courseCompleted[course.id] = false;
          continue;
        }

        int completedLessons = 0;

        for (final lesson in classes) {
          if (lesson is! Map) continue;

          final lessonId = lesson['id']?.toString();

          final isCompleted = progressList.any((progress) {
            if (progress is! Map) return false;

            return progress['classId']?.toString() == lessonId &&
                progress['isCompleted'] == true;
          });

          if (isCompleted) {
            completedLessons++;
            completedClassesCount++;
          }
        }

        final progress = completedLessons / classes.length;

        courseProgress[course.id] = progress;
        courseCompleted[course.id] =
            completedLessons == classes.length;
      }

      totalClasses = classesCount;

      overallProgress = classesCount == 0
          ? 0
          : completedClassesCount / classesCount;
    } catch (error) {
      debugPrint('PROGRESS LOAD ERROR: $error');

      totalClasses = 0;
      overallProgress = 0;
    }
  }

  Future<void> _refreshScreen() async {
    await _loadScreenData();
  }

  Future<void> _enrollCourse(CourseModel course) async {
    if (selectedPlanId == null) {
      AppSnackbar.showError(
        context,
        'No self-paced plan is currently available',
      );
      return;
    }

    final token = await AuthManager.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await _selfPacedService.initiatePayment(
        token,
        course.id,
        selectedPlanId!,
      );

      if (!mounted) return;

      if (ApiHelper.isSuccess(response)) {
        Navigator.pushNamed(context, AppRoutes.payments);
      } else {
        AppSnackbar.showError(
          context,
          response['message'] ?? 'Payment initiation failed',
        );
      }
    } catch (error) {
      if (!mounted) return;

      AppSnackbar.showError(
        context,
        'Unable to initiate payment',
      );
    }
  }

  Future<void> _continueLearning(CourseModel course) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null || token.isEmpty) return;

      final results = await Future.wait([
        _selfPacedService.getClasses(token, course.id),
        _progressService.getMyProgress(token),
      ]);

      final classesData = results[0]['data'];
      final progressData = results[1]['data'];

      final classes = classesData is List ? classesData : [];
      final progressList = progressData is List ? progressData : [];

      if (classes.isEmpty) {
        if (mounted) {
          AppSnackbar.showError(
            context,
            'No classes are available in this module',
          );
        }
        return;
      }

      final completedMap = <String, bool>{};

      for (final item in progressList) {
        if (item is! Map) continue;

        completedMap[item['classId'].toString()] =
            item['isCompleted'] == true;
      }

      final firstUnfinished = classes.firstWhere(
        (lesson) =>
            lesson is Map &&
            completedMap[lesson['id'].toString()] != true,
        orElse: () => classes.first,
      );

      if (!mounted || firstUnfinished is! Map) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelfPacedLessonScreen(
            lesson: ClassModel.fromJson(
              Map<String, dynamic>.from(firstUnfinished),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackbar.showError(
        context,
        'Unable to open the lesson',
      );
    }
  }

  void _handleCourseTap(CourseModel course) {
    if (!hasActiveSubscription) {
      _enrollCourse(course);
      return;
    }

    if (courseCompleted[course.id] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelfPacedClassesScreen(
            moduleId: course.id,
            title: course.title,
          ),
        ),
      );
      return;
    }

    _continueLearning(course);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(currentPage: 'Self-Paced'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xff1E1B39),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 52,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7E22CE),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshScreen,
              color: const Color(0xff7E22CE),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildGradientHeader(),
                  ),

                  if (!hasActiveSubscription)
                    SliverToBoxAdapter(
                      child: _buildSubscriptionBanner(),
                    ),

                  SliverToBoxAdapter(
                    child: _buildSearchCard(),
                  ),

                  if (filteredCourses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        32,
                      ),
                      sliver: SliverList.separated(
                        itemCount: filteredCourses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];

                          return _buildCourseCard(course)
                              .animate(
                                delay: Duration(
                                  milliseconds: index * 80,
                                ),
                              )
                              .fadeIn(
                                duration:
                                    const Duration(milliseconds: 350),
                              )
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration:
                                    const Duration(milliseconds: 350),
                              );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffFF6B35),
            Color(0xff7B0AA5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Self-Paced Learning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Learn at your own pace, anytime, anywhere',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _buildTopStat(
                  icon: Icons.menu_book_outlined,
                  title: 'Modules',
                  value: courses.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTopStat(
                  icon: Icons.play_circle_outline_rounded,
                  title: 'Classes',
                  value: totalClasses.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTopStat(
                  icon: Icons.trending_up_rounded,
                  title: 'Progress',
                  value:
                      '${(overallProgress * 100).round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTopStat(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Active Plan',
                  value: activePlanName,
                  valueFontSize:
                      activePlanName.length > 12 ? 16 : 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat({
    required IconData icon,
    required String title,
    required String value,
    double valueFontSize = 20,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.23),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.17),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 21,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueFontSize,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF6F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffFFB18A),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffFFE3D4),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xffFF641F),
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscribe to unlock self-paced classes',
                      style: TextStyle(
                        color: Color(0xff16112B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Browse the catalogue below and enrol to start '
                      'watching at your own pace.',
                      style: TextStyle(
                        color: Color(0xff5F5871),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.payments,
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xff72039A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 11,
              ),
              minimumSize: const Size(112, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'View Plans',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content,
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: button,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 14),
              button,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        20,
        hasActiveSubscription ? 24 : 8,
        20,
        22,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search courses...',
          hintStyle: const TextStyle(
            color: Color(0xff7A849B),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xff52617A),
          ),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: const Color(0xffFCFDFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xff7586A3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xff7E22CE),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchQuery.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xffF3F4F7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 40,
              color: Color(0xff98A3B6),
            ),
          ),
          const SizedBox(height: 19),
          Text(
            isSearching ? 'No courses found' : 'No courses available',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff11101B),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            isSearching
                ? 'Try adjusting your search.'
                : 'Self-paced courses will appear here once available.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff677086),
              fontSize: 13,
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xffFF641F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  Widget _buildCourseCard(CourseModel course) {
    final progress = courseProgress[course.id] ?? 0;
    final completed = courseCompleted[course.id] ?? false;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            course.image,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 170,
                alignment: Alignment.center,
                color: const Color(0xffEEEFF3),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 42,
                  color: Colors.grey,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff687083),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.instructor,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 17,
                    ),
                    const SizedBox(width: 4),
                    Text(course.duration),
                  ],
                ),
                if (hasActiveSubscription) ...[
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course.lessonsText ?? 'Course progress',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff687083),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xff7E22CE),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xffECE6F2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                            Color(0xff7E22CE),
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleCourseTap(course),
                    icon: Icon(
                      !hasActiveSubscription
                          ? Icons.lock_open_rounded
                          : completed
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      !hasActiveSubscription
                          ? 'Enrol Now'
                          : completed
                          ? 'Review Course'
                          : 'Continue Learning',
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: !hasActiveSubscription
                          ? const Color(0xffFF641F)
                          : const Color(0xff7E22CE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}