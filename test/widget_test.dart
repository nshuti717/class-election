import 'package:class_election/election_rules.dart';
import 'package:class_election/models/candidate.dart';
import 'package:class_election/screens/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('election name rules', () {
    test('cleans names before storing and comparing voters', () {
      final voters = <String>[];
      final cleaned = cleanElectionName('  aLINE ');
      expect(cleaned, 'Aline');
      expect(voterHasAlreadyVoted(cleaned, voters), isFalse);
      voters.add(cleaned);
      expect(voterHasAlreadyVoted('Aline', voters), isTrue);
    });

    test('rejects a cleaned duplicate candidate', () {
      final candidates = [const Candidate(name: 'Keza')];
      expect(
        candidateNameExists(cleanElectionName(' keza '), candidates),
        isTrue,
      );
    });

    test('a candidate with votes cannot be removed', () {
      expect(
        canRemoveCandidate(const Candidate(name: 'Aline', votes: 1)),
        isFalse,
      );
      expect(canRemoveCandidate(const Candidate(name: 'Keza')), isTrue);
    });
  });

  testWidgets('shows percentages and a tie for 4, 4, and 1 votes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsScreen(
          candidates: const [
            Candidate(name: 'Aline', votes: 4),
            Candidate(name: 'Keza', votes: 4),
            Candidate(name: 'Eric', votes: 1),
          ],
          onReset: () async => false,
        ),
      ),
    );

    expect(find.text('44.4%'), findsNWidgets(2));
    expect(find.text('11.1%'), findsOneWidget);
    expect(find.textContaining('tie between Aline and Keza'), findsOneWidget);
  });

  testWidgets('shows No votes yet before the first vote', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultsScreen(
          candidates: const [
            Candidate(name: 'Aline'),
            Candidate(name: 'Keza'),
          ],
          onReset: () async => false,
        ),
      ),
    );

    expect(find.text('No votes yet'), findsOneWidget);
  });
}
