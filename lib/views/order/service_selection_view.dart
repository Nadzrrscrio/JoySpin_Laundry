import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../app_theme.dart';
import '../map/address_map_view.dart'; 

class ServiceSelectionView extends GetView<OrderController> {
  const ServiceSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Obx(() => Text("Pilih ${controller.selectedCategory.value}"))),
      body: Column(
        children: [
          // BAGIAN ATAS: SEARCH & SORT BUTTON
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                // 1. Search Bar (Expanded agar memenuhi ruang)
                Expanded(
                  child: TextField(
                    onChanged: (val) => controller.searchText.value = val, // Trigger Dynamic Search
                    decoration: InputDecoration(
                      hintText: "Cari layanan...",
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // 2. SORT BUTTON (Sort Overlay Trigger)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.sort, color: AppTheme.secondaryColor),
                    onPressed: () => _showSortBottomSheet(context),
                  ),
                )
              ],
            ),
          ),
          
          // 1. LIST ITEM LAYANAN
          Expanded(
            child: Obx(() {
              // 1. Cek jika hasil pencarian kosong (Fitur Search Results Feedback)
              if (controller.currentServices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        "Layanan tidak ditemukan",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              // 2. Tampilkan List jika data ada
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.currentServices.length,
                itemBuilder: (ctx, i) {
                  final item = controller.currentServices[i];
                  
                  // Obx inner tetap dibutuhkan untuk update visual seleksi (border warna)
                  return Obx(() {
                    final isSelected = controller.selectedService.value == item['name'];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppTheme.secondaryColor : Colors.transparent,
                          width: 2
                        )
                      ),
                      color: context.theme.cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: controller.selectedCategory.value == 'Cuci Setrika' 
                            ? const Text("Min. 1 Kg") 
                            : null,
                        trailing: Text(
                          currencyFormat.format(item['price']),
                          style: TextStyle(
                            color: isSelected ? AppTheme.secondaryColor : Colors.grey,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? AppTheme.secondaryColor : Colors.grey,
                        ),
                        onTap: () {
                          controller.setService(item['name'], item['price']);
                          // Tutup keyboard saat user memilih item (UX Enhancement)
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    );
                  });
                },
              );
            }),
          ),

          // 2. BAGIAN INPUT JUMLAH & PICKUP
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Counter Jumlah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      "Jumlah (${controller.quantityUnit}):", 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    )),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18), 
                            onPressed: controller.decrementQty,
                            color: AppTheme.secondaryColor,
                          ),
                          Obx(() => Text(
                            "${controller.quantity.value}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          )),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18), 
                            onPressed: controller.incrementQty,
                            color: AppTheme.secondaryColor,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                // LOGIKA PICKUP
                Obx(() {
                  if (controller.isSelfService) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200)
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(child: Text("Layanan Self Service. Silakan datang langsung ke outlet untuk mencuci.", style: TextStyle(fontSize: 12))),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Metode Pengambilan:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPickupOpt(context, "Diantar (Outlet)"),
                            const SizedBox(width: 10),
                            _buildPickupOpt(context, "Dijemput"),
                          ],
                        ),
                        // Tampilkan Alamat jika "Dijemput" dipilih
                        if (controller.selectedPickup.value == "Dijemput" && controller.pickupAddress.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2))
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: AppTheme.secondaryColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.pickupAddress.value,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      maxLines: 2, overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                  // Tombol ubah lokasi
                                  InkWell(
                                    onTap: () async {
                                       final result = await Get.to(() => const AddressMapView());
                                       if (result != null) {
                                         controller.pickupAddress.value = result;
                                       }
                                    },
                                    child: const Text("Ubah", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    );
                  }
                }),
                
                const Divider(height: 30),

                // Total & Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Estimasi:", style: TextStyle(color: Colors.grey)),
                        Obx(() => Text(
                          currencyFormat.format(controller.totalPrice),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                        )),
                      ],
                    ),
                    Obx(() => ElevatedButton(
                      onPressed: (controller.isLoading.value || controller.selectedService.value.isEmpty)
                        ? null 
                        : () => controller.submitOrder(),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      child: controller.isLoading.value 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Cuci Sekarang"),
                    )),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPickupOpt(BuildContext context, String label) {
    return Expanded(
      child: Obx(() => InkWell(
        onTap: () async {
          // LOGIKA PENTING DI SINI
          if (label == "Dijemput") {
            // Buka Peta
            final result = await Get.to(() => const AddressMapView());
            if (result != null) {
              controller.selectedPickup.value = label;
              controller.pickupAddress.value = result;
            }
          } else {
            // Jika Diantar ke outlet
            controller.selectedPickup.value = label;
            controller.pickupAddress.value = ''; // Reset alamat
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.selectedPickup.value == label ? AppTheme.secondaryColor : Colors.grey.shade300
            ),
            borderRadius: BorderRadius.circular(10),
            color: controller.selectedPickup.value == label ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                color: controller.selectedPickup.value == label ? AppTheme.secondaryColor : Colors.grey,
                fontWeight: FontWeight.w600
              )
            )
          ),
        ),
      )),
    );
  }

  // --- UI SORT OVERLAY (Bottom Sheet) ---
  void _showSortBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Urutkan Layanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _sortOptionItem(context, "Default", "default", Icons.list),
            _sortOptionItem(context, "Harga Terendah", "lowest_price", Icons.arrow_downward),
            _sortOptionItem(context, "Harga Tertinggi", "highest_price", Icons.arrow_upward),
            _sortOptionItem(context, "Nama (A-Z)", "name_az", Icons.sort_by_alpha),
          ],
        ),
      ),
    );
  }

  Widget _sortOptionItem(BuildContext context, String title, String value, IconData icon) {
    return Obx(() {
      final isSelected = controller.sortOption.value == value;
      return ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.secondaryColor : Colors.grey),
        title: Text(title, style: TextStyle(color: isSelected ? AppTheme.secondaryColor : context.textTheme.bodyLarge?.color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
        onTap: () {
          controller.sortOption.value = value;
          Get.back(); // Tutup overlay setelah memilih
        },
      );
    });
  }
}