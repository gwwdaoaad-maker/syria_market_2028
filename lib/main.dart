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
          mainAxisSize: dynamic,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                size: 68, color: _manager.primaryColor),
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _isPhoneAuthMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: !_isPhoneAuthMode
                            ? _manager.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined,
                              size: 16,
                              color: !_isPhoneAuthMode
                                  ? Colors.white
                                  : Colors.black87),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'البريد الإلكتروني',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !_isPhoneAuthMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _isPhoneAuthMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: _isPhoneAuthMode
                            ? _manager.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android,
                              size: 16,
                              color: _isPhoneAuthMode
                                  ? Colors.white
                                  : Colors.black87),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'رقم الهاتف (SMS)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isPhoneAuthMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                        fontSize: 15,
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
    final text = 'تفقد هذا العرض المميز على تطبيق "${_manager.appTitle}":\n\n'
        '${_ad.title}\n'
        'السعر: ${_ad.priceUsd != null ? "\$${_ad.priceUsd}" : "${_ad.priceSyp} ل.س"}\n'
        'الموقع: ${_ad.governorate} - ${_ad.neighborhood}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 تم نسخ تفاصيل الإعلان لمشاركتها مع أصدقائك!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
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
// 15. دالة التشغيل الرئيسية والتهيئة الشاملة لـ Supabase (main)
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
