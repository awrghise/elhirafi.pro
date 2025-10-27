class AppStrings {
  // عام
  static const String appName = 'الصانع الحرفي';
  static const String welcome = 'مرحباً بك';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String save = 'حفظ';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String settings = 'الإعدادات';
  static const String profile = 'الملف الشخصي';
  static const String logout = 'تسجيل الخروج';

  // التسجيل والدخول
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String theme = 'السمة';
  static const String changeLanguage = 'تغيير اللغة';
  static const String darkMode = 'الوضع الليلي';
  static const String lightMode = 'الوضع النهاري';
  static const String privacyPolicy = 'سياسة الخصوصية';
  static const String termsOfService = 'شروط الاستخدام';
  static const String aboutUs = 'من نحن';
  static const String contactUs = 'اتصل بنا';
  static const String shareApp = 'مشاركة التطبيق';
  static const String rateApp = 'تقييم التطبيق';
  static const String switchToClientMode = 'التحول إلى وضع العميل';
  static const String switchToCraftsmanMode = 'التحول إلى وضع الحرفي';
  static const String currentMode = 'الوضع الحالي';
  static const String clientMode = 'وضع العميل';
  static const String craftsmanMode = 'وضع الحرفي';
  static const String supplierMode = 'وضع المورد';  static const String phone = 'رقم الهاتف';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String dontHaveAccount = 'ليس لديك حساب؟';
  static const String alreadyHaveAccount = 'لديك حساب بالفعل؟';

  // أنواع المستخدمين
  static const String userType = 'نوع الحساب';
  static const String craftsman = 'أنا حرفي';
  static const String client = 'أبحث عن حرفي';
  static const String supplier = 'أنا مورد';

  // المهن
  static const String profession = 'الحرفة';
  static const String selectProfession = 'اختر حرفتك';
  static const List<String> professions = [
    'نجار', 'سباك', 'كهربائي', 'بنّاء', 'مليس', 'دهان', 'حداد', 'فني تكييف', 'فني ألمنيوم', 'فني جبس',
  ];
  static const String experienceYears = 'سنوات الخبرة';
  static const String workCities = 'المدن التي تعمل بها';
  static const String selectWorkCities = 'اختر المدن التي تعمل بها';
  static const String country = 'الدولة';
  static const String selectCountry = 'اختر دولتك';

  // الشاشة الرئيسية
  static const String home = 'الرئيسية';
  static const String requests = 'الطلبات';
  static const String chats = 'المحادثات';
  static const String availableCraftsmen = 'الحرفيون المتاحون';
  static const String suppliers = 'الموردون';
  static const String clientDashboardTitle = 'لوحة تحكم العميل';
  static const String craftsmanDashboardTitle = 'لوحة تحكم الحرفي';
  static const String makeNewRequest = 'إنشاء طلب جديد';
  static const String selectProfessionForRequest = 'اختر نوع الحرفي المطلوب';
  static const String enterCity = 'أدخل المدينة';
  static const String city = 'المدينة';
  static const String recordAudioRequest = 'سجل طلبك الصوتي';
  static const String submitRequest = 'إرسال الطلب';
  static const String requestSubmittedSuccessfully = 'تم إرسال طلبك بنجاح!';
  static const String craftsmanStatus = 'حالة الحرفي';
  static const String notAvailable = 'غير متاح للعمل';
  static const String viewMyProfessionProfile = 'عرض ملفي الشخصي كحرفي';
  static const String recentActivity = 'النشاطات الأخيرة';
  static const String noRecentActivityYet = 'لا يوجد نشاطات حديثة حتى الآن.';
  static const String clientDashboardWelcomeMessage = 'مرحباً بك! ابحث عن الحرفي المناسب لمشروعك';
  static const String craftsmanDashboardWelcomeMessage = 'مرحباً بك! استقبل طلبات العمل الجديدة';
  static const String selectCraftsmanType = 'اختر نوع الحرفي';
  static const String audioRecordedSuccessfully = 'تم تسجيل الصوت بنجاح';
  static const String dialect = 'اللهجة';
  static const String selectDialect = 'اختر لهجتك';
  static const String moroccan = 'مغربية';
  static const String algerian = 'جزائرية';
  static const String tunisian = 'تونسية';
  static const String recordAudio = 'تسجيل صوتي';
  static const String stopRecording = 'إيقاف التسجيل';
  static const String playAudio = 'تشغيل الصوت';
  static const String pauseAudio = 'إيقاف مؤقت';
  static const String deleteAudio = 'حذف التسجيل';
  static const String microphonePermissionMessage = 'يحتاج التطبيق إذن الوصول إلى الميكروفون لتسجيل الرسائل الصوتية';
  static const String grantPermission = 'منح الإذن';
  static const String directedTo = 'موجه إلى';
  static const String workStatus = 'حالة العمل';
  static const String availableForWork = 'متاح للعمل';
  static const String notAvailableForWork = 'غير متاح للعمل';
  static const String willReceiveJobAlerts = 'ستتلقى تنبيهات الطلبات الجديدة';
  static const String willNotReceiveJobAlerts = 'لن تتلقى تنبيهات الطلبات';
  static const String recentJobRequests = 'الطلبات الأخيرة';
  static const String viewAll = 'عرض الكل';
  static const String unknownUser = 'مستخدم غير معروف';
  static const String accountType = 'نوع الحساب';
  static const String notSpecified = 'غير محدد';
  static const String unknown = 'غير معروف';
  static const String available = 'متاح';
  static const String microphonePermissionDeniedMessage = 'تم رفض إذن الميكروفون. يرجى منح الإذن من إعدادات التطبيق.';

  // الطلبات
  static const String sendRequest = 'إرسال طلب';
  static const String recordAudioMessage = 'سجل رسالة صوتية';
  static const String addTextDescription = 'إضافة وصف نصي (اختياري)';
  static const String location = 'الموقع';
  static const String currentLocation = 'الموقع الحالي';
  static const String requestSent = 'تم إرسال الطلب بنجاح';
  static const String noRequestsFound = 'لا توجد طلبات حالياً';
  static const String currentRequests = 'الطلبات الحالية';
  static const String noRequestsYet = 'لا توجد طلبات حتى الآن.';
  static const String viewDetails = 'عرض التفاصيل';
  static const String acceptRequest = 'قبول الطلب';
  static const String declineRequest = 'رفض الطلب';
  static const String requestDetails = 'تفاصيل الطلب';
  static const String clientInfo = 'معلومات العميل';
  static const String requestStatus = 'حالة الطلب';
  static const String createdAt = 'تاريخ الإنشاء';
  static const String acceptedBy = 'تم القبول بواسطة';
  static const String yourRequests = 'طلباتك';
  static const String acceptedRequests = 'الطلبات المقبولة';
  static const String pendingRequests = 'الطلبات المعلقة';
  static const String declinedRequests = 'الطلبات المرفوضة';
  static const String allRequests = 'جميع الطلبات';

  // الحالة
  static const String status = 'الحالة';
  static const String busy = 'مشغول';
  static const String offline = 'غير متصل';
  static const String readyToWork = 'جاهز للعمل';
  
  // المحادثات
  static const String startChat = 'بدء محادثة';
  static const String typeMessage = 'اكتب رسالة...';
  static const String sendMessage = 'إرسال';
  static const String noChatsFound = 'لا توجد محادثات';
  static const String contact = 'تواصل';
  static const String chatWith = 'محادثة مع';
  static const String noMessages = 'لا توجد رسائل بعد.';
  static const String errorLoadingMessages = 'خطأ في تحميل الرسائل.';

  // الإعدادات
  static const String language = 'اللغة';
  static const String notifications = 'التنبيهات';
  static const String privacy = 'الخصوصية';
  static const String about = 'حول التطبيق';
  static const String version = 'الإصدار';
  static const String myProfile = 'ملفي الشخصي';
  static const String editProfile = 'تعديل الملف الشخصي';
  static const String updateProfile = 'تحديث الملف الشخصي';
  static const String myProfession = 'مهنتي';
  static const String myWorkCities = 'مدن عملي';
  static const String update = 'تحديث';
  static const String addProfession = 'إضافة مهنة';
  static const String selectYourProfession = 'اختر مهنتك';
  static const String selectYourCities = 'اختر مدنك';
  static const String saveChanges = 'حفظ التغييرات';
  static const String profileUpdatedSuccessfully = 'تم تحديث الملف الشخصي بنجاح!';
  static const String profileUpdateFailed = 'فشل تحديث الملف الشخصي.';
  static const String chooseImage = 'اختر صورة';
  static const String takePhoto = 'التقاط صورة';
  static const String chooseFromGallery = 'الاختيار من المعرض';
  static const String updatePhoto = 'تحديث الصورة';
  static const String deleteAccount = 'حذف الحساب';
  static const String confirmDeleteAccount = 'هل أنت متأكد أنك تريد حذف حسابك؟';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String accountDeleted = 'تم حذف الحساب بنجاح.';
  static const String accountDeletionFailed = 'فشل حذف الحساب.';

  // رسائل الخطأ
  static const String emailRequired = 'البريد الإلكتروني مطلوب';
  static const String passwordRequired = 'كلمة المرور مطلوبة';
  static const String nameRequired = 'الاسم مطلوب';
  static const String phoneRequired = 'رقم الهاتف مطلوب';
  static const String professionRequired = 'الحرفة مطلوبة';
  static const String workCitiesRequired = 'يجب اختيار مدينة واحدة على الأقل';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordsDoNotMatch = 'كلمات المرور غير متطابقة';
  static const String pleaseSelectUserType = 'الرجاء اختيار نوع المستخدم';
  static const String pleaseSelectProfession = 'الرجاء اختيار المهنة';
  static const String pleaseSelectAtLeastOneCity = 'الرجاء اختيار مدينة عمل واحدة على الأقل';
  static const String registrationSuccessful = 'تم التسجيل بنجاح!';
  static const String loginSuccessful = 'تم تسجيل الدخول بنجاح!';
  static const String somethingWentWrong = 'حدث خطأ ما. الرجاء المحاولة مرة أخرى.';
  static const String errorLoadingData = 'خطأ في تحميل البيانات.';
  static const String noDataAvailable = 'لا توجد بيانات متاحة.';
  static const String connectionError = 'خطأ في الاتصال بالإنترنت.';
  static const String noInternet = 'لا يوجد اتصال بالإنترنت.';
  static const String pleaseConnectToInternet = 'الرجاء الاتصال بالإنترنت والمحاولة مرة أخرى.';
  static const String unknownError = 'خطأ غير معروف';

  // الوقت
  static const String now = 'الآن';
  static const String minutesAgo = 'منذ دقائق';
  static const String hoursAgo = 'منذ ساعات';
  static const String daysAgo = 'منذ أيام';
  static const String expiresIn = 'ينتهي خلال';
  static const String expired = 'منتهي الصلاحية';
  static const String ok = 'موافق';
  static const String professionAndCityRequired = 'الرجاء اختيار المهنة ومدينة عمل واحدة على الأقل';

  // *** قائمة الدول والمدن المضافة ***
  static const Map<String, List<String>> citiesByCountry = {
    'المملكة العربية السعودية': [
      'الرياض', 'الدرعية', 'الخرج', 'الدوادمي', 'المجمعة', 'القويعية', 'الأفلاج', 'وادي الدواسر', 'الزلفي', 'شقراء', 'حوطة بني تميم', 'عفيف', 'الغاط', 'السليل', 'ضرما', 'المزاحمية', 'رماح', 'ثادق', 'حريملاء', 'الحريق', 'مرات',
      'مكة المكرمة', 'جدة', 'الطائف', 'القنفذة', 'الليث', 'رابغ', 'الجموم', 'الكامل', 'الخرمة', 'رنية', 'تربة', 'أضم', 'العرضيات', 'ميسان', 'بحرة',
      'المدينة المنورة', 'ينبع', 'العلا', 'المهد', 'الحناكية', 'بدر', 'خيبر', 'العيص', 'وادي الفرع',
      'بريدة', 'عنيزة', 'الرس', 'المذنب', 'البكيرية', 'البدائع', 'الأسياح', 'النبهانية', 'عيون الجواء', 'رياض الخبراء', 'الشماسية', 'عقلة الصقور',
      'الدمام', 'الأحساء', 'حفر الباطن', 'الجبيل', 'القطيف', 'الخبر', 'الخفجي', 'رأس تنورة', 'بقيق', 'النعيرية', 'قرية العليا', 'العديد',
      'أبها', 'خميس مشيط', 'بيشة', 'النماص', 'محايل عسير', 'ظهران الجنوب', 'تثليث', 'سراة عبيدة', 'رجال ألمع', 'بلقرن', 'أحد رفيدة', 'المجاردة', 'البرك', 'بارق', 'تنومة', 'طريب',
      'تبوك', 'الوجه', 'ضباء', 'تيماء', 'أملج', 'حقل', 'البدع',
      'حائل', 'بقعاء', 'الشنان', 'الغزالة', 'السليمي', 'موقق', 'الحائط', 'الشملي',
      'عرعر', 'رفحاء', 'طريف', 'العويقيلة',
      'جازان', 'صبيا', 'أبو عريش', 'صامطة', 'بيش', 'الدرب', 'الحرث', 'ضمد', 'الريث', 'فرسان', 'الدائر', 'العارضة', 'أحد المسارحة', 'العيدابي', 'فيفاء', 'الطوال', 'هروب',
      'نجران', 'شرورة', 'حبونا', 'بدر الجنوب', 'يدمة', 'ثار', 'خباش', 'الخرخير',
      'الباحة', 'بلجرشي', 'المندق', 'المخواة', 'قلوة', 'العقيق', 'القرى', 'غامد الزناد', 'الحجرة', 'بني حسن',
      'سكاكا', 'القريات', 'دومة الجندل', 'طبرجل',
    ],
    'جمهورية مصر العربية': [
      'القاهرة', 'الجيزة', 'الأسكندرية', 'الدقهلية', 'الشرقية', 'المنوفية', 'القليوبية', 'البحيرة', 'الغربية', 'بور سعيد', 'دمياط', 'الإسماعيلية', 'السويس', 'كفر الشيخ', 'الفيوم', 'بني سويف', 'المنيا', 'أسيوط', 'سوهاج', 'قنا', 'الأقصر', 'أسوان', 'البحر الأحمر', 'الوادي الجديد', 'مطروح', 'شمال سيناء', 'جنوب سيناء',
    ],
    'الإمارات العربية المتحدة': [
      'أبو ظبي', 'دبي', 'الشارقة', 'عجمان', 'أم القيوين', 'رأس الخيمة', 'الفجيرة', 'العين', 'خورفكان', 'دبا الحصن',
    ],
    'الكويت': [
      'الكويت العاصمة', 'الأحمدي', 'حولي', 'الجهراء', 'الفروانية', 'مبارك الكبير', 'السالمية',
    ],
    'قطر': [
      'الدوحة', 'الريان', 'الوكرة', 'الخور', 'أم صلال', 'الشحانية', 'الظعاين', 'مسيعيد',
    ],
    'البحرين': [
      'المنامة', 'المحرق', 'الرفاع', 'مدينة حمد', 'عيسى', 'سترة', 'جد حفص',
    ],
    'سلطنة عمان': [
      'مسقط', 'صلالة', 'صحار', 'نزوى', 'صور', 'البريمي', 'عبري', 'السيب', 'بوشر',
    ],
    'الأردن': [
      'عمان', 'الزرقاء', 'إربد', 'العقبة', 'السلط', 'الكرك', 'معان', 'مأدبا', 'جرش', 'عجلون', 'الطفيلة',
    ],
    'لبنان': [
      'بيروت', 'طرابلس', 'صيدا', 'صور', 'النبطية', 'بعلبك', 'زحلة', 'جونيه',
    ],
    'سوريا': [
      'دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'دير الزور', 'الرقة', 'إدلب', 'السويداء', 'درعا', 'طرطوس', 'الحسكة', 'القنيطرة',
    ],
    'العراق': [
      'بغداد', 'الموصل', 'البصرة', 'أربيل', 'النجف', 'كربلاء', 'كركوك', 'السليمانية', 'الناصرية', 'الحلة', 'الرمادي', 'بعقوبة', 'دهوك',
    ],
    'اليمن': [
      'صنعاء', 'عدن', 'تعز', 'الحديدة', 'المكلا', 'إب', 'ذمار', 'عمران', 'سيئون',
    ],
    'فلسطين': [
      'القدس', 'غزة', 'رام الله', 'نابلس', 'الخليل', 'جنين', 'طولكرم', 'بيت لحم', 'أريحا',
    ],
    'ليبيا': [
      'طرابلس', 'بنغازي', 'مصراتة', 'البيضاء', 'الزاوية', 'طبرق', 'سبها', 'درنة', 'سرت',
    ],
    'تونس': [
      'تونس', 'صفاقس', 'سوسة', 'القيروان', 'بنزرت', 'قابس', 'أريانة', 'قفصة', 'المنستير',
    ],
    'الجزائر': [
      'الجزائر العاصمة', 'وهران', 'قسنطينة', 'عنابة', 'سطيف', 'باتنة', 'تلمسان', 'سكيكدة', 'بجاية', 'تيزي وزو', 'ورقلة',
    ],
    'المغرب': [
      'الدار البيضاء', 'الرباط', 'فاس', 'مراكش', 'أكادير', 'طنجة', 'مكناس', 'وجدة', 'القنيطرة', 'تطوان', 'العيون',
    ],
    'السودان': [
      'الخرطوم', 'أم درمان', 'بورتسودان', 'كسلا', 'الأبيض', 'كوستي', 'ود مدني', 'القضارف', 'الفاشر',
    ],
    'موريتانيا': [
      'نواكشوط', 'نواذيبو', 'كيهيدي', 'روصو', 'أطار', 'الزويرات',
    ],
    'الصومال': [
      'مقديشو', 'هرجيسا', 'بوصاصو', 'كيسمايو', 'مركا', 'بيدوا',
    ],
    'جيبوتي': [
      'جيبوتي العاصمة', 'علي صبيح', 'تاجورة', 'أبخ', 'دخيل',
    ],
    'جزر القمر': [
      'موروني', 'موتسامودو', 'فومبوني',
    ],
  };
}
