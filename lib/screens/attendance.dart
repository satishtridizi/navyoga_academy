import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Dashboard/dashboard_menu.dart';
import '../models/attendance_stat_model.dart';
import '../models/student_attendance_model.dart';
import '../services/attendance_service.dart';
import '../utils/auth_manager.dart';
import '../widgets/animatedItem.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/attendance_stat_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  StudentAttendanceResponse? _attendance;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final token = await AuthManager.getToken();
    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final attendance = await _attendanceService.getAttendance(token);
      if (!mounted) return;
      setState(() {
        _attendance = attendance;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is AttendanceException
            ? error.message
            : 'Unable to load attendance. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 3,
      drawer: const CustomDrawer(currentPage: 'Attendance'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendance,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.event_busy, size: 58, color: Colors.deepOrange),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: _loadAttendance,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    final attendance = _attendance!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const AnimatedItem(
          index: 0,
          child: Text(
            'My Attendance',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your attended live classes and practice history',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 20),
        _buildStatsGrid(attendance),
        const SizedBox(height: 24),
        Text(
          'Attendance History',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (attendance.records.isEmpty)
          _buildEmptyState()
        else
          ...attendance.records.asMap().entries.map(
                (entry) => AnimatedItem(
                  index: entry.key + 5,
                  child: _buildRecordCard(entry.value),
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsGrid(StudentAttendanceResponse data) {
    final totalMinutes = data.records.fold<int>(
      0,
      (total, record) => total + record.liveClass.duration,
    );
    final stats = [
      AttendanceStatModel(
        title: 'Total Attended',
        value: '${data.summary.totalAttended}',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      AttendanceStatModel(
        title: 'This Month',
        value: '${data.summary.attendedThisMonth}',
        icon: Icons.calendar_month,
        color: Colors.orange,
      ),
      AttendanceStatModel(
        title: 'Practice Time',
        value: _formatDuration(totalMinutes),
        icon: Icons.timer_outlined,
        color: Colors.deepPurple,
      ),
      AttendanceStatModel(
        title: 'Last Attended',
        value: data.summary.lastAttendedAt == null
            ? '--'
            : DateFormat('d MMM').format(data.summary.lastAttendedAt!),
        icon: Icons.history,
        color: Colors.blue,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) =>
          AnimatedItem(index: index + 1, child: StatCard(stats[index])),
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    final liveClass = record.liveClass;
    final classDate = liveClass.scheduledAt ?? record.joinedAt;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    liveClass.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (liveClass.yogaType.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      liveClass.yogaType,
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (classDate != null)
                        DateFormat('EEE, d MMM yyyy • h:mm a').format(classDate),
                      '${liveClass.duration} min',
                    ].join('  •  '),
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trainer: ${liveClass.tutorName}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 44, color: Colors.black38),
          SizedBox(height: 12),
          Text(
            'No attendance records yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Classes you attend will appear here.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '${hours}h' : '${hours}h ${remainder}m';
  }
}
