/// Represents an AI-powered product recommendation with scoring and explanation
class Recommendation {
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

  const Recommendation({
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

  /// yang ini buat yang persentase itu
  int get matchPercentage => ((finalScore.clamp(0.01, 0.999)) * 100).toInt();
}
