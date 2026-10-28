import 'package:flutter/material.dart';

import '../models/candidate.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key, required this.candidates, required this.onVote});

  final List<Candidate> candidates;
  final String? Function(String voter, String candidate) onVote;

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final _nameController = TextEditingController();
  String? _selectedCandidate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitVote() {
    if (_selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a candidate first.')),
      );
      return;
    }
    final error = widget.onVote(_nameController.text, _selectedCandidate!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Your vote has been recorded.')),
    );
    if (error == null) _nameController.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cast your vote')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Your name', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Choose one candidate',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...widget.candidates.map(
          (candidate) => Card(
            child: RadioListTile<String>(
              value: candidate.name,
              groupValue: _selectedCandidate,
              title: Text(candidate.name),
              secondary: const Icon(Icons.how_to_vote_outlined),
              onChanged: (value) => setState(() => _selectedCandidate = value),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submitVote,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Submit vote'),
        ),
      ],
    ),
  );
}
