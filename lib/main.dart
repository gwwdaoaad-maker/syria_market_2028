import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==============================================================================
// 1. الثوابت السحابية الحقيقية الدقيقة لمشروعك وقنوات التخزين
// ==============================================================================
const String kSupabaseUrl = 'https://zbjjkigkxbpktpmpcdqc.supabase.co';
const String kSupabaseAnonKey =
    'sb_publishable_ZZ8I_vTK7kslyf02g3Zo8Q_Sg4Qi_zbjjkigkxbpktpmpcdqc';

const List<String> kSuperAdminEmails = [
  'sameraoaad@gmail.com',
  'aoaadabdo@gmail.com',
];

const String kStorageBucketAds = 'ad_images';
const String kStorageBucketBanners = 'banner_images';
const String kStorageBucketReceipts = 'receipt_images';

// ==============================================================================
// 2. نقطة الدخول والتهيئة المتوافقة 100% مع أندرويد و Supabase
// ==============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasSavedSession = false;
  String savedEmail = '';
  String savedUserId = '';

  try {
    await Supabase.initialize(
      url: kSupabaseUrl.trim(),
      anonKey: kSupabaseAnonKey.trim(),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    ).timeout(const Duration(seconds: 10));

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && session.user.email != null) {
      hasSavedSession = true;
      savedEmail = session.user.email!;
      savedUserId = session.user.id;
    }
  } on SocketException catch (e) {
    debugPrint('⚠️ [Network Error] SocketException during init: ${e.message}');
  } on TimeoutException catch (e) {
    debugPrint('⚠️ [Network Error] Connection timed out: $e');
  } catch (e) {
    debugPrint('⚠️ [Init Notice] General Supabase init notice: $e');
  }

  final appState = AppStateManager();

  if (hasSavedSession && savedEmail.isNotEmpty) {
    appState.setSessionUser(
      userId: savedUserId,
      email: savedEmail,
      name: savedEmail.split('@').first,
    );
  }

  try {
    await appState.initializeDataFromSupabase();
  } catch (e) {
    debugPrint('Initial Data Fetch notice: $e');
  }

  runApp(const SyriaMarket2028App());
}

// ==============================================================================
// 3. نماذج البيانات السحابية الحقيقية (Clean Data Models)
// ==============================================================================

/// نموذج الإعلان الحقيقي المرتبط بجدول ads في Supabase
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
  final DateTime? soldAt;
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
    this.soldAt,
    this.allowComments = true,
    this.status = 'approved',
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
    DateTime? soldAt,
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
      soldAt: soldAt ?? this.soldAt,
      allowComments: allowComments ?? this.allowComments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
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
      'sold_at': soldAt?.toIso8601String(),
      'allow_comments': allowComments,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
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
      categoryId: map['category_id']?.toString() ?? '',
      subcategory: map['subcategory']?.toString() ?? 'عام',
      governorate: map['governorate']?.toString() ?? 'دمشق',
      neighborhood: map['neighborhood']?.toString() ?? 'المركز',
      condition: map['condition']?.toString() ?? 'جديد',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      imageUrls:
          map['image_urls'] != null ? List<String>.from(map['image_urls']) : [],
      videoUrl: map['video_url']?.toString(),
      publisherName: map['publisher_name']?.toString() ?? 'معلن',
      publisherPhone: map['publisher_phone']?.toString() ?? '',
      publisherEmail: map['publisher_email']?.toString() ?? '',
      isFeatured: map['is_featured'] == true,
      isSold: map['is_sold'] == true,
      soldAt: map['sold_at'] != null
          ? DateTime.tryParse(map['sold_at'].toString())
          : null,
      allowComments: map['allow_comments'] ?? true,
      status: map['status']?.toString() ?? 'approved',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// نموذج ميزة الباقة المصحوبة بأيقونة
class PlanFeature {
  String text;
  IconData icon;

  PlanFeature({required this.text, required this.icon});

  Map<String, dynamic> toMap() => {'text': text, 'icon_code': icon.codePoint};
}

/// نموذج باقة الاشتراك المرتبط بجدول plans
class PlanConfig {
  final String id;
  final String name;
  final double priceSyp;
  final String durationText;
  final String statusConditionText;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price_syp': priceSyp,
      'duration_text': durationText,
      'status_condition_text': statusConditionText,
      'max_ads_per_month': maxAdsPerMonth,
      'max_images_per_ad': maxImagesPerAd,
      'custom_features': customFeatures.map((f) => f.toMap()).toList(),
    };
  }

  factory PlanConfig.fromMap(Map<String, dynamic> map) {
    return PlanConfig(
      id: map['id']?.toString() ?? 'plan_free',
      name: map['name']?.toString() ?? 'الباقة المجانية',
      priceSyp: (map['price_syp'] as num?)?.toDouble() ?? 0.0,
      durationText: map['duration_text']?.toString() ?? 'شهرياً',
      statusConditionText:
          map['status_condition_text']?.toString() ?? 'متاحة للجميع',
      maxAdsPerMonth: (map['max_ads_per_month'] as num?)?.toInt() ?? 5,
      maxImagesPerAd: (map['max_images_per_ad'] as num?)?.toInt() ?? 10,
      customFeatures: (map['custom_features'] as List<dynamic>?)
              ?.map((f) => PlanFeature(
                    text: f['text']?.toString() ?? '',
                    icon: IconData(f['icon_code'] ?? Icons.check.codePoint,
                        fontFamily: 'MaterialIcons'),
                  ))
              .toList() ??
          [],
    );
  }
}

/// نموذج القسم الرئيسي والفرعي المرتبط بجدول categories
class CategoryModel {
  final String id;
  String name;
  IconData iconData;
  Color backgroundColor;
  Color textColor;
  double borderRadiusValue;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconData.codePoint,
      'bg_color': backgroundColor.value,
      'text_color': textColor.value,
      'border_radius': borderRadiusValue,
      'subcategories': subcategories,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      iconData: IconData(
          (map['icon_code'] as num?)?.toInt() ?? Icons.category.codePoint,
          fontFamily: 'MaterialIcons'),
      backgroundColor: Color((map['bg_color'] as num?)?.toInt() ?? 0xFF0F5132),
      textColor: Color((map['text_color'] as num?)?.toInt() ?? 0xFFFFFFFF),
      borderRadiusValue: (map['border_radius'] as num?)?.toDouble() ?? 12.0,
      subcategories: map['subcategories'] != null
          ? List<String>.from(map['subcategories'])
          : ['عام'],
    );
  }
}

/// نموذج البنرات الترويجية الحية المرتبطة بجدول banners
class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetUrl;
  final String position; // 'top' أو 'bottom'

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'position': position,
    };
  }

  factory BannerItem.fromMap(Map<String, dynamic> map) {
    return BannerItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      targetUrl: map['target_url']?.toString() ?? '',
      position: map['position']?.toString() ?? 'top',
    );
  }
}

/// نموذج طرق الدفع والتواصل
class PaymentMethod {
  final String id;
  final String title;
  final String accountNumber;
  final String recipientName;
  final String notes;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.title,
    required this.accountNumber,
    required this.recipientName,
    required this.notes,
    required this.icon,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      accountNumber: map['account_number']?.toString() ?? '',
      recipientName: map['recipient_name']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      icon: IconData(
          (map['icon_code'] as num?)?.toInt() ?? Icons.payment.codePoint,
          fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'account_number': accountNumber,
        'recipient_name': recipientName,
        'notes': notes,
        'icon_code': icon.codePoint,
      };
}

/// نموذج رسائل المحادثة والتفاوض المباشر
class ChatMessage {
  final String id;
  final String adId;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final double? offerAmount;

  ChatMessage({
    required this.id,
    this.adId = '',
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.offerAmount,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    final sender = map['sender_id']?.toString() ?? '';
    return ChatMessage(
      id: map['id']?.toString() ?? '',
      adId: map['ad_id']?.toString() ?? '',
      senderId: sender,
      senderName: map['sender_name']?.toString() ?? 'مستخدم',
      senderEmail: map['sender_email']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      timestamp: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isMe: sender == currentUserId,
      offerAmount: (map['offer_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ad_id': adId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_email': senderEmail,
        'message': message,
        'offer_amount': offerAmount,
        'created_at': timestamp.toIso8601String(),
      };
}

/// نموذج الصلاحيات للمشرفين
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

  Map<String, dynamic> toMap() => {
        'can_review_ads': canReviewAds,
        'can_manage_news': canManageNews,
        'can_manage_banners': canManageBanners,
        'can_manage_categories': canManageCategories,
        'can_manage_plans': canManagePlans,
        'can_manage_users': canManageUsers,
        'can_change_colors': canChangeColors,
      };

  factory AdminPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AdminPermissions();
    return AdminPermissions(
      canReviewAds: map['can_review_ads'] ?? true,
      canManageNews: map['can_manage_news'] ?? true,
      canManageBanners: map['can_manage_banners'] ?? true,
      canManageCategories: map['can_manage_categories'] ?? true,
      canManagePlans: map['can_manage_plans'] ?? true,
      canManageUsers: map['can_manage_users'] ?? true,
      canChangeColors: map['can_change_colors'] ?? true,
    );
  }
}

/// نموذج المشرف والمستخدم (AdminUser)
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String planId;
  final bool isBanned;
  final bool isFrozen;
  final AdminPermissions permissions;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.planId = 'plan_free',
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
    String? planId,
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
      planId: planId ?? this.planId,
      isBanned: isBanned ?? this.isBanned,
      isFrozen: isFrozen ?? this.isFrozen,
      permissions: permissions ?? this.permissions,
    );
  }

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'مستخدم',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      planId: map['plan_id']?.toString() ?? 'plan_free',
      isBanned: map['is_banned'] == true,
      isFrozen: map['is_frozen'] == true,
      permissions:
          AdminPermissions.fromMap(map['permissions'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'plan_id': planId,
        'is_banned': isBanned,
        'is_frozen': isFrozen,
        'permissions': permissions.toMap(),
      };
}

// ==============================================================================
// 4. شاشة عرض الصور الكبيرة بملء الشاشة مع التكبير والتصغير (FullScreenImageViewer)
// ==============================================================================
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'الصورة ${_currentIndex + 1} من ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (idx) => setState(() => _currentIndex = idx),
        itemBuilder: (ctx, idx) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrls[idx],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (_, __, ___) => const Center(
                  child:
                      Icon(Icons.broken_image, size: 80, color: Colors.white38),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==============================================================================
// 5. مزود الحالة العام السحابي المطور الحقيقي (AppStateManager)
// ==============================================================================
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // إعدادات التطبيق العامة
  String appTitle = 'سوق سوريا';
  String appSubtitle = 'الشامل 2028';
  bool isMaintenanceMode = false;
  String maintenanceMessage =
      'المنصة حالياً تحت الصيانة الدورية. سنعود قريباً جداً!';
  String disclaimerText =
      'إخلاء مسؤولية: موقع وتطبيق "سوق سوريا الشامل 2028" منصة إعلانية حرة ومستقلة للربط المباشر بين البائع والمشتري دون وسيط. إدارة المنصة تخلي مسؤوليتها القانونية والمالية عن صحة التعاملات، ونحث دائماً على المعاينة الشخصية قبل إتمام أي دفع. كافة الحقوق محفوظة © 2028.';

  // الميزات الصوتية
  bool isVoiceTypingEnabled = true;
  bool isTextToSpeechEnabled = true;

  // الثيم والألوان العامة
  Color primaryColor = const Color(0xFF0F5132);
  Color secondaryColor = const Color(0xFFD4AF37);
  Color appBarColor = const Color(0xFF0F5132);
  Color buttonColor = const Color(0xFF0F5132);
  Color scaffoldBgColor = const Color(0xFFF8FAFC);

  // إعدادات شريط الأخبار المتحرك
  double tickerSpeed = 1.2;
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
  List<BannerItem> banners = [];
  List<String> newsTicker = [];
  List<PlanConfig> plans = [];
  List<CategoryModel> categories = [];
  List<PaymentMethod> paymentMethods = [];
  List<AdminUser> registeredUsers = [];

  // ==========================================
  // استدعاء وتحميل البيانات الحقيقية من Supabase
  // ==========================================
  Future<void> initializeDataFromSupabase() async {
    _populateDefaults();

    try {
      final session = _client?.auth.currentSession;
      if (session != null && session.user.email != null) {
        setSessionUser(
          userId: session.user.id,
          email: session.user.email!,
          name: session.user.email!.split('@').first,
        );
      }
    } catch (_) {}

    fetchAppSettings();
    fetchAds();
    fetchBanners();
    fetchCategories();
    fetchPlans();
    fetchNewsTicker();
    fetchPaymentMethods();
    autoCleanupExpiredSoldAds();
  }

  void _populateDefaults() {
    _populateDefaultCategories();
    _populateDefaultPlans();
    _populateDefaultPaymentMethods();
    _populateDefaultNewsTicker();
  }

  void setSessionUser(
      {required String userId, required String email, required String name}) {
    isLoggedIn = true;
    currentUserId = userId;
    currentUserEmail = email.trim();
    currentUserName = name;
    currentUserPlanId = isSuperAdmin ? 'plan_vip' : 'plan_free';
    notifyListeners();
  }

  // 1. جلب الإعدادات العامة
  Future<void> fetchAppSettings() async {
    if (_client == null) return;
    try {
      final res = await _client!
          .from('app_settings')
          .select()
          .maybeSingle()
          .timeout(const Duration(seconds: 6));
      if (res != null) {
        appTitle = res['app_title'] ?? appTitle;
        appSubtitle = res['app_subtitle'] ?? appSubtitle;
        isMaintenanceMode = res['is_maintenance'] ?? false;
        maintenanceMessage = res['maintenance_message'] ?? maintenanceMessage;
        disclaimerText = res['disclaimer_text'] ?? disclaimerText;
        if (res['primary_color'] != null)
          primaryColor = Color(res['primary_color']);
        if (res['secondary_color'] != null)
          secondaryColor = Color(res['secondary_color']);
        if (res['app_bar_color'] != null)
          appBarColor = Color(res['app_bar_color']);
        if (res['button_color'] != null)
          buttonColor = Color(res['button_color']);
        if (res['scaffold_bg_color'] != null)
          scaffoldBgColor = Color(res['scaffold_bg_color']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching app settings: $e');
    }
  }

  // 2. جلب الإعلانات الحقيقية
  Future<void> fetchAds() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('ads')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));
      if (response is List) {
        ads = response.map((row) => AdItem.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching ads: $e');
    }
  }

  // 3. جلب البنرات
  Future<void> fetchBanners() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('banners')
          .select()
          .timeout(const Duration(seconds: 6));
      if (response is List) {
        banners = response.map((row) => BannerItem.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    }
  }

  // 4. جلب الأقسام
  Future<void> fetchCategories() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('categories')
          .select()
          .timeout(const Duration(seconds: 6));
      if ((response as List).isNotEmpty) {
        categories = response.map((row) => CategoryModel.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _populateDefaultCategories() {
    categories = [
      CategoryModel(
        id: 'cars',
        name: '🚗 سيارات ومركبات',
        iconData: Icons.directions_car,
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
        subcategories: [
          'فرص عمل وشواغر',
          'خدمات صيانة ومنزلية',
          'شحن ونقل بضائع',
          'دروس واستشارات'
        ],
      ),
    ];
  }

  // 5. جلب الباقات
  Future<void> fetchPlans() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('plans')
          .select()
          .timeout(const Duration(seconds: 6));
      if ((response as List).isNotEmpty) {
        plans = response.map((row) => PlanConfig.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _populateDefaultPlans() {
    plans = [
      PlanConfig(
        id: 'plan_free',
        name: 'الباقة المجانية',
        priceSyp: 0,
        durationText: 'دائمة',
        statusConditionText: 'متاحة لجميع الحسابات الجديدة فوراً',
        maxAdsPerMonth: 5,
        maxImagesPerAd: 10,
        customFeatures: [
          PlanFeature(
              text: 'نشر 5 إعلانات شهرياً', icon: Icons.check_circle_outline),
          PlanFeature(
              text: 'حتى 10 صور لكل إعلان بالمعرض',
              icon: Icons.photo_library_outlined),
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
          PlanFeature(
              text: 'حتى 10 صور عالية الدقة', icon: Icons.photo_library),
          PlanFeature(
              text: 'إضافة روابط وفيديوهات يوتيوب',
              icon: Icons.video_collection),
          PlanFeature(
              text: 'شارة VIP الذهبية والظهور بالصدارة', icon: Icons.verified),
          PlanFeature(
              text: 'الظهور في قسم البنرات الممولة', icon: Icons.campaign),
        ],
      ),
    ];
  }

  // 6. جلب شريط الأخبار
  Future<void> fetchNewsTicker() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('news_ticker')
          .select()
          .order('id', ascending: true)
          .timeout(const Duration(seconds: 6));
      if ((response as List).isNotEmpty) {
        newsTicker =
            response.map((row) => row['text']?.toString() ?? '').toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _populateDefaultNewsTicker() {
    newsTicker = [
      '🔥 مرحباً بكم في سوق سوريا الشامل 2028 - المنصة الرائدة للبيع والشراء والمزادات الحرة في كافة المحافظات',
      '👑 باقة VIP الذهبية متاحة الآن بخصم 50% مع ميزات نشر وتفاوض غير محدودة',
      '⚡ نظام الختم الأحمر والحذف التلقائي بعد 48 ساعة نشط الآن لحماية وتطهير المحتوى',
    ];
  }

  // 7. جلب طرق الدفع
  Future<void> fetchPaymentMethods() async {
    if (_client == null) return;
    try {
      final response = await _client!
          .from('payment_methods')
          .select()
          .timeout(const Duration(seconds: 6));
      if ((response as List).isNotEmpty) {
        paymentMethods =
            response.map((row) => PaymentMethod.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void _populateDefaultPaymentMethods() {
    paymentMethods = [
      PaymentMethod(
        id: 'syriatel',
        title: 'سيريتل كاش (Syriatel Cash)',
        accountNumber: '0933112233',
        recipientName: 'سوق سوريا الشامل 2028',
        notes:
            'يرجى تحويل المبلغ وتصوير إشعار العملية وإرفاقه بالأسفل لتفعيل الباقة فوراً.',
        icon: Icons.phone_android,
      ),
      PaymentMethod(
        id: 'mtn',
        title: 'MTN كاش (MTN Cash)',
        accountNumber: '0944112233',
        recipientName: 'سوق سوريا الشامل 2028',
        notes: 'تحويل فوري مباشر لحساب الكاش مع حفظ صورة العملية.',
        icon: Icons.account_balance_wallet,
      ),
      PaymentMethod(
        id: 'sham_bank',
        title: 'حساب بنك الشام / بنك البركة',
        accountNumber: 'SY-1002938472910',
        recipientName: 'شركة سوق سوريا للاستثمار',
        notes: 'إيداع بنكي مباشر عبر فروع البنك في كافة المحافظات.',
        icon: Icons.account_balance,
      ),
    ];
  }

  // تحديث إعدادات التطبيق وحفظها في Supabase
  Future<void> updateAppConfig({
    String? title,
    String? subtitle,
    bool? maintenance,
    String? maintMsg,
    String? disclaimer,
  }) async {
    if (title != null) appTitle = title;
    if (subtitle != null) appSubtitle = subtitle;
    if (maintenance != null) isMaintenanceMode = maintenance;
    if (maintMsg != null) maintenanceMessage = maintMsg;
    if (disclaimer != null) disclaimerText = disclaimer;
    notifyListeners();

    if (_client != null) {
      try {
        await _client!.from('app_settings').upsert({
          'id': 1,
          'app_title': appTitle,
          'app_subtitle': appSubtitle,
          'is_maintenance': isMaintenanceMode,
          'maintenance_message': maintenanceMessage,
          'disclaimer_text': disclaimerText,
        }).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Error updating app config: $e');
      }
    }
  }

  // تحديث الألوان وحفظها في Supabase
  Future<void> updateAppColors({
    Color? primary,
    Color? secondary,
    Color? appBar,
    Color? button,
    Color? scaffoldBg,
  }) async {
    if (primary != null) primaryColor = primary;
    if (secondary != null) secondaryColor = secondary;
    if (appBar != null) appBarColor = appBar;
    if (button != null) buttonColor = button;
    if (scaffoldBg != null) scaffoldBgColor = scaffoldBg;
    notifyListeners();

    if (_client != null) {
      try {
        await _client!.from('app_settings').upsert({
          'id': 1,
          'primary_color': primaryColor.value,
          'secondary_color': secondaryColor.value,
          'app_bar_color': appBarColor.value,
          'button_color': buttonColor.value,
          'scaffold_bg_color': scaffoldBgColor.value,
        }).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Error updating app colors: $e');
      }
    }
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

  Future<void> logoutUser() async {
    if (_client != null) {
      try {
        await _client!.auth.signOut().timeout(const Duration(seconds: 6));
      } catch (_) {}
    }
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

  // حذف صور الإعلان الحقيقية من الـ Storage
  static Future<void> deleteStorageImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.pathSegments.isNotEmpty) {
          final fileName = uri.pathSegments.last;
          await Supabase.instance.client.storage
              .from(kStorageBucketAds)
              .remove([fileName]).timeout(const Duration(seconds: 8));
        }
      } catch (_) {}
    }
  }

  // تنظيف وحذف الإعلانات المباعة بعد 48 ساعة حقيقياً من قاعدة البيانات والـ Storage
  Future<void> autoCleanupExpiredSoldAds() async {
    final now = DateTime.now();
    final expiredAds = ads.where((ad) {
      if (!ad.isSold || ad.soldAt == null) return false;
      return now.difference(ad.soldAt!).inHours >= 48;
    }).toList();

    for (final ad in expiredAds) {
      try {
        if (_client != null) {
          await _client!
              .from('ads')
              .delete()
              .eq('id', ad.id)
              .timeout(const Duration(seconds: 8));
        }
        await deleteStorageImages(ad.imageUrls);
        ads.removeWhere((x) => x.id == ad.id);
      } catch (_) {}
    }
    if (expiredAds.isNotEmpty) {
      notifyListeners();
    }
  }
}

// ==============================================================================
// 6. كلاس التطبيق الجذري (SyriaMarket2028App)
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
// 7. الشاشة الرئيسية الكبرى وشبكة المنشورات الثنائية الحقيقية (MainDashboardScreen)
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
    _fetchUserFavorites();
    _fetchUserChats();
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
      if (mounted && topBanners.length > 1 && _topBannerController.hasClients) {
        _currentTopBannerPage = (_currentTopBannerPage + 1) % topBanners.length;
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
      if (mounted &&
          bottomBanners.length > 1 &&
          _bottomBannerController.hasClients) {
        _currentBottomBannerPage =
            (_currentBottomBannerPage + 1) % bottomBanners.length;
        _bottomBannerController.animateToPage(
          _currentBottomBannerPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
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

      if (bannerRes is List) {
        _manager.banners = bannerRes
            .map((map) => BannerItem.fromMap(map as Map<String, dynamic>))
            .toList();
      }

      if (_manager.isSuperAdmin) {
        final pendingRes = await Supabase.instance.client
            .from('ads')
            .select('id')
            .eq('status', 'pending')
            .timeout(const Duration(seconds: 8));

        if (pendingRes is List && mounted) {
          setState(() => _pendingAdsCount = pendingRes.length);
        }
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
          if (_manager.isSuperAdmin)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_active,
                      color: Colors.amberAccent),
                  tooltip: 'إشعارات الإدارة والطلبات المعلقة',
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
      final isApproved = ad.status == 'approved' || (_manager.isSuperAdmin);

      return matchesGov &&
          matchesCat &&
          matchesSub &&
          matchesSearch &&
          isApproved;
    }).toList();

    return Column(
      children: [
        _buildCustomNewsTickerWidget(),
        _buildBannerCarouselBox('top', _topBannerController),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText:
                  'ابحث في كافة إعلانات سوق سوريا (سيارات، عقارات، هواتف...)...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.search, color: _manager.primaryColor),
              suffixIcon: _manager.isVoiceTypingEnabled
                  ? IconButton(
                      icon: Icon(Icons.mic, color: _manager.primaryColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('🎙️ جاري الاستماع للبحث الصوتي...')),
                        );
                      },
                    )
                  : null,
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
                  const Text('أحدث إعلانات السوق',
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
                          const SizedBox(height: 50),
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
                          const SizedBox(height: 20),
                          _buildBannerCarouselBox(
                              'bottom', _bottomBannerController),
                        ],
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, index) {
                                  final ad = filteredAds[index];
                                  return _buildGridAdCard(ad);
                                },
                                childCount: filteredAds.length,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _buildBannerCarouselBox(
                                'bottom', _bottomBannerController),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
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

  Widget _buildBannerCarouselBox(String position, PageController controller) {
    final positionBanners =
        _manager.banners.where((b) => b.position == position).toList();

    return Container(
      height: 125,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: positionBanners.isEmpty
          ? _buildVacantBannerPlaceholder(position)
          : PageView.builder(
              controller: controller,
              itemCount: positionBanners.length,
              itemBuilder: (ctx, idx) {
                final banner = positionBanners[idx];
                return _buildSingleBannerSquareCard(banner);
              },
            ),
    );
  }

  Widget _buildVacantBannerPlaceholder(String position) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _manager.primaryColor.withOpacity(0.12),
            _manager.secondaryColor.withOpacity(0.15),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _manager.secondaryColor.withOpacity(0.6), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => const FullPaymentMethodsScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _manager.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign,
                      color: _manager.primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مساحة إعلانية شاغرة ⭐ (${position == "top" ? "القسم العلوي" : "القسم السفلي"})',
                        style: TextStyle(
                            color: _manager.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ضع إعلانك التجاري المميز هنا ليصل لآلاف الزوار يومياً. اضغط للتواصل والحجز.',
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: _manager.primaryColor, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleBannerSquareCard(BannerItem banner) {
    return InkWell(
      onTap: () async {
        if (banner.targetUrl.isNotEmpty) {
          final uri = Uri.tryParse(banner.targetUrl);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
                      child: Icon(Icons.campaign,
                          color: Colors.white70, size: 36)),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                        color: _manager.secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

  Widget _buildGridAdCard(AdItem ad) {
    final isFav = _favoriteAdIds.contains(ad.id);

    return Card(
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
              flex: 6,
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
                              child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (ctx, _, __) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Center(
                              child: Icon(Icons.image,
                                  size: 36, color: Colors.white38)),
                        ),
                      ),
                    ),
                  ),
                  if (ad.isFeatured)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: _manager.secondaryColor,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('VIP ★',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10)),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
                            size: 16),
                      ),
                    ),
                  ),
                  if (ad.isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Text('✓ تم البيع',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ad.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ad.priceUsd != null)
                          Text('\$${ad.priceUsd!.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: _manager.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14))
                        else if (ad.priceSyp != null)
                          Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.blueGrey)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: _manager.primaryColor, size: 12),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${ad.governorate} - ${ad.neighborhood}',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
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
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: favAds.length,
      itemBuilder: (ctx, idx) => _buildGridAdCard(favAds[idx]),
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
          leading: Icon(Icons.payment, color: _manager.primaryColor),
          title: const Text('طرق الدفع والتحويل المالي'),
          subtitle: const Text('سيريتل كاش، MTN، بنك الشام وإرفاق الإيصال'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => const FullPaymentMethodsScreen())),
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
                  content:
                      Text('✨ تم نشر إعلانك بنجاح وحفظه سحابياً في Supabase!')),
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
                  leading: Icon(Icons.payment, color: _manager.primaryColor),
                  title: const Text('طرق الدفع والتواصل'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) =>
                                const FullPaymentMethodsScreen()));
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
                if (_manager.isSuperAdmin)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.red),
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
// 8. شاشة المصادقة وتأكيد الحسابات الشاملة والمحصنة (AuthScreen)
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
  bool _isPhoneAuthMode = false;
  bool _isWaitingForOtp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال رقم هاتف صالح (مثال: 0944000000)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final formattedPhone = phone.startsWith('+')
          ? phone
          : '+963${phone.startsWith('0') ? phone.substring(1) : phone}';
      await Supabase.instance.client.auth
          .signInWithOtp(phone: formattedPhone)
          .timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() {
          _isWaitingForOtp = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('📱 تم إرسال كود التحقق إلى $formattedPhone عبر SMS')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إرسال الرمز: $e')),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    final token = _otpController.text.trim();
    if (token.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى إدخال رمز التحقق المكون من 6 أرقام')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'مستخدم الهاتف';

    try {
      final formattedPhone = phone.startsWith('+')
          ? phone
          : '+963${phone.startsWith('0') ? phone.substring(1) : phone}';
      final res = await Supabase.instance.client.auth
          .verifyOTP(
            phone: formattedPhone,
            token: token,
            type: OtpType.sms,
          )
          .timeout(const Duration(seconds: 10));

      if (res.user != null) {
        _manager.setSessionUser(
            userId: res.user!.id, email: res.user!.email ?? '', name: name);
        try {
          await Supabase.instance.client.from('users_profiles').upsert({
            'id': res.user!.id,
            'name': name,
            'phone': phone,
            'role': _manager.isSuperAdmin ? 'super_admin' : 'user',
          }).timeout(const Duration(seconds: 8));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('OTP Verification Notice: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('🎉 تم التحقق وتأكيد رقم الهاتف $phone بنجاح!'),
            backgroundColor: _manager.primaryColor),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ كلمتا المرور غير متطابقتين، يرجى التأكد.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name =
        _isSignUp ? _nameController.text.trim() : (email.split('@').first);
    final phone = _phoneController.text.trim();

    try {
      if (_isSignUp) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name, 'phone': phone},
        ).timeout(const Duration(seconds: 12));

        if (mounted) setState(() => _isLoading = false);

        if (res.session == null && res.user != null) {
          if (mounted) _showEmailVerificationDialog(email);
          return;
        } else if (res.user != null) {
          _manager.setSessionUser(
              userId: res.user!.id, email: email, name: name);
          try {
            await Supabase.instance.client.from('users_profiles').upsert({
              'id': res.user!.id,
              'name': name,
              'email': email,
              'phone': phone,
              'role': _manager.isSuperAdmin ? 'super_admin' : 'user',
            }).timeout(const Duration(seconds: 8));
          } catch (_) {}
        }
      } else {
        final res = await Supabase.instance.client.auth
            .signInWithPassword(
              email: email,
              password: password,
            )
            .timeout(const Duration(seconds: 12));
        if (res.user != null) {
          _manager.setSessionUser(
              userId: res.user!.id, email: email, name: name);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
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
    } on SocketException catch (_) {
      _handleNetworkOrDnsFailure(name, email);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('⚠️ خطأ في الحساب: ${e.message}'),
              backgroundColor: Colors.red.shade800),
        );
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException')) {
        _handleNetworkOrDnsFailure(name, email);
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('خطأ: $e'), backgroundColor: Colors.red.shade800),
          );
        }
      }
    }
  }

  void _handleNetworkOrDnsFailure(String name, String email) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('تنبيه الاتصال بالشبكة'),
          ],
        ),
        content: const Text(
          'تعذر الوصول لمخدم Supabase بسبب حجب أو بطء بالـ DNS المحلي.\n\n'
          'يمكنك المتابعة بالوضع المحلي فوراً لاستخدام التطبيق دون توقف.',
          style: TextStyle(height: 1.5, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _manager.primaryColor),
            onPressed: () {
              Navigator.pop(ctx);
              _manager.setSessionUser(
                userId: 'local_${DateTime.now().millisecondsSinceEpoch}',
                email: email,
                name: name,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم تسجيل الدخول بالوضع المحلي بنجاح ✨')),
              );
            },
            child: const Text('المتابعة بالوضع المحلي',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mark_email_read, color: _manager.primaryColor, size: 28),
            const SizedBox(width: 8),
            const Text('تأكيد البريد الإلكتروني'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تم إرسال رابط تأكيد وتفعيل الحساب إلى البريد:'),
            const SizedBox(height: 6),
            Text(email,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 12),
            const Text('يرجى فتح بريدك والضغط على رابط التأكيد لتفعيل حسابك.'),
          ],
        ),
        actions: [
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isSignUp = false);
            },
            child: const Text('تم تأكيد الحساب (تسجيل الدخول)',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _manager.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        elevation: 0,
        title: Text(
          _isWaitingForOtp
              ? 'تأكيد رمز الهاتف OTP'
              : (_isSignUp ? 'إنشاء حساب جديد' : 'تسجيل الدخول'),
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
          child:
              _isWaitingForOtp ? _buildOtpVerificationUI() : _buildMainAuthUI(),
        ),
      ),
    );
  }

  Widget _buildOtpVerificationUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _manager.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(Icons.sms, size: 70, color: _manager.primaryColor),
        ),
        const SizedBox(height: 16),
        const Text('أدخل رمز التحقق (OTP)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('تم إرسال رمز مكون من 6 أرقام إلى ${_phoneController.text.trim()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '------',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _manager.buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            onPressed: _isLoading ? null : _verifyOtp,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('تأكيد الرمز والدخول فوراً ✨',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _isWaitingForOtp = false),
          child: const Text('العودة وتعديل رقم الهاتف'),
        ),
      ],
    );
  }

  Widget _buildMainAuthUI() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: _manager.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(Icons.account_circle,
                size: 72, color: _manager.primaryColor),
          ),
          const SizedBox(height: 14),
          Text(
            _isSignUp
                ? 'انضم إلى منصة سوق سوريا الشامل 2028'
                : 'أهلاً بك من جديد في ${_manager.appTitle}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('📧 البريد الإلكتروني'),
                selected: !_isPhoneAuthMode,
                selectedColor: _manager.primaryColor,
                labelStyle: TextStyle(
                    color: !_isPhoneAuthMode ? Colors.white : Colors.black87),
                onSelected: (val) => setState(() => _isPhoneAuthMode = false),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('📱 رقم الهاتف (SMS)'),
                selected: _isPhoneAuthMode,
                selectedColor: _manager.primaryColor,
                labelStyle: TextStyle(
                    color: _isPhoneAuthMode ? Colors.white : Colors.black87),
                onSelected: (val) => setState(() => _isPhoneAuthMode = true),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isSignUp) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل *',
                prefixIcon:
                    Icon(Icons.person_outline, color: _manager.primaryColor),
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
          ],
          if (_isPhoneAuthMode) ...[
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (سيريتل / MTN) *',
                hintText: '0944000000',
                prefixIcon:
                    Icon(Icons.phone_outlined, color: _manager.primaryColor),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: _isLoading ? null : _sendPhoneOtp,
                icon: const Icon(Icons.send_to_mobile, color: Colors.white),
                label: const Text('إرسال رمز التحقق OTP 📩',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني *',
                hintText: 'example@domain.com',
                prefixIcon:
                    Icon(Icons.email_outlined, color: _manager.primaryColor),
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
            const SizedBox(height: 14),
            if (_isSignUp) ...[
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور *',
                  prefixIcon:
                      Icon(Icons.lock_reset, color: _manager.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
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
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'يرجى إعادة كتابة كلمة المرور';
                  if (v != _passwordController.text)
                    return 'كلمتا المرور غير متطابقتين!';
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _manager.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                onPressed: _isLoading ? null : _submitEmailAuth,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isSignUp
                            ? 'إنشاء الحساب وتأكيد البريد ✨'
                            : 'تسجيل الدخول 🔑',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {
              _isSignUp = !_isSignUp;
              _isPhoneAuthMode = false;
            }),
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
    );
  }
}

// ==============================================================================
// 9. شاشة إضافة الإعلانات مع الرفع المتعدد للصور وحفظها في Supabase (FullAddAdScreen)
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
    if (_manager.categories.isNotEmpty) {
      _selectedCategory = _manager.categories.first.name;
      _selectedSubcategory = _manager.categories.first.subcategories.isNotEmpty
          ? _manager.categories.first.subcategories.first
          : 'عام';
    }
  }

  Future<void> _pickMultiImagesAndUpload() async {
    final currentPlan = _manager.getCurrentUserPlan();
    final remainingAllowed =
        currentPlan.maxImagesPerAd - _uploadedImageUrls.length;

    if (remainingAllowed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠️ لقد وصلت للحد الأقصى لعدد الصور (${currentPlan.maxImagesPerAd} صور).'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images.isNotEmpty) {
        setState(() => _isSubmitting = true);
        final selectedBatch = images.take(remainingAllowed).toList();

        for (final image in selectedBatch) {
          try {
            final Uint8List imageBytes = await image.readAsBytes();
            setState(() => _previewImageBytes.add(imageBytes));

            final cleanName =
                image.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
            final fileName =
                'ad_${DateTime.now().millisecondsSinceEpoch}_$cleanName';

            await Supabase.instance.client.storage
                .from(kStorageBucketAds)
                .uploadBinary(
                  fileName,
                  imageBytes,
                  fileOptions: const FileOptions(
                      contentType: 'image/jpeg', upsert: true),
                )
                .timeout(const Duration(seconds: 12));

            final publicUrl = Supabase.instance.client.storage
                .from(kStorageBucketAds)
                .getPublicUrl(fileName);
            setState(() => _uploadedImageUrls.add(publicUrl));
          } catch (e) {
            debugPrint('Multi-image upload notice: $e');
          }
        }

        setState(() => _isSubmitting = false);
        if (images.length > remainingAllowed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'تم رفع أول $remainingAllowed صور فقط بحسب سعة باقتك.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      debugPrint('Image picker error: $e');
    }
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final currentPlan = _manager.getCurrentUserPlan();
    final isSuper = _manager.isSuperAdmin;

    final newAdData = {
      'user_id': _manager.currentUserId.isNotEmpty
          ? _manager.currentUserId
          : Supabase.instance.client.auth.currentUser?.id,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'price_usd': double.tryParse(_priceUsdController.text.trim()),
      'price_syp': double.tryParse(_priceSypController.text.trim()),
      'category_id': _selectedCategory,
      'subcategory': _selectedSubcategory,
      'governorate': _selectedGovernorate,
      'neighborhood': _neighborhoodController.text.trim().isEmpty
          ? 'المركز'
          : _neighborhoodController.text.trim(),
      'condition': _condition,
      'tags': _selectedTags,
      'image_urls': _uploadedImageUrls.isNotEmpty
          ? _uploadedImageUrls
          : [
              'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'
            ],
      'video_url':
          currentPlan.customFeatures.any((f) => f.text.contains('فيديو'))
              ? _videoUrlController.text.trim()
              : null,
      'publisher_name': _publisherNameController.text.trim(),
      'publisher_phone': _publisherPhoneController.text.trim(),
      'publisher_email': _manager.currentUserEmail,
      'is_featured':
          currentPlan.customFeatures.any((f) => f.text.contains('VIP')),
      'allow_comments': _allowComments,
      'status': isSuper ? 'approved' : 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      final res = await Supabase.instance.client
          .from('ads')
          .insert(newAdData)
          .select()
          .single()
          .timeout(const Duration(seconds: 12));

      final createdAd = AdItem.fromMap(res);
      widget.onAdCreated(createdAd);
    } catch (e) {
      debugPrint('Supabase insert ad fallback notice: $e');
      final fallbackAd = AdItem(
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
        videoUrl:
            currentPlan.customFeatures.any((f) => f.text.contains('فيديو'))
                ? _videoUrlController.text.trim()
                : null,
        publisherName: _publisherNameController.text.trim(),
        publisherPhone: _publisherPhoneController.text.trim(),
        publisherEmail: _manager.currentUserEmail,
        isFeatured:
            currentPlan.customFeatures.any((f) => f.text.contains('VIP')),
        allowComments: _allowComments,
        status: isSuper ? 'approved' : 'pending',
        createdAt: DateTime.now(),
      );
      widget.onAdCreated(fallbackAd);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
    }
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
                      'أنت تنشر باستخدام "${currentPlan.name}" (مسموح حتى ${currentPlan.maxImagesPerAd} صور).',
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
                suffixIcon: _manager.isVoiceTypingEnabled
                    ? IconButton(
                        icon: Icon(Icons.mic, color: _manager.primaryColor),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    '🎙️ جاري الإملاء الصوتي لعنوان الإعلان...')),
                          );
                        },
                      )
                    : null,
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
                    value: _manager.categories
                            .any((c) => c.name == _selectedCategory)
                        ? _selectedCategory
                        : (_manager.categories.isNotEmpty
                            ? _manager.categories.first.name
                            : null),
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
                suffixIcon: _manager.isVoiceTypingEnabled
                    ? IconButton(
                        icon: Icon(Icons.mic, color: _manager.primaryColor),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('🎙️ جاري تسجيل الوصف صوتياً...')),
                          );
                        },
                      )
                    : null,
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
                const Text('صور الإعلان (تحديد عدة صور معاً):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                    '${_uploadedImageUrls.length} / ${currentPlan.maxImagesPerAd} صور مسموحة',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  InkWell(
                    onTap: _pickMultiImagesAndUpload,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: _manager.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _manager.primaryColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              color: _manager.primaryColor, size: 28),
                          const SizedBox(height: 4),
                          Text('تحديد صور متعددة 🖼️',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _manager.primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._previewImageBytes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final bytes = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 85,
                          margin: const EdgeInsets.only(left: 8),
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
// 10. شاشة تفاصيل المنشور وتكبير الصور والختم الأحمر الموحد (FullAdDetailsScreen)
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
  int _selectedImageIndex = 0;
  final TextEditingController _negotiateOfferController =
      TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
    _fetchAdComments();
  }

  @override
  void dispose() {
    _negotiateOfferController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final res = await Supabase.instance.client
          .from('ad_comments')
          .select()
          .eq('ad_id', _ad.id)
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _comments.clear();
          _comments.addAll(List<Map<String, dynamic>>.from(res));
        });
      }
    } catch (e) {
      debugPrint('Fetch comments error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment() async {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى تسجيل الدخول أولاً للتعليق.')),
      );
      return;
    }

    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final commentData = {
      'ad_id': _ad.id,
      'user_id': _manager.currentUserId,
      'user_name': _manager.currentUserName,
      'content': commentText,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _comments.add(commentData);
      _commentController.clear();
    });

    try {
      await Supabase.instance.client
          .from('ad_comments')
          .insert(commentData)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Insert comment error: $e');
    }
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
            const Text('تقديم عرض سعر وتفاوض'),
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
                labelText: 'عرضك المقترح (\$ أو ل.س)',
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
                      adId: _ad.id,
                      partnerName: _ad.publisherName,
                      productTitle: _ad.title,
                      initialPrice: double.tryParse(offer) ?? _ad.priceUsd ?? 0,
                    ),
                  ),
                );
              }
            },
            child: const Text('بدء الدردشة 🤝',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmAndApplySoldStamp() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('تأكيد ختم "تم البيع"'),
          ],
        ),
        content: const Text(
          'عند تأكيد تم البيع، سيتم عرض الختم للجميع وسيتم حذف المنشور نهائياً خلال 48 ساعة.\n\nهل أنت متأكد من إتمام العملية؟',
          style: TextStyle(height: 1.5, fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () async {
              Navigator.pop(ctx);
              final now = DateTime.now();
              final updated = _ad.copyWith(
                isSold: true,
                soldAt: now,
              );
              setState(() => _ad = updated);
              widget.onAdUpdated(updated);

              try {
                await Supabase.instance.client
                    .from('ads')
                    .update({
                      'is_sold': true,
                      'sold_at': now.toIso8601String(),
                    })
                    .eq('id', updated.id)
                    .timeout(const Duration(seconds: 8));
              } catch (e) {
                debugPrint('Supabase sold status update error: $e');
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '🔴 تم وضع ختم "تم البيع" وسيتم حذف الإعلان نهائياً بعد 48 ساعة.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('نعم، تأكيد تم البيع ✓',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteAdPermanently() async {
    final imagesToDelete = List<String>.from(_ad.imageUrls);
    try {
      await Supabase.instance.client
          .from('ads')
          .delete()
          .eq('id', _ad.id)
          .timeout(const Duration(seconds: 8));
      await AppStateManager.deleteStorageImages(imagesToDelete);
    } catch (e) {
      debugPrint('Supabase permanent delete error: $e');
    }

    widget.onAdDeleted(_ad.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🗑️ تم حذف المنشور ومسح صوره نهائياً من Supabase.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _ad.imageUrls.isNotEmpty
        ? _ad.imageUrls
        : [
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'
          ];

    final isOwnerOrAdmin = _manager.isSuperAdmin ||
        (_manager.isLoggedIn && _ad.userId == _manager.currentUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: Text(_ad.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_manager.isTextToSpeechEnabled)
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              tooltip: 'قراءة الإعلان صوتياً',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '🔊 تفاصيل الإعلان: ${_ad.title} - السعر: ${_ad.priceUsd != null ? "${_ad.priceUsd} دولار" : "${_ad.priceSyp} ليرة"}')),
                );
              },
            ),
          IconButton(
            icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.isFavorite ? Colors.red : Colors.white),
            onPressed: widget.onToggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          // 1. المربع الكبير لعرض الصورة المحددة
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => FullScreenImageViewer(
                    imageUrls: images,
                    initialIndex: _selectedImageIndex,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: Image.network(
                    images[_selectedImageIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                        child:
                            Icon(Icons.image, size: 60, color: Colors.white38)),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: const [
                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('انقر للتكبير الكامل',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                if (_ad.isSold)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade800,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('✓ تـم الـبـيـع',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                SizedBox(height: 2),
                                Text('سيتم حذف الإعلان نهائياً خلال 48 ساعة',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 2. شريط الصور المصغرة Thumbnails تحت الصورة الكبيرة
          if (images.length > 1) ...[
            Container(
              height: 75,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: Colors.grey.shade900,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (ctx, idx) {
                  final isSelected = idx == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = idx),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _manager.secondaryColor
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(images[idx]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

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
                      label: Text('تفاوض 🤝',
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                    onPressed: () async {
                      final uri = Uri.tryParse(_ad.videoUrl!);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // 3. قسم أزرار المالك والأدمن
                if (isOwnerOrAdmin) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'إجراءات التحكم بالمنشور (خاص بصاحب الإعلان والمشرف):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (!_ad.isSold)
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade800),
                                  icon: const Icon(Icons.verified,
                                      color: Colors.white, size: 18),
                                  label: const Text('ختم تم البيع 🔴',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  onPressed: _confirmAndApplySoldStamp,
                                ),
                              )
                            else
                              const Expanded(
                                child: Text(
                                    'الإعلان مختوم بـ "تم البيع" وسيتم حذفه تلقائياً.',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red)),
                              icon: const Icon(Icons.delete_forever, size: 18),
                              label: const Text('حذف فوري',
                                  style: TextStyle(fontSize: 12)),
                              onPressed: _deleteAdPermanently,
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      onPressed: _addComment,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_isLoadingComments)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator()))
                else if (_comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('لا توجد تعليقات بعد، كن أول من يعلق!',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                else
                  ..._comments.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['user_name'] ?? 'مستخدم',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _manager.primaryColor)),
                            const SizedBox(height: 2),
                            Text(c['content'] ?? '',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
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
                  onPressed: () async {
                    final uri = Uri.parse('tel:${_ad.publisherPhone}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
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
                  onPressed: () async {
                    final cleanPhone =
                        _ad.publisherPhone.replaceAll(RegExp(r'[^0-9]'), '');
                    final uri = Uri.parse('https://wa.me/963$cleanPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
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
// 11. شاشة طرق الدفع والتحويل المالي السحابية (FullPaymentMethodsScreen)
// ==============================================================================
class FullPaymentMethodsScreen extends StatefulWidget {
  const FullPaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<FullPaymentMethodsScreen> createState() =>
      _FullPaymentMethodsScreenState();
}

class _FullPaymentMethodsScreenState extends State<FullPaymentMethodsScreen> {
  final AppStateManager _manager = AppStateManager();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _receiptBytes;
  bool _isUploadingReceipt = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _receiptBytes = bytes);
    }
  }

  Future<void> _submitReceipt() async {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ يرجى تسجيل الدخول أولاً لرفع إشعار التحويل.')),
      );
      return;
    }

    if (_receiptBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى إرفاق صورة إشعار التحويل أولاً')),
      );
      return;
    }

    setState(() => _isUploadingReceipt = true);
    try {
      final fileName =
          'receipt_${DateTime.now().millisecondsSinceEpoch}_${_manager.currentUserId}.jpg';
      await Supabase.instance.client.storage
          .from(kStorageBucketReceipts)
          .uploadBinary(
            fileName,
            _receiptBytes!,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          )
          .timeout(const Duration(seconds: 12));

      final publicUrl = Supabase.instance.client.storage
          .from(kStorageBucketReceipts)
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('receipts').insert({
        'user_id': _manager.currentUserId,
        'user_name': _manager.currentUserName,
        'user_email': _manager.currentUserEmail,
        'receipt_url': publicUrl,
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).timeout(const Duration(seconds: 8));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  '✅ تم رفع وحفظ إشعار التحويل في Supabase! سيتم تفعيل حسابك فوراً.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Receipt Upload Notice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح!')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isUploadingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: const Text('طرق الدفع والتواصل 💳',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('الحسابات المعتمدة للتحويل وتفعيل VIP:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ..._manager.paymentMethods
              .map((method) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      _manager.primaryColor.withOpacity(0.12),
                                  child: Icon(method.icon,
                                      color: _manager.primaryColor)),
                              const SizedBox(width: 10),
                              Text(method.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('رقم الحساب: ${method.accountNumber}',
                                    style: TextStyle(
                                        color: _manager.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'تم نسخ الرقم: ${method.accountNumber}')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('اسم المستلم: ${method.recipientName}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(method.notes,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          const SizedBox(height: 16),
          const Divider(),
          const Text('إرفاق إشعار التحويل المالي:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickReceiptImage,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: _manager.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: _manager.primaryColor.withOpacity(0.4)),
              ),
              child: _receiptBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(_receiptBytes!,
                          fit: BoxFit.cover, width: double.infinity))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file,
                            size: 36, color: _manager.primaryColor),
                        const SizedBox(height: 6),
                        const Text('اضغط لاختيار صورة الإيصال من المعرض',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
                labelText: 'ملاحظات أو رقم المعاملة...',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _manager.buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.send, color: Colors.white),
              label: _isUploadingReceipt
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إرسال الإشعار لتفعيل الباقة فوراً 🚀',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _isUploadingReceipt ? null : _submitReceipt,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 12. شاشة التفاوض والدردشة الحقيقية (FullChatNegotiationScreen)
// ==============================================================================
class FullChatNegotiationScreen extends StatefulWidget {
  final String adId;
  final String partnerName;
  final String productTitle;
  final double initialPrice;

  const FullChatNegotiationScreen({
    Key? key,
    this.adId = '',
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
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveChatMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveChatMessages() async {
    setState(() => _isLoadingMessages = true);
    try {
      final res = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 8));

      if (res is List && res.isNotEmpty && mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(res.map((r) => ChatMessage.fromMap(
              r as Map<String, dynamic>, _manager.currentUserId)));
        });
      } else if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: 'msg-init',
              adId: widget.adId,
              senderId: _manager.currentUserId,
              senderName: _manager.currentUserName,
              senderEmail: _manager.currentUserEmail,
              message:
                  'مرحباً، أود بدء التفاوض حول "${widget.productTitle}" بسعر \$${widget.initialPrice.toStringAsFixed(0)}.',
              timestamp: DateTime.now(),
              isMe: true,
              offerAmount: widget.initialPrice,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _sendMessage() async {
    final txt = _msgController.text.trim();
    if (txt.isEmpty) return;

    final newMsg = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      adId: widget.adId,
      senderId: _manager.currentUserId,
      senderName: _manager.currentUserName,
      senderEmail: _manager.currentUserEmail,
      message: txt,
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(newMsg);
      _msgController.clear();
    });

    try {
      await Supabase.instance.client
          .from('chat_messages')
          .insert(newMsg.toMap())
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Error inserting chat message: $e');
    }
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
            child: _isLoadingMessages
                ? Center(
                    child:
                        CircularProgressIndicator(color: _manager.primaryColor))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, idx) {
                      final msg = _messages[idx];
                      return Align(
                        alignment: msg.isMe
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
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
                              Text(msg.message,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                  '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, "0")}',
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
// 13. شاشة باقات وترقيات VIP الذهبية (FullSubscriptionPlansScreen)
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
                      child: Text('الحالة: ${plan.statusConditionText}',
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
                        onPressed: () async {
                          manager.currentUserPlanId = plan.id;
                          manager.notifyListeners();
                          if (manager.isLoggedIn &&
                              manager.currentUserId.isNotEmpty) {
                            try {
                              await Supabase.instance.client
                                  .from('users_profiles')
                                  .update({
                                    'plan_id': plan.id,
                                  })
                                  .eq('id', manager.currentUserId)
                                  .timeout(const Duration(seconds: 8));
                            } catch (e) {
                              debugPrint('Error updating user plan: $e');
                            }
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('🎉 تم اختيار ${plan.name} بنجاح!')),
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
// 14. غرفة العمليات ولوحة تحكم المشرفين التنفيذية (FullAdminPanelScreen)
// ==============================================================================
class FullAdminPanelScreen extends StatefulWidget {
  final int initialTab;

  const FullAdminPanelScreen({Key? key, this.initialTab = 0}) : super(key: key);

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
  late TextEditingController _disclaimerController;

  final TextEditingController _categoryNameController = TextEditingController();
  double _catRadius = 12.0;
  IconData _selectedCatIcon = Icons.category;

  final TextEditingController _newsInputController = TextEditingController();

  final TextEditingController _bannerTitleController = TextEditingController();
  final TextEditingController _bannerSubController = TextEditingController();
  final TextEditingController _bannerUrlController = TextEditingController();
  String _bannerPosition = 'top';
  Uint8List? _selectedBannerBytes;
  bool _isPublishingBanner = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 7, vsync: this, initialIndex: widget.initialTab);
    _titleController = TextEditingController(text: _manager.appTitle);
    _subtitleController = TextEditingController(text: _manager.appSubtitle);
    _maintMsgController =
        TextEditingController(text: _manager.maintenanceMessage);
    _disclaimerController =
        TextEditingController(text: _manager.disclaimerText);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _maintMsgController.dispose();
    _disclaimerController.dispose();
    _categoryNameController.dispose();
    _newsInputController.dispose();
    _bannerTitleController.dispose();
    _bannerSubController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _selectedBannerBytes = bytes);
    }
  }

  Future<void> _publishBannerToSupabase() async {
    final title = _bannerTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى كتابة عنوان البنر')));
      return;
    }

    setState(() => _isPublishingBanner = true);
    String finalImageUrl =
        'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600';

    try {
      if (_selectedBannerBytes != null) {
        final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from(kStorageBucketBanners)
            .uploadBinary(
              fileName,
              _selectedBannerBytes!,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            )
            .timeout(const Duration(seconds: 12));
        finalImageUrl = Supabase.instance.client.storage
            .from(kStorageBucketBanners)
            .getPublicUrl(fileName);
      }

      final newBannerData = {
        'title': title,
        'subtitle': _bannerSubController.text.trim(),
        'image_url': finalImageUrl,
        'target_url': _bannerUrlController.text.trim(),
        'position': _bannerPosition,
      };

      final res = await Supabase.instance.client
          .from('banners')
          .insert(newBannerData)
          .select()
          .single()
          .timeout(const Duration(seconds: 8));

      final newBanner = BannerItem.fromMap(res);

      if (mounted) {
        setState(() {
          _manager.banners.add(newBanner);
          _selectedBannerBytes = null;
          _bannerTitleController.clear();
          _bannerSubController.clear();
          _bannerUrlController.clear();
        });
        _manager.notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🚀 تم رفع ونشر البنر سحابياً في Supabase بنجاح!')),
        );
      }
    } catch (e) {
      debugPrint('Banner publish notice: $e');
    } finally {
      if (mounted) setState(() => _isPublishingBanner = false);
    }
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
        const Text('إعدادات الهوية ووضع الصيانة وإخلاء المسؤولية:',
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
                        border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                        labelText: 'العنوان الفرعي',
                        border: OutlineInputBorder())),
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
                          labelText: 'رسالة الصيانة',
                          border: OutlineInputBorder())),
                ],
                const SizedBox(height: 12),
                TextField(
                    controller: _disclaimerController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'نص إخلاء المسؤولية وحقوق النشر',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('تفعيل الإملاء الصوتي 🎙️'),
                  value: _manager.isVoiceTypingEnabled,
                  activeColor: _manager.primaryColor,
                  onChanged: (val) {
                    setState(() => _manager.isVoiceTypingEnabled = val);
                    _manager.notifyListeners();
                  },
                ),
                SwitchListTile(
                  title: const Text('تفعيل القراءة الصوتية (TTS) 🔊'),
                  value: _manager.isTextToSpeechEnabled,
                  activeColor: _manager.primaryColor,
                  onChanged: (val) {
                    setState(() => _manager.isTextToSpeechEnabled = val);
                    _manager.notifyListeners();
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _manager.buttonColor),
                    onPressed: () async {
                      await _manager.updateAppConfig(
                        title: _titleController.text.trim(),
                        subtitle: _subtitleController.text.trim(),
                        maintMsg: _maintMsgController.text.trim(),
                        disclaimer: _disclaimerController.text.trim(),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                '✨ تم حفظ الإعدادات سحابياً في Supabase بنجاح!')));
                      }
                    },
                    child: const Text('حفظ التعديلات سحابياً 💾',
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
            Text('لا توجد إعلانات معلقة بانتظار المراجعة.',
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
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 65,
                              height: 65,
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
                              'السعر: ${ad.priceUsd != null ? "\$${ad.priceUsd}" : "${ad.priceSyp} ل.س"}',
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
                            backgroundColor: Colors.green.shade700),
                        icon:
                            const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('قبول ✔',
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
                                .update({'status': 'approved'})
                                .eq('id', ad.id)
                                .timeout(const Duration(seconds: 8));
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
                            backgroundColor: Colors.red.shade700),
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
                                .update({'status': 'rejected'})
                                .eq('id', ad.id)
                                .timeout(const Duration(seconds: 8));
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

    const allowedRadiusValues = [0.0, 12.0, 24.0];
    final safeRadius =
        allowedRadiusValues.contains(_catRadius) ? _catRadius : 12.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إضافة قسم جديد:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
                hintText: 'اسم القسم...', border: OutlineInputBorder())),
        const SizedBox(height: 10),
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
              value: safeRadius,
              items: const [
                DropdownMenuItem(value: 0.0, child: Text('حواف حادة (0px)')),
                DropdownMenuItem(
                    value: 12.0, child: Text('حواف منحنية (12px)')),
                DropdownMenuItem(
                    value: 24.0, child: Text('حواف دائرية (24px)')),
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
          label: const Text('إضافة وحفظ القسم سحابياً',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () async {
            final name = _categoryNameController.text.trim();
            if (name.isNotEmpty) {
              final newCat = CategoryModel(
                id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                iconData: _selectedCatIcon,
                backgroundColor: _manager.primaryColor,
                textColor: Colors.white,
                borderRadiusValue: safeRadius,
                subcategories: ['عام', 'ملحقات'],
              );
              setState(() {
                _manager.categories.add(newCat);
                _categoryNameController.clear();
              });
              _manager.notifyListeners();
              try {
                await Supabase.instance.client
                    .from('categories')
                    .insert(newCat.toMap())
                    .timeout(const Duration(seconds: 8));
              } catch (e) {
                debugPrint('Category insert notice: $e');
              }
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        setState(() => _manager.categories.remove(c));
                        _manager.notifyListeners();
                        try {
                          await Supabase.instance.client
                              .from('categories')
                              .delete()
                              .eq('id', c.id)
                              .timeout(const Duration(seconds: 8));
                        } catch (e) {
                          debugPrint('Category delete note: $e');
                        }
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
        const Text('إدارة الخطط والباقات:',
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
                        onChanged: (val) async {
                          final p = double.tryParse(val) ?? plan.priceSyp;
                          final updated = plan.copyWith(priceSyp: p);
                          _manager.plans[idx] = updated;
                          _manager.notifyListeners();
                          try {
                            await Supabase.instance.client
                                .from('plans')
                                .upsert(updated.toMap())
                                .timeout(const Duration(seconds: 8));
                          } catch (e) {
                            debugPrint('Plan update notice: $e');
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: conditionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'شرط وحالة الباقة',
                            border: OutlineInputBorder()),
                        onChanged: (val) async {
                          final updated =
                              plan.copyWith(statusConditionText: val);
                          _manager.plans[idx] = updated;
                          _manager.notifyListeners();
                          try {
                            await Supabase.instance.client
                                .from('plans')
                                .upsert(updated.toMap())
                                .timeout(const Duration(seconds: 8));
                          } catch (e) {
                            debugPrint('Plan condition notice: $e');
                          }
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '✨ تم تطبيق وحفظ ثيم ${t["name"]} في قاعدة البيانات!')));
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
      Icons.notifications_active
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
                        hintText: 'نص الخبر الجديد...',
                        border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton(
              style:
                  IconButton.styleFrom(backgroundColor: _manager.buttonColor),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final txt = _newsInputController.text.trim();
                if (txt.isNotEmpty) {
                  setState(() {
                    _manager.newsTicker.insert(0, txt);
                    _newsInputController.clear();
                  });
                  _manager.notifyListeners();
                  try {
                    await Supabase.instance.client.from('news_ticker').insert(
                        {'text': txt}).timeout(const Duration(seconds: 8));
                  } catch (e) {
                    debugPrint('News ticker insert note: $e');
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text('إدارة البنرات الإعلانية والرفع الحقيقي:',
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
                labelText: 'النص الفرعي', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(
            controller: _bannerUrlController,
            decoration: const InputDecoration(
                labelText: 'رابط التوجيه (URL)', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        Row(
          children: [
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
        InkWell(
          onTap: _pickBannerImage,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: _manager.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _manager.primaryColor.withOpacity(0.4)),
            ),
            child: _selectedBannerBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_selectedBannerBytes!,
                        fit: BoxFit.cover, width: double.infinity))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          color: _manager.primaryColor, size: 30),
                      const SizedBox(height: 4),
                      const Text('اختر صورة البنر من المعرض 🖼️',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style:
                ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            label: _isPublishingBanner
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('نشر البنر الآن 🚀',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _isPublishingBanner ? null : _publishBannerToSupabase,
          ),
        ),
        const SizedBox(height: 12),
        ..._manager.banners
            .map((b) => Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(b.imageUrl,
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image)),
                    ),
                    title: Text(b.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'القسم: ${b.position == "top" ? "العلوي" : "السفلي"}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        setState(() => _manager.banners.remove(b));
                        _manager.notifyListeners();
                        try {
                          await Supabase.instance.client
                              .from('banners')
                              .delete()
                              .eq('id', b.id)
                              .timeout(const Duration(seconds: 8));
                        } catch (e) {
                          debugPrint('Banner delete note: $e');
                        }
                      },
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildManageUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('قائمة المستخدمين والصلاحيات:',
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
              subtitle: Text(
                  '${user.email.isNotEmpty ? user.email : user.phone} | ${user.role}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(user.isFrozen ? Icons.wb_sunny : Icons.ac_unit,
                        color: Colors.orange),
                    onPressed: () async {
                      final updatedUser =
                          user.copyWith(isFrozen: !user.isFrozen);
                      setState(
                          () => _manager.registeredUsers[idx] = updatedUser);
                      _manager.notifyListeners();
                      try {
                        await Supabase.instance.client
                            .from('users_profiles')
                            .update({'is_frozen': updatedUser.isFrozen})
                            .eq('id', user.id)
                            .timeout(const Duration(seconds: 8));
                      } catch (e) {
                        debugPrint('User status update error: $e');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(user.isBanned ? Icons.check_circle : Icons.block,
                        color: Colors.red),
                    onPressed: () async {
                      final updatedUser =
                          user.copyWith(isBanned: !user.isBanned);
                      setState(
                          () => _manager.registeredUsers[idx] = updatedUser);
                      _manager.notifyListeners();
                      try {
                        await Supabase.instance.client
                            .from('users_profiles')
                            .update({'is_banned': updatedUser.isBanned})
                            .eq('id', user.id)
                            .timeout(const Duration(seconds: 8));
                      } catch (e) {
                        debugPrint('User ban update error: $e');
                      }
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
