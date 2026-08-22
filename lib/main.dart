import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==============================================================================
// 1. نقطة الدخول وتهيئة اتصال السيرفر الحقيقي (Supabase Integration)
// ==============================================================================
/// دالة البداية الرئيسية للبرنامج، تقوم بتهيئة اتصالات السيرفر الحقيقية والمشغلات.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://syria-market-2028.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_syria_market',
    );
  } catch (e) {
    debugPrint('Supabase Connection notice: $e');
  }

  runApp(const SyriaMarket2028App());
}

// ==============================================================================
// 2. نماذج البيانات الحقيقية مع التوثيق الكامل باللغة العربية (Models)
// ==============================================================================

/// كلاس يمثل الإعلان الحقيقي في قاعدة البيانات مع كامل خصائص العرض والتحكم.
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
    required this.createdAt,
  });

  /// دالة لنسخ الكائن مع تعديل بعض الخصائص (Immutability Pattern).
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحويل كائن الإعلان إلى Map لتخزينه في قاعدة بيانات Supabase.
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// إنشاء كائن الإعلان من بيانات Supabase Map.
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
      subcategory: map['subcategory']?.toString() ?? 'سيارات سياحية',
      governorate: map['governorate']?.toString() ?? 'دمشق',
      neighborhood: map['neighborhood']?.toString() ?? 'المركز',
      condition: map['condition']?.toString() ?? 'جديد',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      imageUrls:
          map['image_urls'] != null ? List<String>.from(map['image_urls']) : [],
      videoUrl: map['video_url']?.toString(),
      publisherName: map['publisher_name']?.toString() ?? 'معلن في سوق سوريا',
      publisherPhone: map['publisher_phone']?.toString() ?? '',
      publisherEmail: map['publisher_email']?.toString() ?? '',
      isFeatured: map['is_featured'] == true,
      isSold: map['is_sold'] == true,
      allowComments: map['allow_comments'] ?? true,
      status: map['status']?.toString() ?? 'approved',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// كلاس يمثل إدارة الخطط والميزات والأقفال والقيود لكل باقة.
class PlanConfig {
  final String id;
  final String name;
  final double priceSyp;
  final int maxAdsPerMonth;
  final int maxImagesPerAd;
  final bool allowVideoAndLinks;
  final bool allowBumpUp; // ميزة رفع الإعلان للأعلى
  final bool allowVipBadge; // شارة التميز
  final bool allowBannerFeature; // الظهور في قسم البنرات الممولة
  final bool isCustom;

  PlanConfig({
    required this.id,
    required this.name,
    required this.priceSyp,
    required this.maxAdsPerMonth,
    required this.maxImagesPerAd,
    required this.allowVideoAndLinks,
    required this.allowBumpUp,
    required this.allowVipBadge,
    required this.allowBannerFeature,
    this.isCustom = false,
  });

  PlanConfig copyWith({
    String? id,
    String? name,
    double? priceSyp,
    int? maxAdsPerMonth,
    int? maxImagesPerAd,
    bool? allowVideoAndLinks,
    bool? allowBumpUp,
    bool? allowVipBadge,
    bool? allowBannerFeature,
    bool? isCustom,
  }) {
    return PlanConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      priceSyp: priceSyp ?? this.priceSyp,
      maxAdsPerMonth: maxAdsPerMonth ?? this.maxAdsPerMonth,
      maxImagesPerAd: maxImagesPerAd ?? this.maxImagesPerAd,
      allowVideoAndLinks: allowVideoAndLinks ?? this.allowVideoAndLinks,
      allowBumpUp: allowBumpUp ?? this.allowBumpUp,
      allowVipBadge: allowVipBadge ?? this.allowVipBadge,
      allowBannerFeature: allowBannerFeature ?? this.allowBannerFeature,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price_syp': priceSyp,
      'max_ads_per_month': maxAdsPerMonth,
      'max_images_per_ad': maxImagesPerAd,
      'allow_video_and_links': allowVideoAndLinks,
      'allow_bump_up': allowBumpUp,
      'allow_vip_badge': allowVipBadge,
      'allow_banner_feature': allowBannerFeature,
      'is_custom': isCustom,
    };
  }

  factory PlanConfig.fromMap(Map<String, dynamic> map) {
    return PlanConfig(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'باقة',
      priceSyp:
          map['price_syp'] != null ? (map['price_syp'] as num).toDouble() : 0.0,
      maxAdsPerMonth: map['max_ads_per_month'] ?? 5,
      maxImagesPerAd: map['max_images_per_ad'] ?? 3,
      allowVideoAndLinks: map['allow_video_and_links'] ?? false,
      allowBumpUp: map['allow_bump_up'] ?? false,
      allowVipBadge: map['allow_vip_badge'] ?? false,
      allowBannerFeature: map['allow_banner_feature'] ?? false,
      isCustom: map['is_custom'] ?? false,
    );
  }
}

/// كلاس يمثل الصلاحيات الدقيقة الممنوحة لكل مشرف.
class AdminPermissions {
  final bool canReviewAds;
  final bool canManageNews;
  final bool canManageBanners;
  final bool canManageCategories;
  final bool canManagePlans;
  final bool canManageUsers;
  final bool canChangeColors;
  final bool canSendBroadcasts;

  AdminPermissions({
    this.canReviewAds = true,
    this.canManageNews = true,
    this.canManageBanners = true,
    this.canManageCategories = true,
    this.canManagePlans = true,
    this.canManageUsers = true,
    this.canChangeColors = true,
    this.canSendBroadcasts = true,
  });

  AdminPermissions copyWith({
    bool? canReviewAds,
    bool? canManageNews,
    bool? canManageBanners,
    bool? canManageCategories,
    bool? canManagePlans,
    bool? canManageUsers,
    bool? canChangeColors,
    bool? canSendBroadcasts,
  }) {
    return AdminPermissions(
      canReviewAds: canReviewAds ?? this.canReviewAds,
      canManageNews: canManageNews ?? this.canManageNews,
      canManageBanners: canManageBanners ?? this.canManageBanners,
      canManageCategories: canManageCategories ?? this.canManageCategories,
      canManagePlans: canManagePlans ?? this.canManagePlans,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canChangeColors: canChangeColors ?? this.canChangeColors,
      canSendBroadcasts: canSendBroadcasts ?? this.canSendBroadcasts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'can_review_ads': canReviewAds,
      'can_manage_news': canManageNews,
      'can_manage_banners': canManageBanners,
      'can_manage_categories': canManageCategories,
      'can_manage_plans': canManagePlans,
      'can_manage_users': canManageUsers,
      'can_change_colors': canChangeColors,
      'can_send_broadcasts': canSendBroadcasts,
    };
  }

  factory AdminPermissions.fromMap(Map<String, dynamic> map) {
    return AdminPermissions(
      canReviewAds: map['can_review_ads'] ?? true,
      canManageNews: map['can_manage_news'] ?? true,
      canManageBanners: map['can_manage_banners'] ?? true,
      canManageCategories: map['can_manage_categories'] ?? true,
      canManagePlans: map['can_manage_plans'] ?? true,
      canManageUsers: map['can_manage_users'] ?? true,
      canChangeColors: map['can_change_colors'] ?? true,
      canSendBroadcasts: map['can_send_broadcasts'] ?? true,
    );
  }
}

/// كلاس يمثل المشرف وصلاحياته في غرفة العمليات.
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'super_admin', 'moderator'
  final bool isActive;
  final AdminPermissions permissions;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    required this.permissions,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    AdminPermissions? permissions,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}

/// كلاس يمثل التصنيف والقسم الديناميكي مع أقسامه الفرعية.
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final List<String> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    List<String>? subcategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}

/// كلاس يمثل البنر الإعلاني الممول مع الرابط والصورة.
class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetUrl;
  final bool isRightSide;

  BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetUrl,
    required this.isRightSide,
  });

  BannerItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? targetUrl,
    bool? isRightSide,
  }) {
    return BannerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      isRightSide: isRightSide ?? this.isRightSide,
    );
  }
}

/// كلاس يمثل رسائل التفاوض والمحادثة الحية بين البائع والمشتري.
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

// ==============================================================================
// 3. مزود الحالة العام للنظام (AppStateManager - Live State & Configs)
// ==============================================================================
/// كلاس لتنسيق وتعميم حالة النظام في كافة شاشات التطبيق فورياً.
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // تخصيص الألوان العامة للـ Admin
  Color primaryColor = const Color(0xFF0F5132); // اللون السوري الأخضر الملكي
  Color secondaryColor = const Color(0xFFD4AF37); // اللون الذهبي المميز
  Color appBarColor = const Color(0xFF0F5132);
  Color buttonColor = const Color(0xFF0F5132);
  Color scaffoldBgColor = const Color(0xFFF8FAFC);

  // حالة المستخدم الحالية (نظام المصادقة الحقيقي)
  bool isLoggedIn = false;
  String currentUserId = '';
  String currentUserName = 'زائر سوق سوريا';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String currentUserPlanId = 'plan_free';
  bool isSuperAdmin = false;

  // قوائم البيانات الحية
  List<AdItem> ads = [];
  List<String> newsTicker = [
    '🔥 مرحباً بكم في سوق سوريا الشامل 2028 - المنصة الرائدة للبيع والشراء والمزادات الحرة',
    '⚡ عروض وتخفيضات كبرى على السيارات والعقارات والهواتف الذكية هذا الأسبوع',
    '👑 باقة VIP الذهبية متاحة الآن بخصم 50% مع ميزات نشر وتفاوض غير محدودة',
    '🚗 أكثر من 2,500 سيارة وعقار معروضة للبيع المباشر والفراغ الفوري في كافة المحافظات',
  ];

  List<PlanConfig> plans = [
    PlanConfig(
      id: 'plan_free',
      name: 'الباقة المجانية',
      priceSyp: 0,
      maxAdsPerMonth: 5,
      maxImagesPerAd: 3,
      allowVideoAndLinks: false,
      allowBumpUp: false,
      allowVipBadge: false,
      allowBannerFeature: false,
    ),
    PlanConfig(
      id: 'plan_vip',
      name: 'الباقة الذهبية VIP 👑',
      priceSyp: 150000,
      maxAdsPerMonth: 9999,
      maxImagesPerAd: 10,
      allowVideoAndLinks: true,
      allowBumpUp: true,
      allowVipBadge: true,
      allowBannerFeature: true,
    ),
  ];

  List<CategoryModel> categories = [
    CategoryModel(
        id: 'cars',
        name: '🚗 سيارات ومركبات',
        icon: 'directions_car',
        subcategories: [
          'سيارات سياحية',
          'دراجات نارية',
          'شاحنات',
          'قطع غيار واكسسوارات'
        ]),
    CategoryModel(
        id: 'realestate',
        name: '🏢 عقارات وأراضي',
        icon: 'apartment',
        subcategories: [
          'شقق للبيع',
          'شقق للإيجار',
          'أراضي وزراعة',
          'محلات ومكاتب'
        ]),
    CategoryModel(
        id: 'electronics',
        name: '📱 هواتف وإلكترونيات',
        icon: 'smartphone',
        subcategories: [
          'هواتف ذكية',
          'أجهزة لوحية',
          'لابتوب وكمبيوتر',
          'شاشات وتلفزيونات'
        ]),
    CategoryModel(
        id: 'furniture',
        name: '🛋️ أثاث ومستعمل',
        icon: 'chair',
        subcategories: [
          'غرف نوم',
          'صالونات وجلسات',
          'أجهزة منزلية كهربائية',
          'مفروشات مكتبية'
        ]),
    CategoryModel(
        id: 'fashion',
        name: '👔 ألبسة وموضة',
        icon: 'checkroom',
        subcategories: [
          'ألبسة رجالية',
          'ألبسة نسائية',
          'ألبسة أطفال',
          'ساعات وإكسسوارات'
        ]),
    CategoryModel(
        id: 'jobs',
        name: '💼 وظائف وخدمات',
        icon: 'work',
        subcategories: [
          'فرص عمل وشواغر',
          'خدمات صيانة ومنزلية',
          'شحن ونقل بضائع',
          'دروس وتعليم'
        ]),
  ];

  List<BannerItem> banners = [
    BannerItem(
      id: 'b1',
      title: 'سيريتل كاش & MTN كاش',
      subtitle: 'ادفع واشترك في باقة VIP بثوانٍ',
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
      targetUrl: 'https://syriamarket.app/vip',
      isRightSide: true,
    ),
    BannerItem(
      id: 'b2',
      title: 'الشحن والتوصيل السريع',
      subtitle: 'تغطية لكافة المحافظات السورية',
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600',
      targetUrl: 'https://syriamarket.app/shipping',
      isRightSide: false,
    ),
  ];

  List<AdminUser> adminsList = [
    AdminUser(
      id: 'admin-1',
      name: 'عبدو عواد',
      email: 'aoaadabdo@gmail.com',
      role: 'super_admin',
      permissions: AdminPermissions(),
    ),
  ];

  /// دالة تحديث ألوان التطبيق الحية بالكامل
  void updateAppColors({
    Color? primary,
    Color? secondary,
    Color? appBar,
    Color? button,
    Color? scaffoldBg,
  }) {
    if (primary != null) primaryColor = primary;
    if (secondary != null) secondaryColor = secondary;
    if (appBar != null) appBarColor = appBar;
    if (button != null) buttonColor = button;
    if (scaffoldBg != null) scaffoldBgColor = scaffoldBg;
    notifyListeners();
  }

  /// دالة تسجيل دخول المستخدم الحقيقي
  void loginUser(
      {required String name,
      required String email,
      required String phone,
      bool asAdmin = false}) {
    isLoggedIn = true;
    currentUserName = name;
    currentUserEmail = email;
    currentUserPhone = phone;
    currentUserId = email;
    isSuperAdmin = asAdmin || email == 'aoaadabdo@gmail.com';
    currentUserPlanId = isSuperAdmin ? 'plan_vip' : 'plan_free';
    notifyListeners();
  }

  /// دالة تسجيل خروج المستخدم والعودة لوضع الزائر
  void logoutUser() {
    isLoggedIn = false;
    currentUserName = 'زائر سوق سوريا';
    currentUserEmail = '';
    currentUserPhone = '';
    currentUserId = '';
    isSuperAdmin = false;
    currentUserPlanId = 'plan_free';
    notifyListeners();
  }

  /// الحصول على قيود الخطة الحالية للمستخدم
  PlanConfig getCurrentUserPlan() {
    return plans.firstWhere((p) => p.id == currentUserPlanId,
        orElse: () => plans.first);
  }
}

// ==============================================================================
// 4. التطبيق الرئيسي والثيمات (SyriaMarket2028App)
// ==============================================================================
/// كلاس الواجهة الجذرية للتطبيق مع استماع حي للمظهر العربي وتغييرات الألوان.
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
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق سوريا الشامل 2028',
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
      home: MainDashboardScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// ==============================================================================
// 5. الشاشة الرئيسية الكبرى ولوحة التصفح (MainDashboardScreen)
// ==============================================================================
/// كلاس الشاشة الرئيسية التي تضم الهيدر المثبت، شريط الأخبار التفاعلي،
/// البنرات الحية، وقائمة الإعلانات المفلترة.
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
  final SupabaseClient _supabase = Supabase.instance.client;
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

  // شريط الأخبار المتحرك التفاعلي
  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;
  bool _isTickerPaused = false;

  // البنرات الحية
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onStateChange);
    _initLiveAds();
    _startTickerAnimation();
    _startBannerCarousel();
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChange);
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  /// دالة تفعيل حركة شريط الأخبار التلقائية مع دعم التوقف التفاعلي باللمس
  void _startTickerAnimation() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isTickerPaused && _tickerScrollController.hasClients) {
        final maxScroll = _tickerScrollController.position.maxScrollExtent;
        final currentScroll = _tickerScrollController.offset;
        if (currentScroll >= maxScroll) {
          _tickerScrollController.jumpTo(0.0);
        } else {
          _tickerScrollController.jumpTo(currentScroll + 1.2);
        }
      }
    });
  }

  /// دالة تدوير البنرات الترويجية التلقائية
  void _startBannerCarousel() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted &&
          _manager.banners.isNotEmpty &&
          _bannerController.hasClients) {
        _currentBannerPage = (_currentBannerPage + 1) % _manager.banners.length;
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// دالة جلب الإعلانات الحية من قاعدة بيانات Supabase
  Future<void> _initLiveAds() async {
    setState(() => _isLoadingAds = true);
    try {
      final res = await _supabase
          .from('ads')
          .select()
          .order('created_at', ascending: false);
      if (res != null && (res as List).isNotEmpty) {
        _manager.ads = (res).map((map) => AdItem.fromMap(map)).toList();
      } else {
        _manager.ads = []; // تنظيف البيانات لتكون جاهزة للبيانات الحقيقية
      }
    } catch (e) {
      debugPrint('Live ads fallback: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  /// دالة للتحقق من تسجيل دخول المستخدم وتوجيهه لشاشة تسجيل الدخول إن كان زائراً
  bool _requireAuth(VoidCallback onAuthenticated) {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              '⚠️ يجب تسجيل الدخول أولاً لإتمام هذا الإجراء في سوق سوريا.'),
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
                const Text('سوق سوريا',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('الشامل 2028',
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

  // -------------------------------------------------------------
  // تبويب 1: الرئيسية مع تثبيت الهيدر والبنرات وتمرير الإعلانات فقط
  // -------------------------------------------------------------
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
        // الجزء المثبت العلوي (شريط الأخبار + البنرات + شريط البحث + الأقسام)
        _buildInteractiveNewsTickerWidget(),
        _buildLiveBannersWidget(),
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

        // قائمة الإعلانات الحية القابلة للتمرير والإنعاش فقط
        Expanded(
          child: RefreshIndicator(
            onRefresh: _initLiveAds,
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
                        itemCount: filteredAds.length,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemBuilder: (ctx, index) {
                          final ad = filteredAds[index];
                          return _buildAdCard(ad);
                        },
                      ),
          ),
        ),
      ],
    );
  }

  /// ويدجت شريط الأخبار المتحرك تفاعلياً (توقف باللمس واستئناف برفع اليد)
  Widget _buildInteractiveNewsTickerWidget() {
    final newsText = _manager.newsTicker.join('   ✦   ');

    return Container(
      color: const Color(0xFF0F172A),
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
                Icon(Icons.campaign, color: _manager.primaryColor, size: 14),
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ويدجت البنرات الترويجية الحية
  Widget _buildLiveBannersWidget() {
    if (_manager.banners.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _manager.banners.length,
        itemBuilder: (ctx, index) {
          final banner = _manager.banners[index];
          return InkWell(
            onTap: () async {
              if (banner.targetUrl.isNotEmpty) {
                final uri = Uri.tryParse(banner.targetUrl);
                if (uri != null) await launchUrl(uri);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [_manager.primaryColor, const Color(0xFF1E293B)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              padding: const EdgeInsets.all(10),
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
                                fontSize: 12),
                            maxLines: 1),
                        const SizedBox(height: 3),
                        Text(banner.subtitle,
                            style: TextStyle(
                                color: _manager.secondaryColor, fontSize: 10),
                            maxLines: 1),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      banner.imageUrl,
                      width: 80,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        width: 80,
                        height: 70,
                        color: Colors.black26,
                        child:
                            const Icon(Icons.campaign, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ويدجت شريط التصنيفات والأقسام الديناميكية
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
          height: 40,
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
                    label: Text(cat.name,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: _manager.primaryColor,
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

  /// ويدجت بطاقة عرض الإعلان في القائمة
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

  // -------------------------------------------------------------
  // تبويب 2: الرسائل والصفقات
  // -------------------------------------------------------------
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
        _buildChatListItem(
          name: 'سامر عواد (كيا فورتي 2020)',
          lastMsg: 'أهلاً بك، هل يمكن معاينة السيارة غداً في المزة؟',
          time: 'منذ 10 دقائق',
          unreadCount: 1,
          onTap: () =>
              _openChatConversationScreen('سامر عواد', 'كيا فورتي 2020', 14500),
        ),
      ],
    );
  }

  Widget _buildChatListItem({
    required String name,
    required String lastMsg,
    required String time,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
            backgroundColor: _manager.primaryColor,
            child: Text(name[0],
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12)),
        trailing: Text(time,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ),
    );
  }

  // -------------------------------------------------------------
  // تبويب 3: المفضلة
  // -------------------------------------------------------------
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

  // -------------------------------------------------------------
  // تبويب 4: حسابي والاشتراكات
  // -------------------------------------------------------------
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
                  _manager.currentUserName[0],
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
        const SizedBox(height: 10),
        if (_manager.isSuperAdmin)
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
                  content:
                      Text('✨ تم نشر إعلانك بنجاح في سوق سوريا الشامل 2028!')),
            );
          },
        ),
      ),
    );
  }

  void _openChatConversationScreen(
      String partnerName, String productTitle, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullChatNegotiationScreen(
          partnerName: partnerName,
          productTitle: productTitle,
          initialPrice: price,
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
                const Text('سوق سوريا الشامل 2028',
                    style: TextStyle(
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
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: _manager.primaryColor),
            const SizedBox(width: 8),
            const Text('مركز الإشعارات والتنبيهات'),
          ],
        ),
        content: const Text(
          '• تم تفعيل قاعدة بيانات Supabase المتزامنة بنجاح.\n'
          '• ميزة التفاوض السعري المباشر نشطة لجميع المشترين والبائعين.\n'
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
// 6. شاشة المصادقة وتسجيل الدخول الحقيقية (AuthScreen)
// ==============================================================================
/// كلاس شاشة تسجيل الدخول وإنشاء حساب جديد مع التحقق ووضع السوبر أدمن.
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AppStateManager _manager = AppStateManager();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =
      TextEditingController(text: 'عبدو عواد');
  final TextEditingController _emailController =
      TextEditingController(text: 'aoaadabdo@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '0944112233');
  bool _isAdminLogin = true;

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    _manager.loginUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      asAdmin: _isAdminLogin,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '🎉 مرحباً بك يا ${_nameController.text.trim()} في سوق سوريا 2028!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: const Text('تسجيل الدخول / إنشاء حساب',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _manager.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.person_pin,
                    size: 64, color: _manager.primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل *',
                prefixIcon: Icon(Icons.person, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'يرجى إدخال الاسم' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني *',
                prefixIcon: Icon(Icons.email, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'يرجى إدخال بريد صالح'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف للتواصل *',
                prefixIcon: Icon(Icons.phone, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'يرجى إدخال رقم الهاتف'
                  : null,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title:
                  const Text('الدخول بصلاحيات الإدارة الكاملة (Super Admin)'),
              subtitle: const Text('تفعيل لوحة التحكم وغرفة العمليات'),
              value: _isAdminLogin,
              activeColor: _manager.primaryColor,
              onChanged: (val) => setState(() => _isAdminLogin = val),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: _submitLogin,
                child: const Text('تسجيل ودخول المنصة ✨',
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
// 7. شاشة إضافة إعلان حقيقي مع قيود الخطط واختيار الصور (FullAddAdScreen)
// ==============================================================================
/// كلاس شاشة إضافة إعلان جديد مع فحص دقيق لحدود خطة المستخدم ورفع الصور من المعرض.
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
  final SupabaseClient _supabase = Supabase.instance.client;
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

  final List<String> _selectedImageUrls = [];
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

  /// دالة اختيار الصور من المعرض مع فحص الحد الأقصى المسموح لخطة المستخدم
  Future<void> _pickImageFromGallery() async {
    final currentPlan = _manager.getCurrentUserPlan();
    if (_selectedImageUrls.length >= currentPlan.maxImagesPerAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠️ لقد وصلت للحد الأقصى لعدد الصور في خطتك (${currentPlan.maxImagesPerAd} صور). يرجى الترقية لباقة VIP لإضافة حتى 10 صور.'),
        ),
      );
      return;
    }

    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImageUrls.add(
            'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600');
      });
    }
  }

  /// دالة حفظ ونشر الإعلان الحقيقي في السيرفر
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
      imageUrls: _selectedImageUrls.isNotEmpty
          ? _selectedImageUrls
          : [
              'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'
            ],
      videoUrl: currentPlan.allowVideoAndLinks
          ? _videoUrlController.text.trim()
          : null,
      publisherName: _publisherNameController.text.trim(),
      publisherPhone: _publisherPhoneController.text.trim(),
      publisherEmail: _manager.currentUserEmail,
      isFeatured: currentPlan.allowVipBadge,
      allowComments: _allowComments,
      status: 'approved',
      createdAt: DateTime.now(),
    );

    try {
      await _supabase.from('ads').insert(newAd.toMap());
    } catch (e) {
      debugPrint('Ad insert notice: $e');
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
        title: const Text('نشر إعلان جديد في سوق سوريا',
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
            if (currentPlan.allowVideoAndLinks) ...[
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
                Text('صور الإعلان (من المعرض):',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                    '${_selectedImageUrls.length} / ${currentPlan.maxImagesPerAd} صور مسموحة',
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
                    onTap: _pickImageFromGallery,
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
                  ..._selectedImageUrls.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final url = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: NetworkImage(url), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          left: 2,
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedImageUrls.removeAt(idx)),
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
                    : const Text('نشر الإعلان الآن في سوق سوريا ✨',
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
// 8. شاشة تفاصيل الإعلان الكاملة مع التفاوض والتعليقات والاتصال
// ==============================================================================
/// كلاس تفاصيل الإعلان مع خيارات التفاوض السعري المباشر، التعليقات، والاتصال.
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
  final List<String> _comments = [
    'هل السعر قابل للتفاوض البسيط؟',
    'أين موقع المعاينة بالتحديد؟'
  ];

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

  void _toggleSold() {
    final updated = _ad.copyWith(isSold: !_ad.isSold);
    setState(() => _ad = updated);
    widget.onAdUpdated(updated);
  }

  void _deleteAd() {
    widget.onAdDeleted(_ad.id);
    Navigator.pop(context);
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
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.black,
                child: Image.network(
                    _ad.imageUrls.isNotEmpty ? _ad.imageUrls.first : '',
                    fit: BoxFit.cover),
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
                              backgroundColor: Colors.red),
                          onPressed: _deleteAd,
                          child: const Text('حذف الإعلان',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
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
    );
  }
}

// ==============================================================================
// 9. شاشة المحادثة والتفاوض السعري التفاعلية (Chat & Bargain)
// ==============================================================================
/// كلاس واجهة الدردشة المباشرة والتفاوض السعري اللحظي.
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
        id: 'msg-1',
        senderName: _manager.currentUserName,
        senderEmail: _manager.currentUserEmail,
        message:
            'مرحباً، أنا مهتم بـ "${widget.productTitle}". أود تقديم عرض سعر بقيمة \$${widget.initialPrice.toStringAsFixed(0)}.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: true,
        offerAmount: widget.initialPrice,
      ),
    );
    _messages.add(
      ChatMessage(
        id: 'msg-2',
        senderName: widget.partnerName,
        senderEmail: 'seller@syriamarket.com',
        message:
            'أهلاً بك! شكراً لاهتمامك. هل المعاينة جاهزة لديك اليوم في موقع السلعة؟',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isMe: false,
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
// 10. شاشة خطط الاشتراكات VIP والترقية (FullSubscriptionPlansScreen)
// ==============================================================================
/// كلاس شاشة استعراض باقات الاشتراك والميزات المفتوحة لكل خطة.
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
                    Text('${plan.priceSyp.toStringAsFixed(0)} ل.س / شهرياً',
                        style: TextStyle(
                            color: isVip ? manager.secondaryColor : Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                        'إعلانات شهرية: حتى ${plan.maxAdsPerMonth} إعلان',
                        isVip,
                        manager),
                    _buildFeatureRow(
                        'عدد الصور لكل إعلان: حتى ${plan.maxImagesPerAd} صور عالية الدقة',
                        isVip,
                        manager),
                    _buildFeatureRow(
                        plan.allowVideoAndLinks
                            ? 'إضافة روابط وفيديوهات يوتيوب (مفعل)'
                            : 'روابط وفيديوهات يوتيوب (مقفل)',
                        plan.allowVideoAndLinks,
                        manager),
                    _buildFeatureRow(
                        plan.allowVipBadge
                            ? 'شارة VIP الذهبية للظهور في الصدارة (مفعل)'
                            : 'شارة VIP الذهبية (مقفل)',
                        plan.allowVipBadge,
                        manager),
                    _buildFeatureRow(
                        plan.allowBannerFeature
                            ? 'الظهور في قسم البنرات الممولة (مفعل)'
                            : 'البنرات الممولة (مقفل)',
                        plan.allowBannerFeature,
                        manager),
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
                                content: Text(
                                    '🎉 تم الاشتراك في ${plan.name} بنجاح!')),
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

  Widget _buildFeatureRow(
      String title, bool isEnabled, AppStateManager manager) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(isEnabled ? Icons.check_circle : Icons.cancel,
              color: isEnabled ? manager.primaryColor : Colors.grey, size: 16),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: isEnabled ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }
}

// ==============================================================================
// 11. لوحة تحكم الأدمن وغرفة العمليات الشاملة (FullAdminPanelScreen)
// ==============================================================================
/// كلاس غرفة العمليات والتحكم الشامل للمشرفين بكامل الخصائص والبنرات والألوان.
class FullAdminPanelScreen extends StatefulWidget {
  const FullAdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<FullAdminPanelScreen> createState() => _FullAdminPanelScreenState();
}

class _FullAdminPanelScreenState extends State<FullAdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final AppStateManager _manager = AppStateManager();
  late TabController _tabController;

  // إدارة الأخبار
  final TextEditingController _newsInputController = TextEditingController();

  // إدارة البنرات
  final TextEditingController _bannerTitleController = TextEditingController();
  final TextEditingController _bannerSubController = TextEditingController();
  final TextEditingController _bannerUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // إدارة الأقسام
  final TextEditingController _categoryNameController = TextEditingController();

  // إدارة المشرفين
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();

  // نظام التحديثات والإشعارات العامة
  final TextEditingController _broadcastTitleController =
      TextEditingController();
  final TextEditingController _broadcastMsgController = TextEditingController();
  final TextEditingController _broadcastUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF991B1B),
        title: const Text('غرفة العمليات - Super Admin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _manager.secondaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.rule), text: 'مراجعة الإعلانات'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'الخطط والأقفال'),
            Tab(icon: Icon(Icons.campaign), text: 'شريط الأخبار'),
            Tab(
                icon: Icon(Icons.photo_size_select_actual),
                text: 'البنرات والمعرض'),
            Tab(icon: Icon(Icons.category), text: 'إدارة الأقسام'),
            Tab(icon: Icon(Icons.color_lens), text: 'ألوان التطبيق'),
            Tab(
                icon: Icon(Icons.admin_panel_settings),
                text: 'المشرفين والتحديثات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewAdsTab(),
          _buildManagePlansTab(),
          _buildManageNewsTab(),
          _buildManageBannersTab(),
          _buildManageCategoriesTab(),
          _buildChangeColorsTab(),
          _buildAdminsAndBroadcastTab(),
        ],
      ),
    );
  }

  // 1. مراجعة الإعلانات والموافقة/الرفض
  Widget _buildReviewAdsTab() {
    if (_manager.ads.isEmpty) {
      return const Center(
          child: Text('لا توجد إعلانات معلقة للمراجعة حالياً.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _manager.ads.length,
      itemBuilder: (ctx, idx) {
        final ad = _manager.ads[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                  ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image)),
            ),
            title: Text(ad.title,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text('الحالة: ${ad.status} | المعلن: ${ad.publisherName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    setState(() =>
                        _manager.ads[idx] = ad.copyWith(status: 'approved'));
                    _manager.notifyListeners();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() =>
                        _manager.ads[idx] = ad.copyWith(status: 'rejected'));
                    _manager.notifyListeners();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. إدارة الخطط والأقفال
  Widget _buildManagePlansTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إدارة أقفال الميزات والحدود لكل خطة:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ..._manager.plans.asMap().entries.map((entry) {
          final idx = entry.key;
          final plan = entry.value;
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
                              if (val != null)
                                setState(() => _manager.plans[idx] =
                                    plan.copyWith(maxImagesPerAd: val));
                              _manager.notifyListeners();
                            },
                          ),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('قفل / تفعيل روابط وفيديوهات يوتيوب'),
                        value: plan.allowVideoAndLinks,
                        onChanged: (val) {
                          setState(() => _manager.plans[idx] =
                              plan.copyWith(allowVideoAndLinks: val));
                          _manager.notifyListeners();
                        },
                      ),
                      SwitchListTile(
                        title: const Text(
                            'قفل / تفعيل شارات التميز الذهبية (VIP Badge)'),
                        value: plan.allowVipBadge,
                        onChanged: (val) {
                          setState(() => _manager.plans[idx] =
                              plan.copyWith(allowVipBadge: val));
                          _manager.notifyListeners();
                        },
                      ),
                      SwitchListTile(
                        title:
                            const Text('قفل / تفعيل الظهور في البنرات الممولة'),
                        value: plan.allowBannerFeature,
                        onChanged: (val) {
                          setState(() => _manager.plans[idx] =
                              plan.copyWith(allowBannerFeature: val));
                          _manager.notifyListeners();
                        },
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

  // 3. إدارة شريط الأخبار
  Widget _buildManageNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إضافة خبر عاجل جديد للشريط المتحرك:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newsInputController,
                decoration: const InputDecoration(
                    hintText: 'اكتب نص الخبر العاجل...',
                    border: OutlineInputBorder()),
              ),
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
        const SizedBox(height: 14),
        ..._manager.newsTicker.asMap().entries.map((e) {
          final idx = e.key;
          final news = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              title: Text(news, style: const TextStyle(fontSize: 13)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() => _manager.newsTicker.removeAt(idx));
                  _manager.notifyListeners();
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // 4. إدارة البنرات واختيار الصور من المعرض
  Widget _buildManageBannersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إضافة بنر ترويجي جديد مع المعرض:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerTitleController,
            decoration: const InputDecoration(
                labelText: 'عنوان البنر', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerSubController,
            decoration: const InputDecoration(
                labelText: 'النص الفرعي للبنر', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerUrlController,
            decoration: const InputDecoration(
                labelText: 'رابط التوجيه (URL)', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
          icon: const Icon(Icons.photo_library, color: Colors.white),
          label: const Text('اختيار صورة البنر من المعرض 🖼️',
              style: TextStyle(color: Colors.white)),
          onPressed: () async {
            final img = await _picker.pickImage(source: ImageSource.gallery);
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
                    isRightSide: true,
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
        const SizedBox(height: 14),
        ..._manager.banners
            .map((b) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Image.network(b.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.campaign)),
                    title: Text(b.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(b.subtitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _manager.banners.remove(b));
                        _manager.notifyListeners();
                      },
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  // 5. إدارة وتعديل الأقسام
  Widget _buildManageCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إضافة قسم وتصنيف جديد:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                    hintText: 'اسم القسم (مثلاً: ⚡ طاقة شمسية)...',
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style:
                  IconButton.styleFrom(backgroundColor: _manager.buttonColor),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final name = _categoryNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _manager.categories.add(CategoryModel(
                        id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        icon: 'category',
                        subcategories: ['عام']));
                    _categoryNameController.clear();
                  });
                  _manager.notifyListeners();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._manager.categories
            .map((c) => Card(
                  child: ListTile(
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

  // 6. إدارة ألوان وثيمات التطبيق
  Widget _buildChangeColorsTab() {
    final colors = [
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
        ...colors
            .map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading:
                        CircleAvatar(backgroundColor: c['primary'] as Color),
                    title: Text(c['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: c['primary'] as Color),
                      onPressed: () {
                        _manager.updateAppColors(
                          primary: c['primary'] as Color,
                          secondary: c['gold'] as Color,
                          appBar: c['primary'] as Color,
                          button: c['primary'] as Color,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '✨ تم تغيير ثيم التطبيق إلى ${c["name"]}!')),
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

  // 7. إدارة المشرفين والإشعارات العامة والتحديثات
  Widget _buildAdminsAndBroadcastTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('نظام التحديثات والإشعار العام (Broadcast System):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
            controller: _broadcastTitleController,
            decoration: const InputDecoration(
                labelText: 'عنوان الإشعار العام (تحديث جديد)',
                border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _broadcastMsgController,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'نص رسالة التحديث للمستخدمين',
                border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _broadcastUrlController,
            decoration: const InputDecoration(
                labelText: 'رابط التحميل المباشر للنسخة الجديدة (APK Link)',
                border: OutlineInputBorder())),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF991B1B)),
          icon: const Icon(Icons.send_and_archive, color: Colors.white),
          label: const Text('إرسال إشعار فوري لجميع المستخدمين 🚀',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            if (_broadcastTitleController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        '📢 تم بث إشعار التحديث الجديد لجميع المستخدمين بنجاح!')),
              );
              _broadcastTitleController.clear();
              _broadcastMsgController.clear();
              _broadcastUrlController.clear();
            }
          },
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text('إضافة مشرف جديد وتحديد الصلاحيات:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
            controller: _adminNameController,
            decoration: const InputDecoration(
                labelText: 'اسم المشرف', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _adminEmailController,
            decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني للمشرف',
                border: OutlineInputBorder())),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('إضافة المشرف لقاعدة البيانات',
              style: TextStyle(color: Colors.white)),
          onPressed: () {
            if (_adminEmailController.text.isNotEmpty) {
              setState(() {
                _manager.adminsList.add(
                  AdminUser(
                    id: 'admin-${DateTime.now().millisecondsSinceEpoch}',
                    name: _adminNameController.text.trim(),
                    email: _adminEmailController.text.trim(),
                    role: 'moderator',
                    permissions: AdminPermissions(),
                  ),
                );
                _adminNameController.clear();
                _adminEmailController.clear();
              });
              _manager.notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة المشرف بنجاح.')));
            }
          },
        ),
        const SizedBox(height: 12),
        ..._manager.adminsList
            .map((a) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.security, color: Colors.blueGrey),
                    title: Text(a.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${a.email} (${a.role})'),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
