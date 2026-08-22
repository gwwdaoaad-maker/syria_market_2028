import 'package:flutter/material.dart';
import '../../../models/ad_model.dart';

class AdDetailsView extends StatefulWidget {
  final AdModel ad;

  const AdDetailsView({Key? key, required this.ad}) : super(key: key);

  @override
  State<AdDetailsView> createState() => _AdDetailsViewState();
}

class _AdDetailsViewState extends State<AdDetailsView> {
  final _commentController = TextEditingController();
  final List<String> _commentsList = [
    'هل السعر نهائي أم يوجد تفاوض بسيط عند المعاينة؟',
    'أين يمكن المعاينة في دمشق لو سمحت؟',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color syriaGreen = Color(0xFF0F5132);
    const Color syriaGold = Color(0xFFD4AF37);
    final ad = widget.ad;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: syriaGreen,
          title: const Text('تفاصيل الإعلان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            // 1. صورة الغلاف الكبيرة مع ختم تم البيع
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: const Color(0xFF1E293B),
                  child: Image.network(
                    ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.white38),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '✓ تـــم الـبـيــع مـن خـلال سـوق سـوريـا',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 2. محتوى تفاصيل الإعلان
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // بطاقة السعر المزدوج
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: syriaGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('السعر المطلوب:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Row(
                              children: [
                                if (ad.priceUsd != null)
                                  Text('\$${ad.priceUsd!.toStringAsFixed(0)}', style: const TextStyle(color: syriaGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                                if (ad.priceUsd != null && ad.priceSyp != null) const SizedBox(width: 10),
                                if (ad.priceSyp != null)
                                  Text('${ad.priceSyp!.toStringAsFixed(0)} ل.س', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              ],
                            ),
                          ],
                        ),
                        if (ad.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: syriaGold, borderRadius: BorderRadius.circular(6)),
                            child: const Text('إعلان مميز ★', style: TextStyle(color: syriaGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // الموقع والمشاهدات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: syriaGreen, size: 16),
                          const SizedBox(width: 4),
                          Text('${ad.governorate} - ${ad.neighborhood}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Text('الحالة: ${ad.condition}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 24),

                  // الوصف
                  const Text('تفاصيل ووصف الإعلان:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: syriaGreen)),
                  const SizedBox(height: 6),
                  Text(ad.description, style: const TextStyle(fontSize: 14, height: 1.6)),
                  const Divider(height: 24),

                  // بطاقة المعلن
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: syriaGreen,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ad.publisherName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Text('معلن موثق في سوق سوريا', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // أزرار الاتصال وواتساب المباشر
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: syriaGreen,
                            shape: RoundedCornerShape(10),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text('اتصال هاتفي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('📞 جاري الاتصال بالرقم: ${ad.publisherPhone}')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedCornerShape(10),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text('محادثة واتساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('💬 فتح واتساب مع: ${ad.publisherPhone}')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // قسم التعليقات (إذا كانت مفعلة)
                  if (ad.allowComments) ...[
                    const Divider(height: 30),
                    Text('الاستفسارات والتعليقات (${_commentsList.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: syriaGreen)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'اكتب سؤالك أو استفسارك للمعلن...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: syriaGreen),
                          onPressed: () {
                            if (_commentController.text.trim().isNotEmpty) {
                              setState(() {
                                _commentsList.add(_commentController.text.trim());
                                _commentController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._commentsList.map((c) => Card(
                      color: Colors.grey.withOpacity(0.06),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(c, style: const TextStyle(fontSize: 13)),
                      ),
                    )).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}