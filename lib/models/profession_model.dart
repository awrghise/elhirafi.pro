// تم حذف كلاس ProfessionsData المكرر بالكامل من هذا الملف

class Profession {
  final String id;
  final String conceptKey; // المفهوم العام للمهنة (building, plumbing, etc.)
  final Map<String, String> dialectNames; // أسماء المهنة بكل لهجة
  final String category; // فئة المهنة (construction, decoration, etc.)
  final String description;
  final bool isActive;

  Profession({
    required this.id,
    required this.conceptKey,
    required this.dialectNames,
    required this.category,
    required this.description,
    this.isActive = true,
  });

  factory Profession.fromMap(Map<String, dynamic> map) {
    return Profession(
      id: map['id'] ?? '',
      conceptKey: map['conceptKey'] ?? '',
      dialectNames: Map<String, String>.from(map['dialectNames'] ?? {}),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conceptKey': conceptKey,
      'dialectNames': dialectNames,
      'category': category,
      'description': description,
      'isActive': isActive,
    };
  }

  // الحصول على اسم المهنة باللهجة المحددة
  String getNameByDialect(String dialect) {
    return dialectNames[dialect] ?? dialectNames['AR'] ?? conceptKey;
  }
}
