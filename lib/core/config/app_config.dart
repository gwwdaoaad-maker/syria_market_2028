/// ملف التكوين والإعدادات الرسمي لمشروع (سوق سوريا)
/// يحتوي على مفاتيح الربط وقواعد البيانات وحسابات غرفة العمليات
class AppConfig {
  AppConfig._();

  // --- 1. هوية التطبيق الأساسية ---
  static const String appName = 'سوق سوريا';
  static const String appNameEn = 'Syria Market';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.syriamarket.app';

  // --- 2. إعدادات قاعدة البيانات والتخزين (Supabase) ---
  static const String supabaseUrl = 'https://zbjjkigkxbpktpmpcdqc.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ZZBI_vTK7ks1yfO2g3Zo0Q_Sg4QizEr';

  // --- 3. حسابات إدارة النظام / غرفة العمليات (Super Admins) ---
  static const String primaryAdminEmail = 'sameraoaad@gmail.com';
  static const String secondaryAdminEmail = 'aoaadabdo@gmail.com';

  /// قائمة الحسابات المصرح لها حصرياً بدخول لوحة الإدارة وتدقيق الإعلانات
  static const List<String> authorizedAdminEmails = [
    primaryAdminEmail,
    secondaryAdminEmail,
  ];

  /// التحقق البرمجي الدقيق من صلاحية الأدمن
  static bool isUserAuthorizedAdmin(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final normalizedEmail = email.trim().toLowerCase();
    return authorizedAdminEmails.any(
      (adminEmail) => adminEmail.toLowerCase() == normalizedEmail,
    );
  }

  // --- 4. جداول قاعدة البيانات المعتمدة في Supabase ---
  static const String tableProfiles = 'profiles';
  static const String tableAds = 'ads';
  static const String tableCategories = 'categories';
  static const String tableReports = 'reports';
  static const String bucketAdImages = 'ad_images';
}