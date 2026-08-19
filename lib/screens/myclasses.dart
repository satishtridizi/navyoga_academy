import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/mylive_class_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/myclass_service.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/utils/live_class_navigator.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/services/reminder_service.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  final MyClassesService _myClassesService = MyClassesService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<MyLiveClassModel> _classes = [];

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isEnrolled = false;

  int _recordingDays = 0;

  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatus = 'All Classes';
  String _selectedDifficulty = 'All Levels';
  
  String? _studentName;
  Timer? _joinWindowTimer;

  @override
  void initState() {
    super.initState();
    _loadMyClasses();
    _joinWindowTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (mounted && _classes.any((item) => item.isUpcoming)) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _joinWindowTimer?.cancel();
    _searchController.dispose();
    _myClassesService.dispose();
    super.dispose();
  }

  Future<void> _loadMyClasses({
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        return;
      }

      await _loadStudentName(token);

final result =
    await _myClassesService.getMyClasses(
  token: token,
);
      if (!mounted) return;

      setState(() {
        _classes = result.classes;
        _isEnrolled = result.enrolled;
        _recordingDays = result.recordingDays;
      });

      for (final item in result.classes) {
        if (item.scheduledAt != null && item.state == LiveClassState.upcoming) {
          ReminderService().scheduleClassReminders(
            classId: item.id,
            classTitle: item.title,
            scheduledAt: item.scheduledAt!,
          );
        }
      }
    } on MyClassesUnauthorizedException {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } on MyClassesException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Something went wrong while loading your classes.';
      });

      debugPrint('My Classes error: $error');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadStudentName(String token) async {
    try {
      final response = await _authService.getProfile(token);
      final data = response is Map ? response['data'] : null;
      final name = data is Map ? data['name']?.toString().trim() : null;

      if (!mounted || name == null || name.isEmpty) return;
      setState(() => _studentName = name);
    } catch (error) {
      debugPrint('Failed to load student name: $error');
    }
  }

  List<MyLiveClassModel> get _filteredClasses {
    return _classes.where((classItem) {
      final query = _searchQuery.trim().toLowerCase();

      if (query.isNotEmpty) {
        final title = classItem.title.toLowerCase();
        final yogaType = classItem.yogaType.toLowerCase();
        final tutorName =
            classItem.tutor?.name.toLowerCase() ?? '';
        final batchName =
            classItem.batch?.name.toLowerCase() ?? '';

        final matchesSearch =
            title.contains(query) ||
            yogaType.contains(query) ||
            tutorName.contains(query) ||
            batchName.contains(query);

        if (!matchesSearch) {
          return false;
        }
      }

      if (_selectedStatus == 'Upcoming' &&
          classItem.state != LiveClassState.upcoming) {
        return false;
      }

      if (_selectedStatus == 'Live Now' &&
          classItem.state != LiveClassState.live) {
        return false;
      }

      if (_selectedStatus == 'Past' &&
          classItem.state != LiveClassState.past) {
        return false;
      }

      if (_selectedDifficulty != 'All Levels') {
        final requiredDifficulty =
            _difficultyApiValue(_selectedDifficulty);

        if (classItem.difficulty != requiredDifficulty) {
          return false;
        }
      }

      return true;
    }).toList()
       ..sort((first, second) {
    if (_selectedStatus != 'Past') {
      final firstIsLive = first.isLive;
      final secondIsLive = second.isLive;

      if (firstIsLive && !secondIsLive) {
        return -1;
      }

      if (!firstIsLive && secondIsLive) {
        return 1;
      }
    }

    final firstDate =
        first.scheduledAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final secondDate =
        second.scheduledAt ??
        DateTime.fromMillisecondsSinceEpoch(0);

    if (_selectedStatus == 'Past') {
      return secondDate.compareTo(firstDate);
    }

    return firstDate.compareTo(secondDate);
  });
  }

  int get _upcomingCount {
    return _classes
        .where(
          (item) => item.state == LiveClassState.upcoming,
        )
        .length;
  }

  int get _liveCount {
    return _classes
        .where(
          (item) => item.state == LiveClassState.live,
        )
        .length;
  }

  int get _pastCount {
    return _classes
        .where(
          (item) => item.state == LiveClassState.past,
        )
        .length;
  }

  String _difficultyApiValue(String value) {
    switch (value) {
      case 'Beginner':
        return 'EASY';

      case 'Intermediate':
        return 'MEDIUM';

      case 'Advanced':
        return 'HARD';

      default:
        return '';
    }
  }

  void _selectStatus(String value) {
    setState(() {
      _selectedStatus = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      drawer: const CustomDrawer(
        currentPage: 'My Classes',
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF1E1B39),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading your classes...'),
          ],
        ),
      );
    }

    if (_errorMessage != null && _classes.isEmpty) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _loadMyClasses,
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return _loadMyClasses(isRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildStatsGrid(),

            const SizedBox(height: 20),

            _buildSearchAndFilters(),

            const SizedBox(height: 22),

            _buildSectionHeader(),

            const SizedBox(height: 16),

            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),

            if (_errorMessage != null)
              _buildInlineError(),

            _buildClassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.deepOrange,
            Colors.orangeAccent,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.menu_book,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'My Classes',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _isEnrolled
                ? 'View your upcoming and live yoga sessions.'
                : 'You do not have an active live-class enrollment.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          if (_recordingDays > 0) ...[
            const SizedBox(height: 10),
            Text(
              'Recordings remain available for '
              '$_recordingDays days.',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      _ClassStatItem(
        title: 'Total Classes',
        value: _classes.length.toString(),
        icon: Icons.menu_book,
        color: Colors.deepOrange,
        status: 'All Classes',
      ),
      _ClassStatItem(
        title: 'Upcoming',
        value: _upcomingCount.toString(),
        icon: Icons.schedule,
        color: Colors.purple,
        status: 'Upcoming',
      ),
      _ClassStatItem(
        title: 'Live Now',
        value: _liveCount.toString(),
        icon: Icons.podcasts,
        color: Colors.green,
        status: 'Live Now',
      ),
      _ClassStatItem(
        title: 'Past',
        value: _pastCount.toString(),
        icon: Icons.history,
        color: Colors.orange,
        status: 'Past',
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected =
            _selectedStatus == item.status;

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            _selectStatus(item.status);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.color.withOpacity(
                    isSelected ? 0.28 : 0.18,
                  ),
                  item.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? item.color
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search classes or instructors...',
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildFilterBox(
                  value: _selectedDifficulty,
                  options: const [
                    'All Levels',
                    'Beginner',
                    'Intermediate',
                    'Advanced',
                  ],
                  onSelected: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildFilterBox(
                  value: _selectedStatus,
                  options: const [
                    'All Classes',
                    'Upcoming',
                    'Live Now',
                    'Past',
                  ],
                  onSelected: _selectStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            '$_selectedStatus (${_filteredClasses.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ),

        if (_selectedStatus != 'All Classes' ||
            _selectedDifficulty != 'All Levels' ||
            _searchQuery.isNotEmpty)
          TextButton(
            onPressed: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
                _selectedStatus = 'All Classes';
                _selectedDifficulty = 'All Levels';
              });
            },
            child: const Text('Clear'),
          ),
      ],
    );
  }

  Widget _buildInlineError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
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
            child: Text(_errorMessage!),
          ),
          TextButton(
            onPressed: _loadMyClasses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    final filteredClasses = _filteredClasses;

    if (!_isEnrolled && _classes.isEmpty) {
      return const _EmptyClassesView(
        icon: Icons.workspace_premium_outlined,
        title: 'No active enrollment',
        message:
            'Enroll in a live yoga plan to view your assigned classes.',
      );
    }

    if (filteredClasses.isEmpty) {
      return const _EmptyClassesView(
        icon: Icons.search_off,
        title: 'No classes found',
        message:
            'Try changing your search or filter selection.',
      );
    }

    return Column(
      children: filteredClasses.map((classItem) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _MyLiveClassCard(
            classItem: classItem,
            onTap: () {
              _handleClassTap(classItem);
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleClassTap(
  MyLiveClassModel classItem,
) async {
  if (!classItem.canJoin) {
    AppSnackbar.showError(
      context,
      'Join button opens 15 minutes before the class starts.',
    );

    return;
  }

  final classId =
      classItem.id.trim();

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
      title: classItem.title,
      tutorName: classItem.tutor?.name,
      yogaType: classItem.yogaType,
      scheduledAt: classItem.scheduledAt,
      duration: classItem.duration,
      rawData: classItem.rawData,
    );

    if (!mounted) return;

    await _loadMyClasses(
      isRefresh: true,
    );
  } catch (error, stackTrace) {
    debugPrint(
      'My Classes join error: $error',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    AppSnackbar.showError(
      context,
      'Unable to open the live class.',
    );
  }
}

  Widget _buildFilterBox({
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final selected =
            await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      final isSelected = option == value;

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? Colors.deepOrange
                              : Colors.grey,
                        ),
                        title: Text(option),
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            option,
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );

        if (selected != null) {
          onSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyLiveClassCard extends StatelessWidget {
  const _MyLiveClassCard({
    required this.classItem,
    required this.onTap,
  });

  final MyLiveClassModel classItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(classItem.state);
    final schedule = classItem.scheduledAt;
    final joinLabel = _joinButtonLabel(classItem);

    final dateText = schedule == null
        ? 'Schedule unavailable'
        : DateFormat(
            'EEE, dd MMM yyyy • hh:mm a',
          ).format(schedule);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 1.5,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: stateColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      classItem.isLive
                          ? Icons.play_circle_fill
                          : Icons.self_improvement,
                      color: stateColor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          classItem.yogaType,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _StateBadge(
                    state: classItem.state,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ClassInfoRow(
                icon: Icons.calendar_today_outlined,
                text: dateText,
              ),

              const SizedBox(height: 9),

              _ClassInfoRow(
                icon: Icons.person_outline,
                text:
                    classItem.tutor?.name ??
                    'Instructor unavailable',
              ),

              const SizedBox(height: 9),

              _ClassInfoRow(
                icon: Icons.timer_outlined,
                text:
                    '${classItem.duration} minutes'
                    ' • ${_difficultyLabel(classItem.difficulty)}',
              ),

              if (classItem.batch?.name.isNotEmpty == true) ...[
                const SizedBox(height: 9),
                _ClassInfoRow(
                  icon: Icons.groups_outlined,
                  text: classItem.batch!.name,
                ),
              ],

              if (classItem.description?.trim().isNotEmpty ==
                  true) ...[
                const SizedBox(height: 14),
                Text(
                  classItem.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],

              if (!classItem.isPast) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: classItem.canJoin ? onTap : null,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      joinLabel,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: classItem.isLive ? Colors.green : Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _joinButtonLabel(MyLiveClassModel classItem) {
    if (classItem.isLive) return 'Join Live Class';
    if (classItem.canJoin) return 'Join Class (Waiting Room)';
    final scheduledAt = classItem.scheduledAt;
    if (scheduledAt == null) return 'Schedule unavailable';
    final remaining = scheduledAt
        .subtract(const Duration(minutes: 15))
        .difference(DateTime.now());
    if (remaining.inMinutes >= 60) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      return 'Join opens in ${hours}h ${minutes}m';
    }
    if (remaining.inMinutes >= 1) {
      return 'Join opens in ${remaining.inMinutes + 1} min';
    }
    return 'Join opens shortly';
  }

  static Color _stateColor(LiveClassState state) {
    switch (state) {
      case LiveClassState.live:
        return Colors.green;

      case LiveClassState.past:
        return Colors.grey;

      case LiveClassState.upcoming:
        return Colors.deepOrange;
    }
  }

  static String _difficultyLabel(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return 'Beginner';

      case 'MEDIUM':
        return 'Intermediate';

      case 'HARD':
        return 'Advanced';

      default:
        return difficulty;
    }
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({
    required this.state,
  });

  final LiveClassState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      LiveClassState.live => 'LIVE',
      LiveClassState.upcoming => 'UPCOMING',
      LiveClassState.past => 'PAST',
    };

    final color = switch (state) {
      LiveClassState.live => Colors.green,
      LiveClassState.upcoming => Colors.deepOrange,
      LiveClassState.past => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ClassInfoRow extends StatelessWidget {
  const _ClassInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.deepOrange,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyClassesView extends StatelessWidget {
  const _EmptyClassesView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 52,
            color: Colors.grey,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load classes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassStatItem {
  const _ClassStatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.status,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String status;
}
