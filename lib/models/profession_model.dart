// هذا الملف هو المصدر الوحيد لكل ما يتعلق بالمهن

class Profession {
  final String id;
  final String conceptKey;
  final Map<String, String> dialectNames;
  final String category;
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

  String getNameByDialect(String dialect) {
    return dialectNames[dialect] ?? dialectNames['AR'] ?? conceptKey;
  }
}

// --- بداية الدمج: نقل كلاس البيانات إلى هنا ---
class ProfessionsData {
  final List<Profession> professions = [
    Profession(
      id: 'building',
      conceptKey: 'building',
      dialectNames: {'MA': 'بناي', 'DZ': 'ماصو', 'TN': 'بنّاي', 'AR': 'بناء'},
      category: 'construction',
      description: 'أعمال البناء والخرسانة',
    ),
    Profession(
      id: 'tiling',
      conceptKey: 'tiling',
      dialectNames: {'MA': 'زلايجي', 'DZ': 'كارلور', 'TN': 'بلانجي', 'AR': 'بلاط'},
      category: 'construction',
      description: 'أعمال البلاط والزليج',
    ),
    Profession(
      id: 'plastering',
      conceptKey: 'plastering',
      dialectNames: {'MA': 'جباص', 'DZ': 'جباص', 'TN': 'جباص', 'AR': 'جبس'},
      category: 'construction',
      description: 'أعمال الجبس والتجصيص',
    ),
    Profession(
      id: 'gypsum_carving',
      conceptKey: 'gypsum_carving',
      dialectNames: {'MA': 'نقاش', 'DZ': 'سكيلتور', 'TN': 'نقاش', 'AR': 'نقش الجبس'},
      category: 'decoration',
      description: 'النقش على الجبس',
    ),
    Profession(
      id: 'gypsum_molds',
      conceptKey: 'gypsum_molds',
      dialectNames: {'MA': 'سطافور', 'DZ': 'سطافور', 'TN': 'سطافور', 'AR': 'صانع قوالب الجبس'},
      category: 'decoration',
      description: 'صناعة قوالب الجبس',
    ),
    Profession(
      id: 'electrical',
      conceptKey: 'electrical',
      dialectNames: {'MA': 'تريسيان', 'DZ': 'تريسيان', 'TN': 'تريسيان', 'AR': 'كهرباء'},
      category: 'technical',
      description: 'أعمال الكهرباء',
    ),
    Profession(
      id: 'plumbing',
      conceptKey: 'plumbing',
      dialectNames: {'MA': 'پلومبيي', 'DZ': 'پلومبيي', 'TN': 'بلومبيي', 'AR': 'سباكة'},
      category: 'technical',
      description: 'أعمال السباكة والترصيص',
    ),
    Profession(
      id: 'carpentry',
      conceptKey: 'carpentry',
      dialectNames: {'MA': 'نجار', 'DZ': 'نجار', 'TN': 'نجّار', 'AR': 'نجارة'},
      category: 'woodwork',
      description: 'أعمال النجارة (خشب وألومنيوم)',
    ),
    Profession(
      id: 'wood_carving',
      conceptKey: 'wood_carving',
      dialectNames: {'MA': 'نقاش خشب', 'DZ': 'نقاش خشب', 'TN': 'نقاش خشب', 'AR': 'نقش الخشب'},
      category: 'decoration',
      description: 'النقش على الخشب',
    ),
    Profession(
      id: 'glasswork',
      conceptKey: 'glasswork',
      dialectNames: {'MA': 'زجاج', 'DZ': 'زجاج', 'TN': 'زجاج', 'AR': 'زجاج'},
      category: 'technical',
      description: 'أعمال الزجاج',
    ),
    Profession(
      id: 'metalwork',
      conceptKey: 'metalwork',
      dialectNames: {'MA': 'سودور', 'DZ': 'سودور', 'TN': 'حدّاد', 'AR': 'حدادة'},
      category: 'metalwork',
      description: 'أعمال الحدادة واللحام',
    ),
    Profession(
      id: 'painting',
      conceptKey: 'painting',
      dialectNames: {'MA': 'صباغ', 'DZ': 'پانتر', 'TN': 'دهّان', 'AR': 'صباغة'},
      category: 'decoration',
      description: 'أعمال الصباغة والدهان',
    ),
    Profession(
      id: 'facade_decoration',
      conceptKey: 'facade_decoration',
      dialectNames: {'MA': 'معلم فرصاضة', 'DZ': 'معلم لا فاصاد', 'TN': 'معلم واجهات', 'AR': 'تهيئة الواجهات'},
      category: 'decoration',
      description: 'تهيئة وتزيين واجهات المنازل (كريفي، موشتي، باسطا، مونوكوش، ترافيرتينو)',
    ),
    Profession(
      id: 'apprentice',
      conceptKey: 'apprentice',
      dialectNames: {'MA': 'خدام', 'DZ': 'خدام متعلم', 'TN': 'خدام', 'AR': 'متعلم حرفي'},
      category: 'helper',
      description: 'مساعد حرفي / متعلم',
    ),
    Profession(
      id: 'day_laborer',
      conceptKey: 'day_laborer',
      dialectNames: {'MA': 'عطَّاش', 'DZ': 'لياطاش', 'TN': 'عامل', 'AR': 'عامل يومي'},
      category: 'helper',
      description: 'عامل يومي / بالمهمة (حمل المواد، أعمال الفورفي)',
    ),
  ];

  List<Profession> getAllProfessions() {
    return professions;
  }

  List<Profession> getProfessionsByDialect(String dialect) {
    return professions.where((p) => p.dialectNames.containsKey(dialect)).toList();
  }

  Profession? findProfessionByName(String name, String dialect) {
    try {
      return professions.firstWhere((p) => p.getNameByDialect(dialect).toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  Profession? getProfessionByConceptKey(String conceptKey) {
    try {
      return professions.firstWhere((p) => p.conceptKey == conceptKey);
    } catch (e) {
      return null;
    }
  }

  String getLocalizedProfessionName(String conceptKey, String dialect) {
    final profession = getProfessionByConceptKey(conceptKey);
    return profession?.getNameByDialect(dialect) ?? conceptKey;
  }
}
// --- نهاية الدمج ---
