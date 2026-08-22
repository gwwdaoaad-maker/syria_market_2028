import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


// ==========================================
// 1. نقطة الدخول وتهيئة التطبيق (main)
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    await Supabase.initialize(
      url: 'https://syria-market-2028.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_syria_market',
    );
  } catch (e) {
    debugPrint('Supabase Init notice: $e');
  }


  runApp(const SyriaMarket2028App());
}


// ==========================================
// 2. النماذج وهياكل البيانات (Models)
// ==========================================
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
  final String publisherName;
  final String publisherPhone;
  final String publisherEmail;
  final bool isFeatured;
  final bool isSold;
  final bool allowComments;
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
    required this.publisherName,
    this.publisherPhone = '',
    this.publisherEmail = '',
    this.isFeatured = false,
    this.isSold = false,
    this.allowComments = true,
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
    String? publisherName,
    String? publisherPhone,
    String? publisherEmail,
    bool? isFeatured,
    bool? isSold,
    bool? allowComments,
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
      publisherName: publisherName ?? this.publisherName,
      publisherPhone: publisherPhone ?? this.publisherPhone,
      publisherEmail: publisherEmail ?? this.publisherEmail,
      isFeatured: isFeatured ?? this.isFeatured,
      isSold: isSold ?? this.isSold,
      allowComments: allowComments ?? this.allowComments,
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
      'publisher_name': publisherName,
      'publisher_phone': publisherPhone,
      'publisher_email': publisherEmail,
      'is_featured': isFeatured,
      'is_sold': isSold,
      'allow_comments': allowComments,
      'created_at': createdAt.toIso8601String(),
    };
  }


  factory AdItem.fromMap(Map<String, dynamic> map) {
    return AdItem(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priceUsd: map['price_usd'] != null ? (map['price_usd'] as num).toDouble() : null,
      priceSyp: map['price_syp'] != null ? (map['price_syp'] as num).toDouble() : null,
      categoryId: map['category_id']?.toString() ?? '🚗 سيارات ومركبات',
      subcategory: map['subcategory']?.toString() ?? 'سيارات سياحية',
      governorate: map['governorate']?.toString() ?? 'دمشق',
      neighborhood: map['neighborhood']?.toString() ?? 'المركز',
      condition: map['condition']?.toString() ?? 'جديد',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      imageUrls: map['image_urls'] != null ? List<String>.from(map['image_urls']) : [],
      publisherName: map['publisher_name']?.toString() ?? 'معلن في سوق سوريا',
      publisherPhone: map['publisher_phone']?.toString() ?? '',
      publisherEmail: map['publisher_email']?.toString() ?? '',
      isFeatured: map['is_featured'] == true,
      isSold: map['is_sold'] == true,
      allowComments: map['allow_comments'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) ?? DateTime.now() : DateTime.now(),
    );
  }
}


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


// ==========================================
// 3. التطبيق الرئيسي والثيمات (Material 3)
// ==========================================
class SyriaMarket2028App extends StatefulWidget {
  const SyriaMarket2028App({Key? key}) : super(key: key);


  @override
  State<SyriaMarket2028App> createState() => _SyriaMarket2028AppState();
}


class _SyriaMarket2028AppState extends State<SyriaMarket2028App> {
  bool _isDarkMode = false;


  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }


  @override
  Widget build(BuildContext context) {
    const Color syriaGreen = Color(0xFF0F5132);
    const Color syriaGold = Color(0xFFD4AF37);


    return MaterialApp(
      title: 'سوق سوريا الشامل 2028',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SY'),
      supportedLocales: const [Locale('ar', 'SY'), Locale('ar', '')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: syriaGreen,
          primary: syriaGreen,
          secondary: syriaGold,
          brightness: Brightness.light,
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: syriaGreen,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: syriaGreen,
          primary: const Color(0xFF198754),
          secondary: syriaGold,
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


// ==========================================
// 4. الشاشة الرئيسية الكبرى والملاحة (Dashboard)
// ==========================================
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
  final SupabaseClient _supabase = Supabase.instance.client;
  int _currentNavIndex = 0;


  final List<String> _governorates = [
    'كل المحافظات', 'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة',
    'اللاذقية', 'طرطوس', 'إدلب', 'درعا', 'السويداء', 'القنيطرة',
    'دير الزور', 'الرقة', 'الحسكة'
  ];


  final Map<String, List<String>> _categoriesMap = {
    'الكل': [],
    '🚗 سيارات ومركبات': ['الكل', 'سيارات سياحية', 'دراجات نارية', 'شاحنات', 'قطع غيار واكسسوارات'],
    '🏢 عقارات وأراضي': ['الكل', 'شقق للبيع', 'شقق للإيجار', 'أراضي وزراعة', 'محلات ومكاتب'],
    '📱 هواتف وإلكترونيات': ['الكل', 'هواتف ذكية', 'أجهزة لوحية', 'لابتوب وكمبيوتر', 'شاشات وتلفزيونات'],
    '🛋️ أثاث ومستعمل': ['الكل', 'غرف نوم', 'صالونات وجلسات', 'أجهزة منزلية كهربائية', 'مفروشات مكتبية'],
    '👔 ألبسة وموضة': ['الكل', 'ألبسة رجالية', 'ألبسة نسائية', 'ألبسة أطفال', 'ساعات وإكسسوارات'],
    '💼 وظائف وخدمات': ['الكل', 'فرص عمل وشواغر', 'خدمات صيانة ومنزلية', 'شحن ونقل بضائع', 'دروس وتعليم'],
  };


  String _selectedGovernorate = 'كل المحافظات';
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';


  List<String> _newsTickerList = [
    '🔥 مرحباً بكم في سوق سوريا الشامل 2028 - المنصة الرائدة للبيع والشراء والمزادات الحرة',
    '⚡ عروض وتخفيضات كبرى على السيارات والعقارات والهواتف الذكية هذا الأسبوع',
    '👑 باقة VIP الذهبية متاحة الآن بخصم 50% مع ميزات نشر وتفاوض غير محدودة',
    '🚗 أكثر من 2,500 سيارة وعقار معروضة للبيع المباشر والفراغ الفوري في كافة المحافظات',
  ];
  int _currentNewsIndex = 0;
  Timer? _newsTimer;


  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  final PageController _leftBannerController = PageController();
  final PageController _rightBannerController = PageController();


  final List<Map<String, String>> _leftBanners = [
    {
      'title': 'سيريتل كاش & MTN كاش',
      'subtitle': 'ادفع واشترك في باقة VIP بثوانٍ',
      'image': 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
      'url': 'https://syriamarket.app/vip'
    },
    {
      'title': 'الشحن والتوصيل السريع',
      'subtitle': 'تغطية لكافة المحافظات السورية',
      'image': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600',
      'url': 'https://syriamarket.app/shipping'
    }
  ];


  final List<Map<String, String>> _rightBanners = [
    {
      'title': 'تطبيق سوق سوريا 2028',
      'subtitle': 'أكبر منصة تجارية إلكترونية في سوريا',
      'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600',
      'url': 'https://syriamarket.app/about'
    },
    {
      'title': 'عروض الأجهزة والهواتف',
      'subtitle': 'حسومات حصرية تصل حتى 30%',
      'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600',
      'url': 'https://syriamarket.app/deals'
    }
  ];


  List<AdItem> _adsList = [];
  final Set<String> _favoriteAdIds = {};
  bool _isLoadingAds = false;


  final String _currentUserEmail = 'aoaadabdo@gmail.com';
  final String _currentUserName = 'عبدو عواد (Super Admin)';
  final String _currentUserPhone = '0944112233';
  final String _currentUserPlan = 'ذهبية VIP';


  @override
  void initState() {
    super.initState();
    _initSampleAds();
    _fetchSupabaseAds();
    _startTimers();
  }


  void _startTimers() {
    _newsTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (mounted && _newsTickerList.isNotEmpty) {
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % _newsTickerList.length;
        });
      }
    });


    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (mounted) {
        _currentBannerPage = (_currentBannerPage + 1) % 2;
        if (_leftBannerController.hasClients) {
          _leftBannerController.animateToPage(_currentBannerPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
        if (_rightBannerController.hasClients) {
          _rightBannerController.animateToPage(_currentBannerPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
      }
    });
  }


  void _initSampleAds() {
    _adsList = [
      AdItem(
        id: 'ad-101',
        userId: 'user-1',
        title: 'كيا فورتي 2020 بحالة الوكالة خالية العلام قطعت 45 ألف كم',
        description: 'سيارة كيا فورتي كاملة المواصفات، فتحة سقف، بصمة تشغيل، جنوط كروم، فحص كامل كرت أبيض جاهزة للفراغ الفوري في دمشق.',
        priceUsd: 14500,
        priceSyp: 217500000,
        categoryId: '🚗 سيارات ومركبات',
        subcategory: 'سيارات سياحية',
        governorate: 'دمشق',
        neighborhood: 'المزة فيلات غربية',
        condition: 'جديد',
        tags: ['✨ بحالة ممتازة', '🔍 فحص كامل', '🤝 قابل للتفاوض', '🚀 جاهز للتسليم'],
        imageUrls: ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'],
        publisherName: 'سامر عواد',
        publisherPhone: '0944112233',
        publisherEmail: 'sameraoaad@gmail.com',
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AdItem(
        id: 'ad-102',
        userId: 'user-2',
        title: 'شقة مفروشة سوبر ديلوكس إطلالة بانورامية 160 م²',
        description: 'شقة فاخرة طابق رابع مع مصعد وتدفئة مستقلة، 3 غرف نوم وصالون كبير ومطبخ أمريكي مجهز بالكامل.',
        priceUsd: 85000,
        priceSyp: 1275000000,
        categoryId: '🏢 عقارات وأراضي',
        subcategory: 'شقق للبيع',
        governorate: 'اللاذقية',
        neighborhood: 'الكورنيش الجنوبي',
        condition: 'جديد',
        tags: ['📜 طابو أخضر', '🌊 إطلالة بحرية', '🛋️ فرش كامل'],
        imageUrls: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600'],
        publisherName: 'مكتب الأمل العقاري',
        publisherPhone: '0933556677',
        publisherEmail: 'aoaadabdo@gmail.com',
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AdItem(
        id: 'ad-103',
        userId: 'user-3',
        title: 'آيفون 15 برو ماكس 256 غيغا تيتانيوم طبيعي مقفل وكالة',
        description: 'الجهاز بحالة الوكالة 100% نسبة البطارية، مجمرك نظامي مع كامل ملحقاته وعلبته الأصلية.',
        priceUsd: 1150,
        priceSyp: 17250000,
        categoryId: '📱 هواتف وإلكترونيات',
        subcategory: 'هواتف ذكية',
        governorate: 'حلب',
        neighborhood: 'الشهباء',
        condition: 'مستعمل',
        tags: ['🔋 بطارية 100%', '💎 كرت أبيض', '🛡️ كفالة وتجربة'],
        imageUrls: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600'],
        publisherName: 'عبدو عواد',
        publisherPhone: '0988445566',
        publisherEmail: 'aoaadabdo@gmail.com',
        isSold: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }


  Future<void> _fetchSupabaseAds() async {
    setState(() => _isLoadingAds = true);
    try {
      final res = await _supabase.from('ads').select().order('created_at', ascending: false);
      if (res != null && (res as List).isNotEmpty) {
        setState(() {
          _adsList = (res).map((map) => AdItem.fromMap(map)).toList();
        });
      }
    } catch (e) {
      debugPrint('Supabase fetch fallback: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }


  @override
  void dispose() {
    _newsTimer?.cancel();
    _bannerTimer?.cancel();
    _leftBannerController.dispose();
    _rightBannerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    const Color syriaGreen = Color(0xFF0F5132);
    const Color syriaGold = Color(0xFFD4AF37);


    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildAppDrawer(context, syriaGreen, syriaGold),
        appBar: AppBar(
          backgroundColor: syriaGreen,
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
                decoration: const BoxDecoration(color: syriaGold, shape: BoxShape.circle),
                child: const Icon(Icons.storefront, color: syriaGreen, size: 20),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سوق سوريا', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('الشامل 2028', style: TextStyle(color: syriaGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          actions: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGovernorate,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: syriaGold),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                items: _governorates.map((gov) {
                  return DropdownMenuItem<String>(
                    value: gov,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: syriaGold, size: 14),
                        const SizedBox(width: 4),
                        Text(gov, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
              icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
              onPressed: widget.onToggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.notifications_active, color: syriaGold),
              onPressed: () => _showNotificationDialog(context, syriaGreen),
            ),
          ],
        ),
        body: _buildCurrentScreenBody(syriaGreen, syriaGold),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          selectedItemColor: syriaGreen,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 2) {
              _openAddAdScreen();
            } else {
              setState(() => _currentNavIndex = index);
            }
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'الرسائل والصفقات'),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: syriaGreen, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: syriaGold, size: 24),
              ),
              label: 'أضف إعلان',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }


  Widget _buildCurrentScreenBody(Color green, Color gold) {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeFeedTab(green, gold);
      case 1:
        return _buildChatsAndNegotiationsTab(green, gold);
      case 3:
        return _buildFavoritesTab(green, gold);
      case 4:
        return _buildProfileTab(green, gold);
      default:
        return _buildHomeFeedTab(green, gold);
    }
  }


  // -------------------------------------------------------------
  // تبويب 1: الرئيسية وتغذية الإعلانات والبنرات والشريط العاجل
  // -------------------------------------------------------------
  Widget _buildHomeFeedTab(Color green, Color gold) {
    final filteredAds = _adsList.where((ad) {
      final matchesGov = _selectedGovernorate == 'كل المحافظات' || ad.governorate == _selectedGovernorate;
      final matchesCat = _selectedCategory == null || _selectedCategory == 'الكل' || ad.categoryId == _selectedCategory;
      final matchesSub = _selectedSubcategory == null || _selectedSubcategory == 'الكل' || ad.subcategory == _selectedSubcategory;
      final matchesSearch = _searchQuery.isEmpty ||
          ad.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ad.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ad.neighborhood.toLowerCase().contains(_searchQuery.toLowerCase());


      return matchesGov && matchesCat && matchesSub && matchesSearch;
    }).toList();


    return RefreshIndicator(
      onRefresh: _fetchSupabaseAds,
      color: green,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildNewsTickerWidget(green, gold),
          _buildDualBannersWidget(green, gold),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث في كافة إعلانات سوق سوريا (سيارات، عقارات، هواتف...)...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: Icon(Icons.search, color: green),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          _buildCategoriesHorizontalBar(green, gold),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('أحدث إعلانات السوق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                      child: Text('${filteredAds.length} إعلان', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_selectedGovernorate != 'كل المحافظات')
                  Text('محافظة: $_selectedGovernorate', style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (_isLoadingAds)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: green)),
            )
          else if (filteredAds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('لا توجد إعلانات مطابقة لخيارات الفلترة الحالية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...filteredAds.map((ad) => _buildAdCard(context, ad, green, gold)).toList(),
        ],
      ),
    );
  }


  Widget _buildNewsTickerWidget(Color green, Color gold) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(Icons.campaign, color: green, size: 14),
                const SizedBox(width: 4),
                Text('عاجل', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _newsTickerList.isNotEmpty ? _newsTickerList[_currentNewsIndex] : 'جاري تحميل آخر الأخبار...',
                key: ValueKey<int>(_currentNewsIndex),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDualBannersWidget(Color green, Color gold) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 100,
              child: PageView.builder(
                controller: _rightBannerController,
                itemCount: _rightBanners.length,
                itemBuilder: (ctx, index) {
                  final banner = _rightBanners[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF1E293B)]),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(banner['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1),
                        const SizedBox(height: 4),
                        Text(banner['subtitle']!, style: TextStyle(color: gold, fontSize: 10), maxLines: 1),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100,
              child: PageView.builder(
                controller: _leftBannerController,
                itemCount: _leftBanners.length,
                itemBuilder: (ctx, index) {
                  final banner = _leftBanners[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F5132)]),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(banner['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1),
                        const SizedBox(height: 4),
                        Text(banner['subtitle']!, style: TextStyle(color: gold, fontSize: 10), maxLines: 1),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoriesHorizontalBar(Color green, Color gold) {
    final subcategories = _selectedCategory != null && _categoriesMap[_selectedCategory] != null
        ? _categoriesMap[_selectedCategory]!
        : [];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _categoriesMap.keys.map((cat) {
              final isSelected = (_selectedCategory == cat) || (_selectedCategory == null && cat == 'الكل');
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: green,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  checkmarkColor: Colors.white,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategory = cat == 'الكل' ? null : cat;
                      _selectedSubcategory = null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: subcategories.map((sub) {
                final isSelected = (_selectedSubcategory == sub) || (_selectedSubcategory == null && sub == 'الكل');
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(sub, style: TextStyle(color: isSelected ? green : Colors.black87, fontSize: 11)),
                    selected: isSelected,
                    selectedColor: green.withOpacity(0.15),
                    backgroundColor: Colors.transparent,
                    onSelected: (val) {
                      setState(() {
                        _selectedSubcategory = sub == 'الكل' ? null : sub;
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


  Widget _buildAdCard(BuildContext context, AdItem ad, Color green, Color gold) {
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
                currentUserEmail: _currentUserEmail,
                isFavorite: isFav,
                onToggleFavorite: () {
                  setState(() {
                    if (isFav) {
                      _favoriteAdIds.remove(ad.id);
                    } else {
                      _favoriteAdIds.add(ad.id);
                    }
                  });
                },
                onAdUpdated: (updatedAd) {
                  setState(() {
                    final idx = _adsList.indexWhere((x) => x.id == updatedAd.id);
                    if (idx != -1) _adsList[idx] = updatedAd;
                  });
                },
                onAdDeleted: (deletedId) {
                  setState(() {
                    _adsList.removeWhere((x) => x.id == deletedId);
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
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.white38)),
                    ),
                  ),
                ),
                if (ad.isFeatured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(6)),
                      child: Text('مميز ★', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          if (isFav) {
                            _favoriteAdIds.remove(ad.id);
                          } else {
                            _favoriteAdIds.add(ad.id);
                          }
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                            child: const Text('✓ تـم الـبـيـع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  Text(ad.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (ad.priceUsd != null)
                            Text('\$${ad.priceUsd!.toStringAsFixed(0)}', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 17)),
                          if (ad.priceUsd != null && ad.priceSyp != null) const SizedBox(width: 8),
                          if (ad.priceSyp != null)
                            Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: green, size: 14),
                          const SizedBox(width: 2),
                          Text('${ad.governorate} - ${ad.neighborhood}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
  // تبويب 2: الرسائل والدردشات والتفاوض الحي
  // -------------------------------------------------------------
  Widget _buildChatsAndNegotiationsTab(Color green, Color gold) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.mark_chat_unread, color: green),
            const SizedBox(width: 8),
            const Text('غرف المحادثة والتفاوض المباشر', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        _buildChatListItem(
          name: 'سامر عواد (كيا فورتي 2020)',
          lastMsg: 'أهلاً بك، هل يمكن معاينة السيارة غداً في المزة؟ قدمت لك عرض 14,000\$',
          time: 'منذ 10 دقائق',
          unreadCount: 2,
          green: green,
          onTap: () => _openChatConversationScreen(context, 'سامر عواد', 'كيا فورتي 2020', 14500),
        ),
        _buildChatListItem(
          name: 'مكتب الأمل العقاري (شقة الكورنيش)',
          lastMsg: 'تم قبول عرض التفاوض المبدئي، يرجى تزويدنا برقم الهاتف لتنسيق المعاينة.',
          time: 'منذ ساعتين',
          unreadCount: 0,
          green: green,
          onTap: () => _openChatConversationScreen(context, 'مكتب الأمل العقاري', 'شقة الكورنيش', 85000),
        ),
      ],
    );
  }


  Widget _buildChatListItem({
    required String name,
    required String lastMsg,
    required String time,
    required int unreadCount,
    required Color green,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: green, child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }


  // -------------------------------------------------------------
  // تبويب 3: المفضلة
  // -------------------------------------------------------------
  Widget _buildFavoritesTab(Color green, Color gold) {
    final favAds = _adsList.where((x) => _favoriteAdIds.contains(x.id)).toList();


    if (favAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('قائمة المفضلة فارغة حالياً', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 6),
            const Text('اضغط على رمز القلب في أي إعلان لحفظه هنا للرجوع إليه لاحقاً.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            Text('إعلاناتك المفضلة (${favAds.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...favAds.map((ad) => _buildAdCard(context, ad, green, gold)).toList(),
      ],
    );
  }


  // -------------------------------------------------------------
  // تبويب 4: حسابي والاشتراكات
  // -------------------------------------------------------------
  Widget _buildProfileTab(Color green, Color gold) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: gold, child: Text(_currentUserName[0], style: TextStyle(color: green, fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_currentUserEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(6)),
                      child: Text('باقة VIP: $_currentUserPlan 👑', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: Colors.grey.withOpacity(0.06),
          leading: Icon(Icons.workspace_premium, color: gold),
          title: const Text('ترقية الباقة والاشتراكات VIP'),
          subtitle: const Text('سيريتل كاش & MTN كاش للدفع الفوري'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _openSubscriptionPlansScreen(context, green, gold),
        ),
        const SizedBox(height: 10),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: Colors.grey.withOpacity(0.06),
          leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
          title: const Text('غرفة العمليات ولوحة تحكم الأدمن'),
          subtitle: const Text('إدارة البنرات، الأخبار، وقيود النظام'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _openAdminControlPanel(context, green, gold),
        ),
      ],
    );
  }


  void _openAddAdScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullAddAdScreen(
          userPlan: _currentUserPlan,
          userName: _currentUserName,
          userEmail: _currentUserEmail,
          userPhone: _currentUserPhone,
          onAdCreated: (newAd) {
            setState(() {
              _adsList.insert(0, newAd);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✨ تم نشر إعلانك بنجاح في سوق سوريا الشامل 2028!')),
            );
          },
        ),
      ),
    );
  }


  void _openSubscriptionPlansScreen(BuildContext context, Color green, Color gold) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullSubscriptionPlansScreen(green: green, gold: gold),
      ),
    );
  }


  void _openAdminControlPanel(BuildContext context, Color green, Color gold) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullAdminPanelScreen(
          green: green,
          gold: gold,
          newsList: _newsTickerList,
          onUpdateNews: (updated) {
            setState(() => _newsTickerList = updated);
          },
        ),
      ),
    );
  }


  void _openChatConversationScreen(BuildContext context, String partnerName, String productTitle, double price) {
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


  Widget _buildAppDrawer(BuildContext context, Color green, Color gold) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.storefront, color: green, size: 36),
                ),
                const SizedBox(height: 8),
                const Text('سوق سوريا الشامل 2028', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('المنصة الأولى للبيع والشراء والمزادات', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: green),
            title: const Text('الرئيسية'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.workspace_premium, color: gold),
            title: const Text('خطط الاشتراك والترقية VIP'),
            onTap: () {
              Navigator.pop(context);
              _openSubscriptionPlansScreen(context, green, gold);
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('غرفة العمليات ولوحة تحكم الأدمن'),
            onTap: () {
              Navigator.pop(context);
              _openAdminControlPanel(context, green, gold);
            },
          ),
        ],
      ),
    );
  }


  void _showNotificationDialog(BuildContext context, Color green) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: green),
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
            child: Text('حسناً', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// 5. شاشة إضافة إعلان جديد مع اختيار الصور من المعرض
// =============================================================
class FullAddAdScreen extends StatefulWidget {
  final String userPlan;
  final String userName;
  final String userEmail;
  final String userPhone;
  final Function(AdItem) onAdCreated;


  const FullAddAdScreen({
    Key? key,
    required this.userPlan,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.onAdCreated,
  }) : super(key: key);


  @override
  State<FullAddAdScreen> createState() => _FullAddAdScreenState();
}


class _FullAddAdScreenState extends State<FullAddAdScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceUsdController = TextEditingController();
  final TextEditingController _priceSypController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
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
    '✨ بحالة ممتازة', '🔍 فحص كامل', '🤝 قابل للتفاوض',
    '🚀 جاهز للتسليم', '📜 طابو أخضر', '🔋 بطارية 100%', '💎 كرت أبيض'
  ];


  final List<String> _governorates = [
    'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية',
    'طرطوس', 'إدلب', 'درعا', 'السويداء', 'القنيطرة', 'دير الزور', 'الرقة', 'الحسكة'
  ];


  final Map<String, List<String>> _categoriesMap = {
    '🚗 سيارات ومركبات': ['سيارات سياحية', 'دراجات نارية', 'شاحنات', 'قطع غيار واكسسوارات'],
    '🏢 عقارات وأراضي': ['شقق للبيع', 'شقق للإيجار', 'أراضي وزراعة', 'محلات ومكاتب'],
    '📱 هواتف وإلكترونيات': ['هواتف ذكية', 'أجهزة لوحية', 'لابتوب وكمبيوتر', 'شاشات وتلفزيونات'],
    '🛋️ أثاث ومستعمل': ['غرف نوم', 'صالونات وجلسات', 'أجهزة منزلية كهربائية', 'مفروشات مكتبية'],
    '👔 ألبسة وموضة': ['ألبسة رجالية', 'ألبسة نسائية', 'ألبسة أطفال', 'ساعات وإكسسوارات'],
    '💼 وظائف وخدمات': ['فرص عمل وشواغر', 'خدمات صيانة ومنزلية', 'شحن ونقل بضائع', 'دروس وتعليم'],
  };


  @override
  void initState() {
    super.initState();
    _publisherNameController = TextEditingController(text: widget.userName);
    _publisherPhoneController = TextEditingController(text: widget.userPhone);
  }


  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImageUrls.add('https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600');
      });
    }
  }


  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);


    final newAd = AdItem(
      id: 'ad-${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.userEmail,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priceUsd: double.tryParse(_priceUsdController.text.trim()),
      priceSyp: double.tryParse(_priceSypController.text.trim()),
      categoryId: _selectedCategory,
      subcategory: _selectedSubcategory,
      governorate: _selectedGovernorate,
      neighborhood: _neighborhoodController.text.trim().isEmpty ? 'المركز' : _neighborhoodController.text.trim(),
      condition: _condition,
      tags: _selectedTags,
      imageUrls: _selectedImageUrls.isNotEmpty ? _selectedImageUrls : ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'],
      publisherName: _publisherNameController.text.trim(),
      publisherPhone: _publisherPhoneController.text.trim(),
      publisherEmail: widget.userEmail,
      isFeatured: widget.userPlan == 'ذهبية VIP',
      allowComments: _allowComments,
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
    const Color green = Color(0xFF0F5132);
    final subs = _categoriesMap[_selectedCategory] ?? ['عام'];


    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: green,
          title: const Text('نشر إعلان جديد في سوق سوريا', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الإعلان (ماذا تبيع؟) *',
                  prefixIcon: const Icon(Icons.title, color: green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى كتابة عنوان الإعلان' : null,
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
                        prefixIcon: const Icon(Icons.attach_money, color: green),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                      decoration: InputDecoration(labelText: 'القسم الرئيسي', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      items: _categoriesMap.keys.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() { _selectedCategory = v; _selectedSubcategory = _categoriesMap[v]!.first; });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: subs.contains(_selectedSubcategory) ? _selectedSubcategory : subs.first,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'القسم الفرعي', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      items: subs.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
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
                      decoration: InputDecoration(labelText: 'المحافظة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      items: _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => setState(() => _selectedGovernorate = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: InputDecoration(labelText: 'الحي / المنطقة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'الوصف مطلوب' : null,
              ),
              const SizedBox(height: 8),
              const Text('وسوم سريعة تميز إعلانك:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _quickTags.map((tag) {
                  final sel = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag, style: TextStyle(fontSize: 11, color: sel ? Colors.white : Colors.black87)),
                    selected: sel,
                    selectedColor: green,
                    onSelected: (val) {
                      setState(() {
                        if (val) _selectedTags.add(tag); else _selectedTags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('صور الإعلان (من المعرض):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${_selectedImageUrls.length} صور', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                        decoration: BoxDecoration(color: green.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: green)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: green, size: 28),
                            SizedBox(height: 4),
                            Text('من المعرض 🖼️', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    ..._selectedImageUrls.map((url) => Container(
                      width: 85,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _publisherPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف للتواصل والواتساب',
                  prefixIcon: const Icon(Icons.phone, color: green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _isSubmitting ? null : _submitAd,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('نشر الإعلان الآن في سوق سوريا ✨', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// 6. شاشة تفاصيل الإعلان الكاملة مع التفاوض والتعليقات والاتصال
// =============================================================
class FullAdDetailsScreen extends StatefulWidget {
  final AdItem ad;
  final String currentUserEmail;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(AdItem) onAdUpdated;
  final Function(String) onAdDeleted;


  const FullAdDetailsScreen({
    Key? key,
    required this.ad,
    required this.currentUserEmail,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAdUpdated,
    required this.onAdDeleted,
  }) : super(key: key);


  @override
  State<FullAdDetailsScreen> createState() => _FullAdDetailsScreenState();
}


class _FullAdDetailsScreenState extends State<FullAdDetailsScreen> {
  late AdItem _ad;
  final TextEditingController _negotiateOfferController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = ['هل السعر قابل للتفاوض البسيط؟', 'أين موقع المعاينة بالتحديد؟'];


  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
  }


  void _openNegotiateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.handshake, color: Color(0xFF0F5132)),
            SizedBox(width: 8),
            Text('تقديم عرض سعر وتفاوض مباشر'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر الأصلي المعلن: ${_ad.priceUsd != null ? "\$${_ad.priceUsd!.toStringAsFixed(0)}" : "${_ad.priceSyp} ل.س"}'),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
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
            child: const Text('إرسال وبدء الدردشة 🤝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    const Color green = Color(0xFF0F5132);
    const Color gold = Color(0xFFD4AF37);


    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: green,
          title: Text(_ad.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border, color: widget.isFavorite ? Colors.red : Colors.white),
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
                  child: Image.network(_ad.imageUrls.isNotEmpty ? _ad.imageUrls.first : '', fit: BoxFit.cover),
                ),
                if (_ad.isSold)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                          child: const Text('✓ تـم الـبـيـع بالكامل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
                  Text(_ad.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (_ad.priceUsd != null)
                            Text('\$${_ad.priceUsd!.toStringAsFixed(0)}', style: TextStyle(color: green, fontSize: 22, fontWeight: FontWeight.bold)),
                          if (_ad.priceUsd != null && _ad.priceSyp != null) const SizedBox(width: 10),
                          if (_ad.priceSyp != null)
                            Text('${_ad.priceSyp!.toStringAsFixed(0)} ل.س', style: const TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: gold),
                        onPressed: _openNegotiateDialog,
                        icon: const Icon(Icons.handshake, color: green, size: 18),
                        label: const Text('تفاوض على السعر 🤝', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${_ad.governorate} - ${_ad.neighborhood}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 14),
                  const Text('الوصف والمواصفات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(_ad.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _toggleSold,
                          child: Text(_ad.isSold ? 'إلغاء تم البيع' : 'تمييز: تم البيع ✓'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _deleteAd,
                          child: const Text('حذف الإعلان', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('التعليقات والاستفسارات العامة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(hintText: 'اكتب استفسارك هنا...', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: green),
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            setState(() {
                              _comments.add(_commentController.text);
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
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: green, padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text('اتصال هاتفي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => launchUrl(Uri.parse('tel:${_ad.publisherPhone}')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: const EdgeInsets.symmetric(vertical: 12)),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('واتساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () => launchUrl(Uri.parse('https://wa.me/963${_ad.publisherPhone}')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================
// 7. شاشة المحادثة والتفاوض السعري التفاعلية (Chat & Bargain)
// =============================================================
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
  State<FullChatNegotiationScreen> createState() => _FullChatNegotiationScreenState();
}


class _FullChatNegotiationScreenState extends State<FullChatNegotiationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessage> _messages = [];


  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'msg-1',
        senderName: 'أنا',
        senderEmail: 'aoaadabdo@gmail.com',
        message: 'مرحباً، أنا مهتم بـ "${widget.productTitle}". أود تقديم عرض سعر بقيمة \$${widget.initialPrice.toStringAsFixed(0)}.',
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
        message: 'أهلاً بك! شكراً لاهتمامك. هل المعاينة جاهزة لديك اليوم في موقع السلعة؟',
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
          senderName: 'أنا',
          senderEmail: 'aoaadabdo@gmail.com',
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
    const Color green = Color(0xFF0F5132);


    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: green,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.partnerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(widget.productTitle, style: const TextStyle(fontSize: 11, color: Colors.white70)),
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
                    alignment: msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isMe ? green.withOpacity(0.15) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.message, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${msg.timestamp.hour}:${msg.timestamp.minute}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                      decoration: const InputDecoration(hintText: 'اكتب رسالتك أو قدم عرض سعر جديد...', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: green),
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =============================================================
// 8. شاشة خطط الاشتراك VIP
// =============================================================
class FullSubscriptionPlansScreen extends StatelessWidget {
  final Color green;
  final Color gold;


  const FullSubscriptionPlansScreen({Key? key, required this.green, required this.gold}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: green,
          title: const Text('باقات وترقيات VIP 👑', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPlanCard(
              title: 'الباقة المجانية',
              price: '0 ل.س / شهرياً',
              features: ['نشر حتى 5 إعلانات شهرياً', '3 صور لكل إعلان', 'دعم فني عادي'],
              isVip: false,
              green: green,
              gold: gold,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'الباقة الذهبية VIP 👑',
              price: '150,000 ل.س / شهرياً (خصم 50%)',
              features: [
                'إعلانات غير محدودة شهرياً',
                'حتى 10 صور عالية الدقة لكل إعلان',
                'شارة VIP الذهبية المميزة في صدارة البحث',
                'تفعيل زر التفاوض الفوري والمباشر',
                'دفع سهل عبر سيريتل كاش / MTN كاش'
              ],
              isVip: true,
              green: green,
              gold: gold,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isVip,
    required Color green,
    required Color gold,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isVip ? gold : Colors.grey.shade300, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isVip ? green : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: TextStyle(color: isVip ? gold : Colors.grey, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Icon(Icons.check_circle, color: isVip ? gold : green, size: 16), const SizedBox(width: 8), Text(f, style: const TextStyle(fontSize: 13))]))),
          ],
        ),
      ),
    );
  }
}


// =============================================================
// 9. لوحة تحكم الأدمن وغرفة العمليات (Admin Control Panel)
// =============================================================
class FullAdminPanelScreen extends StatefulWidget {
  final Color green;
  final Color gold;
  final List<String> newsList;
  final Function(List<String>) onUpdateNews;


  const FullAdminPanelScreen({
    Key? key,
    required this.green,
    required this.gold,
    required this.newsList,
    required this.onUpdateNews,
  }) : super(key: key);


  @override
  State<FullAdminPanelScreen> createState() => _FullAdminPanelScreenState();
}


class _FullAdminPanelScreenState extends State<FullAdminPanelScreen> {
  final TextEditingController _newsController = TextEditingController();
  late List<String> _news;


  @override
  void initState() {
    super.initState();
    _news = List.from(widget.newsList);
  }


  void _addNews() {
    final txt = _newsController.text.trim();
    if (txt.isNotEmpty) {
      setState(() {
        _news.insert(0, txt);
        _newsController.clear();
      });
      widget.onUpdateNews(_news);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF991B1B),
          title: const Text('غرفة العمليات - Super Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('إدارة الشريط الإخباري العاجل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newsController,
                    decoration: const InputDecoration(hintText: 'اكتب نص خبر عاجل جديد...', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(backgroundColor: widget.green),
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addNews,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._news.map((n) => Card(
              child: ListTile(
                title: Text(n, style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => _news.remove(n));
                    widget.onUpdateNews(_news);
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
