import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/candidate.dart';
import 'models/weather.dart';
import 'election_rules.dart';
import 'screens/candidates_screen.dart';
import 'screens/results_screen.dart';
import 'screens/vote_screen.dart';
import 'weather.dart';

void main() => runApp(const ClassElectionApp());

class ClassElectionApp extends StatelessWidget {
  const ClassElectionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Class Election',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
      scaffoldBackgroundColor: const Color(0xFFF5F8F7),
      useMaterial3: true,
      cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.zero),
    ),
    home: const ElectionHomeScreen(),
  );
}

class ElectionHomeScreen extends StatefulWidget {
  const ElectionHomeScreen({super.key});

  @override
  State<ElectionHomeScreen> createState() => _ElectionHomeScreenState();
}

class _ElectionHomeScreenState extends State<ElectionHomeScreen> {
  static const _candidatesKey = 'election_candidates';
  static const _votersKey = 'election_voters';
  static const _sampleCandidates = ['Aline', 'Keza', 'Eric'];

  List<Candidate> _candidates = [];
  List<String> _voters = [];
  bool _dataLoading = true;
  bool _weatherLoading = true;
  String? _weatherError;
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _loadElectionData();
    _loadWeather();
  }

  Future<void> _loadElectionData() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final candidateJson = preferences.getString(_candidatesKey);
      final voterJson = preferences.getString(_votersKey);
      final loadedCandidates = candidateJson == null
          ? _sampleCandidates.map((name) => Candidate(name: name)).toList()
          : (jsonDecode(candidateJson) as List)
                .map((item) => Candidate.fromJson(item as Map<String, dynamic>))
                .toList();
      final loadedVoters = voterJson == null
          ? <String>[]
          : (jsonDecode(voterJson) as List).cast<String>();
      if (!mounted) return;
      setState(() {
        _candidates = loadedCandidates;
        _voters = loadedVoters;
        _dataLoading = false;
      });
      if (candidateJson == null || voterJson == null) await _saveElectionData();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _candidates = _sampleCandidates
            .map((name) => Candidate(name: name))
            .toList();
        _voters = [];
        _dataLoading = false;
      });
      await _saveElectionData();
    }
  }

  Future<void> _saveElectionData() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _candidatesKey,
      jsonEncode(_candidates.map((candidate) => candidate.toJson()).toList()),
    );
    await preferences.setString(_votersKey, jsonEncode(_voters));
  }

  Future<void> _loadWeather() async {
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
      _weather = null;
    });
    try {
      final result = await fetchWeather();
      if (!mounted) return;
      setState(() {
        _weather = result;
        _weatherLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _weatherError =
            'Could not load the weather. Check your internet connection.';
        _weatherLoading = false;
      });
    }
  }

  String? castVote(String voterName, String candidateName) {
    final voter = cleanElectionName(voterName);
    if (voter.isEmpty) return 'Enter your name before voting.';
    if (voterHasAlreadyVoted(voter, _voters)) {
      return 'You have already voted.';
    }
    final candidateIndex = _candidates.indexWhere(
      (c) => c.name == candidateName,
    );
    if (candidateIndex < 0) return 'Choose a valid candidate.';
    _candidates[candidateIndex] = _candidates[candidateIndex].copyWith(
      votes: _candidates[candidateIndex].votes + 1,
    );
    _voters.add(voter);
    setState(() {});
    _saveElectionData();
    return null;
  }

  String? addCandidate(String rawName) {
    final name = cleanElectionName(rawName);
    if (name.isEmpty) return 'Candidate name cannot be empty.';
    if (candidateNameExists(name, _candidates)) {
      return 'That candidate already exists.';
    }
    setState(() => _candidates.add(Candidate(name: name)));
    _saveElectionData();
    return null;
  }

  bool removeCandidate(Candidate candidate) {
    if (!canRemoveCandidate(candidate)) return false;
    setState(
      () => _candidates.removeWhere((item) => item.name == candidate.name),
    );
    _saveElectionData();
    return true;
  }

  Future<bool> resetVotes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all votes?'),
        content: const Text('This clears every vote and voter record.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset votes'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    setState(() {
      _candidates = _candidates
          .map((candidate) => candidate.copyWith(votes: 0))
          .toList();
      _voters.clear();
    });
    await _saveElectionData();
    return true;
  }

  void _open(Widget screen) =>
      Navigator.push<void>(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final totalVotes = _candidates.fold<int>(
      0,
      (sum, candidate) => sum + candidate.votes,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Election',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh weather',
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Choose your class representative',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Every student gets one vote.'),
                const SizedBox(height: 20),
                _weatherSection(),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.how_to_vote_outlined),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_candidates.length} candidates',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text('$totalVotes votes cast'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _actionTile(
                  Icons.how_to_vote,
                  'Vote',
                  'Cast your confidential class vote',
                  () => _open(
                    VoteScreen(
                      candidates: List.of(_candidates),
                      onVote: castVote,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  Icons.poll_outlined,
                  'Results',
                  'View the current standings',
                  () => _open(
                    ResultsScreen(
                      candidates: List.of(_candidates),
                      onReset: resetVotes,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _actionTile(
                  Icons.people_alt_outlined,
                  'Candidates',
                  'Manage the candidate list',
                  () => _open(
                    CandidatesScreen(
                      candidates: List.of(_candidates),
                      onAdd: addCandidate,
                      onRemove: removeCandidate,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _weatherSection() {
    if (_weatherLoading) {
      return const Card(
        child: SizedBox(
          height: 126,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_weatherError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, size: 32),
              const SizedBox(width: 12),
              Expanded(child: Text(_weatherError!)),
              TextButton.icon(
                onPressed: _loadWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_weatherLoading == false && _weatherError == null && _weather != null) {
      final weather = _weather!;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kigali weather',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${weather.temperature.round()}°C · ${weather.description}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  Text('Humidity ${weather.humidity}%'),
                  Text('Wind ${weather.wind.toStringAsFixed(1)} km/h'),
                  Text('Updated ${weather.time.replaceFirst('T', ' ')}'),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
