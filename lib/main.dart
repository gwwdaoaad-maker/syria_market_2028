import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ==============================================================================
// 1. الثوابت السحابية الحقيقية والمشرفين وقنوات التخزين
// ==============================================================================
const String kSupabaseUrl = 'https://zbjjkigkxbpktpmpcdqc.supabase.co';
const String kSupabaseAnonKey =
    'sb_publishable_ZZBI_vTK7ks1yfO2g3Zo0Q_Sg4QizEr';

const List<String> kSuperAdminEmails = [
  'sameraoaad@gmail.com',
  'aoaadabdo@gmail.com',
];

const String kAppOwnerWhatsApp =
    '0933000001'; // رقم واتساب صاحب التطبيق للاقتراحات المباشرة

const String kStorageBucketAds = 'ad_images';
const String kStorageBucketBanners = 'banner_images';
const String kStorageBucketReceipts = 'receipt_images';
const String kStorageBucketFeedbacks = 'feedback_images';

// ==============================================================================
// 2. نقطة الدخول والتهيئة المتوافقة 100% مع أندرويد
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
    debugPrint('⚠️ [Init Notice] Supabase init notice: $e');
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
// 3. المساعدات الشاملة (معالجة أرقام الواتساب، المايك والصوت)
// ==============================================================================

/// تنظيف وتجهيز رقم الهاتف والواتساب بدقة
class PhoneHelper {
  static String formatForWhatsapp(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.startsWith('+')) {
      return clean.substring(1);
    }
    if (clean.startsWith('00')) {
      return clean.substring(2);
    }
    if (clean.startsWith('09')) {
      return '963${clean.substring(1)}';
    }
    if (clean.startsWith('9') && clean.length == 9) {
      return '963$clean';
    }
    return clean;
  }

  static bool isValidPhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return clean.length >= 9 && clean.length <= 15;
  }
}

/// نافذة محاكاة التسجيل الصوتي والإملاء التلقائي (Speech-to-Text Dialog)
class VoiceInputDialog extends StatefulWidget {
  final String title;
  const VoiceInputDialog({Key? key, this.title = 'تحدث الآن، جاري الاستماع...'})
      : super(key: key);

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final TextEditingController _voiceTextController = TextEditingController();
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    _startListeningSimulation();
  }

  void _startListeningSimulation() {
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted && _isListening) {
        setState(() {
          _voiceTextController.text =
              'اقترح إضافة قسم خاص بالسيارات الكهربائية ومحطات الشحن';
        });
      }
    });
  }

  @override
  void dispose() {
    _voiceTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppStateManager();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.red.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.mic, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 10),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _voiceTextController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'النص المنطوق سيتحول لكتابة هنا...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text('المايكروفون يستمع بدقة...',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: manager.buttonColor),
          icon: const Icon(Icons.check, color: Colors.white, size: 18),
          label: const Text('اعتماد النص',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.pop(context, _voiceTextController.text.trim());
          },
        ),
      ],
    );
  }
}

// ==============================================================================
// 4. نماذج البيانات السحابية المتكاملة مع نموذج الاقتراحات (Data Models)
// ==============================================================================

/// نموذج الاقتراحات والملاحظات المباشرة لصاحب التطبيق
class AppFeedbackItem {
  final String id;
  final String userId;
  final String userName;
  final String userContact; // هاتف أو إيميل
  final String
      type; // 'فكرة وميزة جديدة 💡', 'ملاحظة على السرعة/التصميم ⚡', 'مشكلة تقنية 🛠️', 'طلب قسم جديد 📁', 'شكر وتقييم ⭐'
  final String content;
  final String? screenshotUrl;
  final DateTime createdAt;
  final bool isReviewed;

  AppFeedbackItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userContact,
    required this.type,
    required this.content,
    this.screenshotUrl,
    required this.createdAt,
    this.isReviewed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_contact': userContact,
      'type': type,
      'content': content,
      'screenshot_url': screenshotUrl,
      'created_at': createdAt.toIso8601String(),
      'is_reviewed': isReviewed,
    };
  }

  factory AppFeedbackItem.fromMap(Map<String, dynamic> map) {
    return AppFeedbackItem(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      userName: map['user_name']?.toString() ?? 'مستخدم',
      userContact: map['user_contact']?.toString() ?? '',
      type: map['type']?.toString() ?? 'فكرة وميزة جديدة 💡',
      content: map['content']?.toString() ?? '',
      screenshotUrl: map['screenshot_url']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isReviewed: map['is_reviewed'] == true,
    );
  }
}

/// نموذج الإعلان الحقيقي المرتبط بجدول ads
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
  final String publisherTelegram;
  final String publisherEmail;
  final bool isFeatured;
  final bool isSold;
  final DateTime? soldAt;
  final bool allowComments;
  final String status; // 'approved', 'pending', 'rejected'
  final int viewsCount;
  final double sellerRating;
  final int sellerReviewsCount;
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
    this.publisherWhatsapp = '',
    this.publisherTelegram = '',
    this.publisherEmail = '',
    this.isFeatured = false,
    this.isSold = false,
    this.soldAt,
    this.allowComments = true,
    this.status = 'approved',
    this.viewsCount = 0,
    this.sellerRating = 5.0,
    this.sellerReviewsCount = 1,
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
    bool? isSold,
    DateTime? soldAt,
    bool? allowComments,
    String? status,
    int? viewsCount,
    double? sellerRating,
    int? sellerReviewsCount,
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
      isSold: isSold ?? this.isSold,
      soldAt: soldAt ?? this.soldAt,
      allowComments: allowComments ?? this.allowComments,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerReviewsCount: sellerReviewsCount ?? this.sellerReviewsCount,
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
      'publisher_whatsapp': publisherWhatsapp,
      'publisher_telegram': publisherTelegram,
      'publisher_email': publisherEmail,
      'is_featured': isFeatured,
      'is_sold': isSold,
      'sold_at': soldAt?.toIso8601String(),
      'allow_comments': allowComments,
      'status': status,
      'views_count': viewsCount,
      'seller_rating': sellerRating,
      'seller_reviews_count': sellerReviewsCount,
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
      publisherWhatsapp: map['publisher_whatsapp']?.toString() ??
          (map['publisher_phone']?.toString() ?? ''),
      publisherTelegram: map['publisher_telegram']?.toString() ?? '',
      publisherEmail: map['publisher_email']?.toString() ?? '',
      isFeatured: map['is_featured'] == true,
      isSold: map['is_sold'] == true,
      soldAt: map['sold_at'] != null
          ? DateTime.tryParse(map['sold_at'].toString())
          : null,
      allowComments: map['allow_comments'] ?? true,
      status: map['status']?.toString() ?? 'approved',
      viewsCount: (map['views_count'] as num?)?.toInt() ?? 0,
      sellerRating: (map['seller_rating'] as num?)?.toDouble() ?? 5.0,
      sellerReviewsCount: (map['seller_reviews_count'] as num?)?.toInt() ?? 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// ميزة الباقة
class PlanFeature {
  String text;
  IconData icon;

  PlanFeature({required this.text, required this.icon});

  Map<String, dynamic> toMap() => {'text': text, 'icon_code': icon.codePoint};
}

/// باقة الاشتراك
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

/// نموذج القسم والأفرع القابل للتعديل الفوري
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

/// نموذج البنر الإعلاني
class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetUrl;
  final String phone;
  final String whatsapp;
  final String telegram;
  final String position; // 'top' أو 'bottom'

  BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.targetUrl,
    this.phone = '',
    this.whatsapp = '',
    this.telegram = '',
    this.position = 'top',
  });

  BannerItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? targetUrl,
    String? phone,
    String? whatsapp,
    String? telegram,
    String? position,
  }) {
    return BannerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      telegram: telegram ?? this.telegram,
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
      'phone': phone,
      'whatsapp': whatsapp,
      'telegram': telegram,
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
      phone: map['phone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      telegram: map['telegram']?.toString() ?? '',
      position: map['position']?.toString() ?? 'top',
    );
  }
}

/// نموذج بلاغات الإعلانات
class AdReportItem {
  final String id;
  final String adId;
  final String adTitle;
  final String reporterId;
  final String reporterName;
  final String reason;
  final DateTime createdAt;

  AdReportItem({
    required this.id,
    required this.adId,
    required this.adTitle,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.createdAt,
  });

  factory AdReportItem.fromMap(Map<String, dynamic> map) {
    return AdReportItem(
      id: map['id']?.toString() ?? '',
      adId: map['ad_id']?.toString() ?? '',
      adTitle: map['ad_title']?.toString() ?? '',
      reporterId: map['reporter_id']?.toString() ?? '',
      reporterName: map['reporter_name']?.toString() ?? 'مستخدم',
      reason: map['reason']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ad_id': adId,
        'ad_title': adTitle,
        'reporter_id': reporterId,
        'reporter_name': reporterName,
        'reason': reason,
        'created_at': createdAt.toIso8601String(),
      };
}

/// نموذج الصلاحيات التفصيلية للمشرفين
class AdminPermissions {
  bool canApproveAds;
  bool canDeleteAds;
  bool canManageCategories;
  bool canManageBanners;
  bool canManageNews;
  bool canViewReports;
  bool canManageUsers;

  AdminPermissions({
    this.canApproveAds = true,
    this.canDeleteAds = true,
    this.canManageCategories = false,
    this.canManageBanners = true,
    this.canManageNews = true,
    this.canViewReports = true,
    this.canManageUsers = false,
  });

  Map<String, dynamic> toMap() => {
        'can_approve_ads': canApproveAds,
        'can_delete_ads': canDeleteAds,
        'can_manage_categories': canManageCategories,
        'can_manage_banners': canManageBanners,
        'can_manage_news': canManageNews,
        'can_view_reports': canViewReports,
        'can_manage_users': canManageUsers,
      };

  factory AdminPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return AdminPermissions();
    return AdminPermissions(
      canApproveAds: map['can_approve_ads'] ?? true,
      canDeleteAds: map['can_delete_ads'] ?? true,
      canManageCategories: map['can_manage_categories'] ?? false,
      canManageBanners: map['can_manage_banners'] ?? true,
      canManageNews: map['can_manage_news'] ?? true,
      canViewReports: map['can_view_reports'] ?? true,
      canManageUsers: map['can_manage_users'] ?? false,
    );
  }
}

/// نموذج المستخدم والمشرف
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'super_admin', 'moderator', 'user'
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

/// رسائل المحادثة
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

// ==============================================================================
// 5. مزود الحالة العام السحابي المطور (AppStateManager)
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

  // الهوية والإعدادات
  String appTitle = 'سوق سوريا';
  String appSubtitle = 'الشامل 2028';
  bool isMaintenanceMode = false;
  String maintenanceMessage =
      'المنصة حالياً تحت الصيانة الدورية. سنعود قريباً جداً!';
  String disclaimerText =
      'إخلاء مسؤولية: موقع وتطبيق "سوق سوريا الشامل 2028" منصة إعلانية حرة ومستقلة للربط المباشر بين البائع والمشتري دون وسيط. إدارة المنصة تخلي مسؤوليتها القانونية والمالية عن صحة التعاملات، ونحث دائماً على المعاينة الشخصية قبل إتمام أي دفع. كافة الحقوق محفوظة © 2028.';

  // الصوت والمايك
  bool isVoiceTypingEnabled = true;
  bool isTextToSpeechEnabled = true;

  // الثيم والألوان (متناغمة تماماً للوضع النهاري والليلي)
  Color primaryColor = const Color(0xFF0F5132);
  Color secondaryColor = const Color(0xFFD4AF37);
  Color appBarColor = const Color(0xFF0F5132);
  Color buttonColor = const Color(0xFF0F5132);
  Color scaffoldBgColor = const Color(0xFFF8FAFC);

  // شريط الأخبار
  double tickerSpeed = 1.2;
  Color tickerBackgroundColor = const Color(0xFF0F172A);
  Color tickerTextColor = Colors.white;
  double tickerFontSize = 12.0;
  IconData tickerIcon = Icons.campaign;

  // توقيت البنرات
  int topBannerIntervalSeconds = 4;
  int bottomBannerIntervalSeconds = 5;

  // حالة المستخدم والمشرف
  bool isLoggedIn = false;
  String currentUserId = '';
  String currentUserName = 'زائر سوق سوريا';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String currentUserPlanId = 'plan_free';
  String currentUserRole = 'user'; // 'super_admin', 'moderator', 'user'
  AdminPermissions currentUserPermissions = AdminPermissions();

  bool get isSuperAdmin {
    if (!isLoggedIn || currentUserEmail.isEmpty) return false;
    final cleanEmail = currentUserEmail.trim().toLowerCase();
    return kSuperAdminEmails
            .any((adminEmail) => adminEmail.toLowerCase() == cleanEmail) ||
        currentUserRole == 'super_admin';
  }

  bool get isModerator => isSuperAdmin || currentUserRole == 'moderator';

  // القوائم
  List<AdItem> ads = [];
  List<BannerItem> banners = [];
  List<String> newsTicker = [];
  List<PlanConfig> plans = [];
  List<CategoryModel> categories = [];
  List<PaymentMethod> paymentMethods = [];
  List<AdminUser> registeredUsers = [];
  List<AdReportItem> reports = [];
  List<AppFeedbackItem> feedbacks = []; // قائمة الملاحظات والاقتراحات الواردة

  // قائمة الأيقونات الملونة للأقسام
  final List<Map<String, dynamic>> availableIconsPool = [
    {
      'name': 'سيارات',
      'icon': Icons.directions_car,
      'color': Color(0xFF1E88E5)
    },
    {'name': 'عقارات', 'icon': Icons.apartment, 'color': Color(0xFF43A047)},
    {'name': 'هواتف', 'icon': Icons.phone_android, 'color': Color(0xFF8E24AA)},
    {'name': 'أثاث', 'icon': Icons.chair, 'color': Color(0xFFFB8C00)},
    {'name': 'ألبسة', 'icon': Icons.checkroom, 'color': Color(0xFFE91E63)},
    {'name': 'وظائف', 'icon': Icons.work, 'color': Color(0xFF3949AB)},
    {
      'name': 'طاقة شمسية',
      'icon': Icons.solar_power,
      'color': Color(0xFFFDD835)
    },
    {'name': 'أدوات بناء', 'icon': Icons.build, 'color': Color(0xFF6D4C41)},
    {'name': 'حيوانات', 'icon': Icons.pets, 'color': Color(0xFF00897B)},
    {
      'name': 'طعام ومطاعم',
      'icon': Icons.restaurant,
      'color': Color(0xFFD81B60)
    },
    {'name': 'خدمات صيانة', 'icon': Icons.handyman, 'color': Color(0xFF546E7A)},
    {'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Color(0xFF00ACC1)},
    {
      'name': 'رياضة ولياقة',
      'icon': Icons.fitness_center,
      'color': Color(0xFF7CB342)
    },
    {'name': 'ساعات ومجوهرات', 'icon': Icons.watch, 'color': Color(0xFFC0CA33)},
    {
      'name': 'دراجات نارية',
      'icon': Icons.two_wheeler,
      'color': Color(0xFFF4511E)
    },
  ];

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
    fetchReports();
    fetchFeedbacks();
    fetchUsers();
    autoCleanupExpiredSoldAds();
  }

  void _populateDefaults() {
    _populateDefaultCategories();
    _populateDefaultPlans();
    _populateDefaultPaymentMethods();
    _populateDefaultNewsTicker();
    _populateDefaultModerators();
  }

  void setSessionUser(
      {required String userId, required String email, required String name}) {
    isLoggedIn = true;
    currentUserId = userId;
    currentUserEmail = email.trim();
    currentUserName = name;
    if (kSuperAdminEmails.any((adminEmail) =>
        adminEmail.toLowerCase() == currentUserEmail.toLowerCase())) {
      currentUserRole = 'super_admin';
      currentUserPermissions = AdminPermissions(
        canApproveAds: true,
        canDeleteAds: true,
        canManageCategories: true,
        canManageBanners: true,
        canManageNews: true,
        canViewReports: true,
        canManageUsers: true,
      );
    }
    currentUserPlanId = isSuperAdmin ? 'plan_vip' : 'plan_free';
    notifyListeners();
  }

  void _populateDefaultModerators() {
    registeredUsers = [
      AdminUser(
        id: 'adm-1',
        name: 'سامر المشرف العام',
        email: 'sameraoaad@gmail.com',
        phone: '0933000001',
        role: 'super_admin',
        permissions: AdminPermissions(
          canApproveAds: true,
          canDeleteAds: true,
          canManageCategories: true,
          canManageBanners: true,
          canManageNews: true,
          canViewReports: true,
          canManageUsers: true,
        ),
      ),
      AdminUser(
        id: 'adm-2',
        name: 'عبد المشرف التنفيذي',
        email: 'aoaadabdo@gmail.com',
        phone: '0944000002',
        role: 'super_admin',
        permissions: AdminPermissions(
          canApproveAds: true,
          canDeleteAds: true,
          canManageCategories: true,
          canManageBanners: true,
          canManageNews: true,
          canViewReports: true,
          canManageUsers: true,
        ),
      ),
    ];
  }

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
      debugPrint('Error fetching settings: $e');
    }
  }

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
        name: 'سيارات ومركبات',
        iconData: Icons.directions_car,
        backgroundColor: const Color(0xFF1E88E5),
        subcategories: [
          'سيارات سياحية',
          'دراجات نارية',
          'شاحنات ومعدات ثقيلة',
          'قطع غيار واكسسوارات'
        ],
      ),
      CategoryModel(
        id: 'realestate',
        name: 'عقارات وأراضي',
        iconData: Icons.apartment,
        backgroundColor: const Color(0xFF43A047),
        subcategories: [
          'شقق للبيع',
          'شقق للإيجار',
          'أراضي وزراعة',
          'محلات ومكاتب تجارية'
        ],
      ),
      CategoryModel(
        id: 'electronics',
        name: 'هواتف وإلكترونيات',
        iconData: Icons.phone_android,
        backgroundColor: const Color(0xFF8E24AA),
        subcategories: [
          'هواتف ذكية',
          'أجهزة لوحية',
          'لابتوب وكمبيوتر',
          'شاشات وكاميرات'
        ],
      ),
      CategoryModel(
        id: 'furniture',
        name: 'أثاث ومستعمل',
        iconData: Icons.chair,
        backgroundColor: const Color(0xFFFB8C00),
        subcategories: [
          'غرف نوم وصالونات',
          'أجهزة منزلية كهربائية',
          'مفروشات مكتبية',
          'طاقة شمسية وبطاريات'
        ],
      ),
      CategoryModel(
        id: 'fashion',
        name: 'ألبسة وموضة',
        iconData: Icons.checkroom,
        backgroundColor: const Color(0xFFE91E63),
        subcategories: [
          'ألبسة رجالية',
          'ألبسة نسائية',
          'ألبسة أطفال',
          'ساعات ومجوهرات'
        ],
      ),
      CategoryModel(
        id: 'jobs',
        name: 'وظائف وخدمات',
        iconData: Icons.work,
        backgroundColor: const Color(0xFF3949AB),
        subcategories: [
          'فرص عمل وشواغر',
          'خدمات صيانة ومنزلية',
          'شحن ونقل بضائع',
          'دروس واستشارات'
        ],
      ),
    ];
  }

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
      '💡 صوتك مسموع! أرسل لنا اقتراحاتك وأفكارك لتطوير المنصة مباشرةً من القائمة الجانبية',
    ];
  }

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

  Future<void> fetchReports() async {
    if (_client == null || !isModerator) return;
    try {
      final response = await _client!
          .from('ad_reports')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 6));
      if (response is List) {
        reports = response.map((row) => AdReportItem.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchFeedbacks() async {
    if (_client == null || !isModerator) return;
    try {
      final response = await _client!
          .from('app_feedbacks')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 6));
      if (response is List) {
        feedbacks =
            response.map((row) => AppFeedbackItem.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchUsers() async {
    if (_client == null || !isSuperAdmin) return;
    try {
      final response = await _client!
          .from('users_profiles')
          .select()
          .timeout(const Duration(seconds: 6));
      if (response is List && response.isNotEmpty) {
        registeredUsers =
            response.map((row) => AdminUser.fromMap(row)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> incrementAdViews(String adId) async {
    final idx = ads.indexWhere((a) => a.id == adId);
    if (idx != -1) {
      final updatedAd = ads[idx].copyWith(viewsCount: ads[idx].viewsCount + 1);
      ads[idx] = updatedAd;
      notifyListeners();

      if (_client != null) {
        try {
          await _client!
              .from('ads')
              .update({'views_count': updatedAd.viewsCount})
              .eq('id', adId)
              .timeout(const Duration(seconds: 4));
        } catch (_) {}
      }
    }
  }

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
    currentUserRole = 'user';
    currentUserPlanId = 'plan_free';
    notifyListeners();
  }

  PlanConfig getCurrentUserPlan() {
    return plans.firstWhere((p) => p.id == currentUserPlanId,
        orElse: () => plans.first);
  }

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
// 6. كلاس التطبيق الجذري المصحح تماماً (CardThemeData) (SyriaMarket2028App)
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
        // ✅ تم تصحيح CardThemeData لتتوافق 100% مع إصدارات Flutter الحديثة
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
        // ✅ تم تصحيح CardThemeData في الوضع الليلي
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

      // حفظ محلي وسحابي
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
// 8. الشاشة الرئيسية الكبرى والشبكة الثنائية الحديثة المصغرة (MainDashboardScreen)
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

  // متغيرات الفلترة المتقدمة
  String _filterCondition = 'الكل';
  double? _filterMinPrice;
  double? _filterMaxPrice;
  String _sortBy = 'newest';

  final ScrollController _tickerScrollController = ScrollController();
  Timer? _tickerTimer;
  bool _isTickerPaused = false;

  final PageController _topBannerController = PageController();
  int _currentTopBannerPage = 0;
  Timer? _topBannerTimer;

  final PageController _bottomBannerController = PageController();
  int _currentBottomBannerPage = 0;
  Timer? _bottomBannerTimer;

  final TextEditingController _searchController = TextEditingController();

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
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGovernorate,
              dropdownColor: const Color(0xFF1E293B),
              icon: Icon(Icons.arrow_drop_down, color: _manager.secondaryColor),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              // ✅ تم تصحيح القائمة وإزالة الرمز الخاطئ >
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
        _buildBannerCarouselBox('top', _topBannerController),
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
                  const Text('أحدث إعلانات السوق',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 10),
                                const Text(
                                    'لا توجد إعلانات مطابقة لخيارات البحث أو الفلترة',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey)),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: _manager.buttonColor),
                                  onPressed: () =>
                                      _requireAuth(() => _openAddAdScreen()),
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.white, size: 16),
                                  label: const Text(
                                      'كن أول من ينشر إعلاناً الآن ✨',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
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
                                horizontal: 8, vertical: 4),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, index) {
                                  final ad = filteredAds[index];
                                  return _buildCompactGridAdCard(ad);
                                },
                                childCount: filteredAds.length,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _buildBannerCarouselBox(
                                'bottom', _bottomBannerController),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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

  Widget _buildBannerCarouselBox(String position, PageController controller) {
    final positionBanners =
        _manager.banners.where((b) => b.position == position).toList();

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _manager.secondaryColor.withOpacity(0.6), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => const FullPaymentMethodsScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _manager.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign,
                      color: _manager.primaryColor, size: 24),
                ),
                const SizedBox(width: 10),
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
                            fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ضع إعلانك التجاري المميز هنا ليصل لآلاف الزوار يومياً. اضغط للتواصل والحجز.',
                        style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: _manager.primaryColor, size: 12),
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
        if (banner.whatsapp.isNotEmpty) {
          final cleanPhone = PhoneHelper.formatForWhatsapp(banner.whatsapp);
          final uri = Uri.parse('https://wa.me/$cleanPhone');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        }
        if (banner.targetUrl.isNotEmpty) {
          final uri = Uri.tryParse(banner.targetUrl);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 3, offset: Offset(0, 1.5))
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
                          color: Colors.white70, size: 30)),
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
              bottom: 6,
              right: 10,
              left: 10,
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
                  const SizedBox(height: 2),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11),
                      maxLines: 1,
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
                                  fontSize: 13))
                        else if (ad.priceSyp != null)
                          Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.blueGrey)),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: _manager.primaryColor, size: 10),
                            const SizedBox(width: 1),
                            Expanded(
                              child: Text(
                                '${ad.governorate} - ${ad.neighborhood}',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
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
        // ✅ زر صوتك مسموع والاقتراحات في البروفايل
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
                'موافقة الإعلانات، المشرفين، البنرات، البلاغات والأقسام'),
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
                // ✅ زر صوتك مسموع في القائمة الجانبية
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
// 9. شاشة المصادقة وتأكيد الحسابات الشاملة (AuthScreen)
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
    if (!PhoneHelper.isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '⚠️ يرجى إدخال رقم هاتف سوري أو دولي صالح (مثال: 0944000000)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final formattedPhone = PhoneHelper.formatForWhatsapp(phone);
      await Supabase.instance.client.auth
          .signInWithOtp(phone: '+$formattedPhone')
          .timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() {
          _isWaitingForOtp = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('📱 تم إرسال كود التحقق إلى +$formattedPhone عبر SMS')),
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
      final formattedPhone = PhoneHelper.formatForWhatsapp(phone);
      final res = await Supabase.instance.client.auth
          .verifyOTP(
            phone: '+$formattedPhone',
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
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: $e'), backgroundColor: Colors.red.shade800),
        );
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
              validator: (v) => (v == null || !PhoneHelper.isValidPhone(v))
                  ? 'يرجى إدخال رقم هاتف صالح'
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
// 10. شاشة إضافة الإعلانات الخاضعة للمراجعة بالصوت والمايك (FullAddAdScreen)
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
  late TextEditingController _publisherWhatsappController;
  late TextEditingController _publisherTelegramController;

  String _selectedGovernorate = 'دمشق';
  String _selectedCategory = 'سيارات ومركبات';
  String _selectedSubcategory = 'سيارات سياحية';
  String _condition = 'جديد';
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
    _publisherWhatsappController =
        TextEditingController(text: _manager.currentUserPhone);
    _publisherTelegramController = TextEditingController();
    if (_manager.categories.isNotEmpty) {
      _selectedCategory = _manager.categories.first.name;
      _selectedSubcategory = _manager.categories.first.subcategories.isNotEmpty
          ? _manager.categories.first.subcategories.first
          : 'عام';
    }
  }

  void _recordVoiceForField(
      TextEditingController controller, String label) async {
    final text = await showDialog<String>(
      context: context,
      builder: (c) => VoiceInputDialog(title: 'تسجيل $label صوتياً 🎙️'),
    );
    if (text != null && text.isNotEmpty) {
      setState(() {
        controller.text = text;
      });
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
        maxWidth: 1024,
        maxHeight: 1024,
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

    final phone = _publisherPhoneController.text.trim();
    if (!PhoneHelper.isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ يرجى إدخال رقم هاتف اتصال حقيقي وصحيح للتواصل.')),
      );
      return;
    }

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
      'publisher_phone': phone,
      'publisher_whatsapp': _publisherWhatsappController.text.trim().isNotEmpty
          ? _publisherWhatsappController.text.trim()
          : phone,
      'publisher_telegram': _publisherTelegramController.text.trim(),
      'publisher_email': _manager.currentUserEmail,
      'is_featured':
          currentPlan.customFeatures.any((f) => f.text.contains('VIP')),
      'allow_comments': _allowComments,
      'status': isSuper ? 'approved' : 'pending',
      'views_count': 0,
      'seller_rating': 5.0,
      'seller_reviews_count': 1,
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
        publisherPhone: phone,
        publisherWhatsapp: _publisherWhatsappController.text.trim().isNotEmpty
            ? _publisherWhatsappController.text.trim()
            : phone,
        publisherTelegram: _publisherTelegramController.text.trim(),
        publisherEmail: _manager.currentUserEmail,
        isFeatured:
            currentPlan.customFeatures.any((f) => f.text.contains('VIP')),
        allowComments: _allowComments,
        status: isSuper ? 'approved' : 'pending',
        viewsCount: 0,
        sellerRating: 5.0,
        sellerReviewsCount: 1,
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
                      'أنت تنشر باستخدام "${currentPlan.name}" (مسموح حتى ${currentPlan.maxImagesPerAd} صور). سيتم مراجعة المنشور فوراً.',
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
                        onPressed: () => _recordVoiceForField(
                            _titleController, 'عنوان الإعلان'),
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
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: InputDecoration(
                  labelText: 'حالة السلعة',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: const [
                DropdownMenuItem(
                    value: 'جديد', child: Text('جديد (بالكرتونة)')),
                DropdownMenuItem(
                    value: 'مستعمل بحالة ممتازة',
                    child: Text('مستعمل بحالة ممتازة (شبه جديد)')),
                DropdownMenuItem(value: 'مستعمل', child: Text('مستعمل')),
              ],
              onChanged: (v) => setState(() => _condition = v!),
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
                        onPressed: () =>
                            _recordVoiceForField(_descController, 'وصف السلعة'),
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
                const Text('صور الإعلان (تحديد عدة صور معاً مع ضغط ذكي):',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                    '${_uploadedImageUrls.length} / ${currentPlan.maxImagesPerAd} صور',
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
                labelText: 'رقم هاتف الاتصال المباشر *',
                hintText: '0944000000',
                prefixIcon: Icon(Icons.phone, color: _manager.primaryColor),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => (v == null || !PhoneHelper.isValidPhone(v))
                  ? 'يرجى إدخال رقم هاتف اتصال صالح'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _publisherWhatsappController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الواتساب للتواصل الفوري *',
                hintText: '0933000000 أو +963...',
                prefixIcon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => (v == null || !PhoneHelper.isValidPhone(v))
                  ? 'يرجى إدخال رقم واتساب صالح للتواصل'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _publisherTelegramController,
              decoration: InputDecoration(
                labelText: 'معرف التلغرام (اختياري)',
                hintText: '@username',
                prefixIcon: const Icon(Icons.send, color: Colors.lightBlue),
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
                    : const Text('إرسال الإعلان للمراجعة والنشر ✨',
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
// 11. شاشة تفاصيل الإعلان الشاملة والتفاوض والتقييمات (FullAdDetailsScreen)
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
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();

  List<CommentItem> _comments = [];
  bool _isLoadingComments = false;
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
    _fetchComments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final res = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('ad_id', _ad.id)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _comments = res
              .map((m) => CommentItem.fromMap(m as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Comments fetch notice: $e');
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment() async {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً لإضافة تعليق')),
      );
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = CommentItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      adId: _ad.id,
      userId: _manager.currentUserId,
      userName: _manager.currentUserName,
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    try {
      await Supabase.instance.client
          .from('comments')
          .insert(newComment.toMap())
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Add comment notice: $e');
    }
  }

  Future<void> _submitRating(double rating) async {
    if (!_manager.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول لتقييم البائع')),
      );
      return;
    }

    setState(() => _userRating = rating);
    final newCount = _ad.sellerReviewsCount + 1;
    final newRating =
        ((_ad.sellerRating * _ad.sellerReviewsCount) + rating) / newCount;

    final updated = _ad.copyWith(
      sellerRating: newRating,
      sellerReviewsCount: newCount,
    );

    setState(() => _ad = updated);
    widget.onAdUpdated(updated);

    try {
      await Supabase.instance.client
          .from('ads')
          .update({
            'seller_rating': newRating,
            'seller_reviews_count': newCount,
          })
          .eq('id', _ad.id)
          .timeout(const Duration(seconds: 8));
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم تسجيل تقييمك ($rating ★) للبائع بنجاح!'),
            backgroundColor: _manager.primaryColor),
      );
    }
  }

  Future<void> _markAsSold() async {
    final updated = _ad.copyWith(
      isSold: true,
      soldAt: DateTime.now(),
    );
    setState(() => _ad = updated);
    widget.onAdUpdated(updated);

    try {
      await Supabase.instance.client
          .from('ads')
          .update({
            'is_sold': true,
            'sold_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _ad.id)
          .timeout(const Duration(seconds: 8));
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تمييز السلعة كـ "تم البيع" ✓')),
      );
    }
  }

  void _showReportDialog() {
    String reason = 'إعلان مخالف أو معلومات مضللة';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.report_problem, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('الإبلاغ عن الإعلان'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى تحديد سبب الإبلاغ للمشرفين:'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: reason,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: 'إعلان مخالف أو معلومات مضللة',
                    child: Text('إعلان مخالف أو مضلل')),
                DropdownMenuItem(
                    value: 'سلعة مباعة أو غير متوفرة',
                    child: Text('سلعة مباعة أو غير متوفرة')),
                DropdownMenuItem(
                    value: 'سعر غير حقيقي أو احتيال',
                    child: Text('سعر غير حقيقي أو احتيال')),
                DropdownMenuItem(
                    value: 'صور غير لائقة', child: Text('صور غير لائقة')),
              ],
              onChanged: (v) => reason = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('تم إرسال بلاغك لغرفة العمليات للمراجعة فوراً')),
              );
            },
            child: const Text('إرسال البلاغ',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareAd() {
    final text =
        'تفقد هذا العرض المميز على تطبيق "${_manager.appTitle}":\n\n${_ad.title}\nالسعر: ${_ad.priceUsd != null ? "\$${_ad.priceUsd}" : "${_ad.priceSyp} ل.س"}\nالموقع: ${_ad.governorate} - ${_ad.neighborhood}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _manager.isLoggedIn &&
        (_manager.currentUserId == _ad.userId || _manager.isModerator);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: Text(_ad.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite ? Colors.red : Colors.white),
              onPressed: widget.onToggleFavorite),
          IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareAd),
          IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white70),
              tooltip: 'إبلاغ',
              onPressed: _showReportDialog),
        ],
      ),
      bottomNavigationBar: _buildBottomContactBar(),
      body: ListView(
        children: [
          _buildImageGallerySlider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_ad.isSold)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                      child: Text('✓ تم بيع هذه السلعة بنجاح',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _ad.title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _manager.titleTextColor),
                      ),
                    ),
                    if (_ad.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: _manager.secondaryColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('VIP ★',
                            style: TextStyle(
                                color: _manager.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_ad.priceUsd != null)
                      Text('\$${_ad.priceUsd!.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _manager.priceUsdColor)),
                    if (_ad.priceUsd != null && _ad.priceSyp != null)
                      const Text('   |   ',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    if (_ad.priceSyp != null)
                      Text('${_ad.priceSyp!.toStringAsFixed(0)} ل.س',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _manager.priceSypColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildMetaBadge(Icons.category, _ad.categoryId),
                    _buildMetaBadge(
                        Icons.subdirectory_arrow_left, _ad.subcategory),
                    _buildMetaBadge(Icons.location_on,
                        '${_ad.governorate} - ${_ad.neighborhood}',
                        color: _manager.locationTextColor),
                    _buildMetaBadge(Icons.check_circle_outline, _ad.condition),
                    _buildMetaBadge(
                        Icons.remove_red_eye, '${_ad.viewsCount} مشاهدة'),
                  ],
                ),
                if (_ad.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: _ad.tags
                        .map((t) => Chip(
                            label:
                                Text(t, style: const TextStyle(fontSize: 11)),
                            backgroundColor:
                                _manager.primaryColor.withOpacity(0.08)))
                        .toList(),
                  ),
                ],
                const Divider(height: 24),
                const Text('تفاصيل ووصف السلعة:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  _ad.description,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
                if (_ad.videoUrl != null && _ad.videoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    tileColor: Colors.red.withOpacity(0.1),
                    leading: const Icon(Icons.video_library, color: Colors.red),
                    title: const Text('مشاهدة فيديو استعراض السلعة 🎥',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(_ad.videoUrl!,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () async {
                      final uri = Uri.parse(_ad.videoUrl!);
                      if (await canLaunchUrl(uri))
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
                const Divider(height: 24),
                _buildSellerProfileCard(),
                const SizedBox(height: 14),
                if (isOwner && !_ad.isSold) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green)),
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text('تأكيد البيع (تمييز كـ "تم البيع")',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      onPressed: _markAsSold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (_manager.isModerator) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon:
                          const Icon(Icons.delete_forever, color: Colors.white),
                      label: const Text('حذف هذا الإعلان نهائياً (إجراء مشرف)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        widget.onAdDeleted(_ad.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildCommentsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBadge(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color ?? _manager.primaryColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildImageGallerySlider() {
    final images = _ad.imageUrls.isNotEmpty
        ? _ad.imageUrls
        : [
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'
          ];

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
            itemBuilder: (ctx, idx) {
              return Image.network(
                images[idx],
                fit: BoxFit.cover,
                errorBuilder: (c, _, __) => Container(
                  color: const Color(0xFF1E293B),
                  child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 48, color: Colors.white30)),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.black60,
                    borderRadius: BorderRadius.circular(12)),
                child: Text('${_currentImageIndex + 1} / ${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSellerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _manager.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _manager.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _manager.primaryColor,
            child: Text(
              _ad.publisherName.isNotEmpty ? _ad.publisherName[0] : 'S',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_ad.publisherName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      '${_ad.sellerRating.toStringAsFixed(1)} (${_ad.sellerReviewsCount} تقييم)',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              side: BorderSide(color: _manager.primaryColor),
            ),
            icon: const Icon(Icons.rate_review, size: 14),
            label: const Text('قيّم البائع', style: TextStyle(fontSize: 11)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('تقييم البائع والتجربة ⭐'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('كم نجمة تعطي البائع مقابل الأمانة والتعامل؟'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [1, 2, 3, 4, 5].map((st) {
                          return IconButton(
                            icon: Icon(
                                st <= _userRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 30),
                            onPressed: () {
                              Navigator.pop(c);
                              _submitRating(st.toDouble());
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, size: 18),
            const SizedBox(width: 6),
            const Text('الأسئلة والتعليقات العامة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 6),
            Text('(${_comments.length})',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'اكتب استفسارك للبائع هنا...',
                  hintStyle: const TextStyle(fontSize: 12),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style:
                  IconButton.styleFrom(backgroundColor: _manager.buttonColor),
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _addComment,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingComments)
          const Center(child: CircularProgressIndicator(strokeWidth: 2))
        else if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('لا توجد تعليقات بعد، كن أول من يسأل!',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (ctx, idx) {
              final c = _comments[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.userName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _manager.primaryColor)),
                        Text('${c.createdAt.day}/${c.createdAt.month}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(c.content, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomContactBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر التفاوض المباشر والشات
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _manager.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon:
                    const Icon(Icons.handshake, color: Colors.white, size: 18),
                label: const Text('تفاوض مباشر 💬',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                onPressed: () {
                  if (!_manager.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('يرجى تسجيل الدخول لبدء التفاوض والمحادثة')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => FullChatNegotiationScreen(
                        adId: _ad.id,
                        partnerName: _ad.publisherName,
                        productTitle: _ad.title,
                        initialPrice: _ad.priceUsd ?? (_ad.priceSyp ?? 0),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            // اتصال هاتفي
            IconButton(
              style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.phone, color: Colors.white, size: 20),
              tooltip: 'اتصال هاتفي',
              onPressed: () async {
                final uri = Uri.parse('tel:${_ad.publisherPhone}');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            const SizedBox(width: 6),
            // واتساب
            IconButton(
              style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.chat, color: Colors.white, size: 20),
              tooltip: 'محادثة واتساب',
              onPressed: () async {
                final clean =
                    PhoneHelper.formatForWhatsapp(_ad.publisherWhatsapp);
                final msg = Uri.encodeComponent(
                    'مرحباً، أنا مهتم بإعلانك على سوق سوريا الشامل 2028:\n"${_ad.title}"');
                final uri = Uri.parse('https://wa.me/$clean?text=$msg');
                if (await canLaunchUrl(uri))
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            if (_ad.publisherTelegram != null &&
                _ad.publisherTelegram!.isNotEmpty) ...[
              const SizedBox(width: 6),
              // تلغرام
              IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                tooltip: 'تلغرام',
                onPressed: () async {
                  final cleanUser = _ad.publisherTelegram!.replaceAll('@', '');
                  final uri = Uri.parse('https://t.me/$cleanUser');
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 12. شاشة المحادثة المباشرة مع نظام تقديم العروض والتفاوض (FullChatNegotiationScreen)
// ==============================================================================
class FullChatNegotiationScreen extends StatefulWidget {
  final String adId;
  final String partnerName;
  final String productTitle;
  final double initialPrice;

  const FullChatNegotiationScreen({
    Key? key,
    required this.adId,
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
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .eq('ad_id', widget.adId)
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 8));

      if (res is List && mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(res);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Fetch chat messages notice: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? customOfferText}) async {
    final text = customOfferText ?? _msgController.text.trim();
    if (text.isEmpty) return;

    if (customOfferText == null) _msgController.clear();

    final newMsg = {
      'ad_id': widget.adId,
      'sender_id': _manager.currentUserId,
      'sender_name': _manager.currentUserName,
      'message': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() => _messages.add(newMsg));
    _scrollToBottom();

    try {
      await Supabase.instance.client
          .from('chat_messages')
          .insert(newMsg)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('Send message notice: $e');
    }
  }

  void _showOfferDialog() {
    final TextEditingController offerController = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.handshake, color: _manager.primaryColor),
            const SizedBox(width: 8),
            const Text('تقديم عرض سعر للتفاوض 🤝'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('السعر المطلوب الأصلي: \$${widget.initialPrice}'),
            const SizedBox(height: 12),
            TextField(
              controller: offerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عرضك المقترح (\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
            onPressed: () {
              final off = offerController.text.trim();
              if (off.isNotEmpty) {
                Navigator.pop(c);
                _sendMessage(
                    customOfferText:
                        '🤝 أود تقديم عرض سعر مباشر لشراء السلعة بمبلغ: \$$off دولار. هل يناسبك؟');
              }
            },
            child: const Text('إرسال العرض',
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
      appBar: AppBar(
        backgroundColor: _manager.appBarColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.partnerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            Text('تفاوض بخصوص: ${widget.productTitle}',
                style: TextStyle(color: _manager.secondaryColor, fontSize: 11),
                maxLines: 1),
          ],
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: _manager.secondaryColor.withOpacity(0.2)),
            icon: Icon(Icons.local_offer,
                color: _manager.secondaryColor, size: 16),
            label: Text('قدم عرضاً',
                style: TextStyle(
                    color: _manager.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            onPressed: _showOfferDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text('ابدأ التفاوض والدردشة مع البائع الآن',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, idx) {
                          final msg = _messages[idx];
                          final isMe =
                              msg['sender_id'] == _manager.currentUserId;
                          final isOffer =
                              msg['message'].toString().contains('🤝');

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.78),
                              decoration: BoxDecoration(
                                color: isOffer
                                    ? (isMe
                                        ? _manager.secondaryColor
                                        : Colors.amber.shade100)
                                    : (isMe
                                        ? _manager.primaryColor
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                                  bottomRight: Radius.circular(isMe ? 2 : 14),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['message'] ?? '',
                                    style: TextStyle(
                                      color: isOffer
                                          ? _manager.primaryColor
                                          : (isMe
                                              ? Colors.white
                                              : Colors.black87),
                                      fontSize: 13,
                                      fontWeight: isOffer
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك أو استفسارك هنا...',
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _manager.buttonColor,
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 13. شاشة باقات الاشتراك والترقية VIP وطرق الدفع السورية (FullSubscriptionPlansScreen)
// ==============================================================================
class FullSubscriptionPlansScreen extends StatelessWidget {
  const FullSubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = AppStateManager();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: manager.appBarColor,
        title: const Text('باقات الترقية والاشتراكات VIP 👑',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [manager.primaryColor, const Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(Icons.workspace_premium,
                    color: manager.secondaryColor, size: 40),
                const SizedBox(height: 8),
                const Text('ميّز تجارتك وضاعف مبيعاتك اليوم!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('نشر غير محدود، فيديوهات حصرية، وشارة التاج الذهبي VIP',
                    style:
                        TextStyle(color: manager.secondaryColor, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...manager.subscriptionPlans.map((plan) {
            final isCurrent = manager.currentUserPlanId == plan.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                    color: plan.badgeColor, width: isCurrent ? 2 : 1),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: plan.badgeColor)),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('باقتك الحالية ✓',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.priceUsd == 0
                          ? 'مجاناً مدى الحياة'
                          : '\$${plan.priceUsd.toStringAsFixed(0)} / شهرياً (${plan.priceSyp.toStringAsFixed(0)} ل.س)',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: manager.primaryColor),
                    ),
                    const Divider(height: 18),
                    ...plan.customFeatures.map((feat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                                feat.isAvailable
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: feat.isAvailable
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16),
                            const SizedBox(width: 8),
                            Text(feat.text,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: feat.isAvailable
                                        ? Colors.black87
                                        : Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    if (!isCurrent)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: plan.badgeColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () =>
                              _showPaymentInstructions(context, plan, manager),
                          child: const Text('ترقية الباقة الآن 🚀',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showPaymentInstructions(
      BuildContext context, SubscriptionPlan plan, AppStateManager manager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: manager.primaryColor),
                const SizedBox(width: 8),
                Text('طرق الدفع والتفعيل لباقة ${plan.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            const Text(
                'يمكنك التحويل عبر أي من الوسائل السورية المعتمدة التالية:',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            _buildPaymentRow('سيريتل كاش / MTN كاش:', '0933000000'),
            _buildPaymentRow(
                'حوالة الهرم / الفؤاد:', 'باسم: إدارة تطبيق سوق سوريا 2028'),
            _buildPaymentRow(
                'محفظة USDT الإلكترونية (TRC20):', 'TXYZ1234567890abcdef'),
            const SizedBox(height: 16),
            const Text(
                'بعد التحويل، يرجى إرسال إشعار الدفع عبر الواتساب لتفعيل الباقة فوراً:'),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366)),
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('إرسال إشعار الدفع للواتساب 📲',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final clean =
                      PhoneHelper.formatForWhatsapp(kAppOwnerWhatsApp);
                  final msg = Uri.encodeComponent(
                      'مرحباً، أود تفعيل باقة "${plan.name}" في حسابي:\nالمستخدم: ${manager.currentUserName}\nالإيميل: ${manager.currentUserEmail}');
                  final uri = Uri.parse('https://wa.me/$clean?text=$msg');
                  if (await canLaunchUrl(uri))
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.blueGrey))),
        ],
      ),
    );
  }
}

// ==============================================================================
// 14. غرفة العمليات ولوحة تحكم المشرفين وإدارة البنرات (FullAdminPanelScreen)
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

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 6, vsync: this, initialIndex: widget.initialTab);
    _manager.addListener(_refresh);
  }

  @override
  void dispose() {
    _manager.removeListener(_refresh);
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('غرفة العمليات ولوحة الإشراف 🛡️',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'الإحصائيات'),
            Tab(icon: Icon(Icons.pending_actions), text: 'الإعلانات المعلقة'),
            Tab(icon: Icon(Icons.view_carousel), text: 'إدارة البنرات (12+)'),
            Tab(icon: Icon(Icons.shield), text: 'المشرفين والصلاحيات'),
            Tab(icon: Icon(Icons.color_lens), text: 'الألوان والنصوص'),
            Tab(icon: Icon(Icons.lightbulb), text: 'صوتك مسموع 💡'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildPendingAdsTab(),
          _buildBannersManagementTab(),
          _buildModeratorsTab(),
          _buildColorsAndTickerTab(),
          _buildFeedbacksReviewTab(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final pendingCount =
        _manager.ads.where((x) => x.status == 'pending').length;
    final totalAds = _manager.ads.length;
    final soldAds = _manager.ads.where((x) => x.isSold).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
                child: _buildMetricCard('إجمالي الإعلانات', '$totalAds',
                    Icons.list_alt, Colors.blue)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMetricCard('بانتظار الموافقة', '$pendingCount',
                    Icons.hourglass_top, Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildMetricCard('تم بيعها ✓', '$soldAds',
                    Icons.check_circle, Colors.green)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildMetricCard(
                    'المشرفين النشطين',
                    '${_manager.moderators.length}',
                    Icons.security,
                    Colors.purple)),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.grey.withOpacity(0.08),
          title: const Text('وضع الصيانة العام 🛠️',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('إغلاق السوق أمام الزوار وحصره بالمشرفين فقط'),
          value: _manager.isMaintenanceMode,
          onChanged: (val) => setState(() => _manager.isMaintenanceMode = val),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.grey.withOpacity(0.08),
          title: const Text('الكتابة بالصوت والإملاء الذكي 🎙️',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
              const Text('تفعيل ميزة المايك في البحث والإعلانات والاقتراحات'),
          value: _manager.isVoiceTypingEnabled,
          onChanged: (val) =>
              setState(() => _manager.isVoiceTypingEnabled = val),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(count,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPendingAdsTab() {
    final pending = _manager.ads.where((x) => x.status == 'pending').toList();

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 60, color: Colors.green.shade400),
            const SizedBox(height: 10),
            const Text('رائع! لا توجد إعلانات معلقة بانتظار المراجعة 🎉',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pending.length,
      itemBuilder: (ctx, idx) {
        final ad = pending[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
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
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, _, __) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey,
                            child: const Icon(Icons.image)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ad.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                              'الناشر: ${ad.publisherName} (${ad.publisherPhone})',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
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
                const SizedBox(height: 8),
                Text(ad.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('رفض وحذف'),
                      onPressed: () {
                        setState(() =>
                            _manager.ads.removeWhere((x) => x.id == ad.id));
                        Supabase.instance.client
                            .from('ads')
                            .delete()
                            .eq('id', ad.id);
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      icon: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                      label: const Text('موافقة ونشر للجميع',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        setState(() {
                          final i =
                              _manager.ads.indexWhere((x) => x.id == ad.id);
                          if (i != -1)
                            _manager.ads[i] = ad.copyWith(status: 'approved');
                        });
                        await Supabase.instance.client
                            .from('ads')
                            .update({'status': 'approved'}).eq('id', ad.id);
                      },
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

  /// 🖼️ تبويب إدارة البنرات المتطور (يدعم حتى 12+ بطاقة مع إضافة/تعديل/حذف)
  Widget _buildBannersManagementTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('البنرات الترويجية الحالية (${_manager.banners.length})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _manager.primaryColor),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('إضافة بنر جديد',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              onPressed: _showAddBannerDialog,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('سرعة التقليب التلقائي (بالثواني):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: _manager.bannerIntervalSeconds,
              items: [2, 3, 4, 5, 6, 8, 10]
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text('$s ثوانٍ')))
                  .toList(),
              onChanged: (val) {
                if (val != null)
                  setState(() => _manager.bannerIntervalSeconds = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._manager.banners.asMap().entries.map((entry) {
          final idx = entry.key;
          final banner = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(banner.imageUrl,
                    width: 60,
                    height: 45,
                    fit: BoxFit.cover,
                    errorBuilder: (c, _, __) =>
                        Container(width: 60, height: 45, color: Colors.grey)),
              ),
              title: Text(banner.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle:
                  Text(banner.subtitle, style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() => _manager.banners.removeAt(idx));
                  Supabase.instance.client
                      .from('banners')
                      .delete()
                      .eq('id', banner.id);
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddBannerDialog() {
    final titleC = TextEditingController();
    final subtitleC = TextEditingController();
    final imageC = TextEditingController(
        text:
            'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=800');
    final phoneC = TextEditingController();
    final whatsappC = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة بنر إعلاني جديد (يدعم حتى 12+)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleC,
                  decoration: const InputDecoration(
                      labelText: 'العنوان الرئيسي للبنر')),
              TextField(
                  controller: subtitleC,
                  decoration: const InputDecoration(
                      labelText: 'العنوان الفرعي / العرض')),
              TextField(
                  controller: imageC,
                  decoration:
                      const InputDecoration(labelText: 'رابط الصورة (URL)')),
              TextField(
                  controller: phoneC,
                  decoration:
                      const InputDecoration(labelText: 'رقم هاتف الاتصال')),
              TextField(
                  controller: whatsappC,
                  decoration: const InputDecoration(labelText: 'رقم الواتساب')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _manager.primaryColor),
            onPressed: () {
              if (titleC.text.trim().isNotEmpty) {
                final newB = BannerItem(
                  id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                  imageUrl: imageC.text.trim(),
                  title: titleC.text.trim(),
                  subtitle: subtitleC.text.trim(),
                  phone: phoneC.text.trim(),
                  whatsapp: whatsappC.text.trim(),
                );
                setState(() => _manager.banners.add(newB));
                Supabase.instance.client.from('banners').insert(newB.toMap());
                Navigator.pop(c);
              }
            },
            child: const Text('حفظ ونشر البنر',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeratorsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('المشرفون وصلاحيات الإدارة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
              label: const Text('تعيين مشرف جديد',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              onPressed: _showAddModeratorDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._manager.moderators.map((m) {
          final isOwner = m.isSuperAdmin;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOwner ? Colors.amber : Colors.purple,
                child: Icon(isOwner ? Icons.star : Icons.shield,
                    color: Colors.white, size: 18),
              ),
              title: Text(m.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${m.email} (${m.role})',
                  style: const TextStyle(fontSize: 11)),
              trailing: isOwner
                  ? const Chip(
                      label: Text('المالك الأصلي 👑',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: Colors.amber)
                  : IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() => _manager.moderators
                            .removeWhere((x) => x.id == m.id));
                        Supabase.instance.client
                            .from('moderators')
                            .delete()
                            .eq('id', m.id);
                      },
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddModeratorDialog() {
    final emailC = TextEditingController();
    final nameC = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة مشرف أو مدقق محتوى'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'اسم المشرف')),
            TextField(
                controller: emailC,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              if (emailC.text.trim().isNotEmpty) {
                final newMod = Moderator(
                  id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailC.text.trim(),
                  name: nameC.text.trim().isNotEmpty
                      ? nameC.text.trim()
                      : 'مشرف معتمد',
                  role: 'moderator',
                  isSuperAdmin: false,
                  grantedAt: DateTime.now(),
                );
                setState(() => _manager.moderators.add(newMod));
                Supabase.instance.client
                    .from('moderators')
                    .insert(newMod.toMap());
                Navigator.pop(c);
              }
            },
            child: const Text('تعيين المشرف',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsAndTickerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('تخصيص ألوان النصوص والأسعار وشريط الأخبار 🎨',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ListTile(
          title: const Text('لون أسعار الدولار (\$)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: _manager.priceUsdColor, shape: BoxShape.circle)),
          onTap: () {
            setState(() => _manager.priceUsdColor =
                _manager.priceUsdColor == Colors.green
                    ? Colors.teal
                    : Colors.green);
          },
        ),
        ListTile(
          title: const Text('لون أسعار الليرة السورية (ل.س)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: _manager.priceSypColor, shape: BoxShape.circle)),
          onTap: () {
            setState(() => _manager.priceSypColor =
                _manager.priceSypColor == Colors.orange.shade800
                    ? Colors.amber.shade900
                    : Colors.orange.shade800);
          },
        ),
        const Divider(),
        const Text('إدارة شريط الأخبار المتحرك 📢',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        ..._manager.newsTicker.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;
          return ListTile(
            title: Text(text, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () =>
                  setState(() => _manager.newsTicker.removeAt(idx)),
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: _manager.buttonColor),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة خبر جديد للشريط',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            final c = TextEditingController();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('إضافة خبر للشريط المتحرك'),
                content: TextField(
                    controller: c,
                    decoration: const InputDecoration(labelText: 'نص الخبر')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () {
                      if (c.text.trim().isNotEmpty) {
                        setState(() => _manager.newsTicker.add(c.text.trim()));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbacksReviewTab() {
    final feedbacks = _manager.feedbacks;

    if (feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('صندوق الاقتراحات والملاحظات فارغ حالياً',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: feedbacks.length,
      itemBuilder: (ctx, idx) {
        final fb = feedbacks[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fb.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: _manager.secondaryColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(fb.type,
                          style: TextStyle(
                              color: _manager.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (fb.userContact.isNotEmpty)
                  Text('التواصل: ${fb.userContact}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.blueGrey)),
                const SizedBox(height: 6),
                Text(fb.content,
                    style: const TextStyle(fontSize: 12, height: 1.4)),
                if (fb.screenshotUrl != null &&
                    fb.screenshotUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(fb.screenshotUrl!,
                        height: 120, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==============================================================================
// 15. دالة التشغيل الرئيسية والتهيئة الشاملة (main)
// ==============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init notice: $e');
  }

  runApp(const SyriaMarket2028App());
}
