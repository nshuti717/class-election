class Candidate {
  const Candidate({required this.name, this.votes = 0});

  final String name;
  final int votes;

  Candidate copyWith({String? name, int? votes}) =>
      Candidate(name: name ?? this.name, votes: votes ?? this.votes);

  Map<String, dynamic> toJson() => {'name': name, 'votes': votes};

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    name: json['name'] as String,
    votes: (json['votes'] as num?)?.toInt() ?? 0,
  );
}
