import 'package:flutter/material.dart';

import '../election_rules.dart';
import '../models/candidate.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({
    super.key,
    required this.candidates,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Candidate> candidates;
  final String? Function(String name) onAdd;
  final bool Function(Candidate candidate) onRemove;

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  late List<Candidate> _candidates;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _candidates = List.of(widget.candidates);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final error = widget.onAdd(_controller.text);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final cleaned = cleanElectionName(_controller.text);
    setState(() => _candidates.add(Candidate(name: cleaned)));
    _controller.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Candidate added.')));
  }

  Future<void> _remove(Candidate candidate) async {
    if (candidate.votes > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A candidate with votes cannot be removed.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove candidate?'),
        content: Text('Remove ${candidate.name} from the election?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!widget.onRemove(candidate)) return;
    setState(
      () => _candidates.removeWhere((item) => item.name == candidate.name),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Candidate removed.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Candidates')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Candidate name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Add candidate',
              onPressed: _add,
              icon: const Icon(Icons.person_add_alt_1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._candidates.map(
          (candidate) => Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(candidate.name),
              subtitle: Text(
                candidate.votes == 0
                    ? 'No votes'
                    : '${candidate.votes} votes · cannot remove',
              ),
              trailing: IconButton(
                tooltip: candidate.votes > 0
                    ? 'Cannot remove a candidate with votes'
                    : 'Remove candidate',
                onPressed: candidate.votes > 0
                    ? null
                    : () => _remove(candidate),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
