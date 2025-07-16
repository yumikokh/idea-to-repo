class Repository {
  final String name;
  final String description;
  final bool isPrivate;
  final String? ideaId;

  Repository({
    required this.name,
    required this.description,
    this.isPrivate = false,
    this.ideaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'private': isPrivate,
      'auto_init': true,
    };
  }
}