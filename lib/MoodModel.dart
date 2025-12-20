class MoodModel {
  final int id;
  final int userId; // 1. Added userId field
  final int scale;
  final String title;
  final String description;
  final String createdOn;
  final int isFavorite; // 1 true; 0 false

  MoodModel({
    required this.id,
    required this.userId, // 2. Updated constructor
    required this.scale,
    required this.title,
    required this.description,
    required this.createdOn,
    this.isFavorite = 0,
  });

  factory MoodModel.fromJson(Map<String, dynamic> data) => MoodModel(
    id: data['id'] ?? 0,
    userId: data['userId'] ?? 0, // 3. Added userId to fromJson
    scale: data['scale'] ?? 3,
    title: data['title']?.toString() ?? '',
    description: data['description'] ?? '',
    createdOn: data['createdOn']?.toString() ?? '',
    isFavorite: data['isFavorite'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id == 0 ? null : id,
    'userId': userId, // 4. Added userId to toMap
    'scale': scale,
    'title': title,
    'description': description,
    'createdOn': createdOn,
    'isFavorite': isFavorite,
  };
}