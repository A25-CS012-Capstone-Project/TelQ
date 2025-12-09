import '../../domain/entities/profile.dart';

class ProfileHeaderDto {
  final String customerId;
  final String device;
  final String plan;
  final String spendingTier;

  ProfileHeaderDto({
    required this.customerId,
    required this.device,
    required this.plan,
    required this.spendingTier,
  });

  factory ProfileHeaderDto.fromJson(Map<String, dynamic> json) {
    return ProfileHeaderDto(
      customerId: json['customer_id'] ?? '',
      device: json['device'] ?? 'Unknown',
      plan: json['plan'] ?? 'Prepaid',
      spendingTier: json['spending_tier'] ?? 'low',
    );
  }

  ProfileHeader toEntity() => ProfileHeader(
    customerId: customerId,
    device: device,
    plan: plan,
    spendingTier: spendingTier,
  );
}

class PersonaDto {
  final String icon;
  final String title;
  final String desc;

  PersonaDto({required this.icon, required this.title, required this.desc});

  factory PersonaDto.fromJson(Map<String, dynamic> json) {
    return PersonaDto(
      icon: json['icon'] ?? '📱',
      title: json['title'] ?? 'Digital Native',
      desc: json['desc'] ?? '',
    );
  }

  Persona toEntity() => Persona(icon: icon, title: title, desc: desc);
}

class BehaviorStatsDto {
  final double avgDataGb;
  final double monthlySpend;
  final int topupFreq;
  final double travelScore;
  final double pctVideo;

  BehaviorStatsDto({
    required this.avgDataGb,
    required this.monthlySpend,
    required this.topupFreq,
    required this.travelScore,
    required this.pctVideo,
  });

  factory BehaviorStatsDto.fromJson(Map<String, dynamic> json) {
    return BehaviorStatsDto(
      avgDataGb: (json['avg_data_gb'] ?? 0).toDouble(),
      monthlySpend: (json['monthly_spend'] ?? 0).toDouble(),
      topupFreq: (json['topup_freq'] ?? 0).toInt(),
      travelScore: (json['travel_score'] ?? 0).toDouble(),
      pctVideo: (json['pct_video'] ?? 0).toDouble(),
    );
  }

  BehaviorStats toEntity() => BehaviorStats(
    avgDataGb: avgDataGb,
    monthlySpend: monthlySpend,
    topupFreq: topupFreq,
    travelScore: travelScore,
    pctVideo: pctVideo,
  );
}

class HistorySummaryDto {
  final int totalTrx;
  final int totalSpend;
  final String favoriteProduct;

  HistorySummaryDto({
    required this.totalTrx,
    required this.totalSpend,
    required this.favoriteProduct,
  });

  factory HistorySummaryDto.fromJson(Map<String, dynamic> json) {
    return HistorySummaryDto(
      totalTrx: (json['total_trx'] ?? 0).toInt(),
      totalSpend: (json['total_spend'] ?? 0).toInt(),
      favoriteProduct: json['favorite_product'] ?? '-',
    );
  }

  HistorySummary toEntity() => HistorySummary(
    totalTrx: totalTrx,
    totalSpend: totalSpend,
    favoriteProduct: favoriteProduct,
  );
}

class PurchaseHistoryDto {
  final String productName;
  final int price;
  final double dataGb;
  final int durationDays;
  final String? purchaseDate;
  final String category;

  PurchaseHistoryDto({
    required this.productName,
    required this.price,
    required this.dataGb,
    required this.durationDays,
    this.purchaseDate,
    required this.category,
  });

  factory PurchaseHistoryDto.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryDto(
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toInt(),
      dataGb: (json['data_gb'] ?? 0).toDouble(),
      durationDays: (json['duration_days'] ?? 0).toInt(),
      purchaseDate: json['purchase_date']?.toString(),
      category: json['category'] ?? 'General',
    );
  }

  PurchaseHistory toEntity() => PurchaseHistory(
    productName: productName,
    price: price,
    dataGb: dataGb,
    durationDays: durationDays,
    purchaseDate: purchaseDate != null ? DateTime.tryParse(purchaseDate!) : null,
    category: category,
  );
}

class UserProfileDto {
  final ProfileHeaderDto header;
  final List<PersonaDto> personaList;
  final BehaviorStatsDto behaviorStats;
  final HistorySummaryDto historySummary;
  final List<PurchaseHistoryDto> historyList;
  final List<Map<String, dynamic>> recommendations;

  UserProfileDto({
    required this.header,
    required this.personaList,
    required this.behaviorStats,
    required this.historySummary,
    required this.historyList,
    this.recommendations = const [],
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      header: ProfileHeaderDto.fromJson(json['header'] ?? {}),
      personaList: (json['persona_list'] as List<dynamic>?)
          ?.map((e) => PersonaDto.fromJson(e))
          .toList() ?? [],
      behaviorStats: BehaviorStatsDto.fromJson(json['behavior_stats'] ?? {}),
      historySummary: HistorySummaryDto.fromJson(json['history_summary'] ?? {}),
      historyList: (json['history_list'] as List<dynamic>?)
          ?.map((e) => PurchaseHistoryDto.fromJson(e))
          .toList() ?? [],
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
          .toList() ?? [],
    );
  }

  UserProfile toEntity() => UserProfile(
    header: header.toEntity(),
    personas: personaList.map((e) => e.toEntity()).toList(),
    behaviorStats: behaviorStats.toEntity(),
    historySummary: historySummary.toEntity(),
    historyList: historyList.map((e) => e.toEntity()).toList(),
    recommendations: recommendations,
  );
}
