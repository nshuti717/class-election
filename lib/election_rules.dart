import 'models/candidate.dart';

String cleanElectionName(String input) => input
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
    .join(' ');

bool voterHasAlreadyVoted(String name, Iterable<String> voters) {
  final cleanedName = cleanElectionName(name).toLowerCase();
  return cleanedName.isNotEmpty &&
      voters.any(
        (voter) => cleanElectionName(voter).toLowerCase() == cleanedName,
      );
}

bool candidateNameExists(String name, Iterable<Candidate> candidates) {
  final cleanedName = cleanElectionName(name).toLowerCase();
  return cleanedName.isNotEmpty &&
      candidates.any(
        (candidate) => candidate.name.toLowerCase() == cleanedName,
      );
}

bool canRemoveCandidate(Candidate candidate) => candidate.votes == 0;
