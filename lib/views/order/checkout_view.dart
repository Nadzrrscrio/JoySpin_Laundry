import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Pastikan import ini ada
import '../../controllers/order_controller.dart';
import '../../app_theme.dart';

class CheckoutView extends GetView<OrderController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    // Formatter untuk mata uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Konfirmasi Cucian"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Container Putih agar rapi seperti desain Terani's
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10)
                  )
                ],
              ),
              child: Column(
                children: [
                  _rowInfo("Kategori", controller.selectedCategory.value),
                  // Menampilkan detail layanan beserta jumlahnya (misal: "Jas (2x)")
                  _rowInfo("Layanan", "${controller.selectedService.value} (${controller.quantity.value}x)"),
                  _rowInfo("Pickup", controller.selectedPickup.value),
                  const Divider(height: 30),
                  
                  // PERBAIKAN DI SINI: Menggunakan controller.totalPrice
                  _rowInfo(
                    "Total Tagihan", 
                    currencyFormat.format(controller.totalPrice), // Menggunakan totalPrice
                    isBold: true,
                    color: AppTheme.secondaryColor
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Tombol Konfirmasi
            Obx(() => SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: controller.isLoading.value ? null : () => controller.submitOrder(),
                child: controller.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Buat Cucian Sekarang"),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
              fontSize: 16,
              color: color ?? Colors.black87
            )
          ),
        ],
      ),
    );
  }
}