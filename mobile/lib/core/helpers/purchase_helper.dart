import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/injection.dart';
import '../../features/promo/domain/usecases/simulate_purchase.dart';
import '../../features/promo/domain/usecases/trigger_pipeline.dart';

/// Helper class for handling product purchases with popup confirmation
class PurchaseHelper {
  /// Shows confirmation popup and executes purchase flow
  /// 
  /// 1. Show confirmation popup ("Beli Paket?")
  /// 2. Call POST /simulate-purchase
  /// 3. Call POST /trigger-pipeline
  /// 4. Show success popup
  /// 5. Optionally refresh data
  static Future<bool> buyProduct({
    required BuildContext context,
    required int productId,
    required String productName,
    VoidCallback? onSuccess,
  }) async {
    bool purchased = false;

    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Beli Paket?',
      text: productName,
      confirmBtnText: 'Ya, Beli',
      cancelBtnText: 'Cancel',
      confirmBtnColor: const Color(0xFFFF7D00),
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Close confirm dialog
        
        // Show loading
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: 'Memproses...',
          text: 'Sedang memproses pembelian',
        );

        try {
          // Get customer ID from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final customerId = prefs.getString('customer_id');

          if (customerId == null) {
            Navigator.pop(context); // Close loading
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Error',
              text: 'Silakan login terlebih dahulu',
            );
            return;
          }

          // 1. Simulate purchase
          final simulatePurchase = getIt<SimulatePurchase>();
          await simulatePurchase.call(
            customerId: customerId,
            productId: productId,
          );

          // 2. Trigger pipeline to update recommendations
          final triggerPipeline = getIt<TriggerPipeline>();
          await triggerPipeline.call(customerId);

          Navigator.pop(context); // Close loading

          // 3. Show success
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil!',
            text: 'Paket aktif. Rekomendasi sedang diperbarui...',
            autoCloseDuration: const Duration(seconds: 2),
          );

          purchased = true;
          onSuccess?.call();
        } catch (e) {
          Navigator.pop(context); // Close loading
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Gagal',
            text: 'Terjadi kesalahan: ${e.toString()}',
          );
        }
      },
    );

    return purchased;
  }
}
