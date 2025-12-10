import '../../domain/entities/product.dart';

class ProductDto {
  final int productId;
  final String productName;
  final int price;
  final int durationDays;
  final int dataGb;
  final int streamingGbBonus;
  final int gamingGbBonus;
  final int socialGbBonus;
  final int callMinutesBonus;
  final int smsBonus;
  final int roamingDaysBonus;
  final String targetOffer;

  ProductDto({
    required this.productId,
    required this.productName,
    required this.price,
    required this.durationDays,
    required this.dataGb,
    this.streamingGbBonus = 0,
    this.gamingGbBonus = 0,
    this.socialGbBonus = 0,
    this.callMinutesBonus = 0,
    this.smsBonus = 0,
    this.roamingDaysBonus = 0,
    this.targetOffer = '',
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        productId: json['product_id'] ?? 0,
        productName: json['product_name'] ?? '',
        price: json['price'] ?? 0,
        durationDays: json['duration_days'] ?? 30,
        dataGb: json['data_gb'] ?? 0,
        streamingGbBonus: json['streaming_gb_bonus'] ?? 0,
        gamingGbBonus: json['gaming_gb_bonus'] ?? 0,
        socialGbBonus: json['social_gb_bonus'] ?? 0,
        callMinutesBonus: json['call_minutes_bonus'] ?? 0,
        smsBonus: json['sms_bonus'] ?? 0,
        roamingDaysBonus: json['roaming_days_bonus'] ?? 0,
        targetOffer: json['target_offer'] ?? '',
      );

  Product toEntity() => Product(
        productId: productId,
        productName: productName,
        price: price,
        durationDays: durationDays,
        dataGb: dataGb,
        streamingGbBonus: streamingGbBonus,
        gamingGbBonus: gamingGbBonus,
        socialGbBonus: socialGbBonus,
        callMinutesBonus: callMinutesBonus,
        smsBonus: smsBonus,
        roamingDaysBonus: roamingDaysBonus,
        targetOffer: targetOffer,
      );
}
