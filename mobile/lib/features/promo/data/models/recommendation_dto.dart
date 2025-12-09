import '../../domain/entities/recommendation.dart';

class RecommendationDto {
  final int productId;
  final String productName;
  final int price;
  final int dataGb;
  final int durationDays;
  final int streamingGbBonus;
  final int gamingGbBonus;
  final int socialGbBonus;
  final int callMinutesBonus;
  final int roamingDaysBonus;
  final int smsBonus;
  final double finalScore;
  final double mlScore;
  final String reason;

  RecommendationDto({
    required this.productId,
    required this.productName,
    required this.price,
    required this.dataGb,
    required this.durationDays,
    this.streamingGbBonus = 0,
    this.gamingGbBonus = 0,
    this.socialGbBonus = 0,
    this.callMinutesBonus = 0,
    this.roamingDaysBonus = 0,
    this.smsBonus = 0,
    required this.finalScore,
    this.mlScore = 0.0,
    required this.reason,
  });

  factory RecommendationDto.fromJson(Map<String, dynamic> json) => RecommendationDto(
        productId: json['product_id'] ?? 0,
        productName: json['product_name'] ?? '',
        price: json['price'] ?? 0,
        dataGb: json['data_gb'] ?? 0,
        durationDays: json['duration_days'] ?? 30,
        streamingGbBonus: json['streaming_gb_bonus'] ?? 0,
        gamingGbBonus: json['gaming_gb_bonus'] ?? 0,
        socialGbBonus: json['social_gb_bonus'] ?? 0,
        callMinutesBonus: json['call_minutes_bonus'] ?? 0,
        roamingDaysBonus: json['roaming_days_bonus'] ?? 0,
        smsBonus: json['sms_bonus'] ?? 0,
        finalScore: (json['final_score'] ?? 0.5).toDouble(),
        mlScore: (json['ml_score'] ?? 0.0).toDouble(),
        reason: json['reason'] ?? 'Rekomendasi terbaik untukmu.',
      );

  Recommendation toEntity() => Recommendation(
        productId: productId,
        productName: productName,
        price: price,
        dataGb: dataGb,
        durationDays: durationDays,
        streamingGbBonus: streamingGbBonus,
        gamingGbBonus: gamingGbBonus,
        socialGbBonus: socialGbBonus,
        callMinutesBonus: callMinutesBonus,
        roamingDaysBonus: roamingDaysBonus,
        smsBonus: smsBonus,
        finalScore: finalScore,
        mlScore: mlScore,
        reason: reason,
      );
}
