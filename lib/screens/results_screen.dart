import 'package:flutter/material.dart';

import '../models/candidate.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.candidates,
    required this.onReset,
  });

  final List<Candidate> candidates;
  final Future<bool> Function() onReset;

  @override
  Widget build(BuildContext context) {
    final ranked = [...candidates]..sort((a, b) => b.votes.compareTo(a.votes));
    final totalVotes = ranked.fold<int>(
      0,
      (total, candidate) => total + candidate.votes,
    );
    final leaders = ranked.isEmpty || totalVotes == 0
        ? <Candidate>[]
        : ranked
              .where((candidate) => candidate.votes == ranked.first.votes)
              .toList();
    final isTie = leaders.length > 1 && ranked.first.votes > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Election results')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (totalVotes == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Center(
                  child: Text(
                    'No votes yet',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          else
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(isTie ? Icons.balance : Icons.emoji_events_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTie
                            ? 'It’s a tie between ${leaders.map((candidate) => candidate.name).join(' and ')}!'
                            : '${leaders.first.name} is leading!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          ...ranked.map((candidate) {
            final percentage = totalVotes == 0
                ? 0.0
                : candidate.votes * 100 / totalVotes;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('${percentage.toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: totalVotes == 0 ? 0 : candidate.votes / totalVotes,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${candidate.votes} ${candidate.votes == 1 ? 'vote' : 'votes'}',
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              if (await onReset() && context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset votes'),
          ),
        ],
      ),
    );
  }
}
