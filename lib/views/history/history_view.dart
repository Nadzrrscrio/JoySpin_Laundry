import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../services/supabase_service.dart';
import '../../app_theme.dart';
import '../../controllers/profile_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseService service = SupabaseService();
    final ProfileController profileC = Get.isRegistered<ProfileController>() 
        ? Get.find<ProfileController>() 
        : Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Cucian"),
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  const Text("Belum ada riwayat cucian"),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final item = orders[index];
              
              String dateFormatted = "-";
              if (item['created_at'] != null) {
                final date = DateTime.parse(item['created_at']).toLocal();
                dateFormatted = DateFormat('dd-MM-yyyy').format(date);
              }

              // Parsing Service & Address
              String rawService = item['service'] ?? '';
              String cleanService = rawService; 
              String extractedAddress = '';

              if (rawService.contains('[Lokasi:')) {
                final parts = rawService.split('[Lokasi:');
                cleanService = parts[0].trim();
                if (parts.length > 1) {
                  extractedAddress = parts[1].replaceAll(']', '').trim();
                }
              }

              String finalAddress = (item['address'] != null && item['address'].toString().isNotEmpty)
                  ? item['address']
                  : (extractedAddress.isNotEmpty ? extractedAddress : "-");

              final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

              return Card(
                color: context.theme.cardColor,
                margin: const EdgeInsets.only(bottom: 8), 
                elevation: 1, 
                shadowColor: Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // FIX: Kirim data yang sudah diparsing
                    _showDetailDialog(context, item, profileC.fullName.value, dateFormatted, cleanService, finalAddress);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, 
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['type'] == 'Cuci Sepatu' ? Icons.hiking : Icons.local_laundry_service_outlined,
                            color: AppTheme.secondaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['type'], 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 15, 
                                        color: context.textTheme.bodyLarge?.color
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currencyFormat.format(item['total_price']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14,
                                      color: AppTheme.secondaryColor
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormatted,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['status'].toLowerCase(),
                                      style: TextStyle(
                                        fontSize: 10, 
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(item['status'])
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- POPUP DETAIL CUCIAN ---
  void _showDetailDialog(BuildContext context, Map<String, dynamic> item, String userName, String date, String cleanService, String finalAddress) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    // FIX: Menggunakan padLeft agar tidak error RangeError pada ID pendek
    // Contoh: ID 1 menjadi "000001"
    String safeId = item['id'].toString().padLeft(6, '0');

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detail Cucian", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textTheme.bodyLarge?.color)),
                  IconButton(
                    onPressed: () => Get.back(), 
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.1), padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX: Gunakan safeId
                    _detailRow(context, "ID Cucian", "#$safeId"),
                    _detailRow(context, "Tanggal", date),
                    _detailRow(context, "Jenis Cucian", item['type']),
                    _detailRow(context, "Jumlah/Paket", cleanService),
                    _detailRow(context, "Total Tagihan", currencyFormat.format(item['total_price']), isBold: true),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                    if (item['pickup_method'] == 'Dijemput') ...[
                      const Text("Alamat Penjemputan:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.2))
                        ),
                        child: Text(
                          finalAddress,
                          style: TextStyle(fontSize: 13, color: context.textTheme.bodyLarge?.color),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Center(
                        child: Text(
                          "Status: ${item['status']}",
                          style: TextStyle(color: _getStatusColor(item['status']), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showReceiptDialog(context, item, userName, date, cleanService);
                  },
                  icon: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
                  label: const Text("LIHAT STRUK"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                ),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- POPUP STRUK ---
  void _showReceiptDialog(BuildContext context, Map<String, dynamic> item, String userName, String date, String cleanService) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    // FIX: Gunakan padLeft juga di sini
    String safeId = item['id'].toString().padLeft(6, '0');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("JOYSPIN LAUNDRY", style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text("Jl. Joyosari No.555, Merjosari, Lowokwaru, Malang", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.black54)),
                const SizedBox(height: 15),
                const Divider(color: Colors.black87, thickness: 1), 
                const SizedBox(height: 10),
                _receiptRow("Tanggal", date),
                _receiptRow("Nama User", userName),
                // FIX: Gunakan safeId
                _receiptRow("Ref", safeId),
                const SizedBox(height: 10),
                Text("---------------------------------", style: GoogleFonts.robotoMono(color: Colors.black45)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['type'], style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                          Text(cleanService, style: GoogleFonts.robotoMono(color: Colors.black54, fontSize: 10)),
                        ],
                      )
                    ),
                    const SizedBox(width: 10),
                    Text(currencyFormat.format(item['total_price']), style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Text("---------------------------------", style: GoogleFonts.robotoMono(color: Colors.black45)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TOTAL BAYAR", style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      currencyFormat.format(item['total_price']), 
                      style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("* Terima Kasih *", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic)),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black87),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                    ),
                    child: const Text("TUTUP"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.end, 
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 15 : 13,
                color: isBold ? AppTheme.secondaryColor : context.textTheme.bodyLarge?.color
              ),
              maxLines: 3, 
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Colors.green;
      case 'siap diambil': return Colors.teal;
      case 'diproses': return Colors.orange;
      case 'dibatalkan': return Colors.red;
      default: return Colors.blue;
    }
  }
}