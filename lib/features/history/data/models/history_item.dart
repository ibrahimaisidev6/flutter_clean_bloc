class HistoryItem {
  final int id;
  final String description;
  final DateTime date;

  HistoryItem({
    required this.id,
    required this.description,
    required this.date,
  });

  // Factory constructor should be inside the class
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      date: json['date'] != null 
          ? DateTime.tryParse(json['date']) ?? DateTime(1970, 1, 1)
          : DateTime(1970, 1, 1),
    );
  }

  // toJson method should also be inside the class
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Optional: Add copyWith method for easier updates
  HistoryItem copyWith({
    int? id,
    String? description,
    DateTime? date,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  // Optional: Add toString for debugging
  @override
  String toString() {
    return 'HistoryItem(id: $id, description: $description, date: $date)';
  }

  // Optional: Add equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryItem &&
        other.id == id &&
        other.description == description &&
        other.date == date;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ date.hashCode;
}