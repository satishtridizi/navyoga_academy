
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Dashboard/dashboard_menu.dart';
import '../models/live_recording_model.dart';
import '../models/recording_api_model.dart';
import '../routes/app_routes.dart';
import '../services/live_recording_service.dart';
import '../utils/auth_manager.dart';
import '../widgets/app_scaffold.dart';
import 'recording_player_screen.dart';

class RecordingsDashboard extends StatefulWidget {
  const RecordingsDashboard({super.key});

  @override
  State<RecordingsDashboard> createState() => _RecordingsDashboardState();
}

class _RecordingsDashboardState extends State<RecordingsDashboard> {
  final LiveRecordingService _service = LiveRecordingService();
  final TextEditingController _searchController = TextEditingController();
  LiveRecordingAccess? _access;
  bool _loading = true;
  String? _error;
  String _query = '';

  List<LiveRecording> get _recordings {
    final items = _access?.recordings ?? const <LiveRecording>[];
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) =>
        item.title.toLowerCase().contains(query) ||
        item.yogaType.toLowerCase().contains(query) ||
        item.tutorName.toLowerCase().contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = await AuthManager.getToken();
    if (!mounted) return;
    if (token == null || token.trim().isEmpty) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      return;
    }
    try {
      final result = await _service.getAvailableRecordings(token);
      if (!mounted) return;
      setState(() {
        _access = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is LiveRecordingException
            ? error.message
            : 'Unable to load recordings.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      drawer: const CustomDrawer(currentPage: 'Recordings'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
        title: Image.asset('assets/logo/logo_transparent_clean.png', height: 52),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _load, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.cloud_off, size: 56, color: Colors.deepOrange),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Center(child: FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          )),
        ],
      );
    }

    final access = _access!;
    if (!access.enrolled) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: const [
          SizedBox(height: 100),
          Icon(Icons.lock_outline, size: 60, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('Recording access requires an active Live Yoga plan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text('Live Class Recordings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold, color: Colors.deepOrange,
        )),
        const SizedBox(height: 6),
        Text('${access.planName} • Available for ${access.recordingDays} days',
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search recordings or trainers',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty ? null : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 18),
        if (_recordings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Column(children: [
              Icon(Icons.video_library_outlined, size: 54, color: Colors.black38),
              SizedBox(height: 12),
              Text('No recordings are currently available.'),
            ]),
          )
        else
          ..._recordings.map(_recordingCard),
      ],
    );
  }

  Widget _recordingCard(LiveRecording item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => RecordingPlayerScreen(recording: RecordingApiModel(
            id: item.id,
            title: item.title,
            description: item.description ?? 'Recorded live yoga session',
            thumbnail: '',
            yogaType: item.yogaType,
            level: item.difficulty,
            videoUrl: item.videoUrl,
            durationMinutes: item.duration,
            durationSeconds: item.durationSeconds,
          )),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.yogaType} • Recording',
                    style: const TextStyle(color: Colors.deepOrange)),
                const SizedBox(height: 4),
                Text(item.scheduledAt == null
                    ? item.tutorName
                    : '${DateFormat('d MMM yyyy').format(item.scheduledAt!)} • ${item.tutorName}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            )),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
