class TriggerWord {
  final String id;
  final String word;
  final String language;
  final bool isActive;

  const TriggerWord({
    required this.id,
    required this.word,
    required this.language,
    this.isActive = true,
  });

  TriggerWord copyWith({bool? isActive}) {
    return TriggerWord(
      id: id,
      word: word,
      language: language,
      isActive: isActive ?? this.isActive,
    );
  }

  factory TriggerWord.fromJson(Map<String, dynamic> json) {
    return TriggerWord(
      id: json['id'] as String,
      word: json['word'] as String,
      language: json['language'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'language': language,
      'is_active': isActive,
    };
  }
}
