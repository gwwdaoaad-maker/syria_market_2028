class AdModel {
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
  final bool allowComments;
  final bool isSold;
  final bool isFeatured;
  final int viewsCount;
  final DateTime createdAt;

  AdModel({
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
    this.condition = 'مستعمل',
    this.tags = const [],
    this.imageUrls = const [],
    required this.publisherName,
    required this.publisherPhone,
    required this.publisherEmail,
    this.allowComments = true,
    this.isSold = false,
    this.isFeatured = false,
    this.viewsCount = 0,
    required this.createdAt,
  });

  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priceUsd: map['price_usd'] != null ? (map['price_usd'] as num).toDouble() : null,
      priceSyp: map['price_syp'] != null ? (map['price_syp'] as num).toDouble() : null,
      categoryId: map['category_id'] ?? '',
      subcategory: map['subcategory'] ?? '',
      governorate: map['governorate'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      condition: map['condition'] ?? 'مستعمل',
      tags: List<String>.from(map['tags'] ?? []),
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      publisherName: map['publisher_name'] ?? '',
      publisherPhone: map['publisher_phone'] ?? '',
      publisherEmail: map['publisher_email'] ?? '',
      allowComments: map['allow_comments'] ?? true,
      isSold: map['is_sold'] ?? false,
      isFeatured: map['is_featured'] ?? false,
      viewsCount: map['views_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'allow_comments': allowComments,
      'is_sold': isSold,
      'is_featured': isFeatured,
      'views_count': viewsCount,
    };
  }
}