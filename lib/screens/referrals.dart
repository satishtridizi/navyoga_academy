import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/referral_api_model.dart';
import 'package:navyoga_academy/models/referral_stat_model.dart';
import 'package:navyoga_academy/models/referral_user_model.dart';
import 'package:navyoga_academy/services/referral_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/referral_how_it_works_section.dart';
import 'package:navyoga_academy/widgets/referral_invite_section.dart';
import 'package:navyoga_academy/widgets/referral_reward_summary_section.dart';
import 'package:navyoga_academy/widgets/referral_share_section.dart';
import 'package:navyoga_academy/widgets/referral_stat_card.dart';
import 'package:navyoga_academy/widgets/referral_user_card.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralService _service = ReferralService();

  String referralCode = '';
  String referralLink = '';

  int totalReferrals = 0;
  int activeReferrals = 0;
  int pendingReferrals = 0;
  int totalEarned = 0;
  int totalDaysEarned = 0;

  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;

  bool isLoading = true;
  bool isRefreshing = false;
  bool isChangingPage = false;

  String? errorMessage;

  List<ReferralApiModel> referrals = [];

  @override
  void initState() {
    super.initState();
    loadReferrals();
  }

  Future<void> loadReferrals({
    bool refreshing = false,
    bool changingPage = false,
    int page = 1,
  }) async {
    if (!mounted) return;

    setState(() {
      if (refreshing) {
        isRefreshing = true;
      } else if (changingPage) {
        isChangingPage = true;
      } else {
        isLoading = true;
      }

      errorMessage = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        setState(() {
          errorMessage = 'Your session has expired. Please log in again.';
        });

        return;
      }

      final response = await _service.getReferrals(
        token,
        page: page,
        limit: 5,
      );

      debugPrint('REFERRALS API RESPONSE => $response');

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Unable to load referral information',
        );
      }

      final data = _asMap(response['data']);
      final overview = _asMap(data['overview']);

      final rawItems = data['items'];

      final parsedReferrals = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => ReferralApiModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <ReferralApiModel>[];

      final parsedReferralCode =
          data['referralCode']?.toString().trim() ?? '';

      if (!mounted) return;

      setState(() {
        referralCode = parsedReferralCode;

        referralLink = parsedReferralCode.isEmpty
            ? ''
            : 'https://navyoga.academy/join/$parsedReferralCode';

        referrals = parsedReferrals;

        totalReferrals = _toInt(
          overview['totalReferrals'],
        );

        activeReferrals = _toInt(
          overview['active'],
        );

        pendingReferrals = _toInt(
          overview['pending'],
        );

        totalEarned = _toInt(
          overview['totalEarned'],
        );

        totalDaysEarned = _toInt(
          overview['totalDaysEarned'],
        );

        currentPage = _toInt(
          data['page'],
          fallback: 1,
        );

        totalPages = _toInt(
          data['totalPages'],
          fallback: 1,
        );

        totalItems = _toInt(
          data['total'],
          fallback: totalReferrals,
        );
      });
    } catch (error, stackTrace) {
      debugPrint('LOAD REFERRALS ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load your referral information.';
      });

      if (!refreshing && !changingPage) {
        AppSnackbar.showError(
          context,
          'Unable to load referrals',
        );
      }
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
        isChangingPage = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<void> _refresh() async {
    await loadReferrals(
      refreshing: true,
      page: 1,
    );
  }

  Future<void> _goToPreviousPage() async {
    if (currentPage <= 1 || isChangingPage) {
      return;
    }

    await loadReferrals(
      changingPage: true,
      page: currentPage - 1,
    );
  }

  Future<void> _goToNextPage() async {
    if (currentPage >= totalPages || isChangingPage) {
      return;
    }

    await loadReferrals(
      changingPage: true,
      page: currentPage + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 2,
      drawer: const CustomDrawer(
        currentPage: 'Referrals',
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
                Icons.menu_rounded,
                color: Colors.black54,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 58,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.deepPurple,
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
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),

                  _buildHeader(),

                  const SizedBox(height: 20),

                  if (errorMessage != null) _buildErrorCard(),

                  _buildStatsSection(),

                  const SizedBox(height: 20),

                  _buildAchievementSection(),

                  const SizedBox(height: 22),

                  _buildReferralListSection(),

                  const SizedBox(height: 20),

                  ShareSection(
                    referralCode: referralCode,
                    referralLink: referralLink,
                  )
                      .animate()
                      .fadeIn(
                        duration: const Duration(
                          milliseconds: 450,
                        ),
                      ),

                  const SizedBox(height: 20),

                  HowItWorksSection()
                      .animate(
                        delay: const Duration(
                          milliseconds: 100,
                        ),
                      )
                      .fadeIn()
                      .slideY(
                        begin: 0.07,
                        end: 0,
                      ),

                  const SizedBox(height: 20),

                  RewardSummarySection(
                    availableBalance: totalEarned,
                    totalEarned: totalEarned,
                    redeemed: 0,
                    pending: pendingReferrals,
                  )
                      .animate(
                        delay: const Duration(
                          milliseconds: 180,
                        ),
                      )
                      .fadeIn()
                      .slideY(
                        begin: 0.07,
                        end: 0,
                      ),

                  const SizedBox(height: 20),

                  InviteSection()
                      .animate(
                        delay: const Duration(
                          milliseconds: 250,
                        ),
                      )
                      .fadeIn()
                      .scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1, 1),
                      ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
          SizedBox(height: 12),
          Text(
            'Loading referrals...',
            style: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff75109E),
            Color(0xff9B13B2),
            Color(0xffFF6B2B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
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
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referral Program',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Invite friends and earn rewards together.',
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
    )
        .animate()
        .fadeIn(
          duration: const Duration(
            milliseconds: 450,
          ),
        )
        .slideY(
          begin: 0.08,
          end: 0,
        );
  }

  Widget _buildStatsSection() {
    final stats = [
      ReferralStatModel(
        title: 'Total Referrals',
        value: totalReferrals.toString(),
        icon: Icons.people_outline,
        borderColor: Colors.blue,
        iconBg: Colors.blue.shade50,
        iconColor: Colors.blue,
      ),
      ReferralStatModel(
        title: 'Active Referrals',
        value: activeReferrals.toString(),
        icon: Icons.check_circle_outline,
        borderColor: Colors.green,
        iconBg: Colors.green.shade50,
        iconColor: Colors.green,
      ),
      ReferralStatModel(
        title: 'Pending Referrals',
        value: pendingReferrals.toString(),
        icon: Icons.hourglass_top_rounded,
        borderColor: Colors.orange,
        iconBg: Colors.orange.shade50,
        iconColor: Colors.orange,
      ),
      ReferralStatModel(
        title: 'Total Earned',
        value: '₹$totalEarned',
        icon: Icons.currency_rupee_rounded,
        borderColor: Colors.purple,
        iconBg: Colors.purple.shade50,
        iconColor: Colors.purple,
      ),
      ReferralStatModel(
        title: 'Reward Days',
        value: totalDaysEarned.toString(),
        icon: Icons.calendar_month_outlined,
        borderColor: Colors.deepOrange,
        iconBg: Colors.deepOrange.shade50,
        iconColor: Colors.deepOrange,
      ),
    ];

    return Column(
      children: stats.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: ReferralStatCard(
            stat: entry.value,
          )
              .animate(
                delay: Duration(
                  milliseconds: entry.key * 70,
                ),
              )
              .fadeIn()
              .slideX(
                begin: 0.06,
                end: 0,
              ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementSection() {
    final badges = <Map<String, dynamic>>[
      {
        'title': 'First Steps',
        'description': 'Refer 1 friend',
        'target': 1,
        'icon': Icons.track_changes_rounded,
      },
      {
        'title': 'Social Butterfly',
        'description': 'Refer 5 friends',
        'target': 5,
        'icon': Icons.people_alt_outlined,
      },
      {
        'title': 'Rising Star',
        'description': 'Refer 10 friends',
        'target': 10,
        'icon': Icons.star_border_rounded,
      },
      {
        'title': 'Top Performer',
        'description': 'Refer 20 friends',
        'target': 20,
        'icon': Icons.military_tech_outlined,
      },
      {
        'title': 'Champion',
        'description': 'Refer 50 friends',
        'target': 50,
        'icon': Icons.emoji_events_outlined,
      },
      {
        'title': 'Legend',
        'description': 'Refer 100 friends',
        'target': 100,
        'icon': Icons.workspace_premium_outlined,
      },
    ];

    final unlockedCount = badges.where((badge) {
      final target = badge['target'] as int;

      return totalReferrals >= target;
    }).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.orange.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Achievement Badges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unlockedCount/${badges.length} Unlocked',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            totalReferrals == 1
                ? 'You have referred 1 friend so far.'
                : 'You have referred $totalReferrals friends so far.',
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];

              final target = badge['target'] as int;

              final isUnlocked = totalReferrals >= target;

              final progress =
                  (totalReferrals / target).clamp(0.0, 1.0);

              final progressCount =
                  totalReferrals.clamp(0, target);

              final remainingCount =
                  (target - totalReferrals).clamp(0, target);

              return Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.green.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.green.shade300
                        : Colors.grey.shade200,
                  ),
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
                            color: isUnlocked
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            badge['icon'] as IconData,
                            color: isUnlocked
                                ? Colors.green.shade700
                                : Colors.grey,
                            size: 21,
                          ),
                        ),
                        const Spacer(),
                        if (isUnlocked)
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade700,
                            size: 20,
                          )
                        else
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.grey,
                            size: 19,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      badge['title'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked
                            ? Colors.green.shade800
                            : const Color(0xff252238),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge['description'].toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      isUnlocked
                          ? 'Badge unlocked'
                          : '$remainingCount more to unlock',
                      style: TextStyle(
                        color: isUnlocked
                            ? Colors.green.shade700
                            : Colors.deepPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$progressCount/$target',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: isUnlocked
                            ? Colors.green
                            : Colors.deepPurple,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(
                    delay: Duration(
                      milliseconds: index * 70,
                    ),
                  )
                  .fadeIn()
                  .slideY(
                    begin: 0.07,
                    end: 0,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReferralListSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
              const Expanded(
                child: Text(
                  'Your Referrals',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalItems Total',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          if (isChangingPage)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: LinearProgressIndicator(),
            ),

          if (referrals.isEmpty)
            _buildEmptyReferralState()
          else
            ...referrals.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final referral = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReferralUserCard(
                    user: ReferralUserModel(
                      amount: referral.reward,
                      earning:
                          referral.status.toLowerCase() == 'active'
                              ? 'earned'
                              : 'pending',
                      name: referral.name,
                      email: referral.email ?? '',
                      status: referral.status,
                      date: referral.joinedDate,
                    ),
                  )
                      .animate(
                        delay: Duration(
                          milliseconds: index * 90,
                        ),
                      )
                      .fadeIn()
                      .slideY(
                        begin: 0.07,
                        end: 0,
                      ),
                );
              },
            ),

          if (totalPages > 1) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 10),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: currentPage > 1 && !isChangingPage
                ? _goToPreviousPage
                : null,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$currentPage/$totalPages',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                currentPage < totalPages && !isChangingPage
                    ? _goToNextPage
                    : null,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReferralState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 13),
          Text(
            'No referrals yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Share your referral code with friends '
            'to start earning rewards.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
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
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              loadReferrals(
                page: currentPage,
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}