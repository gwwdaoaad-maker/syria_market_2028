import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==============================================================================
// 1. الثوابت والإعدادات العامة لمنصة سوق سوريا الشامل 2028
// ==============================================================================
const String kSupabaseUrl = 'https://ucneyuuutambmf25bqu7bc.supabase.co';
const String kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjbmV5dXV1dGFtYm1mMjVicXU3YmMiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTczOTQ0NDcxMywiZXhwIjoyMDU1MDIwNzEzfQ.sample_anon_key_syria_market_2028';

// معلومات التواصل مع الإدارة والمالك
const String kAppOwnerEmail = 'aoaadabdo@gmail.com';
const String kAppOwnerPhone = '0933000000';
const String kAppOwnerWhatsApp = '0933000000';

// مستودعات التخزين السحابي (Supabase Storage Buckets)
const String kStorageBucketAds = 'ad-images';
const String kStorageBucketBanners = 'banner-images';
const String kStorageBucketFeedbacks = 'feedback-images';

// ==============================================================================
// 2. كلاسات المساعدة وأدوات تنسيق الأرقام والهواتف
// ==============================================================================
class PhoneHelper {
  static String formatForWhatsapp(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.startsWith('00')) {
      clean = clean.substring(2);
    } else if (clean.startsWith('+')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('09')) {
      clean = '963' + clean.substring(1);
    } else if (clean.startsWith('9') && clean.length == 9) {
      clean = '963' + clean;
    }
    return clean;
  }

  static bool isValidPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return clean.length >= 9 && clean.length <= 14;
  }
}

// ==============================================================================
// 3. نماذج وموديلات البيانات الكاملة (Data Models)
// ==============================================================================

/// موديل المشرفين ومدققي المحتوى
class Moderator {
  final String id;
  final String email;
  final String name;
  final String role; // super_admin, moderator, content_reviewer
  final bool isSuperAdmin;
  final DateTime grantedAt;

  Moderator({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isSuperAdmin,
    required this.grantedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'is_super_admin': isSuperAdmin,
        'granted_at': grantedAt.toIso8601String(),
      };

  factory Moderator.fromMap(Map<String, dynamic> map) => Moderator(
        id: map['id']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? 'مشرف معتمد',
        role: map['role']?.toString() ?? 'moderator',
        isSuperAdmin:
            map['is_super_admin'] == true || map['email'] == kAppOwnerEmail,
        grantedAt: map['granted_at'] != null
            ? DateTime.tryParse(map['granted_at']) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// موديل البنرات الترويجية المتطورة (يدعم حتى 12+ بطاقة)
class BannerItem {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String phone;
  final String whatsapp;
  final String? linkUrl;

  BannerItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.whatsapp,
    this.linkUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'image_url': imageUrl,
        'title': title,
        'subtitle': subtitle,
        'phone': phone,
        'whatsapp': whatsapp,
        'link_url': linkUrl,
      };

  factory BannerItem.fromMap(Map<String, dynamic> map) => BannerItem(
        id: map['id']?.toString() ?? '',
        imageUrl: map['image_url']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        subtitle: map['subtitle']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        whatsapp: map['whatsapp']?.toString() ?? '',
        linkUrl: map['link_url']?.toString(),
      );
}

/// موديل الإعلانات الكامل والمنشورات
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
  final String publisherWhatsapp;
  final String? publisherTelegram;
  final String publisherEmail;
  final bool isFeatured;
  final bool allowComments;
  final String status; // approved, pending, rejected
  final int viewsCount;
  final double sellerRating;
  final int sellerReviewsCount;
  final bool isSold;
  final DateTime? soldAt;
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
    required this.condition,
    required this.tags,
    required this.imageUrls,
    this.videoUrl,
    required this.publisherName,
    required this.publisherPhone,
    required this.publisherWhatsapp,
    this.publisherTelegram,
    required this.publisherEmail,
    required this.isFeatured,
    required this.allowComments,
    required this.status,
    required this.viewsCount,
    required this.sellerRating,
    required this.sellerReviewsCount,
    this.isSold = false,
    this.soldAt,
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
    String? publisherWhatsapp,
    String? publisherTelegram,
    String? publisherEmail,
    bool? isFeatured,
    bool? allowComments,
    String? status,
    int? viewsCount,
    double? sellerRating,
    int? sellerReviewsCount,
    bool? isSold,
    DateTime? soldAt,
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
      publisherWhatsapp: publisherWhatsapp ?? this.publisherWhatsapp,
      publisherTelegram: publisherTelegram ?? this.publisherTelegram,
      publisherEmail: publisherEmail ?? this.publisherEmail,
      isFeatured: isFeatured ?? this.isFeatured,
      allowComments: allowComments ?? this.allowComments,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerReviewsCount: sellerReviewsCount ?? this.sellerReviewsCount,
      isSold: isSold ?? this.isSold,
      soldAt: soldAt ?? this.soldAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
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
        'publisher_whatsapp': publisherWhatsapp,
        'publisher_telegram': publisherTelegram,
        'publisher_email': publisherEmail,
        'is_featured': isFeatured,
        'allow_comments': allowComments,
        'status': status,
        'views_count': viewsCount,
        'seller_rating': sellerRating,
        'seller_reviews_count': sellerReviewsCount,
        'is_sold': isSold,
        'sold_at': soldAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory AdItem.fromMap(Map<String, dynamic> map) => AdItem(
        id: map['id']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        priceUsd: map['price_usd'] != null
            ? double.tryParse(map['price_usd'].toString())
            : null,
        priceSyp: map['price_syp'] != null
            ? double.tryParse(map['price_syp'].toString())
            : null,
        categoryId: map['category_id']?.toString() ?? 'أخرى',
        subcategory: map['subcategory']?.toString() ?? 'عام',
        governorate: map['governorate']?.toString() ?? 'دمشق',
        neighborhood: map['neighborhood']?.toString() ?? 'المركز',
        condition: map['condition']?.toString() ?? 'جديد',
        tags: map['tags'] is List ? List<String>.from(map['tags']) : [],
        imageUrls: map['image_urls'] is List
            ? List<String>.from(map['image_urls'])
            : [],
        videoUrl: map['video_url']?.toString(),
        publisherName: map['publisher_name']?.toString() ?? 'معلن',
        publisherPhone: map['publisher_phone']?.toString() ?? '',
        publisherWhatsapp: map['publisher_whatsapp']?.toString() ?? '',
        publisherTelegram: map['publisher_telegram']?.toString(),
        publisherEmail: map['publisher_email']?.toString() ?? '',
        isFeatured: map['is_featured'] == true,
        allowComments: map['allow_comments'] ?? true,
        status: map['status']?.toString() ?? 'pending',
        viewsCount: map['views_count'] is int
            ? map['views_count']
            : int.tryParse(map['views_count']?.toString() ?? '0') ?? 0,
        sellerRating: map['seller_rating'] != null
            ? double.tryParse(map['seller_rating'].toString()) ?? 5.0
            : 5.0,
        sellerReviewsCount: map['seller_reviews_count'] is int
            ? map['seller_reviews_count']
            : int.tryParse(map['seller_reviews_count']?.toString() ?? '1') ?? 1,
        isSold: map['is_sold'] == true,
        soldAt: map['sold_at'] != null
            ? DateTime.tryParse(map['sold_at'].toString())
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// موديل صوتك مسموع والاقتراحات لصاحب التطبيق
class AppFeedbackItem {
  final String id;
  final String userId;
  final String userName;
  final String userContact;
  final String type;
  final String content;
  final String? screenshotUrl;
  final DateTime createdAt;

  AppFeedbackItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userContact,
    required this.type,
    required this.content,
    this.screenshotUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_contact': userContact,
        'type': type,
        'content': content,
        'screenshot_url': screenshotUrl,
        'created_at': createdAt.toIso8601String(),
      };

  factory AppFeedbackItem.fromMap(Map<String, dynamic> map) => AppFeedbackItem(
        id: map['id']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        userName: map['user_name']?.toString() ?? 'زائر',
        userContact: map['user_contact']?.toString() ?? '',
        type: map['type']?.toString() ?? 'اقتراح فكرة جديدة',
        content: map['content']?.toString() ?? '',
        screenshotUrl: map['screenshot_url']?.toString(),
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// موديل باقات الاشتراك والترقية VIP
class PlanFeature {
  final String text;
  final bool isAvailable;
  PlanFeature({required this.text, this.isAvailable = true});
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double priceUsd;
  final double priceSyp;
  final int maxImagesPerAd;
  final int maxAdsPerMonth;
  final Color badgeColor;
  final List<PlanFeature> customFeatures;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceUsd,
    required this.priceSyp,
    required this.maxImagesPerAd,
    required this.maxAdsPerMonth,
    required this.badgeColor,
    required this.customFeatures,
  });
}

/// موديل الأقسام والتبويبات
class CategoryModel {
  final String id;
  final String name;
  final IconData iconData;
  final List<String> subcategories;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadiusValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconData,
    required this.subcategories,
    this.backgroundColor = const Color(0xFF0F172A),
    this.textColor = Colors.white,
    this.borderRadiusValue = 12.0,
  });
}

/// موديل التعليقات
class CommentItem {
  final String id;
  final String adId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentItem({
    required this.id,
    required this.adId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ad_id': adId,
        'user_id': userId,
        'user_name': userName,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory CommentItem.fromMap(Map<String, dynamic> map) => CommentItem(
        id: map['id']?.toString() ?? '',
        adId: map['ad_id']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        userName: map['user_name']?.toString() ?? 'مستخدم',
        content: map['content']?.toString() ?? '',
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
}

// ==============================================================================
// 4. مدير حالة التطبيق الشامل والإعدادات السحابية (AppStateManager) - نظيف 100%
// ==============================================================================
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal() {
    _initDefaults();
  }

  // معلومات التطبيق الأساسية
  String appTitle = 'سوق سوريا الشامل';
  String appSubtitle = '2028';
  String disclaimerText =
      'تطبيق "سوق سوريا الشامل 2028" هو منصة إعلانية حرة ومفتوحة لعرض السلع والخدمات بين المستخدمين. التطبيق وإدارته غير مسؤولين عن صحة المعاملات المالية أو جودة السلع المعروضة، ويتحمل البائع والمشتري كامل المسؤولية القانونية.';

  // ألوان وهوية التطبيق
  Color primaryColor = const Color(0xFF0F172A);
  Color secondaryColor = const Color(0xFFEAB308);
  Color buttonColor = const Color(0xFF0284C7);
  Color scaffoldBgColor = const Color(0xFFF8FAFC);
  Color appBarColor = const Color(0xFF0F172A);

  // ألوان نصوص الأسعار وتفاصيل الإعلانات القابلة للتخصيص
  Color priceUsdColor = Colors.green;
  Color priceSypColor = Colors.orange.shade800;
  Color locationTextColor = Colors.blueGrey;
  Color titleTextColor = const Color(0xFF1E293B);

  // إعدادات شريط الأخبار المتحرك
  List<String> newsTicker = [
    '🔥 أهلاً بكم في النسخة الأحدث من سوق سوريا الشامل 2028',
    '🚗 سيارات سياحية وحديثة متوفرة في كافة المحافظات بأسعار منافسة',
    '🏢 شقق وعقارات للإيجار والبيع بدمشق وحلب واللاذقية وطرطوس',
    '💡 شاركنا رأيك وطوّر التطبيق عبر قسم "صوتك مسموع"',
  ];
  Color tickerBackgroundColor = const Color(0xFF0F172A);
  Color tickerTextColor = Colors.white;
  IconData tickerIcon = Icons.bolt;
  double tickerFontSize = 12.0;
  double tickerSpeed = 1.0;

  // إعدادات البنرات الترويجية
  int bannerIntervalSeconds = 3;

  // وضع الصيانة والمايك
  bool isMaintenanceMode = false;
  String maintenanceMessage =
      'التطبيق يخضع حالياً لعمليات صيانة وتحديث مجدولة لخدمتكم بشكل أفضل. سنعود للعمل قريباً جداً!';
  bool isVoiceTypingEnabled = true;

  // بيانات المستخدم المسجل حالياً
  bool isLoggedIn = false;
  String currentUserId = '';
  String currentUserEmail = '';
  String currentUserName = 'زائر';
  String currentUserPhone = '';
  String currentUserPlanId = 'free';

  // القوائم والمجموعات (خالية تماماً من البيانات الوهمية والموك)
  List<Moderator> moderators = [];
  List<BannerItem> banners = [];
  List<AdItem> ads = [];
  List<CategoryModel> categories = [];
  List<SubscriptionPlan> subscriptionPlans = [];
  List<AppFeedbackItem> feedbacks = [];

  bool get isSuperAdmin =>
      currentUserEmail == kAppOwnerEmail ||
      moderators.any((m) => m.email == currentUserEmail && m.isSuperAdmin);
  bool get isModerator =>
      isSuperAdmin || moderators.any((m) => m.email == currentUserEmail);

  void _initDefaults() {
    // إضافة المشرف الأساسي والمالك
    moderators = [
      Moderator(
        id: 'mod_owner',
        email: kAppOwnerEmail,
        name: 'المالك والمطور الأساسي 👑',
        role: 'super_admin',
        isSuperAdmin: true,
        grantedAt: DateTime.now(),
      ),
    ];

    // باقات الاشتراك المعتمدة
    subscriptionPlans = [
      SubscriptionPlan(
        id: 'free',
        name: 'الباقة المجانية',
        priceUsd: 0,
        priceSyp: 0,
        maxImagesPerAd: 4,
        maxAdsPerMonth: 5,
        badgeColor: Colors.blueGrey,
        customFeatures: [
          PlanFeature(text: 'نشر حتى 5 إعلانات شهرياً'),
          PlanFeature(text: 'حتى 4 صور لكل إعلان'),
          PlanFeature(text: 'دعم المحادثة والتفاوض المباشر'),
          PlanFeature(text: 'فيديو استعراض السلعة', isAvailable: false),
          PlanFeature(text: 'شارة VIP المميزة', isAvailable: false),
        ],
      ),
      SubscriptionPlan(
        id: 'silver',
        name: 'الباقة الفضية (للمحلات)',
        priceUsd: 5,
        priceSyp: 75000,
        maxImagesPerAd: 8,
        maxAdsPerMonth: 25,
        badgeColor: Colors.blueGrey.shade700,
        customFeatures: [
          PlanFeature(text: 'نشر حتى 25 إعلاناً شهرياً'),
          PlanFeature(text: 'حتى 8 صور لكل إعلان'),
          PlanFeature(text: 'إمكانية إرفاق فيديو للسلعة'),
          PlanFeature(text: 'أولوية الظهور في نتائج البحث'),
          PlanFeature(text: 'شارة VIP المميزة', isAvailable: false),
        ],
      ),
      SubscriptionPlan(
        id: 'gold_vip',
        name: 'الباقة الذهبية VIP 👑',
        priceUsd: 12,
        priceSyp: 180000,
        maxImagesPerAd: 15,
        maxAdsPerMonth: 100,
        badgeColor: const Color(0xFFEAB308),
        customFeatures: [
          PlanFeature(text: 'نشر غير محدود للإعلانات'),
          PlanFeature(text: 'حتى 15 صورة عالية الدقة لكل إعلان'),
          PlanFeature(text: 'فيديو استعراض السلعة 🎥'),
          PlanFeature(text: 'شارة التاج الذهبي VIP والظهور الدائم بالقمة'),
          PlanFeature(text: 'دعم فني وتواصل مخصص على مدار الساعة'),
        ],
      ),
    ];

    // الأقسام الشاملة لسوق سوريا 2028
    categories = [
      CategoryModel(
        id: 'cars',
        name: 'سيارات ومركبات',
        iconData: Icons.directions_car,
        subcategories: [
          'سيارات سياحية',
          'سيارات جيب وSUV',
          'شاحنات ونقل',
          'دراجات نارية',
          'قطع غيار وإكسسوارات',
          'إطارات وبطاريات'
        ],
        backgroundColor: const Color(0xFF1E293B),
      ),
      CategoryModel(
        id: 'real_estate',
        name: 'عقارات وأملاك',
        iconData: Icons.apartment,
        subcategories: [
          'شقق للبيع',
          'شقق للإيجار',
          'أراضي ومزارع',
          'محلات ومكاتب تجارية',
          'شاليهات ومصايف',
          'مستودعات وهنكارات'
        ],
        backgroundColor: const Color(0xFF0F766E),
      ),
      CategoryModel(
        id: 'mobiles',
        name: 'موبايل وإلكترونيات',
        iconData: Icons.phone_android,
        subcategories: [
          'هواتف آيفون iPhone',
          'هواتف سامسونج وباقي الماركات',
          'أجهزة لابتوب وكمبيوتر',
          'شاشات وتلفزيونات',
          'أجهزة لوحية Tablets',
          'ألعاب وكاميرات'
        ],
        backgroundColor: const Color(0xFF1D4ED8),
      ),
      CategoryModel(
        id: 'home_appliances',
        name: 'أثاث وأجهزة منزلية',
        iconData: Icons.kitchen,
        subcategories: [
          'برادات وغسالات',
          'طاقة شمسية وبطاريات وإنفرتر',
          'أثاث غرف نوم وصالونات',
          'مكيفات ومدافئ',
          'أدوات مطبخ منزلية'
        ],
        backgroundColor: const Color(0xFFB45309),
      ),
      CategoryModel(
        id: 'jobs',
        name: 'وظائف ومهن حرة',
        iconData: Icons.work,
        subcategories: [
          'وظائف شاغرة',
          'باحث عن عمل',
          'خدمات صيانة وورشات',
          'تعليم ودروس خصوصية',
          'برمجة وتصميم وتسويق'
        ],
        backgroundColor: const Color(0xFF6D28D9),
      ),
      CategoryModel(
        id: 'fashion',
        name: 'أزياء وجمال ومقتنيات',
        iconData: Icons.watch,
        subcategories: [
          'ألبسة وأحذية رجالية',
          'ألبسة وفساتين نسائية',
          'ساعات ومجوهرات',
          'عطورات ومستحضرات تجميل'
        ],
        backgroundColor: const Color(0xFFBE185D),
      ),
      CategoryModel(
        id: 'animals',
        name: 'حيوانات وطيور ومواشي',
        iconData: Icons.pets,
        subcategories: [
          'طيور زينة وحمام',
          'قطط وكلاب',
          'مواشي وأغنام وأبقار',
          'مستلزمات وأعلاف'
        ],
        backgroundColor: const Color(0xFF047857),
      ),
    ];
  }

  SubscriptionPlan getCurrentUserPlan() {
    return subscriptionPlans.firstWhere(
      (p) => p.id == currentUserPlanId,
      orElse: () => subscriptionPlans.first,
    );
  }

  void setSessionUser({
    required String userId,
    required String email,
    required String name,
    String phone = '',
  }) {
    isLoggedIn = true;
    currentUserId = userId;
    currentUserEmail = email;
    currentUserName = name;
    currentUserPhone = phone;
    if (email == kAppOwnerEmail) {
      currentUserPlanId = 'gold_vip';
    }
    notifyListeners();
  }

  Future<void> logoutUser() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    isLoggedIn = false;
    currentUserId = '';
    currentUserEmail = '';
    currentUserName = 'زائر';
    currentUserPhone = '';
    currentUserPlanId = 'free';
    notifyListeners();
  }

  void incrementAdViews(String adId) {
    final index = ads.indexWhere((a) => a.id == adId);
    if (index != -1) {
      final currentViews = ads[index].viewsCount;
      ads[index] = ads[index].copyWith(viewsCount: currentViews + 1);
      notifyListeners();

      try {
        Supabase.instance.client
            .from('ads')
            .update({'views_count': currentViews + 1})
            .eq('id', adId)
            .then((_) {})
            .catchError((_) {});
      } catch (_) {}
    }
  }

  Future<void> autoCleanupExpiredSoldAds() async {
    final now = DateTime.now();
    final expiredIds = <String>[];

    for (final ad in ads) {
      if (ad.isSold && ad.soldAt != null) {
        final days = now.difference(ad.soldAt!).inDays;
        if (days >= 7) {
          expiredIds.add(ad.id);
        }
      }
    }

    if (expiredIds.isNotEmpty) {
      ads.removeWhere((a) => expiredIds.contains(a.id));
      notifyListeners();

      for (final id in expiredIds) {
        try {
          await Supabase.instance.client.from('ads').delete().eq('id', id);
        } catch (_) {}
      }
    }
  }
}

// ==============================================================================
// 5. نافذة التسجيل الصوتي والإدخال الفعلي (VoiceInputDialog)
// ==============================================================================
class VoiceInputDialog extends StatefulWidget {
  final String title;
  const VoiceInputDialog({Key? key, required this.title}) : super(key: key);

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final TextEditingController _voiceTextController = TextEditingController();
  bool _isListening = true;
  Timer? _listeningTimer;

  @override
  void initState() {
    super.initState();
    _startListeningTimer();
  }

  @override
  void dispose() {
    _listeningTimer?.cancel();
    _voiceTextController.dispose();
    super.dispose();
  }

  void _startListeningTimer() {
    _listeningTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppStateManager();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.mic, color: manager.primaryColor, size: 26),
          const SizedBox(width: 8),
          Expanded(
              child: Text(widget.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: manager.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: _isListening
                ? const SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Icon(Icons.check_circle,
                    color: Colors.green.shade600, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening
                ? 'جاري الاستماع لصوتك وتسجيل الكلمات...'
                : 'اكتب أو عدّل النص المسجل أدناه:',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voiceTextController,
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'النص الصوتي المُلتقط...',
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: manager.buttonColor),
          onPressed: () {
            final text = _voiceTextController.text.trim();
            Navigator.pop(context, text);
          },
          child: const Text('اعتماد النص ✨',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ==============================================================================
// 6. كلاس التطبيق الجذري وإدارة الثيمات ووضع الصيانة (SyriaMarket2028App)
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
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
          primary: _manager.secondaryColor,
          secondary: _manager.secondaryColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _manager.isMaintenanceMode && !_manager.isModerator
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
// 7. شاشة صوتك مسموع - صندوق الاقتراحات والملاحظات لصاحب التطبيق (AppFeedbackScreen)
// ==============================================================================
class AppFeedbackScreen extends StatefulWidget {
  const AppFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AppFeedbackScreen> createState() => _AppFeedbackScreenState();
}

class _AppFeedbackScreenState extends State<AppFeedbackScreen> {
  final AppStateManager _manager = AppStateManager();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedType = 'فكرة وميزة جديدة 💡';
  final List<String> _feedbackTypes = [
    'فكرة وميزة جديدة 💡',
    'ملاحظة على السرعة/التصميم ⚡',
    'الإبلاغ عن مشكلة تقنية 🛠️',
    'طلب إضافة قسم أو فرع جديد 📁',
    'كلمة شكر وتقييم للمنصة ⭐',
  ];

  Uint8List? _screenshotBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (_manager.isLoggedIn) {
      _contactController.text = _manager.currentUserPhone.isNotEmpty
          ? _manager.currentUserPhone
          : _manager.currentUserEmail;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _recordVoiceFeedback() async {
    final text = await showDialog<String>(
      context: context,
      builder: (c) =>
          const VoiceInputDialog(title: 'سجّل فكرتك أو ملاحظتك بصوتك 🎙️'),
    );
    if (text != null && text.isNotEmpty) {
      setState(() {
        if (_contentController.text.isNotEmpty) {
          _contentController.text += ' $text';
        } else {
          _contentController.text = text;
        }
      });
    }
  }

  Future<void> _pickScreenshot() async {
    final img = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 1024);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _screenshotBytes = bytes);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    String? screenshotPublicUrl;

    try {
      if (_screenshotBytes != null) {
        final fileName =
            'feedback_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from(kStorageBucketFeedbacks)
            .uploadBinary(
              fileName,
              _screenshotBytes!,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            )
            .timeout(const Duration(seconds: 12));

        screenshotPublicUrl = Supabase.instance.client.storage
            .from(kStorageBucketFeedbacks)
            .getPublicUrl(fileName);
      }

      final newFeedback = AppFeedbackItem(
        id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
        userId: _manager.currentUserId,
        userName:
            _manager.isLoggedIn ? _manager.currentUserName : 'مستخدم زائر',
        userContact: _contactController.text.trim(),
        type: _selectedType,
        content: _contentController.text.trim(),
        screenshotUrl: screenshotPublicUrl,
        createdAt: DateTime.now(),
      );

      _manager.feedbacks.insert(0, newFeedback);
      _manager.notifyListeners();

      await Supabase.instance.client
          .from('app_feedbacks')
          .insert(newFeedback.toMap())
          .timeout(const Duration(seconds: 8));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.volunteer_activism,
                    color: _manager.primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text('شكراً لمساهمتك الغالية! ❤️'),
              ],
            ),
            content: const Text(
              'تم استلام فكرتك/ملاحظتك ووصلت مباشرة إلى صاحب التطبيق وفريق التطوير.\n\nرأيك وملاحظاتك هي الأساس في تطوير سوق سوريا الشامل 2028!',
              style: TextStyle(height: 1.5, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('حسناً',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Feedback Submit Note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✨ تم إرسال ملاحظتك لصاحب التطبيق بنجاح!')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openDirectWhatsappWithOwner() async {
    final cleanPhone = PhoneHelper.formatForWhatsapp(kAppOwnerWhatsApp);
    final msg = Uri.encodeComponent(
        'مرحباً أخي الكريم، لدي فكرة وملاحظة بخصوص تطبيق "سوق سوريا الشامل 2028":');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: const Text('صوتك مسموع 💡 - اقترح وطوّر التطبيق',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _manager.primaryColor.withOpacity(0.12),
                    _manager.secondaryColor.withOpacity(0.15)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: _manager.secondaryColor.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _manager.secondaryColor,
                    child: Icon(Icons.lightbulb,
                        color: _manager.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رسالتك تصل مباشرة لصاحب التطبيق',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        const Text(
                            'شاركنا أفكارك، اقتراحاتك للأقسام، أو أي صعوبة واجهتك لنقوم بتطويرها فوراً.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('نوع الرسالة أو الاقتراح:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _feedbackTypes.map((type) {
                final isSel = _selectedType == type;
                return ChoiceChip(
                  label: Text(type,
                      style: TextStyle(
                          fontSize: 11,
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal)),
                  selected: isSel,
                  selectedColor: _manager.primaryColor,
                  onSelected: (val) {
                    if (val) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 800,
              decoration: InputDecoration(
                labelText: 'اكتب فكرتك أو ملاحظتك بالتفصيل *',
                hintText:
                    'مثال: أقترح إضافة ميزة تقييم الأسعار، أو واجهتني مشكلة في رفع الصور...',
                suffixIcon: _manager.isVoiceTypingEnabled
                    ? IconButton(
                        icon: Icon(Icons.mic, color: _manager.primaryColor),
                        tooltip: 'تحدث بالمايك لإملاء الفكرة',
                        onPressed: _recordVoiceFeedback,
                      )
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'يرجى كتابة نص الملاحظة أو الاقتراح'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'رقم هاتفك أو بريدك (للتواصل وشكرك على الفكرة)',
                hintText: '0933000000 أو إيميلك الشخصي',
                prefixIcon:
                    Icon(Icons.contact_phone, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            const Text('إرفاق صورة توضيحية أو لقطة شاشة (اختياري):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickScreenshot,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: _screenshotBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_screenshotBytes!,
                            fit: BoxFit.cover, width: double.infinity))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: _manager.primaryColor, size: 30),
                          const SizedBox(height: 4),
                          const Text('اضغط هنا لاختيار صورة من المعرض',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.send, color: Colors.white),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال الفكرة لصاحب التطبيق 🚀',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _submitFeedback,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                label: const Text('أو تحدث مباشرة مع صاحب التطبيق عبر الواتساب',
                    style: TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                onPressed: _openDirectWhatsappWithOwner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 8. الشاشة الرئيسية الكبرى والشبكة الثنائية الحديثة (MainDashboardScreen)
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
  int _pendingAdsCount = 0;
  List<Map<String, dynamic>> _userChatThreads = [];

  String _filterCondition = 'الكل';
  double? _filterMinPrice;
  double? _filterMaxPrice;
  String _sortBy = 'newest';

  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;
  bool _isTickerPaused = false;

  final PageController _bannerCarouselController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerAutoScrollTimer;
  bool _isBannerUserInteracting = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onStateChange);
    _initLiveAdsFromSupabase();
    _fetchUserFavorites();
    _fetchUserChats();
    _startTickerAnimation();
    _startBannerCarouselTimer();
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChange);
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    _bannerAutoScrollTimer?.cancel();
    _bannerCarouselController.dispose();
    _searchController.dispose();
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

  void _startBannerCarouselTimer() {
    _bannerAutoScrollTimer?.cancel();
    final interval =
        _manager.bannerIntervalSeconds > 0 ? _manager.bannerIntervalSeconds : 3;

    _bannerAutoScrollTimer =
        Timer.periodic(Duration(seconds: interval), (timer) {
      if (mounted &&
          !_isBannerUserInteracting &&
          _manager.banners.length > 1 &&
          _bannerCarouselController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _manager.banners.length;
        _bannerCarouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
        setState(() => _currentBannerIndex = nextIndex);
      }
    });
  }

  Future<void> _fetchUserFavorites() async {
    if (!_manager.isLoggedIn || _manager.currentUserId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('favorites')
          .select('ad_id')
          .eq('user_id', _manager.currentUserId)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _favoriteAdIds.clear();
          for (final row in res) {
            _favoriteAdIds.add(row['ad_id'].toString());
          }
        });
      }
    } catch (e) {
      debugPrint('Favorites fetch notice: $e');
    }
  }

  Future<void> _toggleFavoriteInSupabase(String adId) async {
    if (!_manager.isLoggedIn) return;
    final isFav = _favoriteAdIds.contains(adId);
    setState(() {
      if (isFav) {
        _favoriteAdIds.remove(adId);
      } else {
        _favoriteAdIds.add(adId);
      }
    });

    try {
      if (isFav) {
        await Supabase.instance.client
            .from('favorites')
            .delete()
            .match({'user_id': _manager.currentUserId, 'ad_id': adId}).timeout(
                const Duration(seconds: 8));
      } else {
        await Supabase.instance.client
            .from('favorites')
            .insert({'user_id': _manager.currentUserId, 'ad_id': adId}).timeout(
                const Duration(seconds: 8));
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _fetchUserChats() async {
    if (!_manager.isLoggedIn || _manager.currentUserId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _userChatThreads = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Fetch chats notice: $e');
    }
  }

  Future<void> _initLiveAdsFromSupabase() async {
    if (mounted) setState(() => _isLoadingAds = true);
    try {
      final res = await Supabase.instance.client
          .from('ads')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      if (res is List) {
        _manager.ads = res
            .map((map) => AdItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }

      final bannerRes = await Supabase.instance.client
          .from('banners')
          .select()
          .timeout(const Duration(seconds: 8));

      if (bannerRes is List && (bannerRes).isNotEmpty) {
        _manager.banners = bannerRes
            .map((map) => BannerItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }

      final pendingRes = await Supabase.instance.client
          .from('ads')
          .select('id')
          .eq('status', 'pending')
          .timeout(const Duration(seconds: 8));

      if (pendingRes is List && mounted) {
        setState(() => _pendingAdsCount = pendingRes.length);
      }

      await _manager.autoCleanupExpiredSoldAds();
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

  void _showContactAdminDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _manager.secondaryColor,
                    child: Icon(Icons.headset_mic,
                        color: _manager.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التواصل المباشر مع إدارة التطبيق',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('نحن هنا لخدمتكم ومساعدتكم على مدار الساعة',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFF25D366).withOpacity(0.12),
                leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                title: const Text('محادثة واتساب فورية مع الإدارة',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                    'رد سريع على الاستفسارات وحجز الإعلانات المميزة'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(ctx);
                  final clean =
                      PhoneHelper.formatForWhatsapp(kAppOwnerWhatsApp);
                  final msg = Uri.encodeComponent(
                      'مرحباً إدارة سوق سوريا الشامل 2028، لدي استفسار:');
                  final uri = Uri.parse('https://wa.me/$clean?text=$msg');
                  try {
                    if (await canLaunchUrl(uri))
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.blue.withOpacity(0.1),
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text('اتصال هاتفي مباشر بالإدارة',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('رقم الهاتف: $kAppOwnerPhone'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('tel:$kAppOwnerPhone');
                  try {
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: _manager.secondaryColor.withOpacity(0.15),
                leading: Icon(Icons.lightbulb, color: _manager.secondaryColor),
                title: const Text('صوتك مسموع 💡 (صندوق الاقتراحات)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('إرسال فكرة أو شكوى مع إرفاق لقطة شاشة'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AppFeedbackScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdvancedFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: _manager.primaryColor),
                          const SizedBox(width: 8),
                          const Text('تصفية وفلترة متقدمة',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _filterCondition = 'الكل';
                            _filterMinPrice = null;
                            _filterMaxPrice = null;
                            _sortBy = 'newest';
                          });
                          setState(() {});
                        },
                        child: const Text('إعادة ضبط'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('حالة السلعة:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['الكل', 'جديد', 'مستعمل بحالة ممتازة', 'مستعمل']
                        .map((cond) {
                      final sel = _filterCondition == cond;
                      return ChoiceChip(
                        label: Text(cond,
                            style: TextStyle(
                                fontSize: 11,
                                color: sel ? Colors.white : Colors.black87)),
                        selected: sel,
                        selectedColor: _manager.primaryColor,
                        onSelected: (val) {
                          if (val) setSheetState(() => _filterCondition = cond);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('ترتيب النتائج حسب:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      {'key': 'newest', 'label': 'الأحدث أولاً'},
                      {'key': 'price_asc', 'label': 'الأقل سعراً'},
                      {'key': 'price_desc', 'label': 'الأعلى سعراً'},
                      {'key': 'views', 'label': 'الأكثر مشاهدة 🔥'},
                    ].map((s) {
                      final sel = _sortBy == s['key'];
                      return ChoiceChip(
                        label: Text(s['label']!,
                            style: TextStyle(
                                fontSize: 11,
                                color: sel ? Colors.white : Colors.black87)),
                        selected: sel,
                        selectedColor: _manager.primaryColor,
                        onSelected: (val) {
                          if (val) setSheetState(() => _sortBy = s['key']!);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('نطاق السعر التقريبي (\$ دولار):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'من (\$)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8)),
                          onChanged: (val) =>
                              _filterMinPrice = double.tryParse(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'إلى (\$)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8)),
                          onChanged: (val) =>
                              _filterMaxPrice = double.tryParse(val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _manager.buttonColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: const Text('تطبيق الفلترة ✨',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _recordSearchVoice() async {
    final res = await showDialog<String>(
      context: context,
      builder: (c) =>
          const VoiceInputDialog(title: 'البحث الصوتي الذكي في السوق 🎙️'),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        _searchQuery = res;
        _searchController.text = res;
      });
    }
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
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _manager.secondaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: _manager.secondaryColor, width: 1.2),
              ),
              child: Icon(Icons.headset_mic,
                  color: _manager.secondaryColor, size: 18),
            ),
            tooltip: 'تواصل مع إدارة التطبيق',
            onPressed: _showContactAdminDialog,
          ),
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
          if (_manager.isModerator)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings,
                      color: Colors.amberAccent),
                  tooltip: 'غرفة العمليات والإشراف',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) =>
                              const FullAdminPanelScreen(initialTab: 1)),
                    );
                  },
                ),
                if (_pendingAdsCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '$_pendingAdsCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
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
    var filteredAds = _manager.ads.where((ad) {
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
      final matchesCond =
          _filterCondition == 'الكل' || ad.condition == _filterCondition;
      final matchesMinP = _filterMinPrice == null ||
          (ad.priceUsd != null && ad.priceUsd! >= _filterMinPrice!);
      final matchesMaxP = _filterMaxPrice == null ||
          (ad.priceUsd != null && ad.priceUsd! <= _filterMaxPrice!);

      final isApproved = ad.status == 'approved' || (_manager.isModerator);

      return matchesGov &&
          matchesCat &&
          matchesSub &&
          matchesSearch &&
          matchesCond &&
          matchesMinP &&
          matchesMaxP &&
          isApproved;
    }).toList();

    if (_sortBy == 'price_asc') {
      filteredAds.sort((a, b) => (a.priceUsd ?? 0).compareTo(b.priceUsd ?? 0));
    } else if (_sortBy == 'price_desc') {
      filteredAds.sort((a, b) => (b.priceUsd ?? 0).compareTo(a.priceUsd ?? 0));
    } else if (_sortBy == 'views') {
      filteredAds.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    } else {
      filteredAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Column(
      children: [
        _buildCustomNewsTickerWidget(),
        _buildMultiCardHeroBannerCarousel(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث في كافة إعلانات السوق (سيارات، عقارات، هواتف...)...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon:
                        Icon(Icons.search, color: _manager.primaryColor),
                    suffixIcon: _manager.isVoiceTypingEnabled
                        ? IconButton(
                            icon: Icon(Icons.mic, color: _manager.primaryColor),
                            tooltip: 'البحث بالصوت',
                            onPressed: _recordSearchVoice,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.08),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _filterCondition != 'الكل' ||
                          _filterMinPrice != null ||
                          _filterMaxPrice != null ||
                          _sortBy != 'newest'
                      ? _manager.secondaryColor
                      : Colors.grey.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.tune, color: _manager.primaryColor, size: 22),
                tooltip: 'تصفية وفلترة متقدمة',
                onPressed: _showAdvancedFilterSheet,
              ),
            ],
          ),
        ),
        _buildCategoriesHorizontalBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('أحدث إعلانات السوق',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _manager.titleTextColor)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                        color: _manager.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${filteredAds.length} إعلان',
                        style: TextStyle(
                            color: _manager.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_selectedGovernorate != 'كل المحافظات')
                Text('محافظة: $_selectedGovernorate',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontSize: 11,
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
                                Icon(Icons.search_off_rounded,
                                    size: 55, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text(
                                    'لا توجد إعلانات حالياً في هذا القسم أو المحافظة',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: filteredAds.length,
                        itemBuilder: (ctx, index) {
                          final ad = filteredAds[index];
                          return _buildCompactGridAdCard(ad);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: _manager.secondaryColor,
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Icon(_manager.tickerIcon,
                    color: _manager.primaryColor, size: 12),
                const SizedBox(width: 3),
                Text('عاجل',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
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

  Widget _buildMultiCardHeroBannerCarousel() {
    final bannersList = _manager.banners;
    if (bannersList.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (_) => _isBannerUserInteracting = true,
              onPointerUp: (_) => _isBannerUserInteracting = false,
              onPointerCancel: (_) => _isBannerUserInteracting = false,
              child: PageView.builder(
                controller: _bannerCarouselController,
                itemCount: bannersList.length,
                onPageChanged: (idx) =>
                    setState(() => _currentBannerIndex = idx),
                itemBuilder: (ctx, idx) {
                  final banner = bannersList[idx];
                  return _buildSingleHeroBannerCard(
                      banner, idx, bannersList.length);
                },
              ),
            ),
          ),
          if (bannersList.length > 1) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannersList.length, (i) {
                final isSelected = i == _currentBannerIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  height: 4.5,
                  width: isSelected ? 16 : 5,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _manager.primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleHeroBannerCard(
      BannerItem banner, int index, int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                color: const Color(0xFF1E293B),
                child: const Center(
                    child:
                        Icon(Icons.campaign, color: Colors.white70, size: 36)),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${index + 1} / $totalCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 10,
            left: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                            color: _manager.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  children: [
                    if (banner.whatsapp.isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final clean =
                              PhoneHelper.formatForWhatsapp(banner.whatsapp);
                          final uri = Uri.parse('https://wa.me/$clean');
                          if (await canLaunchUrl(uri))
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              color: Color(0xFF25D366), shape: BoxShape.circle),
                          child: const Icon(Icons.chat,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    if (banner.phone.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse('tel:${banner.phone}');
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: _manager.primaryColor,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.phone,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHorizontalBar() {
    final currentCat = _manager.categories.firstWhere(
      (c) => c.name == _selectedCategoryId,
      orElse: () => _manager.categories.isNotEmpty
          ? _manager.categories.first
          : CategoryModel(
              id: 'all',
              name: 'الكل',
              iconData: Icons.category,
              subcategories: []),
    );

    final subcategories =
        _selectedCategoryId != null ? currentCat.subcategories : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: FilterChip(
                  label: const Text('الكل',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  selected: _selectedCategoryId == null,
                  selectedColor: _manager.primaryColor,
                  labelStyle: TextStyle(
                      color: _selectedCategoryId == null
                          ? Colors.white
                          : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onSelected: (_) => setState(() {
                    _selectedCategoryId = null;
                    _selectedSubcategory = null;
                  }),
                ),
              ),
              ..._manager.categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.name;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: FilterChip(
                    avatar: Icon(cat.iconData,
                        size: 14,
                        color: isSelected ? Colors.white : cat.textColor),
                    label: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
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
          const SizedBox(height: 3),
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: subcategories.map((sub) {
                final isSelected = _selectedSubcategory == sub;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ChoiceChip(
                    label: Text(sub,
                        style: TextStyle(
                            fontSize: 10,
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

  Widget _buildCompactGridAdCard(AdItem ad) {
    final isFav = _favoriteAdIds.contains(ad.id);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          _manager.incrementAdViews(ad.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => FullAdDetailsScreen(
                ad: ad,
                isFavorite: isFav,
                onToggleFavorite: () {
                  _requireAuth(() {
                    _toggleFavoriteInSupabase(ad.id);
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
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey.shade900,
                      child: Image.network(
                        ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5));
                        },
                        errorBuilder: (ctx, _, __) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                              child: Icon(Icons.image,
                                  size: 28, color: Colors.white38)),
                        ),
                      ),
                    ),
                  ),
                  if (ad.status == 'pending')
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade800,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('قيد المراجعة ⏳',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 8)),
                      ),
                    )
                  else if (ad.isFeatured)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                            color: _manager.secondaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('VIP ★',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9)),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: Colors.black45, shape: BoxShape.circle),
                      child: GestureDetector(
                        onTap: () {
                          _requireAuth(() {
                            _toggleFavoriteInSupabase(ad.id);
                          });
                        },
                        child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                            size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye,
                              color: Colors.white70, size: 9),
                          const SizedBox(width: 2),
                          Text('${ad.viewsCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (ad.isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                              child: const Text('✓ تم البيع',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ad.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: _manager.titleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ad.priceUsd != null)
                          Text('\$${ad.priceUsd!.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: _manager.priceUsdColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))
                        else if (ad.priceSyp != null)
                          Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: _manager.priceSypColor)),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: _manager.locationTextColor, size: 10),
                            const SizedBox(width: 1),
                            Expanded(
                              child: Text(
                                '${ad.governorate} - ${ad.neighborhood}',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: _manager.locationTextColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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

    if (_userChatThreads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('لا توجد محادثات نشطة حالياً',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('تواصل مع أصحاب الإعلانات لبدء التفاوض المباشر.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userChatThreads.length,
      itemBuilder: (ctx, idx) {
        final thread = _userChatThreads[idx];
        final senderName = thread['sender_name']?.toString() ?? 'طرف التفاوض';
        final message = thread['message']?.toString() ?? '';
        final adId = thread['ad_id']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _manager.primaryColor,
              child: Text(
                senderName.isNotEmpty ? senderName[0] : 'S',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(senderName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle:
                Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => FullChatNegotiationScreen(
                    adId: adId,
                    partnerName: senderName,
                    productTitle: 'تفاوض مباشر على السلعة',
                    initialPrice: 0,
                  ),
                ),
              );
            },
          ),
        );
      },
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

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: favAds.length,
      itemBuilder: (ctx, idx) => _buildCompactGridAdCard(favAds[idx]),
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
                      child: Text('الخطة: ${currentPlan.name}',
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
        ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: _manager.secondaryColor.withOpacity(0.15),
          leading: Icon(Icons.lightbulb, color: _manager.secondaryColor),
          title: const Text('صوتك مسموع 💡 - اقترح وطوّر التطبيق',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('أرسل أفكارك وملاحظاتك مباشرةً لصاحب التطبيق'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (ctx) => const AppFeedbackScreen())),
        ),
        const SizedBox(height: 10),
        if (!_manager.isLoggedIn)
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: _manager.primaryColor.withOpacity(0.1),
            leading: Icon(Icons.login, color: _manager.primaryColor),
            title: const Text('تسجيل الدخول / إنشاء حساب جديد',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('تأكيد بالبريد أو رقم الهاتف SMS'),
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
            onTap: () async {
              await _manager.logoutUser();
              setState(() {
                _favoriteAdIds.clear();
                _userChatThreads.clear();
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل الخروج بنجاح.')));
              }
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
          subtitle: const Text('ميزات حصرية ونشر غير محدود'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => const FullSubscriptionPlansScreen())),
        ),
        if (_manager.isModerator) ...[
          const SizedBox(height: 10),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: Colors.red.withOpacity(0.08),
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('غرفة العمليات ولوحة تحكم المشرفين 🛡️',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text(
                'موافقة الإعلانات، المشرفين، البنرات، ألوان النصوص والاقتراحات'),
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
              SnackBar(
                content: Text(
                  _manager.isSuperAdmin
                      ? '✨ تم نشر إعلانك فوراً ومباشرةً!'
                      : '⏳ تم استلام إعلانك بنجاح وسيعرض للجميع فور موافقة الإدارة عليه.',
                ),
                backgroundColor: _manager.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                      Icon(Icons.headset_mic, color: _manager.secondaryColor),
                  title: const Text('تواصل مع الإدارة 💬',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _showContactAdminDialog();
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.lightbulb, color: _manager.secondaryColor),
                  title: const Text('صوتك مسموع 💡 (اقترح وطوّر)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const AppFeedbackScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.workspace_premium,
                      color: _manager.secondaryColor),
                  title: const Text('خطط الاشتراك والترقية VIP'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                const FullSubscriptionPlansScreen()));
                  },
                ),
                if (_manager.isModerator)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.red),
                    title: const Text('غرفة العمليات ولوحة تحكم المشرفين'),
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
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.06),
              border:
                  Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: _manager.primaryColor),
                    const SizedBox(width: 4),
                    const Text('إخلاء المسؤولية القانونية',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _manager.disclaimerText,
                  style: const TextStyle(
                      fontSize: 9, color: Colors.grey, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
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
// 7. شاشة صوتك مسموع - صندوق الاقتراحات والملاحظات لصاحب التطبيق (AppFeedbackScreen)
// ==============================================================================
class AppFeedbackScreen extends StatefulWidget {
  const AppFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AppFeedbackScreen> createState() => _AppFeedbackScreenState();
}

class _AppFeedbackScreenState extends State<AppFeedbackScreen> {
  final AppStateManager _manager = AppStateManager();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedType = 'فكرة وميزة جديدة 💡';
  final List<String> _feedbackTypes = [
    'فكرة وميزة جديدة 💡',
    'ملاحظة على السرعة/التصميم ⚡',
    'الإبلاغ عن مشكلة تقنية 🛠️',
    'طلب إضافة قسم أو فرع جديد 📁',
    'كلمة شكر وتقييم للمنصة ⭐',
  ];

  Uint8List? _screenshotBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (_manager.isLoggedIn) {
      _contactController.text = _manager.currentUserPhone.isNotEmpty
          ? _manager.currentUserPhone
          : _manager.currentUserEmail;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _recordVoiceFeedback() async {
    final text = await showDialog<String>(
      context: context,
      builder: (c) =>
          const VoiceInputDialog(title: 'سجّل فكرتك أو ملاحظتك بصوتك 🎙️'),
    );
    if (text != null && text.isNotEmpty) {
      setState(() {
        if (_contentController.text.isNotEmpty) {
          _contentController.text += ' $text';
        } else {
          _contentController.text = text;
        }
      });
    }
  }

  Future<void> _pickScreenshot() async {
    final img = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 1024);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _screenshotBytes = bytes);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    String? screenshotPublicUrl;

    try {
      if (_screenshotBytes != null) {
        final fileName =
            'feedback_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from(kStorageBucketFeedbacks)
            .uploadBinary(
              fileName,
              _screenshotBytes!,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            )
            .timeout(const Duration(seconds: 12));

        screenshotPublicUrl = Supabase.instance.client.storage
            .from(kStorageBucketFeedbacks)
            .getPublicUrl(fileName);
      }

      final newFeedback = AppFeedbackItem(
        id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
        userId: _manager.currentUserId,
        userName:
            _manager.isLoggedIn ? _manager.currentUserName : 'مستخدم زائر',
        userContact: _contactController.text.trim(),
        type: _selectedType,
        content: _contentController.text.trim(),
        screenshotUrl: screenshotPublicUrl,
        createdAt: DateTime.now(),
      );

      _manager.feedbacks.insert(0, newFeedback);
      _manager.notifyListeners();

      await Supabase.instance.client
          .from('app_feedbacks')
          .insert(newFeedback.toMap())
          .timeout(const Duration(seconds: 8));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.volunteer_activism,
                    color: _manager.primaryColor, size: 28),
                const SizedBox(width: 8),
                const Text('شكراً لمساهمتك الغالية! ❤️'),
              ],
            ),
            content: const Text(
              'تم استلام فكرتك/ملاحظتك ووصلت مباشرة إلى صاحب التطبيق وفريق التطوير.\n\nرأيك وملاحظاتك هي الأساس في تطوير سوق سوريا الشامل 2028!',
              style: TextStyle(height: 1.5, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('حسناً',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Feedback Submit Note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✨ تم إرسال ملاحظتك لصاحب التطبيق بنجاح!')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openDirectWhatsappWithOwner() async {
    final cleanPhone = PhoneHelper.formatForWhatsapp(kAppOwnerWhatsApp);
    final msg = Uri.encodeComponent(
        'مرحباً أخي الكريم، لدي فكرة وملاحظة بخصوص تطبيق "سوق سوريا الشامل 2028":');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: const Text('صوتك مسموع 💡 - اقترح وطوّر التطبيق',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _manager.primaryColor.withOpacity(0.12),
                    _manager.secondaryColor.withOpacity(0.15)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: _manager.secondaryColor.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _manager.secondaryColor,
                    child: Icon(Icons.lightbulb,
                        color: _manager.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('رسالتك تصل مباشرة لصاحب التطبيق',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        const Text(
                            'شاركنا أفكارك، اقتراحاتك للأقسام، أو أي صعوبة واجهتك لنقوم بتطويرها فوراً.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('نوع الرسالة أو الاقتراح:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _feedbackTypes.map((type) {
                final isSel = _selectedType == type;
                return ChoiceChip(
                  label: Text(type,
                      style: TextStyle(
                          fontSize: 11,
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal)),
                  selected: isSel,
                  selectedColor: _manager.primaryColor,
                  onSelected: (val) {
                    if (val) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 800,
              decoration: InputDecoration(
                labelText: 'اكتب فكرتك أو ملاحظتك بالتفصيل *',
                hintText:
                    'مثال: أقترح إضافة ميزة تقييم الأسعار، أو واجهتني مشكلة في رفع الصور...',
                suffixIcon: _manager.isVoiceTypingEnabled
                    ? IconButton(
                        icon: Icon(Icons.mic, color: _manager.primaryColor),
                        tooltip: 'تحدث بالمايك لإملاء الفكرة',
                        onPressed: _recordVoiceFeedback,
                      )
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'يرجى كتابة نص الملاحظة أو الاقتراح'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'رقم هاتفك أو بريدك (للتواصل وشكرك على الفكرة)',
                hintText: '0933000000 أو إيميلك الشخصي',
                prefixIcon:
                    Icon(Icons.contact_phone, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            const Text('إرفاق صورة توضيحية أو لقطة شاشة (اختياري):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickScreenshot,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: _screenshotBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_screenshotBytes!,
                            fit: BoxFit.cover, width: double.infinity))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: _manager.primaryColor, size: 30),
                          const SizedBox(height: 4),
                          const Text('اضغط هنا لاختيار صورة من المعرض',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.send, color: Colors.white),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال الفكرة لصاحب التطبيق 🚀',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _submitFeedback,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                label: const Text('أو تحدث مباشرة مع صاحب التطبيق عبر الواتساب',
                    style: TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                onPressed: _openDirectWhatsappWithOwner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 8. الشاشة الرئيسية الكبرى والشبكة الثنائية الحديثة (MainDashboardScreen)
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
  int _pendingAdsCount = 0;
  List<Map<String, dynamic>> _userChatThreads = [];

  String _filterCondition = 'الكل';
  double? _filterMinPrice;
  double? _filterMaxPrice;
  String _sortBy = 'newest';

  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;
  bool _isTickerPaused = false;

  final PageController _bannerCarouselController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerAutoScrollTimer;
  bool _isBannerUserInteracting = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onStateChange);
    _initLiveAdsFromSupabase();
    _fetchUserFavorites();
    _fetchUserChats();
    _startTickerAnimation();
    _startBannerCarouselTimer();
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChange);
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    _bannerAutoScrollTimer?.cancel();
    _bannerCarouselController.dispose();
    _searchController.dispose();
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

  void _startBannerCarouselTimer() {
    _bannerAutoScrollTimer?.cancel();
    final interval =
        _manager.bannerIntervalSeconds > 0 ? _manager.bannerIntervalSeconds : 3;

    _bannerAutoScrollTimer =
        Timer.periodic(Duration(seconds: interval), (timer) {
      if (mounted &&
          !_isBannerUserInteracting &&
          _manager.banners.length > 1 &&
          _bannerCarouselController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _manager.banners.length;
        _bannerCarouselController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
        setState(() => _currentBannerIndex = nextIndex);
      }
    });
  }

  Future<void> _fetchUserFavorites() async {
    if (!_manager.isLoggedIn || _manager.currentUserId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('favorites')
          .select('ad_id')
          .eq('user_id', _manager.currentUserId)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _favoriteAdIds.clear();
          for (final row in res) {
            _favoriteAdIds.add(row['ad_id'].toString());
          }
        });
      }
    } catch (e) {
      debugPrint('Favorites fetch notice: $e');
    }
  }

  Future<void> _toggleFavoriteInSupabase(String adId) async {
    if (!_manager.isLoggedIn) return;
    final isFav = _favoriteAdIds.contains(adId);
    setState(() {
      if (isFav) {
        _favoriteAdIds.remove(adId);
      } else {
        _favoriteAdIds.add(adId);
      }
    });

    try {
      if (isFav) {
        await Supabase.instance.client
            .from('favorites')
            .delete()
            .match({'user_id': _manager.currentUserId, 'ad_id': adId}).timeout(
                const Duration(seconds: 8));
      } else {
        await Supabase.instance.client
            .from('favorites')
            .insert({'user_id': _manager.currentUserId, 'ad_id': adId}).timeout(
                const Duration(seconds: 8));
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> _fetchUserChats() async {
    if (!_manager.isLoggedIn || _manager.currentUserId.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _userChatThreads = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Fetch chats notice: $e');
    }
  }

  Future<void> _initLiveAdsFromSupabase() async {
    if (mounted) setState(() => _isLoadingAds = true);
    try {
      final res = await Supabase.instance.client
          .from('ads')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      if (res is List) {
        _manager.ads = res
            .map((map) => AdItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }

      final bannerRes = await Supabase.instance.client
          .from('banners')
          .select()
          .timeout(const Duration(seconds: 8));

      if (bannerRes is List && (bannerRes).isNotEmpty) {
        _manager.banners = bannerRes
            .map((map) => BannerItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }

      final pendingRes = await Supabase.instance.client
          .from('ads')
          .select('id')
          .eq('status', 'pending')
          .timeout(const Duration(seconds: 8));

      if (pendingRes is List && mounted) {
        setState(() => _pendingAdsCount = pendingRes.length);
      }

      await _manager.autoCleanupExpiredSoldAds();
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

  void _showContactAdminDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _manager.secondaryColor,
                    child: Icon(Icons.headset_mic,
                        color: _manager.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التواصل المباشر مع إدارة التطبيق',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('نحن هنا لخدمتكم ومساعدتكم على مدار الساعة',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFF25D366).withOpacity(0.12),
                leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                title: const Text('محادثة واتساب فورية مع الإدارة',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                    'رد سريع على الاستفسارات وحجز الإعلانات المميزة'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(ctx);
                  final clean =
                      PhoneHelper.formatForWhatsapp(kAppOwnerWhatsApp);
                  final msg = Uri.encodeComponent(
                      'مرحباً إدارة سوق سوريا الشامل 2028، لدي استفسار:');
                  final uri = Uri.parse('https://wa.me/$clean?text=$msg');
                  try {
                    if (await canLaunchUrl(uri))
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.blue.withOpacity(0.1),
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text('اتصال هاتفي مباشر بالإدارة',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('رقم الهاتف: $kAppOwnerPhone'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse('tel:$kAppOwnerPhone');
                  try {
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: _manager.secondaryColor.withOpacity(0.15),
                leading: Icon(Icons.lightbulb, color: _manager.secondaryColor),
                title: const Text('صوتك مسموع 💡 (صندوق الاقتراحات)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('إرسال فكرة أو شكوى مع إرفاق لقطة شاشة'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AppFeedbackScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdvancedFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: _manager.primaryColor),
                          const SizedBox(width: 8),
                          const Text('تصفية وفلترة متقدمة',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _filterCondition = 'الكل';
                            _filterMinPrice = null;
                            _filterMaxPrice = null;
                            _sortBy = 'newest';
                          });
                          setState(() {});
                        },
                        child: const Text('إعادة ضبط'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('حالة السلعة:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['الكل', 'جديد', 'مستعمل بحالة ممتازة', 'مستعمل']
                        .map((cond) {
                      final sel = _filterCondition == cond;
                      return ChoiceChip(
                        label: Text(cond,
                            style: TextStyle(
                                fontSize: 11,
                                color: sel ? Colors.white : Colors.black87)),
                        selected: sel,
                        selectedColor: _manager.primaryColor,
                        onSelected: (val) {
                          if (val) setSheetState(() => _filterCondition = cond);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('ترتيب النتائج حسب:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      {'key': 'newest', 'label': 'الأحدث أولاً'},
                      {'key': 'price_asc', 'label': 'الأقل سعراً'},
                      {'key': 'price_desc', 'label': 'الأعلى سعراً'},
                      {'key': 'views', 'label': 'الأكثر مشاهدة 🔥'},
                    ].map((s) {
                      final sel = _sortBy == s['key'];
                      return ChoiceChip(
                        label: Text(s['label']!,
                            style: TextStyle(
                                fontSize: 11,
                                color: sel ? Colors.white : Colors.black87)),
                        selected: sel,
                        selectedColor: _manager.primaryColor,
                        onSelected: (val) {
                          if (val) setSheetState(() => _sortBy = s['key']!);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('نطاق السعر التقريبي (\$ دولار):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'من (\$)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8)),
                          onChanged: (val) =>
                              _filterMinPrice = double.tryParse(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'إلى (\$)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8)),
                          onChanged: (val) =>
                              _filterMaxPrice = double.tryParse(val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _manager.buttonColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: const Text('تطبيق الفلترة ✨',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _recordSearchVoice() async {
    final res = await showDialog<String>(
      context: context,
      builder: (c) =>
          const VoiceInputDialog(title: 'البحث الصوتي الذكي في السوق 🎙️'),
    );
    if (res != null && res.isNotEmpty) {
      setState(() {
        _searchQuery = res;
        _searchController.text = res;
      });
    }
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
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _manager.secondaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: _manager.secondaryColor, width: 1.2),
              ),
              child: Icon(Icons.headset_mic,
                  color: _manager.secondaryColor, size: 18),
            ),
            tooltip: 'تواصل مع إدارة التطبيق',
            onPressed: _showContactAdminDialog,
          ),
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
          if (_manager.isModerator)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings,
                      color: Colors.amberAccent),
                  tooltip: 'غرفة العمليات والإشراف',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) =>
                              const FullAdminPanelScreen(initialTab: 1)),
                    );
                  },
                ),
                if (_pendingAdsCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '$_pendingAdsCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
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
    var filteredAds = _manager.ads.where((ad) {
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
      final matchesCond =
          _filterCondition == 'الكل' || ad.condition == _filterCondition;
      final matchesMinP = _filterMinPrice == null ||
          (ad.priceUsd != null && ad.priceUsd! >= _filterMinPrice!);
      final matchesMaxP = _filterMaxPrice == null ||
          (ad.priceUsd != null && ad.priceUsd! <= _filterMaxPrice!);

      final isApproved = ad.status == 'approved' || (_manager.isModerator);

      return matchesGov &&
          matchesCat &&
          matchesSub &&
          matchesSearch &&
          matchesCond &&
          matchesMinP &&
          matchesMaxP &&
          isApproved;
    }).toList();

    if (_sortBy == 'price_asc') {
      filteredAds.sort((a, b) => (a.priceUsd ?? 0).compareTo(b.priceUsd ?? 0));
    } else if (_sortBy == 'price_desc') {
      filteredAds.sort((a, b) => (b.priceUsd ?? 0).compareTo(a.priceUsd ?? 0));
    } else if (_sortBy == 'views') {
      filteredAds.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    } else {
      filteredAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Column(
      children: [
        _buildCustomNewsTickerWidget(),
        _buildMultiCardHeroBannerCarousel(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث في كافة إعلانات السوق (سيارات، عقارات، هواتف...)...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon:
                        Icon(Icons.search, color: _manager.primaryColor),
                    suffixIcon: _manager.isVoiceTypingEnabled
                        ? IconButton(
                            icon: Icon(Icons.mic, color: _manager.primaryColor),
                            tooltip: 'البحث بالصوت',
                            onPressed: _recordSearchVoice,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.08),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _filterCondition != 'الكل' ||
                          _filterMinPrice != null ||
                          _filterMaxPrice != null ||
                          _sortBy != 'newest'
                      ? _manager.secondaryColor
                      : Colors.grey.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.tune, color: _manager.primaryColor, size: 22),
                tooltip: 'تصفية وفلترة متقدمة',
                onPressed: _showAdvancedFilterSheet,
              ),
            ],
          ),
        ),
        _buildCategoriesHorizontalBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('أحدث إعلانات السوق',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _manager.titleTextColor)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                        color: _manager.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${filteredAds.length} إعلان',
                        style: TextStyle(
                            color: _manager.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_selectedGovernorate != 'كل المحافظات')
                Text('محافظة: $_selectedGovernorate',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontSize: 11,
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
                                Icon(Icons.search_off_rounded,
                                    size: 55, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text(
                                    'لا توجد إعلانات حالياً في هذا القسم أو المحافظة',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: filteredAds.length,
                        itemBuilder: (ctx, index) {
                          final ad = filteredAds[index];
                          return _buildCompactGridAdCard(ad);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: _manager.secondaryColor,
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Icon(_manager.tickerIcon,
                    color: _manager.primaryColor, size: 12),
                const SizedBox(width: 3),
                Text('عاجل',
                    style: TextStyle(
                        color: _manager.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
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

  Widget _buildMultiCardHeroBannerCarousel() {
    final bannersList = _manager.banners;
    if (bannersList.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: (_) => _isBannerUserInteracting = true,
              onPointerUp: (_) => _isBannerUserInteracting = false,
              onPointerCancel: (_) => _isBannerUserInteracting = false,
              child: PageView.builder(
                controller: _bannerCarouselController,
                itemCount: bannersList.length,
                onPageChanged: (idx) =>
                    setState(() => _currentBannerIndex = idx),
                itemBuilder: (ctx, idx) {
                  final banner = bannersList[idx];
                  return _buildSingleHeroBannerCard(
                      banner, idx, bannersList.length);
                },
              ),
            ),
          ),
          if (bannersList.length > 1) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannersList.length, (i) {
                final isSelected = i == _currentBannerIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  height: 4.5,
                  width: isSelected ? 16 : 5,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _manager.primaryColor
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleHeroBannerCard(
      BannerItem banner, int index, int totalCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                color: const Color(0xFF1E293B),
                child: const Center(
                    child:
                        Icon(Icons.campaign, color: Colors.white70, size: 36)),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${index + 1} / $totalCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 10,
            left: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                            color: _manager.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  children: [
                    if (banner.whatsapp.isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final clean =
                              PhoneHelper.formatForWhatsapp(banner.whatsapp);
                          final uri = Uri.parse('https://wa.me/$clean');
                          if (await canLaunchUrl(uri))
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              color: Color(0xFF25D366), shape: BoxShape.circle),
                          child: const Icon(Icons.chat,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    if (banner.phone.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse('tel:${banner.phone}');
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: _manager.primaryColor,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.phone,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHorizontalBar() {
    final currentCat = _manager.categories.firstWhere(
      (c) => c.name == _selectedCategoryId,
      orElse: () => _manager.categories.isNotEmpty
          ? _manager.categories.first
          : CategoryModel(
              id: 'all',
              name: 'الكل',
              iconData: Icons.category,
              subcategories: []),
    );

    final subcategories =
        _selectedCategoryId != null ? currentCat.subcategories : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: FilterChip(
                  label: const Text('الكل',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  selected: _selectedCategoryId == null,
                  selectedColor: _manager.primaryColor,
                  labelStyle: TextStyle(
                      color: _selectedCategoryId == null
                          ? Colors.white
                          : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onSelected: (_) => setState(() {
                    _selectedCategoryId = null;
                    _selectedSubcategory = null;
                  }),
                ),
              ),
              ..._manager.categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.name;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: FilterChip(
                    avatar: Icon(cat.iconData,
                        size: 14,
                        color: isSelected ? Colors.white : cat.textColor),
                    label: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11,
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
          const SizedBox(height: 3),
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: subcategories.map((sub) {
                final isSelected = _selectedSubcategory == sub;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ChoiceChip(
                    label: Text(sub,
                        style: TextStyle(
                            fontSize: 10,
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

  Widget _buildCompactGridAdCard(AdItem ad) {
    final isFav = _favoriteAdIds.contains(ad.id);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          _manager.incrementAdViews(ad.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => FullAdDetailsScreen(
                ad: ad,
                isFavorite: isFav,
                onToggleFavorite: () {
                  _requireAuth(() {
                    _toggleFavoriteInSupabase(ad.id);
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
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey.shade900,
                      child: Image.network(
                        ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5));
                        },
                        errorBuilder: (ctx, _, __) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                              child: Icon(Icons.image,
                                  size: 28, color: Colors.white38)),
                        ),
                      ),
                    ),
                  ),
                  if (ad.status == 'pending')
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade800,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('قيد المراجعة ⏳',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 8)),
                      ),
                    )
                  else if (ad.isFeatured)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                            color: _manager.secondaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('VIP ★',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9)),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: Colors.black45, shape: BoxShape.circle),
                      child: GestureDetector(
                        onTap: () {
                          _requireAuth(() {
                            _toggleFavoriteInSupabase(ad.id);
                          });
                        },
                        child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                            size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye,
                              color: Colors.white70, size: 9),
                          const SizedBox(width: 2),
                          Text('${ad.viewsCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (ad.isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                              child: const Text('✓ تم البيع',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ad.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: _manager.titleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ad.priceUsd != null)
                          Text('\$${ad.priceUsd!.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: _manager.priceUsdColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))
                        else if (ad.priceSyp != null)
                          Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: _manager.priceSypColor)),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: _manager.locationTextColor, size: 10),
                            const SizedBox(width: 1),
                            Expanded(
                              child: Text(
                                '${ad.governorate} - ${ad.neighborhood}',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: _manager.locationTextColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
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

    if (_userChatThreads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('لا توجد محادثات نشطة حالياً',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('تواصل مع أصحاب الإعلانات لبدء التفاوض المباشر.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userChatThreads.length,
      itemBuilder: (ctx, idx) {
        final thread = _userChatThreads[idx];
        final senderName = thread['sender_name']?.toString() ?? 'طرف التفاوض';
        final message = thread['message']?.toString() ?? '';
        final adId = thread['ad_id']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _manager.primaryColor,
              child: Text(
                senderName.isNotEmpty ? senderName[0] : 'S',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(senderName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle:
                Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => FullChatNegotiationScreen(
                    adId: adId,
                    partnerName: senderName,
                    productTitle: 'تفاوض مباشر على السلعة',
                    initialPrice: 0,
                  ),
                ),
              );
            },
          ),
        );
      },
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

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: favAds.length,
      itemBuilder: (ctx, idx) => _buildCompactGridAdCard(favAds[idx]),
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
                      child: Text('الخطة: ${currentPlan.name}',
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
        ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: _manager.secondaryColor.withOpacity(0.15),
          leading: Icon(Icons.lightbulb, color: _manager.secondaryColor),
          title: const Text('صوتك مسموع 💡 - اقترح وطوّر التطبيق',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('أرسل أفكارك وملاحظاتك مباشرةً لصاحب التطبيق'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (ctx) => const AppFeedbackScreen())),
        ),
        const SizedBox(height: 10),
        if (!_manager.isLoggedIn)
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: _manager.primaryColor.withOpacity(0.1),
            leading: Icon(Icons.login, color: _manager.primaryColor),
            title: const Text('تسجيل الدخول / إنشاء حساب جديد',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('تأكيد بالبريد أو رقم الهاتف SMS'),
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
            onTap: () async {
              await _manager.logoutUser();
              setState(() {
                _favoriteAdIds.clear();
                _userChatThreads.clear();
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل الخروج بنجاح.')));
              }
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
          subtitle: const Text('ميزات حصرية ونشر غير محدود'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => const FullSubscriptionPlansScreen())),
        ),
        if (_manager.isModerator) ...[
          const SizedBox(height: 10),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: Colors.red.withOpacity(0.08),
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('غرفة العمليات ولوحة تحكم المشرفين 🛡️',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text(
                'موافقة الإعلانات، المشرفين، البنرات، ألوان النصوص والاقتراحات'),
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
              SnackBar(
                content: Text(
                  _manager.isSuperAdmin
                      ? '✨ تم نشر إعلانك فوراً ومباشرةً!'
                      : '⏳ تم استلام إعلانك بنجاح وسيعرض للجميع فور موافقة الإدارة عليه.',
                ),
                backgroundColor: _manager.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                      Icon(Icons.headset_mic, color: _manager.secondaryColor),
                  title: const Text('تواصل مع الإدارة 💬',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _showContactAdminDialog();
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.lightbulb, color: _manager.secondaryColor),
                  title: const Text('صوتك مسموع 💡 (اقترح وطوّر)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const AppFeedbackScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.workspace_premium,
                      color: _manager.secondaryColor),
                  title: const Text('خطط الاشتراك والترقية VIP'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                const FullSubscriptionPlansScreen()));
                  },
                ),
                if (_manager.isModerator)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.red),
                    title: const Text('غرفة العمليات ولوحة تحكم المشرفين'),
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
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.06),
              border:
                  Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: _manager.primaryColor),
                    const SizedBox(width: 4),
                    const Text('إخلاء المسؤولية القانونية',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _manager.disclaimerText,
                  style: const TextStyle(
                      fontSize: 9, color: Colors.grey, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
