import 'package:flutter/foundation.dart';
import '../data/professions_data.dart'; // <-- استيراد المصدر الوحيد للبيانات
import '../models/profession_model.dart';

class ProfessionProvider with ChangeNotifier {
  // --- بداية التعديل: الاعتماد على مصدر واحد للبيانات ---
  final ProfessionsData _professionsData = ProfessionsData();
  
  // Getter بسيط للوصول إلى البيانات
  ProfessionsData get professionsData => _professionsData;

  // --- إعادة الدوال المساعدة التي تحتاجها الشاشات الأخرى ---

  List<Profession> getAllProfessions() {
    return _professionsData.getAllProfessions();
  }
  
  Profession? getProfessionByConceptKey(String conceptKey) {
    return _professionsData.getProfessionByConceptKey(conceptKey);
  }
  
  String getLocalizedProfessionName(String conceptKey, String dialect) {
    return _professionsData.getLocalizedProfessionName(conceptKey, dialect);
  }
  // --- نهاية التعديل ---
}
