import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ad_model.dart';
import '../../models/system_config_model.dart';
import '../config/app_config.dart';

class SupabaseMarketService {
  final SupabaseClient _client = Supabase.instance.client;

  // جلب الإعلانات مع الفلترة حسب المحافظة والقسم
  Future<List<AdModel>> fetchAds({String? governorate, String? categoryId, String? subcategory}) async {
    var query = _client.from('ads').select('*').order('created_at', ascending: false);
    
    if (governorate != null && governorate != 'all' && governorate != 'كل المحافظات') {
      query = query.eq('governorate', governorate);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }
    if (subcategory != null && subcategory.isNotEmpty) {
      query = query.eq('subcategory', subcategory);
    }

    final response = await query;
    return (response as List).map((map) => AdModel.fromMap(map)).toList();
  }

  // نشر إعلان جديد
  Future<void> publishAd(AdModel ad) async {
    await _client.from('ads').insert(ad.toMap());
  }

  // وسم الإعلان (تم البيع)
  Future<void> toggleAdSold(String adId, bool currentStatus) async {
    await _client.from('ads').update({'is_sold': !currentStatus}).eq('id', adId);
  }

  // حذف إعلان (لصاحبه أو للأدمن)
  Future<void> deleteAd(String adId) async {
    await _client.from('ads').delete().eq('id', adId);
  }

  // جلب إعدادات النظام وغرفة العمليات
  Future<SystemConfigModel> fetchSystemConfig() async {
    final response = await _client.from('system_config').select().eq('id', 'global_config').single();
    return SystemConfigModel.fromMap(response);
  }

  // تحديث إعدادات النظام وغرفة العمليات (للأدمن فقط)
  Future<void> updateSystemConfig(Map<String, dynamic> updates) async {
    await _client.from('system_config').update(updates).eq('id', 'global_config');
  }
}