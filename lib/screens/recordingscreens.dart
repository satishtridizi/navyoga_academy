import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/recording_api_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/recording_player_screen.dart';
import 'package:navyoga_academy/services/ytt_recorded_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class RecordingsDashboard extends StatefulWidget {
  const RecordingsDashboard({super.key});

  @override
  State<RecordingsDashboard> createState() =>
      _RecordingsDashboardState();
}

class _RecordingsDashboardState extends State<RecordingsDashboard> {
  final YttRecordedService _yttRecordedService =
      YttRecordedService();

  final TextEditingController _searchController =
      TextEditingController();

  bool isLoading = true;
  bool isRefreshing = false;
  bool hasEnrollment = false;
  bool showRenewalPrompt = false;

  int totalModules = 0;
  int totalClasses = 0;
  int completedClasses = 0;

  double overallProgress = 0;

  String activePlanName = 'Not Enrolled';
  String searchQuery = '';

  List<YttRecordedEnrollment> enrollments = [];
  List<YttRecordedClass> classes = [];

  List<YttRecordedClass> get filteredClasses {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return classes;
    }

    return classes.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.moduleTitle.toLowerCase().contains(query) ||
          item.instructor.toLowerCase().contains(query);
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

  Future<void> _loadScreenData({
    bool showLoader = true,
  }) async {
    if (showLoader && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );

        return;
      }

      final responses = await Future.wait([
        _yttRecordedService.getMyEnrollments(token),
        _yttRecordedService.getRenewalPrompt(token),
      ]);

      final enrollmentsResponse = responses[0];
      final renewalResponse = responses[1];

      _parseEnrollments(enrollmentsResponse);
      _parseRenewalPrompt(renewalResponse);
    } catch (error, stackTrace) {
      debugPrint('YTT RECORDED SCREEN ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        AppSnackbar.showError(
          context,
          'Unable to load YTT Recorded classes',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  void _parseEnrollments(Map<String, dynamic> response) {
    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Unable to load YTT Recorded enrollments',
      );
    }

    final rawData = response['data'];

    if (rawData is! List || rawData.isEmpty) {
      enrollments = [];
      classes = [];

      hasEnrollment = false;
      activePlanName = 'Not Enrolled';

      totalModules = 0;
      totalClasses = 0;
      completedClasses = 0;
      overallProgress = 0;

      return;
    }

    enrollments = rawData
        .whereType<Map>()
        .map(
          (item) => YttRecordedEnrollment.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    hasEnrollment = enrollments.isNotEmpty;

    activePlanName = enrollments.first.planName.trim().isNotEmpty
        ? enrollments.first.planName
        : 'Active';

    final allClasses = <YttRecordedClass>[];

    for (final enrollment in enrollments) {
      allClasses.addAll(enrollment.classes);
    }

    classes = allClasses;

    totalModules = enrollments.fold<int>(
      0,
      (total, enrollment) =>
          total + enrollment.modulesCount,
    );

    totalClasses = classes.length;

    completedClasses = classes
        .where((recordedClass) => recordedClass.isCompleted)
        .length;

    overallProgress = totalClasses == 0
        ? 0
        : completedClasses / totalClasses;
  }

  void _parseRenewalPrompt(
    Map<String, dynamic> response,
  ) {
    showRenewalPrompt = false;

    if (response['success'] != true) {
      return;
    }

    final data = response['data'];

    if (data is! Map) {
      return;
    }

    final yttRecorded = data['yttRecorded'];

    /*
     * Current response:
     * "yttRecorded": []
     *
     * When the backend later returns one or more renewal items,
     * this becomes true.
     */
    if (yttRecorded is List) {
      showRenewalPrompt = yttRecorded.isNotEmpty;
    } else if (yttRecorded is Map) {
      showRenewalPrompt =
          yttRecorded['showRenew'] == true;
    }
  }

  Future<void> _refresh() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    await _loadScreenData(showLoader: false);
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  void _openPlans() {
    Navigator.pushNamed(
      context,
      AppRoutes.payments,
      arguments: {
        'subscriptionType': 'yttRecorded',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      drawer: const CustomDrawer(
        currentPage: 'YTT Recorded',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xff1E1B39),
              ),
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
              onRefresh: _refresh,
              color: const Color(0xff7E22CE),
              child: CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildGradientHeader(),
                  ),

                  if (showRenewalPrompt)
                    SliverToBoxAdapter(
                      child: _buildRenewalBanner(),
                    ),

                  if (!hasEnrollment)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildNotEnrolledState(),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _buildSearchCard(),
                    ),
                    if (filteredClasses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildNoResultsState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          34,
                        ),
                        sliver: SliverList.separated(
                          itemCount: filteredClasses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final recordedClass =
                                filteredClasses[index];

                            return _buildRecordingCard(
                              recordedClass,
                            )
                                .animate(
                                  delay: Duration(
                                    milliseconds: index * 80,
                                  ),
                                )
                                .fadeIn(
                                  duration: const Duration(
                                    milliseconds: 350,
                                  ),
                                )
                                .slideY(
                                  begin: 0.08,
                                  end: 0,
                                  duration: const Duration(
                                    milliseconds: 350,
                                  ),
                                );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        28,
      ),
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
                  Icons.videocam_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YTT Recorded',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Self-paced Yoga Teacher Training – '
                      'your enrolled cohorts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.35,
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
                child: _buildStatCard(
                  icon: Icons.menu_book_outlined,
                  label: 'Modules',
                  value: totalModules.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon:
                      Icons.play_circle_outline_rounded,
                  label: 'Classes',
                  value: totalClasses.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Progress',
                  value:
                      '${(overallProgress * 100).round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon:
                      Icons.workspace_premium_outlined,
                  label: 'Active Plan',
                  value: activePlanName,
                  valueFontSize:
                      activePlanName.length > 12
                      ? 15
                      : 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    double valueFontSize = 20,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 102,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
        ),
      ),
      child: Row(
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
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.84),
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

  Widget _buildNotEnrolledState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        60,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFFF8F5),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xffFFB493),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffFFE2D5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xffFF641F),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'You’re not enrolled in any '
            'YTT Recorded course yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff171126),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enrol in a course from the plans page to '
            'unlock its modules and start learning '
            'at your own pace.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff676078),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openPlans,
            icon: const Icon(
              Icons.workspace_premium_outlined,
              size: 18,
            ),
            label: const Text(
              'View YTT Recorded Plans',
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  const Color(0xff72039A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration:
              const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.06,
          end: 0,
          duration:
              const Duration(milliseconds: 400),
        );
  }

  Widget _buildRenewalBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffF5C46B),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffFFE9BD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.autorenew_rounded,
              color: Color(0xffC77500),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Renew your YTT Recorded plan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Continue accessing your recorded '
                  'training classes.',
                  style: TextStyle(
                    color: Color(0xff6D6251),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openPlans,
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        24,
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
        decoration: InputDecoration(
          hintText:
              'Search recordings or instructors...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xff53627B),
          ),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
          filled: true,
          fillColor: const Color(0xffFCFDFF),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xff7788A4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xff7E22CE),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        50,
        24,
        80,
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xffF1F2F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: Color(0xff98A2B4),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No recordings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Try changing your search.',
            style: TextStyle(
              color: Color(0xff687083),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _clearSearch,
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCard(
    YttRecordedClass recordedClass,
  ) {
    return InkWell(
      onTap: () {
        /*
         * Adapt this constructor once your YTT response
         * shape is confirmed.
         */
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordingPlayerScreen(
              recording:
                  recordedClass.toRecordingApiModel(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF1E8F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xff7E22CE),
                size: 38,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    recordedClass.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recordedClass.moduleTitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xff6C7486),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: recordedClass.progress,
                    minHeight: 5,
                    borderRadius:
                        BorderRadius.circular(10),
                    backgroundColor:
                        const Color(0xffECE6F1),
                    valueColor:
                        const AlwaysStoppedAnimation(
                          Color(0xff7E22CE),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xff8B91A0),
            ),
          ],
        ),
      ),
    );
  }
}

class YttRecordedEnrollment {
  final String id;
  final String planName;
  final int modulesCount;
  final List<YttRecordedClass> classes;

  const YttRecordedEnrollment({
    required this.id,
    required this.planName,
    required this.modulesCount,
    required this.classes,
  });

  factory YttRecordedEnrollment.fromJson(
    Map<String, dynamic> json,
  ) {
    final subscription = json['subscription'];
    final plan = json['plan'];
    final cohort = json['cohort'];

    String planName = '';

    if (plan is Map) {
      planName = plan['name']?.toString() ?? '';
    } else if (subscription is Map) {
      final subscriptionPlan = subscription['plan'];

      if (subscriptionPlan is Map) {
        planName =
            subscriptionPlan['name']?.toString() ?? '';
      } else {
        planName =
            subscription['planName']?.toString() ?? '';
      }
    } else if (cohort is Map) {
      planName =
          cohort['title']?.toString() ??
          cohort['name']?.toString() ??
          '';
    }

    final rawModules =
        json['modules'] ??
        (cohort is Map ? cohort['modules'] : null);

    final modules = rawModules is List
        ? rawModules
        : <dynamic>[];

    final parsedClasses = <YttRecordedClass>[];

    for (final module in modules) {
      if (module is! Map) continue;

      final moduleMap =
          Map<String, dynamic>.from(module);

      final moduleTitle =
          moduleMap['title']?.toString() ??
          moduleMap['name']?.toString() ??
          'Module';

      final rawClasses =
          moduleMap['classes'] ??
          moduleMap['recordings'] ??
          moduleMap['lessons'];

      if (rawClasses is! List) continue;

      for (final item in rawClasses) {
        if (item is! Map) continue;

        parsedClasses.add(
          YttRecordedClass.fromJson(
            Map<String, dynamic>.from(item),
            moduleTitle: moduleTitle,
          ),
        );
      }
    }

    final directClasses =
        json['classes'] ??
        json['recordings'];

    if (directClasses is List) {
      for (final item in directClasses) {
        if (item is! Map) continue;

        parsedClasses.add(
          YttRecordedClass.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    return YttRecordedEnrollment(
      id:
          json['id']?.toString() ??
          json['enrollmentId']?.toString() ??
          '',
      planName: planName,
      modulesCount: modules.isNotEmpty
          ? modules.length
          : (json['modulesCount'] as num?)?.toInt() ??
              0,
      classes: parsedClasses,
    );
  }
}

class YttRecordedClass {
  final String id;
  final String title;
  final String description;
  final String moduleTitle;
  final String instructor;
  final String videoUrl;
  final String thumbnailUrl;
  final String level;
  final double progress;
  final bool isCompleted;

  const YttRecordedClass({
    required this.id,
    required this.title,
    required this.description,
    required this.moduleTitle,
    required this.instructor,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.level,
    required this.progress,
    required this.isCompleted,
  });

  factory YttRecordedClass.fromJson(
    Map<String, dynamic> json, {
    String moduleTitle = '',
  }) {
    final rawProgress =
        json['progress'] ??
        json['progressPercentage'] ??
        json['watchProgress'] ??
        0;

    double parsedProgress = 0;

    if (rawProgress is num) {
      parsedProgress = rawProgress.toDouble();

      if (parsedProgress > 1) {
        parsedProgress /= 100;
      }
    }

    parsedProgress = parsedProgress.clamp(0.0, 1.0);

    final isCompleted =
        json['isCompleted'] == true ||
        json['completed'] == true ||
        parsedProgress >= 1;

    return YttRecordedClass(
      id: json['id']?.toString() ?? '',
      title:
          json['title']?.toString() ??
          json['name']?.toString() ??
          'Recorded Class',
      description: json['description']?.toString() ?? '',
      moduleTitle: moduleTitle.isNotEmpty
          ? moduleTitle
          : json['moduleTitle']?.toString() ??
                json['yogaType']?.toString() ??
                'YTT Recorded',
      instructor:
          json['instructor']?.toString() ??
          json['trainerName']?.toString() ??
          '',
      videoUrl:
          json['videoUrl']?.toString() ??
          json['recordingUrl']?.toString() ??
          json['url']?.toString() ??
          '',
      thumbnailUrl:
          json['thumbnail']?.toString() ??
          json['thumbnailUrl']?.toString() ??
          '',
      level: json['level']?.toString() ?? '',
      progress: parsedProgress,
      isCompleted: isCompleted,
    );
  }

  RecordingApiModel toRecordingApiModel() {
    return RecordingApiModel(
      id: id,
      title: title,
      description: description,
      thumbnail: thumbnailUrl,
      yogaType: moduleTitle,
      level: level,
      videoUrl: videoUrl,
    );
  }
}

    /*
     * Adapt these fields to the exact constructor in your
     * RecordingApiModel.
     */
  
  
