import 'package:equatable/equatable.dart';

/// Profile header with user badge info
class ProfileHeader extends Equatable {
  final String customerId;
  final String device;
  final String plan;
  final String spendingTier;

  const ProfileHeader({
    required this.customerId,
    required this.device,
    required this.plan,
    required this.spendingTier,
  });

  @override
  List<Object?> get props => [customerId, device, plan, spendingTier];
}

/// User persona based on behavior
class Persona extends Equatable {
  final String icon;
  final String title;
  final String desc;

  const Persona({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  List<Object?> get props => [icon, title, desc];
}

/// Behavior statistics
class BehaviorStats extends Equatable {
  final double avgDataGb;
  final double monthlySpend;
  final int topupFreq;
  final double travelScore;
  final double pctVideo;

  const BehaviorStats({
    required this.avgDataGb,
    required this.monthlySpend,
    required this.topupFreq,
    required this.travelScore,
    required this.pctVideo,
  });

  @override
  List<Object?> get props => [avgDataGb, monthlySpend, topupFreq, travelScore, pctVideo];
}

/// History summary
class HistorySummary extends Equatable {
  final int totalTrx;
  final int totalSpend;
  final String favoriteProduct;

  const HistorySummary({
    required this.totalTrx,
    required this.totalSpend,
    required this.favoriteProduct,
  });

  @override
  List<Object?> get props => [totalTrx, totalSpend, favoriteProduct];
}

/// Individual purchase history item
class PurchaseHistory extends Equatable {
  final String productName;
  final int price;
  final double dataGb;
  final int durationDays;
  final DateTime? purchaseDate;
  final String category;

  const PurchaseHistory({
    required this.productName,
    required this.price,
    required this.dataGb,
    required this.durationDays,
    this.purchaseDate,
    required this.category,
  });

  @override
  List<Object?> get props => [productName, price, dataGb, durationDays, purchaseDate, category];
}

/// Complete user profile
class UserProfile extends Equatable {
  final ProfileHeader header;
  final List<Persona> personas;
  final BehaviorStats behaviorStats;
  final HistorySummary historySummary;
  final List<PurchaseHistory> historyList;
  final List<Map<String, dynamic>> recommendations;

  const UserProfile({
    required this.header,
    required this.personas,
    required this.behaviorStats,
    required this.historySummary,
    required this.historyList,
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [header, personas, behaviorStats, historySummary, historyList, recommendations];
}
