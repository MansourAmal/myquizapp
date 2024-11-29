class Category {
  final int id;
  final String name;
  final String description;
  final DateTime createdDate;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
