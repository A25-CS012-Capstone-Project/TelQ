class Product {
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

  const Product({
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
}
