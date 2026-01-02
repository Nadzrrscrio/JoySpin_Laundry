import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/order_controller.dart';
import '../../app_theme.dart';

class HomeView extends GetView<OrderController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("JoySpin Laundry"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchServices();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPromoBanner(),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pilih Layanan",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    // Tombol refresh kecil jika user merasa data belum update
                    InkWell(
                      onTap: () => controller.fetchServices(),
                      child: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                    )
                  ],
                ),
              ),
              
              // --- GRID MENU DINAMIS (OPTIMAL) ---
              Obx(() {
                if (controller.allServices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Memuat layanan..."),
                    ),
                  );
                }

                final categories = controller.uniqueCategories;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (ctx, i) {
                    return _buildServiceCard(context, categories[i]);
                  },
                );
              }),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
          borderRadius: BorderRadius.circular(20)),
      child: Stack(children: [
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Text("PROMO SPESIAL",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  Text("DISKON 20%",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28)),
                  const Text("Promo spesial pengguna baru", style: TextStyle(color: Colors.white70))
                ])),
        Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.local_laundry_service,
                size: 150, color: Colors.white.withOpacity(0.15)))
      ]),
    ).animate().fadeIn().slideX();
  }

  Widget _buildServiceCard(BuildContext context, String categoryName) {
    // Logic Icon Dinamis (Sama seperti Admin)
    IconData icon = Icons.local_laundry_service;
    String lowerName = categoryName.toLowerCase();
    
    if (lowerName.contains('sepatu')) icon = Icons.hiking;
    else if (lowerName.contains('setrika')) icon = Icons.iron;
    else if (lowerName.contains('satuan')) icon = Icons.checkroom;
    else if (lowerName.contains('kering')) icon = Icons.dry_cleaning;
    else if (lowerName.contains('karpet')) icon = Icons.layers;
    else if (lowerName.contains('boneka')) icon = Icons.toys;
    
    return Container(
      decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: AppTheme.secondaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]),
      child: InkWell(
        onTap: () => controller.startNewOrder(categoryName),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppTheme.secondaryColor),
            ).animate().scale(),
            const SizedBox(height: 15),
            Text(categoryName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: context.textTheme.bodyLarge?.color)),
             const SizedBox(height: 4),
            Text("Proses Cepat & Bersih", 
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600))
          ],
        ),
      ),
    );
  }
}