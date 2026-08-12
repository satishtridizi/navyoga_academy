import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/subscription_plan_model.dart';
import 'package:navyoga_academy/services/subscription_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/services/reminder_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _service = SubscriptionService();

  SubscriptionCategory selectedCategory =
      SubscriptionCategory.live;

  PlatformConfigModel? platform;

  List<SubscriptionPlanModel> livePlans = [];
  List<SubscriptionPlanModel> selfPacedPlans = [];
  List<SubscriptionPlanModel> yttRecordedPlans = [];
  List<SubscriptionPlanModel> yttLivePlans = [];

  ActivePlanModel? liveActivePlan;
  ActivePlanModel? selfPacedActivePlan;

  final List<ActivePlanModel> yttRecordedActivePlans = [];
  final List<ActivePlanModel> yttLiveActivePlans = [];

  bool isLoading = true;
  bool isRefreshing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({
    bool refreshing = false,
  }) async {
    if (!mounted) return;

    setState(() {
      isRefreshing = refreshing;

      if (!refreshing) {
        isLoading = true;
      }

      errorMessage = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (_) => false,
        );

        return;
      }

      final responses = await Future.wait([
        _service.getPlatform(token),
        _service.getLivePlans(token),
        _service.getSelfPacedPlans(token),
        _service.getYttRecordedPlans(token),
        _service.getYttLivePlans(token),
        _service.getLiveEnrollment(token),
        _service.getSelfPacedSubscription(token),
        _service.getYttRecordedEnrollments(token),
        _service.getYttLiveEnrollments(token),
      ]);

      final platformResponse = responses[0];
      final livePlansResponse = responses[1];
      final selfPacedResponse = responses[2];
      final yttRecordedResponse = responses[3];
      final yttLiveResponse = responses[4];
      final liveEnrollmentResponse = responses[5];
      final selfSubscriptionResponse = responses[6];
      final yttRecordedEnrollmentResponse = responses[7];
      final yttLiveEnrollmentResponse = responses[8];

      final parsedPlatform = _parsePlatform(platformResponse);

      final parsedLivePlans = _parsePlans(
        livePlansResponse,
        category: SubscriptionCategory.live,
      );

      final parsedSelfPacedPlans = _parsePlans(
        selfPacedResponse,
        category: SubscriptionCategory.selfPaced,
      );

      final parsedYttRecordedPlans = _parsePlans(
        yttRecordedResponse,
        category: SubscriptionCategory.teacherTraining,
        trainingType: TeacherTrainingType.recorded,
      );

      final parsedYttLivePlans = _parsePlans(
        yttLiveResponse,
        category: SubscriptionCategory.teacherTraining,
        trainingType: TeacherTrainingType.live,
      );

      final parsedLivePlan =
          _parseSingleEnrollmentResponse(
        liveEnrollmentResponse,
        category: SubscriptionCategory.live,
      );

      final parsedSelfPacedPlan =
          _parseSelfPacedSubscription(
        selfSubscriptionResponse,
      );

      final parsedYttRecorded =
          _parseEnrollmentList(
        yttRecordedEnrollmentResponse,
        category: SubscriptionCategory.teacherTraining,
        trainingType: TeacherTrainingType.recorded,
      );

      final parsedYttLive =
          _parseEnrollmentList(
        yttLiveEnrollmentResponse,
        category: SubscriptionCategory.teacherTraining,
        trainingType: TeacherTrainingType.live,
      );

      if (!mounted) return;

      setState(() {
        platform = parsedPlatform;
        livePlans = parsedLivePlans;
        selfPacedPlans = parsedSelfPacedPlans;
        yttRecordedPlans = parsedYttRecordedPlans;
        yttLivePlans = parsedYttLivePlans;

        liveActivePlan = parsedLivePlan;
        selfPacedActivePlan = parsedSelfPacedPlan;

        yttRecordedActivePlans
          ..clear()
          ..addAll(parsedYttRecorded);

        yttLiveActivePlans
          ..clear()
          ..addAll(parsedYttLive);
      });

      final activePlansList = [
        if (parsedLivePlan != null) parsedLivePlan,
        if (parsedSelfPacedPlan != null) parsedSelfPacedPlan,
        ...parsedYttRecorded,
        ...parsedYttLive,
      ];

      for (final activePlan in activePlansList) {
        if (activePlan.endDate != null) {
          ReminderService().scheduleSubscriptionRenewalReminder(
            renewalDate: activePlan.endDate!,
            planName: activePlan.name,
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('LOAD SUBSCRIPTIONS ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to load subscription plans. Please try again.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  PlatformConfigModel? _parsePlatform(
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    if (response['success'] != true || data.isEmpty) {
      return null;
    }

    return PlatformConfigModel.fromJson(data);
  }

  List<SubscriptionPlanModel> _parsePlans(
    Map<String, dynamic> response, {
    required SubscriptionCategory category,
    TeacherTrainingType? trainingType,
  }) {
    final data = response['data'];

    if (response['success'] != true || data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => SubscriptionPlanModel.fromJson(
            Map<String, dynamic>.from(item),
            category: category,
            trainingType: trainingType,
          ),
        )
        .where((plan) => plan.isActive)
        .toList();
  }

  ActivePlanModel? _parseSingleEnrollmentResponse(
    Map<String, dynamic> response, {
    required SubscriptionCategory category,
  }) {
    final data = _asMap(response['data']);

    if (response['success'] != true ||
        data['enrolled'] != true) {
      return null;
    }

    final enrollment = _asMap(data['enrollment']);

    return _parseEnrollment(
      enrollment,
      category: category,
    );
  }

  ActivePlanModel? _parseSelfPacedSubscription(
    Map<String, dynamic> response,
  ) {
    final data = _asMap(response['data']);

    if (response['success'] != true ||
        data['enrolled'] != true) {
      return null;
    }

    final subscription = _asMap(data['subscription']);

    return _parseEnrollment(
      subscription,
      category: SubscriptionCategory.selfPaced,
    );
  }

  List<ActivePlanModel> _parseEnrollmentList(
    Map<String, dynamic> response, {
    required SubscriptionCategory category,
    TeacherTrainingType? trainingType,
  }) {
    final data = response['data'];

    if (response['success'] != true || data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => _parseEnrollment(
            Map<String, dynamic>.from(item),
            category: category,
            trainingType: trainingType,
          ),
        )
        .whereType<ActivePlanModel>()
        .where((plan) => plan.isActive)
        .toList();
  }

  ActivePlanModel? _parseEnrollment(
    Map<String, dynamic> enrollment, {
    required SubscriptionCategory category,
    TeacherTrainingType? trainingType,
  }) {
    if (enrollment.isEmpty) return null;

    final plan = _asMap(enrollment['plan']);
    final batch = _asMap(enrollment['batch']);

    final model = ActivePlanModel(
      enrollmentId:
          enrollment['id']?.toString() ??
          enrollment['enrollmentId']?.toString() ??
          '',
      planId:
          enrollment['planId']?.toString() ??
          plan['id']?.toString() ??
          '',
      name:
          plan['name']?.toString() ??
          enrollment['planName']?.toString() ??
          'Subscription',
      status:
          enrollment['status']?.toString() ??
          'ACTIVE',
      batchName: batch['name']?.toString(),
      startDate: DateTime.tryParse(
        enrollment['startDate']?.toString() ?? '',
      )?.toLocal(),
      endDate: DateTime.tryParse(
        enrollment['endDate']?.toString() ??
            enrollment['expiresAt']?.toString() ??
            '',
      )?.toLocal(),
      category: category,
      trainingType: trainingType,
    );

    return model.isActive ? model : null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<SubscriptionPlanModel> get currentPlans {
    switch (selectedCategory) {
      case SubscriptionCategory.live:
        return livePlans;

      case SubscriptionCategory.selfPaced:
        return selfPacedPlans;

      case SubscriptionCategory.teacherTraining:
        return [
          ...yttRecordedPlans,
          ...yttLivePlans,
        ];
    }
  }

  bool _isCurrentPlan(SubscriptionPlanModel plan) {
    switch (plan.category) {
      case SubscriptionCategory.live:
        return liveActivePlan?.planId == plan.id;

      case SubscriptionCategory.selfPaced:
        return selfPacedActivePlan?.planId == plan.id;

      case SubscriptionCategory.teacherTraining:
        final enrollments =
            plan.trainingType == TeacherTrainingType.live
                ? yttLiveActivePlans
                : yttRecordedActivePlans;

        return enrollments.any(
          (item) => item.planId == plan.id,
        );
    }
  }

  void _openPayment(SubscriptionPlanModel plan) {
    if (_isCurrentPlan(plan)) {
      AppSnackbar.showSuccess(
        context,
        'This is your current active plan.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'planId': plan.id,
        'courseId': plan.courseId,
        'name': plan.name,
        'price': plan.price,
        'originalPrice': plan.originalPrice,
        'subscriptionType': plan.categoryKey,
        'gstPercentage': platform?.gstPercentage ?? 0,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(
        currentPage: 'Subscription',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xff241B32),
            ),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 55,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7B0AA5),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(refreshing: true),
              color: const Color(0xff7B0AA5),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  32,
                ),
                children: [
                  if (isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: LinearProgressIndicator(),
                    ),

                  _buildHeader(),

                  const SizedBox(height: 18),

                  _buildCategorySelector(),

                  const SizedBox(height: 22),

                  if (errorMessage != null)
                    _buildErrorCard(),

                  _buildCategoryHeading(),

                  const SizedBox(height: 16),

                  if (selectedCategory ==
                      SubscriptionCategory.teacherTraining)
                    ..._buildTeacherTrainingSections()
                  else if (currentPlans.isEmpty)
                    _buildEmptyState()
                  else
                    ...currentPlans.asMap().entries.map(
                      (entry) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          child: _buildPlanCard(entry.value)
                              .animate(
                                delay: Duration(
                                  milliseconds: entry.key * 70,
                                ),
                              )
                              .fadeIn()
                              .slideY(
                                begin: 0.08,
                                end: 0,
                              ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffFF5B23),
            Color(0xff7B0AA5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Choose the perfect plan for your yoga journey, '
                  'from live classes to self-paced programs and '
                  'professional teacher training.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xffF3F1F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(
            category: SubscriptionCategory.live,
            label: 'Live',
            icon: Icons.bolt_rounded,
          ),
          _buildTab(
            category: SubscriptionCategory.selfPaced,
            label: 'Self-Paced',
            icon: Icons.favorite_border_rounded,
          ),
          _buildTab(
            category: SubscriptionCategory.teacherTraining,
            label: 'Training',
            icon: Icons.school_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required SubscriptionCategory category,
    required String label,
    required IconData icon,
  }) {
    final selected = selectedCategory == category;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xff7B0AA5)
                    : const Color(0xff686275),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected
                      ? const Color(0xff241B32)
                      : const Color(0xff686275),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeading() {
    String title;
    String subtitle;

    switch (selectedCategory) {
      case SubscriptionCategory.live:
        title = 'Live Yoga Classes';
        subtitle = 'Pick a validity that fits your practice';
        break;

      case SubscriptionCategory.selfPaced:
        title = 'Self-Paced Yoga Programs';
        subtitle = 'Learn at your own pace with recorded sessions';
        break;

      case SubscriptionCategory.teacherTraining:
        title = 'Yoga Teacher Training';
        subtitle = 'Become a certified yoga instructor';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xffFF5B23),
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xff81798C),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTeacherTrainingSections() {
    return [
      _buildSectionTitle(
        'Teacher Training – Self-Paced',
        'Learn through professionally recorded modules',
      ),
      const SizedBox(height: 12),
      if (yttRecordedPlans.isEmpty)
        _buildEmptyState()
      else
        ...yttRecordedPlans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(plan),
          ),
        ),
      const SizedBox(height: 10),
      const Divider(),
      const SizedBox(height: 18),
      _buildSectionTitle(
        'Teacher Training – Live Sessions',
        'Interactive training with expert instructors',
      ),
      const SizedBox(height: 12),
      if (yttLivePlans.isEmpty)
        _buildEmptyState()
      else
        ...yttLivePlans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(plan),
          ),
        ),
    ];
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xffFF5B23),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xff81798C),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan) {
    final isCurrent = _isCurrentPlan(plan);
    final gst = platform?.gstPercentage ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffFFFBF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? const Color(0xff28B45D)
              : const Color(0xffF2DDD4),
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffFFE4D8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  plan.icon,
                  color: const Color(0xffFF5B23),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: Color(0xffFF5B23),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff28B45D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_formatPrice(plan.price)}',
                style: const TextStyle(
                  color: Color(0xff171526),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (plan.originalPrice != null &&
                  plan.originalPrice! > plan.price) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    '₹${_formatPrice(plan.originalPrice!)}',
                    style: const TextStyle(
                      color: Color(0xff8E8798),
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                  bottom: 5,
                ),
                child: Text(
                  '+ ${_formatPrice(gst)}% GST',
                  style: const TextStyle(
                    color: Color(0xff6E6980),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            plan.validityLabel,
            style: const TextStyle(
              color: Color(0xff6E6980),
              fontSize: 12,
            ),
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              plan.description,
              style: const TextStyle(
                color: Color(0xff6E6980),
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 17),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xffFF5B23),
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        color: Color(0xff302B3C),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(
                      Icons.check_rounded,
                    ),
                    label: const Text(
                      'Your Current Plan',
                    ),
                    style: OutlinedButton.styleFrom(
                      disabledForegroundColor:
                          const Color(0xff20A856),
                      side: const BorderSide(
                        color: Color(0xff20A856),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _openPayment(plan),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          const Color(0xffFF5B23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      selectedCategory ==
                              SubscriptionCategory.live
                          ? 'Upgrade to this plan'
                          : selectedCategory ==
                                  SubscriptionCategory.selfPaced
                              ? 'Get Started'
                              : 'Enroll Now',
                    ),
                  ),
          ),
          if (isCurrent && liveActivePlan?.batchName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 17,
                  color: Color(0xff6E6980),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    liveActivePlan!.batchName!,
                    style: const TextStyle(
                      color: Color(0xff6E6980),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isCurrent && liveActivePlan?.endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Valid until '
              '${DateFormat('dd MMM yyyy').format(liveActivePlan!.endDate!)}',
              style: const TextStyle(
                color: Color(0xff6E6980),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(errorMessage!),
          ),
          TextButton(
            onPressed: () => _loadData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8F6F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 45,
            color: Color(0xff91899A),
          ),
          SizedBox(height: 12),
          Text(
            'No plans available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Pull down to refresh and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff7B7483),
            ),
          ),
        ],
      ),
    );
  }
}