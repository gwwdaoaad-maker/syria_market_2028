class SystemConfigModel {
  final int tickerSpeedSeconds;
  final int bannerSwitchIntervalSeconds;
  final int maxFreeAdsPerMonth;
  final int maxImagesPerAd;
  final bool allowPhoneForFreeTier;
  final bool allowCommentsForFreeTier;
  final String subscriptionInstructionText;
  final String subscriptionInstructionImageUrl;
  final String supportWhatsappNumber;
  final String telegramChannelUrl;

  SystemConfigModel({
    this.tickerSpeedSeconds = 4,
    this.bannerSwitchIntervalSeconds = 5,
    this.maxFreeAdsPerMonth = 5,
    this.maxImagesPerAd = 6,
    this.allowPhoneForFreeTier = true,
    this.allowCommentsForFreeTier = true,
    this.subscriptionInstructionText = '',
    this.subscriptionInstructionImageUrl = '',
    this.supportWhatsappNumber = '',
    this.telegramChannelUrl = '',
  });

  factory SystemConfigModel.fromMap(Map<String, dynamic> map) {
    return SystemConfigModel(
      tickerSpeedSeconds: map['ticker_speed_seconds'] ?? 4,
      bannerSwitchIntervalSeconds: map['banner_switch_interval_seconds'] ?? 5,
      maxFreeAdsPerMonth: map['max_free_ads_per_month'] ?? 5,
      maxImagesPerAd: map['max_images_per_ad'] ?? 6,
      allowPhoneForFreeTier: map['allow_phone_for_free_tier'] ?? true,
      allowCommentsForFreeTier: map['allow_comments_for_free_tier'] ?? true,
      subscriptionInstructionText: map['subscription_instruction_text'] ?? '',
      subscriptionInstructionImageUrl: map['subscription_instruction_image_url'] ?? '',
      supportWhatsappNumber: map['support_whatsapp_number'] ?? '',
      telegramChannelUrl: map['telegram_channel_url'] ?? '',
    );
  }
}