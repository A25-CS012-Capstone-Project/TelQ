class OnboardingProduct {
  final int productId;
  final String name;
  final int dataGb;
  final int durationDays;
  final double price;
  final int? bonusStream;
  final int? bonusGame;
  final int? bonusRoam;
  final int? bonusSocmed;
  final int? bonusCall;

  const OnboardingProduct({
    required this.productId,
    required this.name,
    required this.dataGb,
    required this.durationDays,
    required this.price,
    this.bonusStream,
    this.bonusGame,
    this.bonusRoam,
    this.bonusSocmed,
    this.bonusCall,
  });

  factory OnboardingProduct.fromJson(Map<String, dynamic> json) {
    return OnboardingProduct(
      productId: json['product_id'] ?? 0,
      name: json['product_name'] ?? json['name'] ?? 'Unknown',
      dataGb: json['data_gb'] ?? 0,
      durationDays: json['duration_days'] ?? 30,
      price: (json['price'] ?? 0).toDouble(),
      bonusStream: json['bonus_stream'],
      bonusGame: json['bonus_game'],
      bonusRoam: json['bonus_roam'],
      bonusSocmed: json['bonus_socmed'],
      bonusCall: json['bonus_call'],
    );
  }

  String get formattedPrice {
    final priceInt = price.toInt();
    final formatted = priceInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  String get subtitle => 'Kuota $dataGb GB • $durationDays hari';
}