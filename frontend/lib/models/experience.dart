class Experience {
  final String id;
  final String companyName;
  final String role;
  final String studentName;
  final String branch;
  final int year;
  final String experience;
  final List<String> rounds;
  final String? tips;

  Experience({
    required this.id,
    required this.companyName,
    required this.role,
    required this.studentName,
    required this.branch,
    required this.year,
    required this.experience,
    required this.rounds,
    this.tips,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['_id'],
      companyName: json['companyName'],
      role: json['role'],
      studentName: json['studentName'],
      branch: json['branch'],
      year: json['year'],
      experience: json['experience'],
      rounds: List<String>.from(json['rounds']),
      tips: json['tips'],
    );
  }
}
