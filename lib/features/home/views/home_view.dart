import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/ad_model.dart';
import '../../../models/system_config_model.dart';
import '../../ads/views/add_ad_view.dart';
import '../../ads/views/ad_details_view.dart';

class HomeView extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeView({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // إدارة التبويبات السفلية
  int _currentBottomNavIndex = 0;

  // حالة الفلترة
  String _selectedGovernorate = 'كل المحافظات';
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';

  // حالة الشريط الإخباري العاجل
  List<String> _newsTickerList = [
    '🔥 مرحباً بكم في سوق سوريا الشامل 2028 - المنصة الرائدة للبيع والشراء في كافة المحافظات',
    '⚡ عروض وتخفيضات كبرى على السيارات والعقارات والهواتف الذكية هذا الأسبوع',
    '👑 باقة VIP الذهبية متاحة الآن بخصم 50% مع ميزات نشر غير محدودة',
    '🚗 أكثر من 1500 سيارة معروضة للبيع المباشر في دمشق وحلب واللاذقية وحمص',
  ];
  int _currentNewsIndex = 0;
  Timer? _newsTimer;

  // حالة البنرات المزدوجة المتنقلة
  int _currentBannerPage = 0;
  Timer? _bannerTimer;
  final PageController _leftBannerController = PageController();
  final PageController _rightBannerController = PageController();

  final List<Map<String, String>> _leftBanners = [
    {
      'title': 'سيريتل كاش & MTN كاش',
      'subtitle': 'ادفع واشترك في VIP بثوانٍ',
      'image': 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
      'url': 'https://syriamarket.app/vip'
    },
    {
      'title': 'خدمات الشحن الداخلي السريع',
      'subtitle': 'توصيل لكافة المحافظات السورية',
      'image': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600',
      'url': 'https://syriamarket.app/shipping'
    }
  ];

  final List<Map<String, String>> _rightBanners = [
    {
      'title': 'تطبيق سوق سوريا 2028',
      'subtitle': 'أكبر منصة تجارية في سوريا',
      'image': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600',
      'url': 'https://syriamarket.app/about'
    },
    {
      'title': 'عروض الأجهزة والهواتف',
      'subtitle': 'حسومات تصل حتى 30%',
      'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600',
      'url': 'https://syriamarket.app/deals'
    }
  ];

  // المحافظات السورية الـ 14 كاملة
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
    'الحسكة',
  ];

  // الأقسام الرئيسية وفروعها التابعة
  final Map<String, List<String>> _categoriesMap = {
    'الكل': [],
    '🚗 سيارات ومركبات': ['الكل', 'سيارات سياحية', 'دراجات نارية', 'شاحنات', 'قطع غيار واكسسوارات'],
    '🏢 عقارات وأراضي': ['الكل', 'شقق للبيع', 'شقق للإيجار', 'أراضي وزراعة', 'محلات ومكاتب'],
    '📱 هواتف وإلكترونيات': ['الكل', 'هواتف ذكية', 'أجهزة لوحية', 'لابتوب وكمبيوتر', 'شاشات وتلفزيونات'],
    '🛋️ أثاث ومستعمل': ['الكل', 'غرف نوم', 'صالونات وجلسات', 'أجهزة منزلية كهربائية', 'مفروشات مكتبية'],
    '👔 ألبسة وموضة': ['الكل', 'ألبسة رجالية', 'ألبسة نسائية', 'ألبسة أطفال', 'ساعات وإكسسوارات'],
    '💼 وظائف وخدمات': ['الكل', 'فرص عمل وشواغر', 'خدمات صيانة ومنزلية', 'شحن ونقل بضائع', 'دروس وتعليم'],
    '🐑 مواشي وحيوانات': ['الكل', 'أغنام وأبقار', 'طيور وحمام', 'أعلاف ومستلزمات بيطرية'],
    '🌾 مواد غذائية ومونة': ['الكل', 'زيت وزيتون', 'حبوب وبقوليات', 'عسل ومنتجات طبيعية'],
  };

  // قائمة الإعلانات المباشرة
  List<AdModel> _adsList = [];
  bool _isLoadingAds = false;

  // إعدادات النظام وغرفة العمليات
  SystemConfigModel _systemConfig = SystemConfigModel();

  @override
  void initState() {
    super.initState();
    _loadInitialDataFromSupabase();
    _setupTimers();
  }

  void _setupTimers() {
    // 1. مؤقت الشريط الإخباري المتحرك
    _newsTimer = Timer.periodic(Duration(seconds: _systemConfig.tickerSpeedSeconds), (timer) {
      if (mounted && _newsTickerList.isNotEmpty) {
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % _newsTickerList.length;
        });
      }
    });

    // 2. مؤقت البنرات المزدوجة المتنقلة
    _bannerTimer = Timer.periodic(Duration(seconds: _systemConfig.bannerSwitchIntervalSeconds), (timer) {
      if (mounted) {
        _currentBannerPage = (_currentBannerPage + 1) % 2;
        if (_leftBannerController.hasClients) {
          _leftBannerController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
        if (_rightBannerController.hasClients) {
          _rightBannerController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Future<void> _loadInitialDataFromSupabase() async {
    setState(() => _isLoadingAds = true);
    try {
      // 1. جلب إعدادات النظام من جدول system_config
      final configRes = await _supabase.from('system_config').select().eq('id', 'global_config').maybeSingle();
      if (configRes != null) {
        setState(() {
          _systemConfig = SystemConfigModel.fromMap(configRes);
        });
      }

      // 2. جلب الأخبار العاجلة من جدول news_ticker
      final newsRes = await _supabase.from('news_ticker').select().eq('is_active', true).order('sort_order');
      if (newsRes != null && (newsRes as List).isNotEmpty) {
        setState(() {
          _newsTickerList = (newsRes).map((e) => e['content'].toString()).toList();
        });
      }

      // 3. جلب الإعلانات من جدول ads
      final adsRes = await _supabase.from('ads').select().order('created_at', ascending: false);
      if (adsRes != null) {
        setState(() {
          _adsList = (adsRes as List).map((map) => AdModel.fromMap(map)).toList();
        });
      }
    } catch (e) {
      debugPrint('Supabase fetch notice: $e');
      // بيانات افتراضية في حال عدم توفر الاتصال السحابي اللحظي
      _populateFallbackData();
    } finally {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  void _populateFallbackData() {
    setState(() {
      _adsList = [
        AdModel(
          id: 'ad-1',
          userId: 'user-1',
          title: 'كيا فورتي 2020 بحالة الوكالة خالية العلام قطعت 45 ألف كم',
          description: 'سيارة كيا فورتي كاملة المواصفات، فتحة سقف، بصمة تشغيل، جنوط كروم، فحص كامل كرت أبيض جاهزة للفراغ الفوري.',
          priceUsd: 14500,
          priceSyp: 217500000,
          categoryId: '🚗 سيارات ومركبات',
          subcategory: 'سيارات سياحية',
          governorate: 'دمشق',
          neighborhood: 'المزة فيلات غربية',
          condition: 'جديد',
          tags: ['جاهزة للبيع', 'سعر مغري', 'قابل للتفاوض'],
          imageUrls: ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'],
          publisherName: 'سامر عواد',
          publisherPhone: '0944112233',
          publisherEmail: 'sameraoaad@gmail.com',
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AdModel(
          id: 'ad-2',
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
          tags: ['طابو أخضر', 'إطلالة بحرية', 'فرش كامل'],
          imageUrls: ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600'],
          publisherName: 'مكتب الأمل العقاري',
          publisherPhone: '0933556677',
          publisherEmail: 'aoaadabdo@gmail.com',
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AdModel(
          id: 'ad-3',
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
          tags: ['مجمرك نظامي', 'بطارية 100%'],
          imageUrls: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600'],
          publisherName: 'عبدو عواد',
          publisherPhone: '0988445566',
          publisherEmail: 'aoaadabdo@gmail.com',
          isSold: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    });
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
    const Color syriaGreenPrimary = Color(0xFF0F5132);
    const Color syriaGoldAccent = Color(0xFFD4AF37);

    // تصفية الإعلانات حسب المحافظة والقسم والبحث
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildAppDrawer(context, syriaGreenPrimary, syriaGoldAccent),
        appBar: AppBar(
          backgroundColor: syriaGreenPrimary,
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
                decoration: const BoxDecoration(color: syriaGoldAccent, shape: BoxShape.circle),
                child: const Icon(Icons.storefront, color: syriaGreenPrimary, size: 20),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سوق سوريا', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('الشامل 2028', style: TextStyle(color: syriaGoldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          actions: [
            // 1. قائمة الـ 14 محافظة سورية المنسدلة للفلترة الفورية
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGovernorate,
                dropdownColor: const Color(0xFF1E293B),
                icon: const Icon(Icons.arrow_drop_down, color: syriaGoldAccent),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                items: _governorates.map((gov) {
                  return DropdownMenuItem<String>(
                    value: gov,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: syriaGoldAccent, size: 14),
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
            // 2. زر التبديل بين الوضع الليلي والنهاري
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
              onPressed: widget.onToggleTheme,
            ),
            // 3. جرس الإشعارات
            IconButton(
              icon: const Icon(Icons.notifications_active, color: syriaGoldAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.notifications, color: syriaGreenPrimary),
                        SizedBox(width: 8),
                        Text('مركز الإشعارات والتنبيهات'),
                      ],
                    ),
                    content: const Text(
                      '• تم نشر إعلانك الأخير بنجاح في سوق سوريا.\n'
                      '• هناك 5 عروض جديدة مطابقة لبحثك في دمشق وحلب.\n'
                      '• خصم 50% على باقة VIP الذهبية متاح حالياً.',
                      style: TextStyle(height: 1.6),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('حسناً', style: TextStyle(color: syriaGreenPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadInitialDataFromSupabase,
          color: syriaGreenPrimary,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // 2. الشريط الإخباري العاجل المتحرك (News Ticker)
              _buildNewsTicker(syriaGreenPrimary, syriaGoldAccent),

              // 3. قسم البنرات المزدوجة المتجاور المُمول (Carousel)
              _buildDualBannersCarousel(syriaGreenPrimary, syriaGoldAccent),

              // حقل البحث السريع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'ابحث في كافة إعلانات سوق سوريا (سيارات، عقارات، هواتف...)...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, color: syriaGreenPrimary),
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

              // 4. شريط الأقسام السحابي الأفقي مع الأقسام الفرعية
              _buildCategoriesBar(syriaGreenPrimary, syriaGoldAccent),

              // ترويسة عدد الإعلانات والمحافظة المختارة
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
                          decoration: BoxDecoration(
                            color: syriaGreenPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${filteredAds.length} إعلان', style: const TextStyle(color: syriaGreenPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (_selectedGovernorate != 'كل المحافظات')
                      Text('محافظة: $_selectedGovernorate', style: const TextStyle(color: syriaGreenPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // 5. قائمة الإعلانات (Feed) التفاعلية مع التسعير المزدوج
              if (_isLoadingAds)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: syriaGreenPrimary)),
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
                        const SizedBox(height: 6),
                        const Text('جرب اختيار محافظة أخرى أو قسم رئيسي آخر.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...filteredAds.map((ad) => _buildAdCard(context, ad, syriaGreenPrimary, syriaGoldAccent)).toList(),
            ],
          ),
        ),

        // 6. الشريط السفلي (BottomNavigationBar) مع زر الإضافة المركزي
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          selectedItemColor: syriaGreenPrimary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 2) {
              // فتح شاشة أضف إعلان
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => AddAdView(
                    onAdPublished: (newAd) {
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
            } else {
              setState(() => _currentBottomNavIndex = index);
            }
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الرسائل'),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: syriaGreenPrimary, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: syriaGoldAccent, size: 24),
              ),
              label: 'أضف إعلان',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  // 2. الشريط الإخباري العاجل المتحرك
  Widget _buildNewsTicker(Color green, Color gold) {
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

  // 3. قسم البنرات المزدوجة المتجاور المُمول (Dual Carousel)
  Widget _buildDualBannersCarousel(Color green, Color gold) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // البنر الأيمن
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
          // البنر الأيسر
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

  // 4. شريط الأقسام والأقسام الفرعية
  Widget _buildCategoriesBar(Color green, Color gold) {
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

  // 5. بطاقة الإعلان في التغذية (Feed Item)
  Widget _buildAdCard(BuildContext context, AdModel ad, Color green, Color gold) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedCornerShape(14),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => AdDetailsView(ad: ad)),
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
                        child: Icon(Icons.image, size: 50, color: Colors.white38),
                      ),
                    ),
                  ),
                ),
                // شارة مميز
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
                // شارة ووسم تم البيع المائي
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

  // 6. القائمة الجانبية (Drawer)
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
                const Text('منصة البيع والشراء الأولى في سوريا', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صفحة باقات VIP الذهبية')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
            title: const Text('غرفة العمليات ولوحة تحكم الأدمن'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دخول غرفة العمليات (Super Admin)')));
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info, color: green),
            title: const Text('عن التطبيق'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: green),
            title: const Text('السياسات والشروط'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}