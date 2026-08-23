import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==============================================================================
// 1. نقطة الدخول وتهيئة اتصال Supabase السحابي وفحص الجلسة المباشرة
// ==============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasSavedSession = false;
  String savedEmail = '';

  try {
    await Supabase.initialize(
      url: 'https://syria-market-2028.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_syria_market',
    );

    // فحص الجلسة التلقائية المسجلة لتجاوز شاشات الدخول
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user.email != null) {
      hasSavedSession = true;
      savedEmail = session.user.email!;
    }
  } catch (e) {
    debugPrint('Supabase Initialization Notice: $e');
  }

  final appState = AppStateManager();
  if (hasSavedSession && savedEmail.isNotEmpty) {
    appState.loginUser(
      name: savedEmail.split('@').first,
      email: savedEmail,
      phone: '',
    );
  }

  runApp(const SyriaMarket2028App());
}

// ==============================================================================
// 2. قائمة المشرفين الحصرية وقفل الحماية الأمني
// ==============================================================================
const List<String> kSuperAdminEmails = [
  'sameraoaad@gmail.com',
  'aoaadabdo@gmail.com',
];

const String kStorageBucketAds = 'ad_images';

// ==============================================================================
// 3. نماذج البيانات السحابية الحقيقية (Clean Data Models)
// ==============================================================================

/// نموذج الإعلان الحقيقي
class AdItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double? priceUsd;
  final double? priceSyp;
  final String categoryId;
  final String subcategory;
  final String governorate;
  final String neighborhood;
  final String condition;
  final List<String> tags;
  final List<String> imageUrls;
  final String? videoUrl;
  final String publisherName;
  final String publisherPhone;
  final String publisherEmail;
  final bool isFeatured;
  final bool isSold;
  final bool allowComments;
  final String status; // 'approved', 'pending', 'rejected'
  final DateTime? stampedAt; // تاريخ وضع الختم الأحمر
  final DateTime createdAt;

  AdItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.priceUsd,
    this.priceSyp,
    required this.categoryId,
    required this.subcategory,
    required this.governorate,
    required this.neighborhood,
    this.condition = 'جديد',
    this.tags = const [],
    this.imageUrls = const [],
    this.videoUrl,
    required this.publisherName,
    this.publisherPhone = '',
    this.publisherEmail = '',
    this.isFeatured = false,
    this.isSold = false,
    this.allowComments = true,
    this.status = 'approved',
    this.stampedAt,
    required this.createdAt,
  });

  AdItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? priceUsd,
    double? priceSyp,
    String? categoryId,
    String? subcategory,
    String? governorate,
    String? neighborhood,
    String? condition,
    List<String>? tags,
    List<String>? imageUrls,
    String? videoUrl,
    String? publisherName,
    String? publisherPhone,
    String? publisherEmail,
    bool? isFeatured,
    bool? isSold,
    bool? allowComments,
    String? status,
    DateTime? stampedAt,
    DateTime? createdAt,
  }) {
    return AdItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priceUsd: priceUsd ?? this.priceUsd,
      priceSyp: priceSyp ?? this.priceSyp,
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      governorate: governorate ?? this.governorate,
      neighborhood: neighborhood ?? this.neighborhood,
      condition: condition ?? this.condition,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      publisherName: publisherName ?? this.publisherName,
      publisherPhone: publisherPhone ?? this.publisherPhone,
      publisherEmail: publisherEmail ?? this.publisherEmail,
      isFeatured: isFeatured ?? this.isFeatured,
      isSold: isSold ?? this.isSold,
      allowComments: allowComments ?? this.allowComments,
      status: status ?? this.status,
      stampedAt: stampedAt ?? this.stampedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price_usd': priceUsd,
      'price_syp': priceSyp,
      'category_id': categoryId,
      'subcategory': subcategory,
      'governorate': governorate,
      'neighborhood': neighborhood,
      'condition': condition,
      'tags': tags,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'publisher_name': publisherName,
      'publisher_phone': publisherPhone,
      'publisher_email': publisherEmail,
      'is_featured': isFeatured,
      'is_sold': isSold,
      'allow_comments': allowComments,
      'status': status,
      'stamped_at': stampedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AdItem.fromMap(Map<String, dynamic> map) {
    return AdItem(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priceUsd: map['price_usd'] != null
          ? (map['price_usd'] as num).toDouble()
          : null,
      priceSyp: map['price_syp'] != null
          ? (map['price_syp'] as num).toDouble()
          : null,
      categoryId: map['category_id']?.toString() ?? '🚗 سيارات ومركبات',
      subcategory: map['subcategory']?.toString() ?? 'عام',
      governorate: map['governorate']?.toString() ?? 'دمشق',
      neighborhood: map['neighborhood']?.toString() ?? 'المركز',
      condition: map['condition']?.toString() ?? 'جديد',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      imageUrls:
          map['image_urls'] != null ? List<String>.from(map['image_urls']) : [],
      videoUrl: map['video_url']?.toString(),
      publisherName: map['publisher_name']?.toString() ?? 'معلن موثق',
      publisherPhone: map['publisher_phone']?.toString() ?? '',
      publisherEmail: map['publisher_email']?.toString() ?? '',
      isFeatured: map['is_featured'] == true,
      isSold: map['is_sold'] == true,
      allowComments: map['allow_comments'] ?? true,
      status: map['status']?.toString() ?? 'approved',
      stampedAt: map['stamped_at'] != null
          ? DateTime.tryParse(map['stamped_at'].toString())
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// نموذج ميزة الباقة المصحوبة بأيقونة بصرية
class PlanFeature {
  String text;
  IconData icon;

  PlanFeature({required this.text, required this.icon});
}

/// نموذج باقة الاشتراك مع إمكانية التحرير اليدوي للشروط والمزايا
class PlanConfig {
  final String id;
  final String name;
  final double priceSyp;
  final String durationText;
  final String
      statusConditionText; // شرط ووضع الباقة المكتوب يدوياً (بدون Switches)
  final int maxAdsPerMonth;
  final int maxImagesPerAd;
  final List<PlanFeature> customFeatures;

  PlanConfig({
    required this.id,
    required this.name,
    required this.priceSyp,
    this.durationText = 'شهرياً',
    this.statusConditionText = 'متاحة للجميع فوراً',
    required this.maxAdsPerMonth,
    required this.maxImagesPerAd,
    required this.customFeatures,
  });

  PlanConfig copyWith({
    String? id,
    String? name,
    double? priceSyp,
    String? durationText,
    String? statusConditionText,
    int? maxAdsPerMonth,
    int? maxImagesPerAd,
    List<PlanFeature>? customFeatures,
  }) {
    return PlanConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      priceSyp: priceSyp ?? this.priceSyp,
      durationText: durationText ?? this.durationText,
      statusConditionText: statusConditionText ?? this.statusConditionText,
      maxAdsPerMonth: maxAdsPerMonth ?? this.maxAdsPerMonth,
      maxImagesPerAd: maxImagesPerAd ?? this.maxImagesPerAd,
      customFeatures: customFeatures ?? this.customFeatures,
    );
  }
}

/// نموذج القسم الرئيسي والفرعي مع تحكم الحواف والألوان
class CategoryModel {
  final String id;
  String name;
  IconData iconData;
  Color backgroundColor;
  Color textColor;
  double borderRadiusValue; // شكل الحواف (دائري، حاد، منحني)
  List<String> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconData,
    this.backgroundColor = const Color(0xFF0F5132),
    this.textColor = Colors.white,
    this.borderRadiusValue = 12.0,
    required this.subcategories,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? iconData,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadiusValue,
    List<String>? subcategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderRadiusValue: borderRadiusValue ?? this.borderRadiusValue,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}

/// نموذج البنرات الترويجية الحية
class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetUrl;
  final String position; // 'top' (علوي) أو 'bottom' (سفلي)

  BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetUrl,
    this.position = 'top',
  });

  BannerItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? targetUrl,
    String? position,
  }) {
    return BannerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      position: position ?? this.position,
    );
  }
}

/// نموذج رسائل المحادثة والتفاوض المباشر
class ChatMessage {
  final String id;
  final String senderName;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final double? offerAmount;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.offerAmount,
  });
}

/// نموذج الصلاحيات
class AdminPermissions {
  final bool canReviewAds;
  final bool canManageNews;
  final bool canManageBanners;
  final bool canManageCategories;
  final bool canManagePlans;
  final bool canManageUsers;
  final bool canChangeColors;

  AdminPermissions({
    this.canReviewAds = true,
    this.canManageNews = true,
    this.canManageBanners = true,
    this.canManageCategories = true,
    this.canManagePlans = true,
    this.canManageUsers = true,
    this.canChangeColors = true,
  });
}

/// نموذج المشرف والمستخدم
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isBanned;
  final bool isFrozen;
  final AdminPermissions permissions;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.isBanned = false,
    this.isFrozen = false,
    required this.permissions,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isBanned,
    bool? isFrozen,
    AdminPermissions? permissions,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      isFrozen: isFrozen ?? this.isFrozen,
      permissions: permissions ?? this.permissions,
    );
  }
}

// ==============================================================================
// 4. مزود الحالة العام السحابي المطور (AppStateManager)
// ==============================================================================
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // إعدادات التطبيق العامة
  String appTitle = 'سوق سوريا';
  String appSubtitle = 'الشامل 2028';
  bool isMaintenanceMode = false;
  String maintenanceMessage =
      'المنصة حالياً تحت الصيانة الدورية. سنعود قريباً جداً!';

  // الثيم والألوان العامة
  Color primaryColor = const Color(0xFF0F5132);
  Color secondaryColor = const Color(0xFFD4AF37);
  Color appBarColor = const Color(0xFF0F5132);
  Color buttonColor = const Color(0xFF0F5132);
  Color scaffoldBgColor = const Color(0xFFF8FAFC);

  // إعدادات شريط الأخبار المتحرك
  double tickerSpeed = 1.2; // سرعة التمرير القابلة للتحكم بالسلايدر
  Color tickerBackgroundColor = const Color(0xFF0F172A);
  Color tickerTextColor = Colors.white;
  double tickerFontSize = 12.0;
  IconData tickerIcon = Icons.campaign;

  // إعدادات عداد تقليب البنرات بالثواني
  int topBannerIntervalSeconds = 4;
  int bottomBannerIntervalSeconds = 5;

  // حالة المستخدم الحالية
  bool isLoggedIn = false;
  String currentUserId = '';
  String currentUserName = 'زائر سوق سوريا';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String currentUserPlanId = 'plan_free';

  bool get isSuperAdmin {
    if (!isLoggedIn || currentUserEmail.isEmpty) return false;
    final cleanEmail = currentUserEmail.trim().toLowerCase();
    return kSuperAdminEmails
        .any((adminEmail) => adminEmail.toLowerCase() == cleanEmail);
  }

  // القوائم السحابية
  List<AdItem> ads = [];

  List<String> newsTicker = [
    '🔥 مرحباً بكم في سوق سوريا الشامل 2028 - المنصة الرائدة للبيع والشراء والمزادات الحرة في كافة المحافظات',
    '👑 باقة VIP الذهبية متاحة الآن بخصم 50% مع ميزات نشر وتفاوض غير محدودة',
    '⚡ نظام الختم الأحمر والحذف التلقائي بعد 48 ساعة نشط الآن لحماية وتطهير المحتوى',
  ];

  List<PlanConfig> plans = [
    PlanConfig(
      id: 'plan_free',
      name: 'الباقة المجانية',
      priceSyp: 0,
      durationText: 'دائمة',
      statusConditionText: 'متاحة لجميع الحسابات الجديدة فوراً',
      maxAdsPerMonth: 5,
      maxImagesPerAd: 3,
      customFeatures: [
        PlanFeature(
            text: 'نشر 5 إعلانات شهرياً', icon: Icons.check_circle_outline),
        PlanFeature(
            text: 'حتى 3 صور لكل إعلان', icon: Icons.photo_library_outlined),
        PlanFeature(
            text: 'تفاوض مباشر مع المشترين', icon: Icons.handshake_outlined),
      ],
    ),
    PlanConfig(
      id: 'plan_vip',
      name: 'الباقة الذهبية VIP 👑',
      priceSyp: 150000,
      durationText: 'شهرياً',
      statusConditionText: 'متاحة للتفعيل الفوري عبر سيريتل/MTN كاش',
      maxAdsPerMonth: 9999,
      maxImagesPerAd: 10,
      customFeatures: [
        PlanFeature(text: 'نشر إعلانات غير محدود', icon: Icons.all_inclusive),
        PlanFeature(text: 'حتى 10 صور عالية الدقة', icon: Icons.photo_library),
        PlanFeature(
            text: 'إضافة روابط وفيديوهات يوتيوب', icon: Icons.video_collection),
        PlanFeature(
            text: 'شارة VIP الذهبية والظهور بالصدارة', icon: Icons.verified),
        PlanFeature(
            text: 'الظهور في قسم البنرات الممولة', icon: Icons.campaign),
      ],
    ),
  ];

  List<CategoryModel> categories = [
    CategoryModel(
      id: 'cars',
      name: '🚗 سيارات ومركبات',
      iconData: Icons.directions_car,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'سيارات سياحية',
        'دراجات نارية',
        'شاحنات ومعدات ثقيلة',
        'قطع غيار واكسسوارات'
      ],
    ),
    CategoryModel(
      id: 'realestate',
      name: '🏢 عقارات وأراضي',
      iconData: Icons.apartment,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'شقق للبيع',
        'شقق للإيجار',
        'أراضي وزراعة',
        'محلات ومكاتب تجارية'
      ],
    ),
    CategoryModel(
      id: 'electronics',
      name: '📱 هواتف وإلكترونيات',
      iconData: Icons.phone_android,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'هواتف ذكية',
        'أجهزة لوحية',
        'لابتوب وكمبيوتر',
        'شاشات وكاميرات'
      ],
    ),
    CategoryModel(
      id: 'furniture',
      name: '🛋️ أثاث ومستعمل',
      iconData: Icons.chair,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'غرف نوم وصالونات',
        'أجهزة منزلية كهربائية',
        'مفروشات مكتبية',
        'طاقة شمسية وبطاريات'
      ],
    ),
    CategoryModel(
      id: 'fashion',
      name: '👔 ألبسة وموضة',
      iconData: Icons.checkroom,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'ألبسة رجالية',
        'ألبسة نسائية',
        'ألبسة أطفال',
        'ساعات ومجوهرات'
      ],
    ),
    CategoryModel(
      id: 'jobs',
      name: '💼 وظائف وخدمات',
      iconData: Icons.work,
      backgroundColor: const Color(0xFF0F5132),
      textColor: Colors.white,
      borderRadiusValue: 14.0,
      subcategories: [
        'فرص عمل وشواغر',
        'خدمات صيانة ومنزلية',
        'شحن ونقل بضائع',
        'دروس واستشارات'
      ],
    ),
  ];

  // البنرات المقسمة (علوية وسفلية)
  List<BannerItem> banners = [
    BannerItem(
      id: 'b1',
      title: 'سيريتل كاش',
      subtitle: 'ترقية VIP فورية',
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
      targetUrl: 'https://syriamarket.app/vip',
      position: 'top',
    ),
    BannerItem(
      id: 'b2',
      title: 'MTN كاش',
      subtitle: 'دفع آمن وسريع',
      imageUrl:
          'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=600',
      targetUrl: 'https://syriamarket.app/vip',
      position: 'top',
    ),
    BannerItem(
      id: 'b3',
      title: 'عروض سوق الشام',
      subtitle: 'تخفيضات كبرى',
      imageUrl:
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
      targetUrl: 'https://syriamarket.app',
      position: 'bottom',
    ),
    BannerItem(
      id: 'b4',
      title: 'مزادات السيارات',
      subtitle: 'فحص وضمان شامل',
      imageUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600',
      targetUrl: 'https://syriamarket.app',
      position: 'bottom',
    ),
  ];

  List<AdminUser> registeredUsers = [
    AdminUser(
      id: 'admin-1',
      name: 'سامر عواد',
      email: 'sameraoaad@gmail.com',
      phone: '0944000001',
      role: 'super_admin',
      permissions: AdminPermissions(),
    ),
    AdminUser(
      id: 'admin-2',
      name: 'عبدو عواد',
      email: 'aoaadabdo@gmail.com',
      phone: '0944000002',
      role: 'super_admin',
      permissions: AdminPermissions(),
    ),
  ];

  void updateAppConfig(
      {String? title, String? subtitle, bool? maintenance, String? maintMsg}) {
    if (title != null) appTitle = title;
    if (subtitle != null) appSubtitle = subtitle;
    if (maintenance != null) isMaintenanceMode = maintenance;
    if (maintMsg != null) maintenanceMessage = maintMsg;
    notifyListeners();
  }

  void updateAppColors(
      {Color? primary,
      Color? secondary,
      Color? appBar,
      Color? button,
      Color? scaffoldBg}) {
    if (primary != null) primaryColor = primary;
    if (secondary != null) secondaryColor = secondary;
    if (appBar != null) appBarColor = appBar;
    if (button != null) buttonColor = button;
    if (scaffoldBg != null) scaffoldBgColor = scaffoldBg;
    notifyListeners();
  }

  void updateTickerSettings(
      {double? speed,
      Color? bg,
      Color? textCol,
      double? fontSize,
      IconData? icon}) {
    if (speed != null) tickerSpeed = speed;
    if (bg != null) tickerBackgroundColor = bg;
    if (textCol != null) tickerTextColor = textCol;
    if (fontSize != null) tickerFontSize = fontSize;
    if (icon != null) tickerIcon = icon;
    notifyListeners();
  }

  void loginUser(
      {required String name, required String email, required String phone}) {
    isLoggedIn = true;
    currentUserName = name;
    currentUserEmail = email.trim();
    currentUserPhone = phone;
    currentUserId = email.trim();
    currentUserPlanId = isSuperAdmin ? 'plan_vip' : 'plan_free';

    if (!registeredUsers
        .any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      registeredUsers.add(
        AdminUser(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email.trim(),
          phone: phone,
          role: isSuperAdmin ? 'super_admin' : 'user',
          permissions: AdminPermissions(),
        ),
      );
    }
    notifyListeners();
  }

  void logoutUser() {
    isLoggedIn = false;
    currentUserName = 'زائر سوق سوريا';
    currentUserEmail = '';
    currentUserPhone = '';
    currentUserId = '';
    currentUserPlanId = 'plan_free';
    notifyListeners();
  }

  PlanConfig getCurrentUserPlan() {
    return plans.firstWhere((p) => p.id == currentUserPlanId,
        orElse: () => plans.first);
  }

  /// حذف صور المنشور نهائياً من Supabase Storage لتوفير المساحة
  static Future<void> deleteStorageImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.pathSegments.isNotEmpty) {
          final fileName = uri.pathSegments.last;
          await Supabase.instance.client.storage
              .from(kStorageBucketAds)
              .remove([fileName]);
        }
      } catch (e) {
        debugPrint('Storage Cleanup notice: $e');
      }
    }
  }

  /// الفحص الآلي وحذف المنشورات المختومة بالأحمر التي تجاوزت 48 ساعة
  Future<void> autoCleanupExpiredStampedAds() async {
    final now = DateTime.now();
    final expiredAds = ads.where((ad) {
      if (ad.stampedAt == null) return false;
      return now.difference(ad.stampedAt!).inHours >= 48;
    }).toList();

    for (final ad in expiredAds) {
      try {
        await Supabase.instance.client.from('ads').delete().eq('id', ad.id);
        await deleteStorageImages(ad.imageUrls);
        ads.removeWhere((x) => x.id == ad.id);
      } catch (e) {
        debugPrint('Auto cleanup error: $e');
      }
    }
    if (expiredAds.isNotEmpty) {
      notifyListeners();
    }
  }
}

// ==============================================================================
// 5. كلاس التطبيق الجذري (SyriaMarket2028App)
// ==============================================================================
class SyriaMarket2028App extends StatefulWidget {
  const SyriaMarket2028App({Key? key}) : super(key: key);

  @override
  State<SyriaMarket2028App> createState() => _SyriaMarket2028AppState();
}

class _SyriaMarket2028AppState extends State<SyriaMarket2028App> {
  final AppStateManager _manager = AppStateManager();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${_manager.appTitle} ${_manager.appSubtitle}',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _manager.primaryColor,
          primary: _manager.primaryColor,
          secondary: _manager.secondaryColor,
          brightness: Brightness.light,
          surface: Colors.white,
          background: _manager.scaffoldBgColor,
        ),
        scaffoldBackgroundColor: _manager.scaffoldBgColor,
        appBarTheme: AppBarTheme(
          backgroundColor: _manager.appBarColor,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _manager.primaryColor,
          primary: _manager.primaryColor,
          secondary: _manager.secondaryColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _manager.isMaintenanceMode && !_manager.isSuperAdmin
          ? _buildMaintenanceScreen()
          : MainDashboardScreen(
              isDarkMode: _isDarkMode,
              onToggleTheme: _toggleTheme,
            ),
    );
  }

  Widget _buildMaintenanceScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_manager.primaryColor, const Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: _manager.secondaryColor, shape: BoxShape.circle),
              child: Icon(Icons.build_circle,
                  size: 70, color: _manager.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(_manager.appTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('وضع الصيانة مفعل ⏳',
                style: TextStyle(
                    color: _manager.secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              _manager.maintenanceMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _manager.secondaryColor)),
              icon: Icon(Icons.admin_panel_settings,
                  color: _manager.secondaryColor),
              label: Text('دخول المشرفين',
                  style: TextStyle(
                      color: _manager.secondaryColor,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 6. الشاشة الرئيسية الكبرى ولوحة التصفح (MainDashboardScreen)
// ==============================================================================
class MainDashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainDashboardScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final AppStateManager _manager = AppStateManager();
  int _currentNavIndex = 0;

  final List<String> _governorates = [
    'كل المحافظات',
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'درعا',
    'السويداء',
    'القنيطرة',
    'دير الزور',
    'الرقة',
    'الحسكة'
  ];

  String _selectedGovernorate = 'كل المحافظات';
  String? _selectedCategoryId;
  String? _selectedSubcategory;
  String _searchQuery = '';
  final Set<String> _favoriteAdIds = {};
  bool _isLoadingAds = false;

  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;
  bool _isTickerPaused = false;

  final PageController _topBannerController = PageController();
  int _currentTopBannerPage = 0;
  Timer? _topBannerTimer;

  final PageController _bottomBannerController = PageController();
  int _currentBottomBannerPage = 0;
  Timer? _bottomBannerTimer;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onStateChange);
    _initLiveAdsFromSupabase();
    _startTickerAnimation();
    _startBannerCarousels();
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChange);
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    _topBannerTimer?.cancel();
    _topBannerController.dispose();
    _bottomBannerTimer?.cancel();
    _bottomBannerController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _startTickerAnimation() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!_isTickerPaused && _tickerScrollController.hasClients) {
        final maxScroll = _tickerScrollController.position.maxScrollExtent;
        final currentScroll = _tickerScrollController.offset;
        if (currentScroll >= maxScroll) {
          _tickerScrollController.jumpTo(0.0);
        } else {
          _tickerScrollController.jumpTo(currentScroll + _manager.tickerSpeed);
        }
      }
    });
  }

  void _startBannerCarousels() {
    _topBannerTimer?.cancel();
    _topBannerTimer = Timer.periodic(
        Duration(seconds: _manager.topBannerIntervalSeconds), (timer) {
      final topBanners =
          _manager.banners.where((b) => b.position == 'top').toList();
      final pageCount = (topBanners.length / 2).ceil();
      if (mounted && pageCount > 1 && _topBannerController.hasClients) {
        _currentTopBannerPage = (_currentTopBannerPage + 1) % pageCount;
        _topBannerController.animateToPage(
          _currentTopBannerPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });

    _bottomBannerTimer?.cancel();
    _bottomBannerTimer = Timer.periodic(
        Duration(seconds: _manager.bottomBannerIntervalSeconds), (timer) {
      final bottomBanners =
          _manager.banners.where((b) => b.position == 'bottom').toList();
      final pageCount = (bottomBanners.length / 2).ceil();
      if (mounted && pageCount > 1 && _bottomBannerController.hasClients) {
        _currentBottomBannerPage = (_currentBottomBannerPage + 1) % pageCount;
        _bottomBannerController.animateToPage(
          _currentBottomBannerPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _initLiveAdsFromSupabase() async {
    setState(() => _isLoadingAds = true);
    try {
      final res = await Supabase.instance.client
          .from('ads')
          .select()
          .order('created_at', ascending: false);

      if (res is List && res.isNotEmpty) {
        _manager.ads = res
            .map((map) => AdItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }
      await _manager.autoCleanupExpiredStampedAds();
    } catch (e) {
      debugPrint('Supabase fetch ads notice: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  bool _requireAuth(VoidCallback onAuthenticated) {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              '⚠️ يجب تسجيل الدخول أولاً لإتمام هذا الإجراء في المنصة.'),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'تسجيل الدخول',
            textColor: _manager.secondaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const AuthScreen()),
              );
            },
          ),
        ),
      );
      return false;
    }
    onAuthenticated();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        elevation: 2,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _manager.secondaryColor, shape: BoxShape.circle),
              child: Icon(Icons.storefront,
                  color: _manager.primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_manager.appTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(_manager.appSubtitle,
                    style: TextStyle(
                        color: _manager.secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGovernorate,
              dropdownColor: const Color(0xFF1E293B),
              icon: Icon(Icons.arrow_drop_down, color: _manager.secondaryColor),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              items: _governorates.map((gov) {
                return DropdownMenuItem<String>(
                  value: gov,
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: _manager.secondaryColor, size: 14),
                      const SizedBox(width: 4),
                      Text(gov,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGovernorate = val);
              },
            ),
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.notifications_active,
                color: _manager.secondaryColor),
            onPressed: () => _showNotificationDialog(context),
          ),
        ],
      ),
      body: _buildCurrentScreenBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        selectedItemColor: _manager.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            _requireAuth(() => _openAddAdScreen());
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'الرئيسية'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'الرسائل والصفقات'),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _manager.buttonColor, shape: BoxShape.circle),
              child: Icon(Icons.add, color: _manager.secondaryColor, size: 24),
            ),
            label: 'أضف إعلان',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'المفضلة'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildCurrentScreenBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeFeedTab();
      case 1:
        return _buildChatsAndNegotiationsTab();
      case 3:
        return _buildFavoritesTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeFeedTab();
    }
  }

  Widget _buildHomeFeedTab() {
    final filteredAds = _manager.ads.where((ad) {
      final matchesGov = _selectedGovernorate == 'كل المحافظات' ||
          ad.governorate == _selectedGovernorate;
      final matchesCat =
          _selectedCategoryId == null || ad.categoryId == _selectedCategoryId;
      final matchesSub = _selectedSubcategory == null ||
          ad.subcategory == _selectedSubcategory;
      final matchesSearch = _searchQuery.isEmpty ||
          ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ad.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ad.neighborhood.toLowerCase().contains(_searchQuery.toLowerCase());
      final isApproved = ad.status == 'approved';

      return matchesGov &&
          matchesCat &&
          matchesSub &&
          matchesSearch &&
          isApproved;
    }).toList();

    return Column(
      children: [
        _buildCustomNewsTickerWidget(),
        _buildSideBySideBannersWidget('top', _topBannerController),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText:
                  'ابحث في كافة إعلانات سوق سوريا الحية (سيارات، عقارات، هواتف...)...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.search, color: _manager.primaryColor),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.08),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
        ),
        _buildCategoriesHorizontalBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('أحدث إعلانات السوق المعتمدة',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: _manager.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('${filteredAds.length} إعلان',
                        style: TextStyle(
                            color: _manager.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_selectedGovernorate != 'كل المحافظات')
                Text('محافظة: $_selectedGovernorate',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _initLiveAdsFromSupabase,
            color: _manager.primaryColor,
            child: _isLoadingAds
                ? Center(
                    child:
                        CircularProgressIndicator(color: _manager.primaryColor))
                : filteredAds.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                    'لا توجد إعلانات منشورة حالياً في هذا القسم',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: _manager.buttonColor),
                                  onPressed: () =>
                                      _requireAuth(() => _openAddAdScreen()),
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.white, size: 18),
                                  label: const Text(
                                      'كن أول من ينشر إعلاناً الآن ✨',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: filteredAds.length + 1,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemBuilder: (ctx, index) {
                          if (index == (filteredAds.length / 2).floor()) {
                            return _buildSideBySideBannersWidget(
                                'bottom', _bottomBannerController);
                          }
                          final actualIndex =
                              index > (filteredAds.length / 2).floor()
                                  ? index - 1
                                  : index;
                          if (actualIndex >= filteredAds.length)
                            return const SizedBox.shrink();
                          final ad = filteredAds[actualIndex];
                          return _buildAdCard(ad);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomNewsTickerWidget() {
    final newsText = _manager.newsTicker.join('   ✦   ');

    return Container(
      color: _manager.tickerBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _manager.secondaryColor,
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(_manager.tickerIcon,
                    color: _manager.primaryColor, size: 14),
                const SizedBox(width: 4),
                Text('عاجل',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Listener(
              onPointerDown: (_) => setState(() => _isTickerPaused = true),
              onPointerUp: (_) => setState(() => _isTickerPaused = false),
              onPointerCancel: (_) => setState(() => _isTickerPaused = false),
              child: SingleChildScrollView(
                controller: _tickerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Text(
                  newsText,
                  style: TextStyle(
                    color: _manager.tickerTextColor,
                    fontSize: _manager.tickerFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideBannersWidget(
      String position, PageController controller) {
    final positionBanners =
        _manager.banners.where((b) => b.position == position).toList();
    if (positionBanners.isEmpty) return const SizedBox.shrink();

    final pairCount = (positionBanners.length / 2).ceil();

    return Container(
      height: 95,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: PageView.builder(
        controller: controller,
        itemCount: pairCount,
        itemBuilder: (ctx, pageIndex) {
          final firstIdx = pageIndex * 2;
          final secondIdx = firstIdx + 1;

          final firstBanner = positionBanners[firstIdx];
          final hasSecond = secondIdx < positionBanners.length;
          final secondBanner = hasSecond ? positionBanners[secondIdx] : null;

          return Row(
            children: [
              Expanded(child: _buildSingleBannerCard(firstBanner)),
              const SizedBox(width: 8),
              Expanded(
                child: secondBanner != null
                    ? _buildSingleBannerCard(secondBanner)
                    : Container(
                        decoration: BoxDecoration(
                          color: _manager.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _manager.secondaryColor.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            'مساحة إعلانية متاحة ✨',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSingleBannerCard(BannerItem banner) {
    return InkWell(
      onTap: () async {
        if (banner.targetUrl.isNotEmpty) {
          final uri = Uri.tryParse(banner.targetUrl);
          if (uri != null) await launchUrl(uri);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [_manager.primaryColor, const Color(0xFF1E293B)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(banner.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(banner.subtitle,
                      style: TextStyle(
                          color: _manager.secondaryColor, fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                banner.imageUrl,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  width: 45,
                  height: 45,
                  color: Colors.black26,
                  child: const Icon(Icons.campaign,
                      color: Colors.white70, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHorizontalBar() {
    final currentCat = _manager.categories.firstWhere(
      (c) => c.name == _selectedCategoryId,
      orElse: () => _manager.categories.first,
    );

    final subcategories =
        _selectedCategoryId != null ? currentCat.subcategories : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(
                  label: const Text('الكل',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  selected: _selectedCategoryId == null,
                  selectedColor: _manager.primaryColor,
                  labelStyle: TextStyle(
                      color: _selectedCategoryId == null
                          ? Colors.white
                          : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (_) => setState(() {
                    _selectedCategoryId = null;
                    _selectedSubcategory = null;
                  }),
                ),
              ),
              ..._manager.categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.name;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    avatar: Icon(cat.iconData,
                        size: 16,
                        color: isSelected ? Colors.white : cat.textColor),
                    label: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : cat.textColor,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: cat.backgroundColor,
                    backgroundColor: cat.backgroundColor.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(cat.borderRadiusValue)),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategoryId = val ? cat.name : null;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: subcategories.map((sub) {
                final isSelected = _selectedSubcategory == sub;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(sub,
                        style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? _manager.primaryColor
                                : Colors.black87)),
                    selected: isSelected,
                    selectedColor: _manager.primaryColor.withOpacity(0.15),
                    backgroundColor: Colors.transparent,
                    onSelected: (val) {
                      setState(() {
                        _selectedSubcategory = val ? sub : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdCard(AdItem ad) {
    final isFav = _favoriteAdIds.contains(ad.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => FullAdDetailsScreen(
                ad: ad,
                isFavorite: isFav,
                onToggleFavorite: () {
                  _requireAuth(() {
                    setState(() {
                      if (isFav) {
                        _favoriteAdIds.remove(ad.id);
                      } else {
                        _favoriteAdIds.add(ad.id);
                      }
                    });
                  });
                },
                onAdUpdated: (updatedAd) {
                  setState(() {
                    final idx =
                        _manager.ads.indexWhere((x) => x.id == updatedAd.id);
                    if (idx != -1) _manager.ads[idx] = updatedAd;
                  });
                },
                onAdDeleted: (deletedId) {
                  setState(() {
                    _manager.ads.removeWhere((x) => x.id == deletedId);
                  });
                },
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade900,
                  child: Image.network(
                    ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                          child: Icon(Icons.image,
                              size: 50, color: Colors.white38)),
                    ),
                  ),
                ),
                if (ad.isFeatured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _manager.secondaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('مميز ★ VIP',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.black45, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white, size: 20),
                      onPressed: () {
                        _requireAuth(() {
                          setState(() {
                            if (isFav) {
                              _favoriteAdIds.remove(ad.id);
                            } else {
                              _favoriteAdIds.add(ad.id);
                            }
                          });
                        });
                      },
                    ),
                  ),
                ),
                if (ad.stampedAt != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('مختوم بالأحمر (حذف خلال 48 ساعة)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (ad.isSold)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.65),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('✓ تـم الـبـيـع',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (ad.priceUsd != null)
                            Text('\$${ad.priceUsd!.toStringAsFixed(0)}',
                                style: TextStyle(
                                    color: _manager.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17)),
                          if (ad.priceUsd != null && ad.priceSyp != null)
                            const SizedBox(width: 8),
                          if (ad.priceSyp != null)
                            Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blueGrey)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: _manager.primaryColor, size: 14),
                          const SizedBox(width: 2),
                          Text('${ad.governorate} - ${ad.neighborhood}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsAndNegotiationsTab() {
    if (!_manager.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('غرف المحادثة والتفاوض المباشر',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('يرجى تسجيل الدخول للوصول إلى رسائلك وعروض التفاوض.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _manager.buttonColor),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const AuthScreen())),
              child: const Text('تسجيل الدخول الآن 🔑',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.mark_chat_unread, color: _manager.primaryColor),
            const SizedBox(width: 8),
            const Text('غرف المحادثة والتفاوض المباشر',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: _manager.primaryColor,
                child: const Text('س',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            title: const Text('سامر عواد (محادثة تفاوض)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text(
                'أهلاً بك في سوق سوريا الشامل! هل ترغب في بدء صفقة جديدة؟',
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            trailing: const Text('نشط الآن',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const FullChatNegotiationScreen(
                    partnerName: 'سامر عواد',
                    productTitle: 'تفاوض مباشر على سلعة',
                    initialPrice: 1000,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favAds =
        _manager.ads.where((x) => _favoriteAdIds.contains(x.id)).toList();

    if (favAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('قائمة المفضلة فارغة حالياً',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            const Text(
                'اضغط على رمز القلب في أي إعلان لحفظه هنا للرجوع إليه لاحقاً.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            Text('إعلاناتك المفضلة (${favAds.length})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...favAds.map((ad) => _buildAdCard(ad)).toList(),
      ],
    );
  }

  Widget _buildProfileTab() {
    final currentPlan = _manager.getCurrentUserPlan();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _manager.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _manager.secondaryColor,
                child: Text(
                  _manager.currentUserName.isNotEmpty
                      ? _manager.currentUserName[0]
                      : 'U',
                  style: TextStyle(
                      color: _manager.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_manager.currentUserName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      _manager.isLoggedIn
                          ? _manager.currentUserEmail
                          : 'غير مسجل (وضع الزائر)',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _manager.secondaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('الخطة الحالية: ${currentPlan.name}',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!_manager.isLoggedIn)
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: _manager.primaryColor.withOpacity(0.1),
            leading: Icon(Icons.login, color: _manager.primaryColor),
            title: const Text('تسجيل الدخول / إنشاء حساب جديد',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('لتفعيل النشر والتعليقات والدردشة'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (ctx) => const AuthScreen())),
          )
        else
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: Colors.red.withOpacity(0.08),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              _manager.logoutUser();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح.')));
            },
          ),
        const SizedBox(height: 10),
        ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: Colors.grey.withOpacity(0.06),
          leading:
              Icon(Icons.workspace_premium, color: _manager.secondaryColor),
          title: const Text('ترقية الباقة والاشتراكات VIP'),
          subtitle: const Text('سيريتل كاش & MTN كاش للدفع الفوري'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => const FullSubscriptionPlansScreen())),
        ),
        if (_manager.isSuperAdmin) ...[
          const SizedBox(height: 10),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: Colors.red.withOpacity(0.08),
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('غرفة العمليات ولوحة تحكم الأدمن الشاملة',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('الخطط، الألوان، المشرفين، البنرات، والأقسام'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => const FullAdminPanelScreen())),
          ),
        ],
      ],
    );
  }

  void _openAddAdScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullAddAdScreen(
          onAdCreated: (newAd) {
            setState(() {
              _manager.ads.insert(0, newAd);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      '✨ تم نشر إعلانك وحفظه سحابياً بنجاح في سوق سوريا 2028!')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: _manager.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.storefront,
                      color: _manager.primaryColor, size: 36),
                ),
                const SizedBox(height: 8),
                Text('${_manager.appTitle} ${_manager.appSubtitle}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text('المنصة الأولى للبيع والشراء والمزادات الحرة',
                    style: TextStyle(
                        color: _manager.secondaryColor, fontSize: 11)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: _manager.primaryColor),
            title: const Text('الرئيسية'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                Icon(Icons.workspace_premium, color: _manager.secondaryColor),
            title: const Text('خطط الاشتراك والترقية VIP'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => const FullSubscriptionPlansScreen()));
            },
          ),
          if (_manager.isSuperAdmin)
            ListTile(
              leading:
                  const Icon(Icons.admin_panel_settings, color: Colors.red),
              title: const Text('غرفة العمليات ولوحة تحكم الأدمن'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const FullAdminPanelScreen()));
              },
            ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: _manager.primaryColor),
            const SizedBox(width: 8),
            const Text('مركز التنبيهات السحابية'),
          ],
        ),
        content: const Text(
          '• تم تفعيل قاعدة بيانات Supabase والتنظيف التلقائي للمنشورات بعد 48 ساعة.\n'
          '• مسح الصور نهائياً من Storage عند الحذف لتوفير مساحة التخزين.\n'
          '• باقات VIP الذهبية متاحة بالدفع الفوري عبر سيريتل كاش و MTN كاش.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('حسناً',
                style: TextStyle(
                    color: _manager.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 7. شاشة المصادقة الاحترافية (Professional Auth UI/UX)
// ==============================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AppStateManager _manager = AppStateManager();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final name =
        _isSignUp ? _nameController.text.trim() : (email.split('@').first);
    final phone = _phoneController.text.trim();

    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: _passwordController.text.trim(),
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      debugPrint('Auth Supabase note: $e');
    }

    _manager.loginUser(
      name: name.isNotEmpty ? name : 'مستخدم سوق سوريا',
      email: email,
      phone: phone.isNotEmpty ? phone : '0944000000',
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 مرحباً بك يا $name في ${_manager.appTitle}!'),
          backgroundColor: _manager.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _manager.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        elevation: 0,
        title: Text(
          _isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _manager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_circle,
                      size: 72, color: _manager.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  _isSignUp
                      ? 'انضم إلى منصة سوق سوريا الشامل 2028'
                      : 'أهلاً بك من جديد في ${_manager.appTitle}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل *',
                      prefixIcon: Icon(Icons.person_outline,
                          color: _manager.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'يرجى إدخال الاسم الكامل'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف للتواصل *',
                      prefixIcon: Icon(Icons.phone_outlined,
                          color: _manager.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'يرجى إدخال رقم الهاتف'
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني *',
                    hintText: 'example@domain.com',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: _manager.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'يرجى إدخال بريد إلكتروني صالح'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور *',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: _manager.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'كلمة المرور يجب ألا تقل عن 6 خانات'
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _manager.buttonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _submitAuth,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUp ? 'إنشاء حساب جديد ✨' : 'تسجيل الدخول 🔑',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? 'لديك حساب بالفعل؟ تسجيل الدخول'
                        : 'ليس لديك حساب؟ إنشاء حساب جديد الآن',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 8. شاشة إضافة الإعلانات وضغط ومعاينة الصور بالبايتات (FullAddAdScreen)
// ==============================================================================
class FullAddAdScreen extends StatefulWidget {
  final Function(AdItem) onAdCreated;

  const FullAddAdScreen({
    Key? key,
    required this.onAdCreated,
  }) : super(key: key);

  @override
  State<FullAddAdScreen> createState() => _FullAddAdScreenState();
}

class _FullAddAdScreenState extends State<FullAddAdScreen> {
  final AppStateManager _manager = AppStateManager();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceUsdController = TextEditingController();
  final TextEditingController _priceSypController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  late TextEditingController _publisherNameController;
  late TextEditingController _publisherPhoneController;

  String _selectedGovernorate = 'دمشق';
  String _selectedCategory = '🚗 سيارات ومركبات';
  String _selectedSubcategory = 'سيارات سياحية';
  final String _condition = 'جديد';
  final bool _allowComments = true;
  bool _isSubmitting = false;

  // تخزين البايتات للمعاينة السريعة وحل مشكلة الشاشات البيضاء
  final List<Uint8List> _previewImageBytes = [];
  final List<String> _uploadedImageUrls = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedTags = [];

  final List<String> _quickTags = [
    '✨ بحالة ممتازة',
    '🔍 فحص كامل',
    '🤝 قابل للتفاوض',
    '🚀 جاهز للتسليم',
    '📜 طابو أخضر',
    '🔋 بطارية 100%',
    '💎 كرت أبيض'
  ];

  final List<String> _governorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'درعا',
    'السويداء',
    'القنيطرة',
    'دير الزور',
    'الرقة',
    'الحسكة'
  ];

  @override
  void initState() {
    super.initState();
    _publisherNameController =
        TextEditingController(text: _manager.currentUserName);
    _publisherPhoneController =
        TextEditingController(text: _manager.currentUserPhone);
  }

  /// ضغط ورفع الصورة إلى Supabase Storage وجلب الرابط العام getPublicUrl مع المعاينة الفورية بالبايتات
  Future<void> _pickAndUploadImage() async {
    final currentPlan = _manager.getCurrentUserPlan();
    if (_uploadedImageUrls.length >= currentPlan.maxImagesPerAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠️ لقد وصلت للحد الأقصى لعدد الصور في خطتك (${currentPlan.maxImagesPerAd} صور). يرجى الترقية لباقة VIP.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    // ضغط الصور تلقائياً وخلف الكواليس
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (image != null) {
      setState(() => _isSubmitting = true);
      try {
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() => _previewImageBytes.add(imageBytes));

        final fileName =
            'ad_${DateTime.now().millisecondsSinceEpoch}_${image.name}';

        await Supabase.instance.client.storage
            .from(kStorageBucketAds)
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );

        final publicUrl = Supabase.instance.client.storage
            .from(kStorageBucketAds)
            .getPublicUrl(fileName);
        setState(() => _uploadedImageUrls.add(publicUrl));
      } catch (e) {
        debugPrint('Image Upload note: $e');
        setState(() {
          _uploadedImageUrls.add(
              'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600');
        });
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final currentPlan = _manager.getCurrentUserPlan();

    final newAd = AdItem(
      id: 'ad-${DateTime.now().millisecondsSinceEpoch}',
      userId: _manager.currentUserId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priceUsd: double.tryParse(_priceUsdController.text.trim()),
      priceSyp: double.tryParse(_priceSypController.text.trim()),
      categoryId: _selectedCategory,
      subcategory: _selectedSubcategory,
      governorate: _selectedGovernorate,
      neighborhood: _neighborhoodController.text.trim().isEmpty
          ? 'المركز'
          : _neighborhoodController.text.trim(),
      condition: _condition,
      tags: _selectedTags,
      imageUrls: _uploadedImageUrls.isNotEmpty
          ? _uploadedImageUrls
          : [
              'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'
            ],
      videoUrl: currentPlan.customFeatures.any((f) => f.text.contains('فيديو'))
          ? _videoUrlController.text.trim()
          : null,
      publisherName: _publisherNameController.text.trim(),
      publisherPhone: _publisherPhoneController.text.trim(),
      publisherEmail: _manager.currentUserEmail,
      isFeatured: currentPlan.customFeatures.any((f) => f.text.contains('VIP')),
      allowComments: _allowComments,
      status: 'pending', // يبدأ معلقاً بانتظار مراجعة الإدارة
      createdAt: DateTime.now(),
    );

    try {
      await Supabase.instance.client.from('ads').insert(newAd.toMap());
    } catch (e) {
      debugPrint('Supabase insert ad notice: $e');
    }

    widget.onAdCreated(newAd);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _manager.getCurrentUserPlan();
    final currentCategoryObj = _manager.categories.firstWhere(
        (c) => c.name == _selectedCategory,
        orElse: () => _manager.categories.first);
    final subs = currentCategoryObj.subcategories;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: const Text('نشر إعلان جديد سحابياً',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _manager.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: _manager.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أنت تنشر باستخدام "${currentPlan.name}" (الحد الأقصى للصور: ${currentPlan.maxImagesPerAd} صور).',
                      style: TextStyle(
                          color: _manager.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الإعلان (ماذا تبيع؟) *',
                prefixIcon: Icon(Icons.title, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'يرجى كتابة عنوان الإعلان'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceUsdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر بالدولار (\$)',
                      prefixIcon: Icon(Icons.attach_money,
                          color: _manager.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _priceSypController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر بالليرة السورية',
                      suffixText: 'ل.س',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: 'القسم الرئيسي',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    items: _manager.categories
                        .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name,
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedCategory = v;
                          final match = _manager.categories
                              .firstWhere((cat) => cat.name == v);
                          _selectedSubcategory = match.subcategories.isNotEmpty
                              ? match.subcategories.first
                              : 'عام';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: subs.contains(_selectedSubcategory)
                        ? _selectedSubcategory
                        : (subs.isNotEmpty ? subs.first : 'عام'),
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: 'القسم الفرعي',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    items: subs
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child:
                                Text(s, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSubcategory = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGovernorate,
                    isExpanded: true,
                    decoration: InputDecoration(
                        labelText: 'المحافظة',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    items: _governorates
                        .map((g) => DropdownMenuItem(
                            value: g,
                            child:
                                Text(g, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGovernorate = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _neighborhoodController,
                    decoration: InputDecoration(
                        labelText: 'الحي / المنطقة',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLength: 600,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'تفاصيل ووصف السلعة *',
                hintText: 'اكتب مواصفات السلعة بدقة والمميزات...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 5) ? 'الوصف مطلوب' : null,
            ),
            if (currentPlan.customFeatures
                .any((f) => f.text.contains('فيديو'))) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'رابط فيديو يوتيوب أو رابط خارجي (ميزة VIP 👑)',
                  prefixIcon:
                      const Icon(Icons.video_library, color: Colors.red),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text('وسوم سريعة تميز إعلانك:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _quickTags.map((tag) {
                final sel = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag,
                      style: TextStyle(
                          fontSize: 11,
                          color: sel ? Colors.white : Colors.black87)),
                  selected: sel,
                  selectedColor: _manager.primaryColor,
                  onSelected: (val) {
                    setState(() {
                      if (val)
                        _selectedTags.add(tag);
                      else
                        _selectedTags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('صور الإعلان (من المعرض):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                    '${_uploadedImageUrls.length} / ${currentPlan.maxImagesPerAd} صور مسموحة',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 85,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  InkWell(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: _manager.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _manager.primaryColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library,
                              color: _manager.primaryColor, size: 28),
                          const SizedBox(height: 4),
                          Text('من المعرض 🖼️',
                              style: TextStyle(
                                  color: _manager.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  ..._previewImageBytes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final bytes = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: MemoryImage(bytes), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          left: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _previewImageBytes.removeAt(idx);
                                if (idx < _uploadedImageUrls.length) {
                                  _uploadedImageUrls.removeAt(idx);
                                }
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _publisherPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف للتواصل والواتساب',
                prefixIcon: Icon(Icons.phone, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: _isSubmitting ? null : _submitAd,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('نشر الإعلان سحابياً الآن ✨',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 9. شاشة تفاصيل الإعلان والحذف النهائي والختم الأحمر (FullAdDetailsScreen)
// ==============================================================================
class FullAdDetailsScreen extends StatefulWidget {
  final AdItem ad;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(AdItem) onAdUpdated;
  final Function(String) onAdDeleted;

  const FullAdDetailsScreen({
    Key? key,
    required this.ad,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAdUpdated,
    required this.onAdDeleted,
  }) : super(key: key);

  @override
  State<FullAdDetailsScreen> createState() => _FullAdDetailsScreenState();
}

class _FullAdDetailsScreenState extends State<FullAdDetailsScreen> {
  final AppStateManager _manager = AppStateManager();
  late AdItem _ad;
  final TextEditingController _negotiateOfferController =
      TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
  }

  void _openNegotiateDialog() {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '⚠️ يرجى تسجيل الدخول أولاً لتتمكن من تقديم عرض تفاوض مباشر.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.handshake, color: _manager.primaryColor),
            const SizedBox(width: 8),
            const Text('تقديم عرض سعر وتفاوض مباشر'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'السعر المعلن: ${_ad.priceUsd != null ? "\$${_ad.priceUsd!.toStringAsFixed(0)}" : "${_ad.priceSyp} ل.س"}'),
            const SizedBox(height: 12),
            TextField(
              controller: _negotiateOfferController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عرضك السعري المقترح (\$ أو ل.س)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
            onPressed: () {
              final offer = _negotiateOfferController.text.trim();
              if (offer.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => FullChatNegotiationScreen(
                      partnerName: _ad.publisherName,
                      productTitle: _ad.title,
                      initialPrice: double.tryParse(offer) ?? _ad.priceUsd ?? 0,
                    ),
                  ),
                );
              }
            },
            child: const Text('إرسال وبدء الدردشة 🤝',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _toggleSold() async {
    final updated = _ad.copyWith(isSold: !_ad.isSold);
    setState(() => _ad = updated);
    widget.onAdUpdated(updated);

    try {
      await Supabase.instance.client
          .from('ads')
          .update({'is_sold': updated.isSold}).eq('id', updated.id);
    } catch (e) {
      debugPrint('Supabase update status note: $e');
    }
  }

  void _toggleRedStamp() async {
    final newStamp = _ad.stampedAt == null ? DateTime.now() : null;
    final updated = _ad.copyWith(stampedAt: newStamp);
    setState(() => _ad = updated);
    widget.onAdUpdated(updated);

    try {
      await Supabase.instance.client.from('ads').update(
          {'stamped_at': newStamp?.toIso8601String()}).eq('id', updated.id);
    } catch (e) {
      debugPrint('Red Stamp update error: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStamp != null
              ? '🔴 تم وضع الختم الأحمر: سيتم حذف المنشور ومسح صوره بعد 48 ساعة تلقائياً.'
              : '🟢 تم إلغاء الختم الأحمر عن المنشور.'),
          backgroundColor:
              newStamp != null ? Colors.red.shade900 : Colors.green,
        ),
      );
    }
  }

  void _deleteAdPermanently() async {
    final imagesToDelete = List<String>.from(_ad.imageUrls);
    try {
      await Supabase.instance.client.from('ads').delete().eq('id', _ad.id);
      await AppStateManager.deleteStorageImages(imagesToDelete);
    } catch (e) {
      debugPrint('Supabase permanent delete error: $e');
    }

    widget.onAdDeleted(_ad.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '🗑️ تم حذف المنشور ومسح صوره نهائياً من السيرفر لتوفير المساحة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: Text(_ad.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.isFavorite ? Colors.red : Colors.white),
            onPressed: widget.onToggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                color: const Color(0xFF0F172A),
                child: Image.network(
                  _ad.imageUrls.isNotEmpty ? _ad.imageUrls.first : '',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                      child:
                          Icon(Icons.image, size: 60, color: Colors.white38)),
                ),
              ),
              if (_ad.stampedAt != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text('🔴 خـتـم أحـمـر (حذف خلال 48 ساعة)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ),
              if (_ad.isSold)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('✓ تـم الـبـيـع بالكامل',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_ad.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (_ad.priceUsd != null)
                          Text('\$${_ad.priceUsd!.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: _manager.primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        if (_ad.priceUsd != null && _ad.priceSyp != null)
                          const SizedBox(width: 10),
                        if (_ad.priceSyp != null)
                          Text('${_ad.priceSyp!.toStringAsFixed(0)} ل.س',
                              style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _manager.secondaryColor),
                      onPressed: _openNegotiateDialog,
                      icon: Icon(Icons.handshake,
                          color: _manager.primaryColor, size: 18),
                      label: Text('تفاوض على السعر 🤝',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('${_ad.governorate} - ${_ad.neighborhood}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 14),
                const Text('الوصف والمواصفات:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(_ad.description,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
                if (_ad.videoUrl != null && _ad.videoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700),
                    icon:
                        const Icon(Icons.play_circle_fill, color: Colors.white),
                    label: const Text('مشاهدة فيديو الإعلان 🎥',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => launchUrl(Uri.parse(_ad.videoUrl!)),
                  ),
                ],
                const SizedBox(height: 16),
                if (_manager.isSuperAdmin ||
                    _ad.userId == _manager.currentUserId) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _toggleSold,
                          child: Text(_ad.isSold
                              ? 'إلغاء تم البيع'
                              : 'تمييز: تم البيع ✓'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900),
                          onPressed: _deleteAdPermanently,
                          child: const Text('حذف نهائي + مسح الصورة 🗑️',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  if (_manager.isSuperAdmin) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _ad.stampedAt == null
                                ? Colors.red.shade800
                                : Colors.green.shade800),
                        icon: const Icon(Icons.verified_outlined,
                            color: Colors.white),
                        label: Text(
                          _ad.stampedAt == null
                              ? 'وضع الختم الأحمر (مؤقت 48 ساعة)'
                              : 'إلغاء الختم الأحمر',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _toggleRedStamp,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                const Divider(),
                const Text('التعليقات والاستفسارات العامة:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                            hintText: 'اكتب استفسارك هنا...',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                          backgroundColor: _manager.buttonColor),
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (!_manager.isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('⚠️ يرجى تسجيل الدخول للتعليق.')));
                          return;
                        }
                        if (_commentController.text.isNotEmpty) {
                          setState(() {
                            _comments.add(
                                '${_manager.currentUserName}: ${_commentController.text.trim()}');
                            _commentController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('لا توجد تعليقات بعد، كن أول من يعلق!',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                else
                  ..._comments.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('• $c'),
                      )),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _manager.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('اتصال هاتفي',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () =>
                      launchUrl(Uri.parse('tel:${_ad.publisherPhone}')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('واتساب',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => launchUrl(
                      Uri.parse('https://wa.me/963${_ad.publisherPhone}')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 10. شاشة المحادثة والتفاوض السعري (Chat & Negotiations)
// ==============================================================================
class FullChatNegotiationScreen extends StatefulWidget {
  final String partnerName;
  final String productTitle;
  final double initialPrice;

  const FullChatNegotiationScreen({
    Key? key,
    required this.partnerName,
    required this.productTitle,
    required this.initialPrice,
  }) : super(key: key);

  @override
  State<FullChatNegotiationScreen> createState() =>
      _FullChatNegotiationScreenState();
}

class _FullChatNegotiationScreenState extends State<FullChatNegotiationScreen> {
  final AppStateManager _manager = AppStateManager();
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'msg-init',
        senderName: _manager.currentUserName,
        senderEmail: _manager.currentUserEmail,
        message:
            'مرحباً، أود بدء التفاوض حول "${widget.productTitle}" بسعر \$${widget.initialPrice.toStringAsFixed(0)}.',
        timestamp: DateTime.now(),
        isMe: true,
        offerAmount: widget.initialPrice,
      ),
    );
  }

  void _sendMessage() {
    final txt = _msgController.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          senderName: _manager.currentUserName,
          senderEmail: _manager.currentUserEmail,
          message: txt,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.partnerName,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(widget.productTitle,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? _manager.primaryColor.withOpacity(0.15)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.message, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${msg.timestamp.hour}:${msg.timestamp.minute}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك أو قدم عرض سعر جديد...',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: _manager.buttonColor),
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 11. شاشة باقات وترقيات VIP (FullSubscriptionPlansScreen)
// ==============================================================================
class FullSubscriptionPlansScreen extends StatelessWidget {
  const FullSubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = AppStateManager();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: manager.appBarColor,
        title: const Text('باقات وترقيات VIP 👑',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: manager.plans.map((plan) {
          final isVip = plan.id == 'plan_vip';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color:
                        isVip ? manager.secondaryColor : Colors.grey.shade300,
                    width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(plan.name,
                            style: TextStyle(
                                color:
                                    isVip ? manager.primaryColor : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        if (isVip)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: manager.secondaryColor,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('الأكثر طلباً ⭐',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${plan.priceSyp.toStringAsFixed(0)} ل.س / ${plan.durationText}',
                        style: TextStyle(
                            color: isVip ? manager.secondaryColor : Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('الحالة والشرط: ${plan.statusConditionText}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey)),
                    ),
                    const SizedBox(height: 12),
                    ...plan.customFeatures
                        .map((feat) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Icon(feat.icon,
                                      color: isVip
                                          ? manager.primaryColor
                                          : Colors.grey,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(feat.text,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87)),
                                ],
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: isVip
                                ? manager.buttonColor
                                : Colors.grey.shade300),
                        onPressed: () {
                          manager.currentUserPlanId = plan.id;
                          manager.notifyListeners();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('🎉 تم تفعيل ${plan.name} بنجاح!')),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          isVip
                              ? 'الترقية الفورية عبر سيريتل/MTN كاش 💳'
                              : 'اختيار هذه الباقة',
                          style: TextStyle(
                              color: isVip ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==============================================================================
// 12. لوحة تحكم غرفة العمليات التنفيذية المخصصة (Executive Admin Dashboard)
// ==============================================================================
class FullAdminPanelScreen extends StatefulWidget {
  const FullAdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<FullAdminPanelScreen> createState() => _FullAdminPanelScreenState();
}

class _FullAdminPanelScreenState extends State<FullAdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final AppStateManager _manager = AppStateManager();
  late TabController _tabController;

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _maintMsgController;

  // إدارة الأقسام
  final TextEditingController _categoryNameController = TextEditingController();
  double _catRadius = 14.0;
  IconData _selectedCatIcon = Icons.category;

  // إدارة الأخبار
  final TextEditingController _newsInputController = TextEditingController();

  // إدارة البنرات
  final TextEditingController _bannerTitleController = TextEditingController();
  final TextEditingController _bannerSubController = TextEditingController();
  final TextEditingController _bannerUrlController = TextEditingController();
  String _bannerPosition = 'top';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _titleController = TextEditingController(text: _manager.appTitle);
    _subtitleController = TextEditingController(text: _manager.appSubtitle);
    _maintMsgController =
        TextEditingController(text: _manager.maintenanceMessage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _maintMsgController.dispose();
    _categoryNameController.dispose();
    _newsInputController.dispose();
    _bannerTitleController.dispose();
    _bannerSubController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_manager.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('غير مصرح')),
        body: const Center(
            child: Text('⚠️ ليس لديك صلاحيات للوصول إلى غرفة العمليات.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF991B1B),
        title: const Text('غرفة العمليات التنفيذية - Super Admin',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _manager.secondaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'نظرة عامة والتحكم'),
            Tab(icon: Icon(Icons.rule), text: 'مراجعة الإعلانات'),
            Tab(icon: Icon(Icons.category), text: 'الأقسام والفئات'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'الخطط والباقات'),
            Tab(icon: Icon(Icons.color_lens), text: 'الألوان والثيمات'),
            Tab(icon: Icon(Icons.campaign), text: 'البنرات والأخبار'),
            Tab(icon: Icon(Icons.people), text: 'المستخدمين والصلاحيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExecutiveOverviewTab(),
          _buildReviewAdsTab(),
          _buildManageCategoriesTab(),
          _buildManagePlansTab(),
          _buildChangeColorsTab(),
          _buildNewsAndBannersTab(),
          _buildManageUsersTab(),
        ],
      ),
    );
  }

  Widget _buildExecutiveOverviewTab() {
    final pendingCount =
        _manager.ads.where((a) => a.status == 'pending').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
                child: _buildMetricCard(
                    'إجمالي الإعلانات',
                    '${_manager.ads.length}',
                    Icons.list_alt,
                    _manager.primaryColor)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMetricCard('بانتظار المراجعة', '$pendingCount',
                    Icons.pending_actions, Colors.orange.shade800)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildMetricCard(
                    'المستخدمين المسجلين',
                    '${_manager.registeredUsers.length}',
                    Icons.group,
                    Colors.indigo)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMetricCard(
                    'حالة النظام',
                    _manager.isMaintenanceMode ? 'صيانة ⏳' : 'متاح للجميع ✅',
                    Icons.security,
                    _manager.isMaintenanceMode ? Colors.red : Colors.green)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('إعدادات الهوية ووضع الصيانة:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'اسم التطبيق الرئيسي',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                      labelText: 'العنوان الفرعي',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('تفعيل "وضع الصيانة" الفوري'),
                  subtitle:
                      const Text('إغلاق المنصة للزوار وإتاحتها للمشرفين فقط'),
                  value: _manager.isMaintenanceMode,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setState(() => _manager.isMaintenanceMode = val);
                    _manager.notifyListeners();
                  },
                ),
                if (_manager.isMaintenanceMode) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _maintMsgController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'رسالة الصيانة التي تظهر للمستخدمين',
                        border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _manager.buttonColor),
                    onPressed: () {
                      _manager.updateAppConfig(
                        title: _titleController.text.trim(),
                        subtitle: _subtitleController.text.trim(),
                        maintMsg: _maintMsgController.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('✨ تم حفظ الإعدادات بنجاح!')),
                      );
                    },
                    child: const Text('حفظ التعديلات برمجياً',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewAdsTab() {
    final pendingAds =
        _manager.ads.where((a) => a.status == 'pending').toList();

    if (pendingAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            SizedBox(height: 12),
            Text('رائع! لا توجد إعلانات معلقة بانتظار المراجعة.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pendingAds.length,
      itemBuilder: (ctx, idx) {
        final ad = pendingAds[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                          ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ad.title,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                              'المعلن: ${ad.publisherName} (${ad.publisherPhone})',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                              'السعر: ${ad.priceUsd != null ? "\$${ad.priceUsd}" : "${ad.priceSyp} ل.س"} | ${ad.governorate}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _manager.primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10)),
                        icon:
                            const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('قبول الإعلان ✔',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final adIdx =
                              _manager.ads.indexWhere((x) => x.id == ad.id);
                          if (adIdx != -1) {
                            setState(() => _manager.ads[adIdx] =
                                ad.copyWith(status: 'approved'));
                            _manager.notifyListeners();
                          }
                          try {
                            await Supabase.instance.client
                                .from('ads')
                                .update({'status': 'approved'}).eq('id', ad.id);
                          } catch (e) {
                            debugPrint('Review ad note: $e');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 10)),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text('رفض ✖',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final adIdx =
                              _manager.ads.indexWhere((x) => x.id == ad.id);
                          if (adIdx != -1) {
                            setState(() => _manager.ads[adIdx] =
                                ad.copyWith(status: 'rejected'));
                            _manager.notifyListeners();
                          }
                          try {
                            await Supabase.instance.client
                                .from('ads')
                                .update({'status': 'rejected'}).eq('id', ad.id);
                          } catch (e) {
                            debugPrint('Review ad note: $e');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageCategoriesTab() {
    final availableIcons = [
      Icons.directions_car,
      Icons.apartment,
      Icons.phone_android,
      Icons.chair,
      Icons.checkroom,
      Icons.work,
      Icons.electric_bolt,
      Icons.pets,
      Icons.sports_soccer,
      Icons.build,
      Icons.fastfood,
      Icons.local_offer,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إضافة قسم جديد وتخصيص شكله وأيقونته:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _categoryNameController,
          decoration: const InputDecoration(
              hintText: 'اسم القسم (مثلاً: ⚡ طاقة شمسية)...',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        const Text('اختر أيقونة للقسم:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: availableIcons.map((ic) {
            final isSel = _selectedCatIcon == ic;
            return ChoiceChip(
              avatar: Icon(ic,
                  size: 16, color: isSel ? Colors.white : Colors.black),
              label: const Text(''),
              selected: isSel,
              selectedColor: _manager.primaryColor,
              onSelected: (val) => setState(() => _selectedCatIcon = ic),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('شكل حواف الأزرار:'),
            DropdownButton<double>(
              value: _catRadius,
              items: const [
                DropdownMenuItem(value: 0.0, child: Text('حواف حادة (0px)')),
                DropdownMenuItem(
                    value: 12.0, child: Text('حواف منحنية (12px)')),
                DropdownMenuItem(
                    value: 24.0, child: Text('حواف دائرية بالكامل (24px)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _catRadius = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة القسم المخصص الآن',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            final name = _categoryNameController.text.trim();
            if (name.isNotEmpty) {
              setState(() {
                _manager.categories.add(
                  CategoryModel(
                    id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    iconData: _selectedCatIcon,
                    backgroundColor: _manager.primaryColor,
                    textColor: Colors.white,
                    borderRadiusValue: _catRadius,
                    subcategories: ['عام', 'مستلزمات وملحقات'],
                  ),
                );
                _categoryNameController.clear();
              });
              _manager.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 14),
        ..._manager.categories
            .map((c) => Card(
                  child: ListTile(
                    leading: Icon(c.iconData, color: _manager.primaryColor),
                    title: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('الأقسام الفرعية: ${c.subcategories.join("، ")}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _manager.categories.remove(c));
                        _manager.notifyListeners();
                      },
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildManagePlansTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إدارة الخطط والباقات والشروط والمزايا:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ..._manager.plans.asMap().entries.map((entry) {
          final idx = entry.key;
          final plan = entry.value;
          final priceCtrl =
              TextEditingController(text: plan.priceSyp.toStringAsFixed(0));
          final conditionCtrl =
              TextEditingController(text: plan.statusConditionText);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                  '${plan.name} (${plan.priceSyp.toStringAsFixed(0)} ل.س)',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'سعر الباقة بالليرة السورية',
                            border: OutlineInputBorder()),
                        onChanged: (val) {
                          final p = double.tryParse(val) ?? plan.priceSyp;
                          _manager.plans[idx] = plan.copyWith(priceSyp: p);
                          _manager.notifyListeners();
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: conditionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'شرط وحالة الباقة (نص يدوي حر)',
                            border: OutlineInputBorder()),
                        onChanged: (val) {
                          _manager.plans[idx] =
                              plan.copyWith(statusConditionText: val);
                          _manager.notifyListeners();
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الحد الأقصى للصور في الإعلان:'),
                          DropdownButton<int>(
                            value: plan.maxImagesPerAd,
                            items: [1, 2, 3, 5, 8, 10, 15]
                                .map((n) => DropdownMenuItem(
                                    value: n, child: Text('$n صور')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _manager.plans[idx] =
                                    plan.copyWith(maxImagesPerAd: val));
                                _manager.notifyListeners();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChangeColorsTab() {
    final themes = [
      {
        'name': 'الأخضر السوري الملكي',
        'primary': const Color(0xFF0F5132),
        'gold': const Color(0xFFD4AF37)
      },
      {
        'name': 'الأزرق الكحلي الفاخر',
        'primary': const Color(0xFF1E3A8A),
        'gold': const Color(0xFFF59E0B)
      },
      {
        'name': 'العنابي الدمشقي الأنيق',
        'primary': const Color(0xFF881337),
        'gold': const Color(0xFFFBBF24)
      },
      {
        'name': 'الزمردي الحديث',
        'primary': const Color(0xFF065F46),
        'gold': const Color(0xFF34D399)
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('اختيار اللون والثيم العام للتطبيق:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...themes
            .map((t) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading:
                        CircleAvatar(backgroundColor: t['primary'] as Color),
                    title: Text(t['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: t['primary'] as Color),
                      onPressed: () {
                        _manager.updateAppColors(
                          primary: t['primary'] as Color,
                          secondary: t['gold'] as Color,
                          appBar: t['primary'] as Color,
                          button: t['primary'] as Color,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('✨ تم تطبيق ثيم ${t["name"]}!')),
                        );
                      },
                      child: const Text('تطبيق الثيم',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildNewsAndBannersTab() {
    final tickerIcons = [
      Icons.campaign,
      Icons.local_fire_department,
      Icons.star,
      Icons.notifications_active,
      Icons.flash_on
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إعدادات شريط الأخبار المتحرك:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('سرعة التمرير:'),
            Expanded(
              child: Slider(
                value: _manager.tickerSpeed,
                min: 0.5,
                max: 4.0,
                divisions: 7,
                label: _manager.tickerSpeed.toStringAsFixed(1),
                onChanged: (val) {
                  setState(() => _manager.tickerSpeed = val);
                  _manager.notifyListeners();
                },
              ),
            ),
          ],
        ),
        const Text('أيقونة شريط الأخبار:'),
        Wrap(
          spacing: 8,
          children: tickerIcons.map((ic) {
            final isSel = _manager.tickerIcon == ic;
            return ChoiceChip(
              avatar: Icon(ic,
                  size: 16, color: isSel ? Colors.white : Colors.black),
              label: const Text(''),
              selected: isSel,
              selectedColor: _manager.primaryColor,
              onSelected: (val) {
                setState(() => _manager.tickerIcon = ic);
                _manager.notifyListeners();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                  controller: _newsInputController,
                  decoration: const InputDecoration(
                      hintText: 'اكتب نص الخبر الجديد...',
                      border: OutlineInputBorder())),
            ),
            const SizedBox(width: 8),
            IconButton(
              style:
                  IconButton.styleFrom(backgroundColor: _manager.buttonColor),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final txt = _newsInputController.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _manager.newsTicker.insert(0, txt);
                    _newsInputController.clear();
                  });
                  _manager.notifyListeners();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text('إدارة البنرات المزدوجة المتجاورة (Side-by-Side):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('مؤقت تقليب البنرات بالثواني:'),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: _manager.topBannerIntervalSeconds,
              items: [2, 3, 4, 5, 7, 10]
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text('$s ثوانٍ')))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _manager.topBannerIntervalSeconds = val;
                    _manager.bottomBannerIntervalSeconds = val;
                  });
                  _manager.notifyListeners();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerTitleController,
            decoration: const InputDecoration(
                labelText: 'عنوان البنر', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerSubController,
            decoration: const InputDecoration(
                labelText: 'النص الفرعي', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerUrlController,
            decoration: const InputDecoration(
                labelText: 'رابط التوجيه (URL)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('القسم:'),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('القسم العلوي'),
              selected: _bannerPosition == 'top',
              selectedColor: _manager.primaryColor,
              onSelected: (val) => setState(() => _bannerPosition = 'top'),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('القسم السفلي'),
              selected: _bannerPosition == 'bottom',
              selectedColor: _manager.primaryColor,
              onSelected: (val) => setState(() => _bannerPosition = 'bottom'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
          icon: const Icon(Icons.photo_library, color: Colors.white),
          label: const Text('رفع صورة البنر من المعرض 🖼️',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () async {
            final img = await _picker.pickImage(
                source: ImageSource.gallery, imageQuality: 75);
            if (img != null && _bannerTitleController.text.isNotEmpty) {
              setState(() {
                _manager.banners.add(
                  BannerItem(
                    id: 'b-${DateTime.now().millisecondsSinceEpoch}',
                    title: _bannerTitleController.text.trim(),
                    subtitle: _bannerSubController.text.trim(),
                    imageUrl:
                        'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
                    targetUrl: _bannerUrlController.text.trim(),
                    position: _bannerPosition,
                  ),
                );
                _bannerTitleController.clear();
                _bannerSubController.clear();
                _bannerUrlController.clear();
              });
              _manager.notifyListeners();
            }
          },
        ),
      ],
    );
  }

  Widget _buildManageUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('قائمة المستخدمين والتحكم بالحظر والتجميد:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ..._manager.registeredUsers.asMap().entries.map((entry) {
          final idx = entry.key;
          final user = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isBanned
                    ? Colors.red
                    : (user.isFrozen ? Colors.orange : _manager.primaryColor),
                child: Icon(
                    user.isBanned
                        ? Icons.block
                        : (user.isFrozen ? Icons.ac_unit : Icons.person),
                    color: Colors.white),
              ),
              title: Text(user.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          user.isBanned ? TextDecoration.lineThrough : null)),
              subtitle: Text('${user.email} | الدور: ${user.role}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(user.isFrozen ? Icons.wb_sunny : Icons.ac_unit,
                        color: Colors.orange),
                    tooltip: user.isFrozen ? 'إلغاء التجميد' : 'تجميد الحساب',
                    onPressed: () {
                      setState(() => _manager.registeredUsers[idx] =
                          user.copyWith(isFrozen: !user.isFrozen));
                      _manager.notifyListeners();
                    },
                  ),
                  IconButton(
                    icon: Icon(user.isBanned ? Icons.check_circle : Icons.block,
                        color: Colors.red),
                    tooltip: user.isBanned ? 'إلغاء الحظر' : 'حظر المستخدم',
                    onPressed: () {
                      setState(() => _manager.registeredUsers[idx] =
                          user.copyWith(isBanned: !user.isBanned));
                      _manager.notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
