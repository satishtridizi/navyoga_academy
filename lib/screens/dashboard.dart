import 'dart:async';
import 'package:navyoga_academy/models/mylive_class_model.dart';
import 'package:navyoga_academy/services/myclass_service.dart';
import 'package:navyoga_academy/utils/live_class_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/dashboard_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/onboarding_overlay.dart';
import 'package:navyoga_academy/screens/payments.dart';
import 'package:navyoga_academy/services/dashboard_service.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/services/notification_service.dart';
import 'package:navyoga_academy/services/reminder_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/animatedItem.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/dashboard_Action_card.dart';
import 'package:navyoga_academy/widgets/dashboard_ReferralCode_card.dart';
import 'package:navyoga_academy/widgets/dashboard_Referral_card.dart';
import 'package:navyoga_academy/widgets/dashboard_class_card.dart';
import 'package:navyoga_academy/widgets/dashboard_section_header.dart';
import 'package:navyoga_academy/widgets/dashboard_stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _WelcomeGlow extends StatelessWidget {
  const _WelcomeGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(opacity)),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  final MyClassesService _myClassesService = MyClassesService();
  final NotificationService _notificationService =
      NotificationService();

  final PageController _bannerController = PageController();

  final GlobalKey<OnboardingOverlayState> onboardingKey =
      GlobalKey<OnboardingOverlayState>();

  Timer? _bannerTimer;
  Timer? _classRefreshTimer;
  Timer? _joinWindowTimer;
  Timer? _notificationCountTimer;

  DashboardModel? dashboard;

  bool isDashboardLoading = true;
  bool isDashboardRefreshing = false;
  bool showOnboarding = false;

  String? dashboardError;

  int currentBanner = 0;
  int unreadCount = 0;
  bool _isOpeningNotifications = false;
  int _unreadRequestSequence = 0;

  static const int _bannerCount = 3;

  String? studentName;

  String? _studentName;

  @override
  void initState() {
    super.initState();

    _loadInitialData();
    _startBannerAutoScroll();
    _classRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkForNewClasses(),
    );
    _joinWindowTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (mounted && dashboard?.upcomingClasses.isNotEmpty == true) {
          setState(() {});
        }
      },
    );
    _notificationCountTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!_isOpeningNotifications) loadUnreadCount();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _classRefreshTimer?.cancel();
    _joinWindowTimer?.cancel();
    _notificationCountTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadStudentDashboard(),
      loadUnreadCount(),
      _loadStudentName(),
    ]);
  }

  Future<void> _loadStudentName() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null || token.trim().isEmpty) return;

      final response = await _authService.getProfile(token);
      final data = response is Map ? response['data'] : null;
      final name = data is Map ? data['name']?.toString().trim() : null;

      if (!mounted || name == null || name.isEmpty) return;
      setState(() => _studentName = name);
    } catch (error) {
      debugPrint('Failed to load student name: $error');
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted || !_bannerController.hasClients) {
          return;
        }

        final nextPage =
            (currentBanner + 1) % _bannerCount;

        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Future<void> loadStudentDashboard({
    bool isRefresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      if (isRefresh) {
        isDashboardRefreshing = true;
      } else if (dashboard == null) {
        isDashboardLoading = true;
      }

      dashboardError = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        await _handleUnauthorized();
        return;
      }

      var result =
          await _dashboardService.getDashboard(
        token: token,
      );

      try {
        final myClassesRes = await _myClassesService.getMyClasses(token: token);
        await _notifyAboutNewClasses(myClassesRes.classes);
        if (myClassesRes.classes.isNotEmpty) {
          final fetchedClasses = myClassesRes.classes.map((c) {
            final status = c.state == LiveClassState.live
                ? 'live'
                : (c.state == LiveClassState.upcoming ? 'upcoming' : 'past');
            return UpcomingClassModel(
              id: c.id,
              name: c.title,
              instructor: c.tutor?.name ?? 'Instructor',
              duration: c.duration,
              status: status,
              startTime: c.scheduledAt,
              meetingUrl: '',
              rawData: c.rawData,
            );
          }).toList();

          final existingIds = result.upcomingClasses.map((e) => e.id).toSet();
          final mergedClasses = [...result.upcomingClasses];
          for (final fc in fetchedClasses) {
            if (!existingIds.contains(fc.id)) {
              mergedClasses.add(fc);
            }
          }
          result = result.copyWith(upcomingClasses: mergedClasses);
        }
      } catch (e) {
        debugPrint('Failed to load my-classes for dashboard: $e');
      }

      if (!mounted) return;

      setState(() {
        dashboard = result;
      });
    } on DashboardUnauthorizedException catch (error) {
      debugPrint(
        'Dashboard unauthorized: ${error.message}',
      );

      await _handleUnauthorized();
    } on DashboardException catch (error) {
      debugPrint(
        'Dashboard API error: ${error.message}',
      );

      if (!mounted) return;

      setState(() {
        dashboardError = error.message;
      });
    } catch (error, stackTrace) {
      debugPrint('Dashboard error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        dashboardError =
            'Unable to load dashboard. Please try again.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isDashboardLoading = false;
        isDashboardRefreshing = false;
      });
    }
  }

  Future<void> _checkForNewClasses() async {
    final token = await AuthManager.getToken();
    if (token == null || token.trim().isEmpty) return;
    try {
      final result = await _myClassesService.getMyClasses(token: token);
      await _notifyAboutNewClasses(result.classes);
      if (mounted) await loadUnreadCount();
    } catch (error) {
      debugPrint('New-class check failed: $error');
    }
  }

  Future<void> _notifyAboutNewClasses(List<MyLiveClassModel> classes) async {
    // Do not erase the snapshot on a temporary empty/error response; doing so
    // would announce every existing class when the API recovers.
    if (classes.isEmpty) return;
    const key = 'known_live_class_ids';
    final prefs = await SharedPreferences.getInstance();
    final previous = prefs.getStringList(key);
    final currentIds = classes
        .map((item) => item.id)
        .where((id) => id.isNotEmpty)
        .toSet();

    if (previous != null) {
      final known = previous.toSet();
      for (final item in classes.where((item) => !known.contains(item.id))) {
        await ReminderService().showNewClassNotification(
          classId: item.id,
          classTitle: item.title,
        );
      }
    }

    await prefs.setStringList(key, currentIds.toList());
  }

  Future<void> loadUnreadCount() async {
    final requestSequence = ++_unreadRequestSequence;
    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        return;
      }

      final count = await _notificationService.getUnreadCount(token);

      if (!mounted || requestSequence != _unreadRequestSequence) return;

      setState(() {
        unreadCount = count;
      });
    } catch (error) {
      debugPrint(
        'Unread notification error: $error',
      );
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      loadStudentDashboard(isRefresh: true),
      loadUnreadCount(),
    ]);
  }

  Future<void> _handleUnauthorized() async {
    await AuthManager.clearToken();

    if (!mounted) return;

    AppSnackbar.showError(
      context,
      'Your session has expired. Please log in again.',
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    final shouldShow =
        prefs.getBool('show_onboarding') ?? false;

    if (!mounted) return;

    setState(() {
      showOnboarding = shouldShow;
    });

    if (shouldShow) {
      await prefs.setBool(
        'show_onboarding',
        false,
      );
    }
  }

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  int _getUnlockedBadges(
    ReferralStatsModel referral,
  ) {
    if (referral.unlockedBadges > 0) {
      return referral.unlockedBadges;
    }

    const badgeTargets = [1, 5, 10, 20, 50, 100];

    return badgeTargets
        .where(
          (target) =>
              referral.totalReferrals >= target,
        )
        .length;
  }

  Widget _buildOfferBanner({
    required String image,
    bool showButton = true,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: const Color(0xFFF3E9E3),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.self_improvement,
                  size: 70,
                  color: Colors.deepOrange,
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Text(
                '🎉 LIMITED TIME OFFER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 68,
            child: Text(
              'Get 20% OFF\non Annual Plans!',
              style: TextStyle(
                color: Color(0xFF1E1B39),
                fontSize: 23,
                height: 1.15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showButton)
            Positioned(
              left: 16,
              bottom: 15,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(30),
                onTap: _claimOffer,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.94),
                    borderRadius:
                        BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_motion,
                        size: 19,
                        color: Colors.purple,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Claim Offer Now',
                        style: TextStyle(
                          color: Color(0xFF590069),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _claimOffer() async {
    await Clipboard.setData(
      const ClipboardData(text: 'NAVYOGA20'),
    );

    if (!mounted) return;

    AppSnackbar.showSuccess(
      context,
      'Coupon copied: NAVYOGA20',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SubscriptionScreen(),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IconButton(
              tooltip: 'Notifications',
              iconSize: 27,
              splashRadius: 25,
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1E1B39),
              ),
              onPressed: _isOpeningNotifications
                  ? null
                  : () async {
                      setState(() => _isOpeningNotifications = true);
                      try {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        );
                        if (mounted) await loadUnreadCount();
                      } finally {
                        if (mounted) {
                          setState(() => _isOpeningNotifications = false);
                        }
                      }
                    },
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 5,
              top: 5,
              child: IgnorePointer(
                child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99
                    ? '99+'
                    : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody() {
    if (isDashboardLoading &&
        dashboard == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading dashboard...'),
          ],
        ),
      );
    }

    if (dashboardError != null &&
        dashboard == null) {
      return _buildErrorState();
    }

    if (dashboard == null) {
      return _buildErrorState();
    }

    return _buildDashboardContent();
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height:
                MediaQuery.sizeOf(context).height *
                    0.22,
          ),
          const Icon(
            Icons.cloud_off_outlined,
            size: 58,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            dashboardError ??
                'Unable to load dashboard.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: loadStudentDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final data = dashboard!;
    final metrics = data.metrics;
    final referral = data.referralStats;
    final upcomingClasses = data.upcomingClasses;

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          28,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            _buildBannerSection(),
            const SizedBox(height: 22),
            _buildStatsGrid(metrics),
            const SizedBox(height: 30),
            _buildUpcomingClassesSection(
              upcomingClasses,
            ),
            const SizedBox(height: 30),
            _buildActionsSection(),
            const SizedBox(height: 30),
            _buildReferralSection(referral),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final fullName = _studentName?.trim() ?? '';
    final firstName = fullName.isEmpty ? 'Yogi' : fullName.split(RegExp(r'\s+')).first;
    final initial = firstName.substring(0, 1).toUpperCase();

    return AnimatedItem(
      index: 0,
      child: Container(
        constraints: const BoxConstraints(minHeight: 210),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6A32),
              Color(0xFFD93D68),
              Color(0xFF7B0AA5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x407B0AA5),
              blurRadius: 24,
              offset: Offset(0, 11),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(
              right: -42,
              top: -52,
              child: _WelcomeGlow(size: 150, opacity: 0.11),
            ),
            const Positioned(
              right: 45,
              bottom: -64,
              child: _WelcomeGlow(size: 130, opacity: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Color(0xFF7B0AA5),
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$firstName!',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.self_improvement_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back to your wellness journey. Take a mindful moment for yourself today.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return AnimatedItem(
      index: 0,
      child: SizedBox(
        height: 220,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _bannerController,
                onPageChanged: (index) {
                  if (!mounted) return;

                  setState(() {
                    currentBanner = index;
                  });
                },
                children: [
                  _buildWelcomeCard(),
                  _buildOfferBanner(
                    image:
                        'assets/images/woman-practicing-cobra-asana-yoga-600nw-1605427378.webp',
                  ),
                  _buildOfferBanner(
                    image:
                        'assets/images/woman-practicing-cobra-asana-yoga-600nw-1605427378.webp',
                    showButton: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                _bannerCount,
                (index) {
                  final isSelected =
                      currentBanner == index;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: isSelected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.grey.shade400,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    DashboardMetrics metrics,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.28,
      children: [
        AnimatedItem(
          index: 0,
          child: StatCard(
            'Enrolled Classes',
            '${metrics.enrolledClasses}',
            '+${metrics.enrolledChangeMonth} this month',
            const Color.fromARGB(
              255,
              255,
              89,
              24,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.myClasses,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 1,
          child: StatCard(
            'Hours Completed',
            _formatNumber(
              metrics.hoursCompleted,
            ),
            '+${_formatNumber(metrics.hoursChangeWeek)} this week',
            const Color.fromARGB(
              255,
              169,
              43,
              191,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.attendance,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 2,
          child: StatCard(
            'Recordings Watched',
            '${metrics.recordingsWatched}',
            '+${metrics.recordingsChangeWeek} this week',
            const Color.fromARGB(
              255,
              43,
              191,
              117,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.selfPaced,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 3,
          child: StatCard(
            'Attendance Rate',
            '${_formatNumber(metrics.attendanceRate)}%',
            '+${_formatNumber(metrics.attendanceImprovement)}% improvement',
            Colors.orange,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.attendance,
              );
            },
          ),
        ),
      ],
    );
  }
  bool _isDashboardClassLive(
  UpcomingClassModel classData,
) {
  final rawData = classData.rawData;

  final status = (
    rawData['state'] ??
    rawData['status'] ??
    rawData['classStatus'] ??
    rawData['liveStatus'] ??
    ''
  ).toString().trim().toUpperCase();

  if (<String>{
    'LIVE',
    'LIVE_NOW',
    'ONGOING',
    'IN_PROGRESS',
    'STARTED',
    'ACTIVE',
  }.contains(status)) {
    return true;
  }

  final explicitLiveValue =
      rawData['isLive'] ??
      rawData['live'] ??
      rawData['is_live'];

  if (explicitLiveValue == true ||
      explicitLiveValue?.toString().toLowerCase() == 'true') {
    return true;
  }

  /*
   * Fallback:
   * Determine live state from start time and duration.
   */
  final startTime = _getDashboardClassDate(classData);

  if (startTime == null) {
    return false;
  }

  final duration = classData.duration;
  final endTime = startTime.add(
    Duration(minutes: duration),
  );

  final now = DateTime.now();

  return !now.isBefore(startTime) &&
      now.isBefore(endTime);
}

DateTime? _getDashboardClassDate(
  UpcomingClassModel classData,
) {
  final rawData = classData.rawData;

  final dynamic rawDate =
      rawData['scheduledAt'] ??
      rawData['scheduledDateTime'] ??
      rawData['startTime'] ??
      rawData['startDateTime'] ??
      rawData['classDateTime'] ??
      rawData['dateTime'] ??
      rawData['date'];

  if (rawDate == null) {
    return null;
  }

  if (rawDate is DateTime) {
    return rawDate.toLocal();
  }

  if (rawDate is int) {
    final milliseconds = rawDate.toString().length <= 10
        ? rawDate * 1000
        : rawDate;

    return DateTime
        .fromMillisecondsSinceEpoch(milliseconds)
        .toLocal();
  }

  final value = rawDate.toString().trim();

  if (value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value)?.toLocal();
}

 Widget _buildUpcomingClassesSection(
  List<UpcomingClassModel> classes,
) {
  final sortedClasses = [...classes]
    ..sort((first, second) {
      final firstIsLive = _isDashboardClassLive(first);
      final secondIsLive = _isDashboardClassLive(second);

      // Live classes must always appear first.
      if (firstIsLive && !secondIsLive) {
        return -1;
      }

      if (!firstIsLive && secondIsLive) {
        return 1;
      }

      final firstDate = _getDashboardClassDate(first);
      final secondDate = _getDashboardClassDate(second);

      if (firstDate == null && secondDate == null) {
        return 0;
      }

      if (firstDate == null) {
        return 1;
      }

      if (secondDate == null) {
        return -1;
      }

      return firstDate.compareTo(secondDate);
    });

  /*
   * Show every live class first.
   * After that, show upcoming classes until the section has
   * at least two cards.
   */
  final liveClasses = sortedClasses
      .where(_isDashboardClassLive)
      .toList();

  final upcomingClasses = sortedClasses
      .where((item) => !_isDashboardClassLive(item))
      .toList();

  final visibleClasses = <UpcomingClassModel>[
    ...liveClasses,
    ...upcomingClasses.take(
      liveClasses.length >= 2
          ? 0
          : 2 - liveClasses.length,
    ),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      sectionHeader(
        Icons.calendar_today_outlined,
        liveClasses.isNotEmpty
            ? 'Live & Upcoming Classes'
            : 'Upcoming Classes',
        onViewAllTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.myClasses,
          );
        },
        viewAllText: 'View All →',
      ),
      const SizedBox(height: 10),
      if (visibleClasses.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8E8EE),
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 38,
                color: Color(0xFF8A94A6),
              ),
              SizedBox(height: 10),
              Text(
                'No live or upcoming classes scheduled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7A99),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
      else
        Column(
          children: visibleClasses
              .map(_buildUpcomingClassCard)
              .toList(),
        ),
    ],
  );
}
  bool _canJoinDashboardClass(
    UpcomingClassModel classData,
  ) {
    if (_isDashboardClassLive(classData)) return true;

    final startTime = _getDashboardClassDate(classData);
    if (startTime == null) return false;

    final now = DateTime.now();
    final windowStart = startTime.subtract(const Duration(minutes: 15));
    final durationMinutes = classData.duration > 0 ? classData.duration : 60;
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    return !now.isBefore(windowStart) && now.isBefore(endTime);
  }

  Widget _buildUpcomingClassCard(
    UpcomingClassModel classData,
  ) {
    final isLive = _isDashboardClassLive(classData);
    final canJoin = _canJoinDashboardClass(classData);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLive)
            Container(
              margin: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 7,
              ),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'LIVE NOW',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ClassCard(
            classData.name,
            classData.instructor,
            isLive
                ? 'Live now • ${classData.duration} mins'
                : '${classData.duration} mins',
            isLive: isLive,
            joinButtonText: isLive
                ? 'Join Live Class'
                : (canJoin ? 'Join (Waiting Room)' : 'View Class'),
            onJoin: () {
              _handleDashboardClassJoin(
                classData,
                isLive: isLive,
                canJoin: canJoin,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDashboardClassJoin(
    UpcomingClassModel classData, {
    required bool isLive,
    bool canJoin = false,
  }) async {
    if (!isLive && !canJoin) {
      AppSnackbar.showError(
        context,
        'Join button opens 15 minutes before the class starts.',
      );

      return;
    }

  final rawData = classData.rawData;

  final classId = (
    rawData['id'] ??
    rawData['liveClassId'] ??
    rawData['classId'] ??
    ''
  ).toString().trim();

  if (classId.isEmpty) {
    AppSnackbar.showError(
      context,
      'Live-class ID is unavailable.',
    );

    return;
  }

  final studentName =
      _studentName?.trim() ?? '';

  if (studentName.isEmpty) {
    AppSnackbar.showError(
      context,
      'Student profile is still loading.',
    );

    return;
  }

  try {
    await LiveClassNavigator.open(
      context: context,
      classId: classId,
      studentName: studentName,
      title: classData.name,
      tutorName: classData.instructor,
      scheduledAt:
          _getDashboardClassDate(classData),
      duration: classData.duration,
      rawData: rawData,
    );

    if (!mounted) return;

    await loadStudentDashboard(
      isRefresh: true,
    );
  } catch (error, stackTrace) {
    debugPrint(
      'Unable to open live class: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    AppSnackbar.showError(
      context,
      'Unable to join the live class.',
    );
  }
}
  Widget _buildActionsSection() {
    return Column(
      children: [
        AnimatedItem(
          index: 0,
          child: ActionCard(
            'Browse Classes',
            'Explore available courses',
            Colors.deepOrange,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.myClasses,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 1,
          child: ActionCard(
            'Self-Paced',
            'Learn at your pace',
            Colors.purple,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.selfPaced,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 2,
          child: ActionCard(
            'View Attendance',
            'Track your progress',
            Colors.green,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.attendance,
              );
            },
          ),
        ),
        AnimatedItem(
          index: 3,
          child: ActionCard(
            'My Profile',
            'Update your details',
            Colors.orange,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferralSection(
    ReferralStatsModel referral,
  ) {
    final unlockedBadges =
        _getUnlockedBadges(referral);
    const badgeTargets = [1, 5, 10, 20, 50, 100];
    int? nextTarget;
    for (final target in badgeTargets) {
      if (referral.totalReferrals < target) {
        nextTarget = target;
        break;
      }
    }
    final previousTarget = nextTarget == null
        ? badgeTargets.last
        : badgeTargets.where((target) => target < nextTarget!).fold<int>(
              0,
              (highest, target) => target > highest ? target : highest,
            );
    final badgeProgress = nextTarget == null
        ? 1.0
        : ((referral.totalReferrals - previousTarget) /
                (nextTarget - previousTarget))
            .clamp(0.0, 1.0);
    final referralsToNext =
        nextTarget == null ? 0 : nextTarget - referral.totalReferrals;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        sectionHeader(
          Icons.card_giftcard,
          'Referral Program',
          onViewAllTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.referral,
            );
          },
          viewAllText: 'View All →',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6D28D9).withOpacity(0.24),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share wellness. Earn rewards.', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Invite friends and grow together.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.redeem_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.15,
          children: [
            ReferralCard(
              referral.totalReferrals
                  .toString(),
              'Total Referrals',
              Colors.blue,
              'Total',
            ),
            ReferralCard(
              '$unlockedBadges/6',
              'Achievement Badges',
              Colors.amber,
              'Unlocked',
            ),
            ReferralCard(
              '₹${_formatNumber(referral.totalEarned)}',
              'Total Earned',
              Colors.orange,
              'Earned',
            ),
            ReferralCard(
              '₹${_formatNumber(referral.availableBalance)}',
              'Available Balance',
              Colors.purple,
              'Balance',
            ),
          ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 19),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nextTarget == null
                                ? 'All referral badges unlocked!'
                                : '$referralsToNext more ${referralsToNext == 1 ? 'referral' : 'referrals'} to your next badge',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          nextTarget == null ? '6/6' : '${referral.totalReferrals}/$nextTarget',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: badgeProgress,
                        minHeight: 7,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD166)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ReferralCodeCard(
                referralCode: referral.referralCode,
                onViewProgram: () => Navigator.pushNamed(context, AppRoutes.referral),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          currentIndex: 2,
          drawer: const CustomDrawer(
            currentPage: 'Dashboard',
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 1,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFF1E1B39),
                  ),
                  onPressed: () {
                    Scaffold.of(context)
                        .openDrawer();
                  },
                );
              },
            ),
            title: Image.asset(
              'assets/logo/logo_transparent_clean.png',
              height: 58,
              fit: BoxFit.contain,
            ),
            centerTitle: true,
            actions: [
              _buildNotificationButton(),
              const SizedBox(width: 4),
            ],
          ),
          body: Stack(
            children: [
              _buildDashboardBody(),
              if (isDashboardRefreshing)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child:
                      LinearProgressIndicator(
                    minHeight: 2,
                  ),
                ),
            ],
          ),
        ),
        if (showOnboarding)
          OnboardingOverlay(
            key: onboardingKey,
            onFinished: () {
              if (!mounted) return;

              setState(() {
                showOnboarding = false;
              });
            },
          ),
      ],
    );
  }
}
