import 'package:flutter/material.dart';
import '../../../models/ad_model.dart';

class AddAdView extends StatefulWidget {
  final Function(AdModel) onAdPublished;

  const AddAdView({Key? key, required this.onAdPublished}) : super(key: key);

  @override
  State<AddAdView> createState() => _AddAdViewState();
}

class _AddAdViewState extends State<AddAdView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceUsdController = TextEditingController();
  final _priceSypController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGov = 'دمشق';
  String _selectedCategory = '🚗 سيارات ومركبات';
  String _selectedSubcategory = 'سيارات سياحية';
  String _condition = 'مستعمل';
  bool _allowComments = true;
  final List<String> _selectedTags = [];
  final List<String> _imageUrls = ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600'];

  final List<String> _governorates = [
    'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس',
    'إدلب', 'درعا', 'السويداء', 'القنيطرة', 'دير الزور', 'الرقة', 'الحسكة'
  ];

  final List<String> _availableTags = [
    'جاهز للتسليم', 'سعر مغري جداً', 'قابل للتفاوض', 'طابو أخضر', 'كفالة وسند', 'جديد بالكرتونة'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceUsdController.dispose();
    _priceSypController.dispose();
    _neighborhoodController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      final newAd = AdModel(
        id: 'ad-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current-user-id',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priceUsd: double.tryParse(_priceUsdController.text),
        priceSyp: double.tryParse(_priceSypController.text),
        categoryId: _selectedCategory,
        subcategory: _selectedSubcategory,
        governorate: _selectedGov,
        neighborhood: _neighborhoodController.text.trim().isEmpty ? 'وسط المدينة' : _neighborhoodController.text.trim(),
        condition: _condition,
        tags: _selectedTags,
        imageUrls: _imageUrls,
        publisherName: 'سامر عواد',
        publisherPhone: _phoneController.text.trim().isEmpty ? '0944000111' : _phoneController.text.trim(),
        publisherEmail: 'sameraoaad@gmail.com',
        allowComments: _allowComments,
        createdAt: DateTime.now(),
      );

      widget.onAdPublished(newAd);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color syriaGreen = Color(0xFF0F5132);
    const Color syriaGold = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: syriaGreen,
          title: const Text('أضف إعلانك في سوق سوريا', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. عنوان الإعلان
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الإعلان *',
                  hintText: 'مثال: سيارة كيا فورتي 2020 بحالة ممتازة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة عنوان واضح للإعلان' : null,
              ),
              const SizedBox(height: 14),

              // 2. الأسعار بالدولار والليرة السورية
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceUsdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'السعر (\$ USD)',
                        prefixIcon: const Icon(Icons.attach_money, color: syriaGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceSypController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'السعر (ل.س)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. المحافظة والحي
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGov,
                      decoration: InputDecoration(
                        labelText: 'المحافظة *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _governorates.map((gov) => DropdownMenuItem(value: gov, child: Text(gov))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGov = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _neighborhoodController,
                      decoration: InputDecoration(
                        labelText: 'المنطقة / الحي *',
                        hintText: 'المزة، الشهباء...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. وصف الإعلان (حتى 600 حرف)
              TextFormField(
                controller: _descController,
                maxLines: 4,
                maxLength: 600,
                decoration: InputDecoration(
                  labelText: 'وصف وتفاصيل الإعلان *',
                  hintText: 'اكتب مواصفات السلعة وحالتها بدقة...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'يرجى كتابة تفاصيل الإعلان' : null,
              ),
              const SizedBox(height: 10),

              // 5. الوسوم السريعة
              const Text('الوسوم الترويجية السريعة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: syriaGreen.withOpacity(0.15),
                    onSelected: (selected) {
                      setState(() {
                        selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // 6. خيار إغلاق/فتح التعليقات
              SwitchListTile(
                title: const Text('السماح بالتعليقات والاستفسارات على المنشور'),
                value: _allowComments,
                activeColor: syriaGreen,
                onChanged: (val) => setState(() => _allowComments = val),
              ),
              const SizedBox(height: 20),

              // 7. زر النشر
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: syriaGreen,
                    shape: RoundedCornerShape(12),
                  ),
                  onPressed: _submitAd,
                  child: const Text('نشر الإعلان الآن مجاناً ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}