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
  final String? postedBy; // User ID who posted the experience
  final String? postedByEmail; // Email of the user who posted

  Experience({
    required this.id,
    required this.companyName,
    required this.role,
    required this.studentName,
    required this.branch,
    required this.year,
    required this.experience,
    required this.rounds,
    this.postedBy,
    this.postedByEmail,
    this.tips,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    var postedByData = json['postedBy'];
    String? postedById;
    String? postedByEmail;

    if (postedByData != null) {
      if (postedByData is Map) {
        postedById = postedByData['_id']?.toString();
        postedByEmail = postedByData['email']?.toString();
      } else {
        postedById = postedByData.toString();
      }
    }

    return Experience(
      id: json['_id'].toString(),
      companyName: json['companyName'].toString(),
      role: json['role'].toString(),
      studentName: json['studentName'].toString(),
      branch: json['branch'].toString(),
      year: int.parse(json['year'].toString()),
      experience: json['experience'].toString(),
      rounds: List<String>.from(json['rounds'] ?? []),
      tips: json['tips']?.toString(),
      postedBy: postedById,
      postedByEmail: postedByEmail,
    );
  }
}
