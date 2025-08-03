class FlowerCard {
  final String id;
  final String imagePath;
  final String generatedText;
  final String emotion;
  final String style;
  final int theme;
  final DateTime createdAt;
  final bool isFavorite;

  FlowerCard({
    required this.id,
    required this.imagePath,
    required this.generatedText,
    required this.emotion,
    required this.style,
    required this.theme,
    required this.createdAt,
    required this.isFavorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'generatedText': generatedText,
      'emotion': emotion,
      'style': style,
      'theme': theme,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory FlowerCard.fromMap(Map<String, dynamic> map) {
    return FlowerCard(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      generatedText: map['generatedText'] ?? '',
      emotion: map['emotion'] ?? '',
      style: map['style'] ?? '',
      theme: map['theme'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isFavorite: (map['isFavorite'] ?? 0) == 1,
    );
  }

  FlowerCard copyWith({
    String? id,
    String? imagePath,
    String? generatedText,
    String? emotion,
    String? style,
    int? theme,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return FlowerCard(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      generatedText: generatedText ?? this.generatedText,
      emotion: emotion ?? this.emotion,
      style: style ?? this.style,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}