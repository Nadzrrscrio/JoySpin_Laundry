import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/profile_controller.dart';
import '../../app_theme.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan Controller dipanggil (Dependency Injection)
    final ProfileController controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (SERAGAM DENGAN ADMIN) ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00BFA5), // Primary
                        Color(0xFF004D40), // Darker Green
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                
                // Tombol Edit
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    onPressed: () => Get.to(() => const EditProfileView()),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),

                // Avatar & Info
                Positioned(
                  bottom: -60,
                  child: Column(
                    children: [
                      Obx(() => Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: controller.userAvatarUrl.value.isNotEmpty
                              ? NetworkImage(controller.userAvatarUrl.value)
                              : null,
                        ),
                      )),
                      const SizedBox(height: 15),
                      Obx(() => Text(
                        controller.fullName.value,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textTheme.bodyLarge?.color),
                      )),
                      Obx(() => Text(
                        controller.email.value,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // --- STATISTIK CARD (USER ONLY) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.local_laundry_service,
                      label: "Total Cucian",
                      valueObx: controller.totalOrders,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Obx(() => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.wallet, color: Colors.blue, size: 30),
                          const SizedBox(height: 10),
                          Text("Pengeluaran", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(
                            currencyFormat.format(controller.totalSpend.value), 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textTheme.bodyLarge?.color),
                            maxLines: 1, overflow: TextOverflow.ellipsis
                          ),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- MENU LAINNYA ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Tombol Dark Mode
                  Obx(() => SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.dark_mode, color: Colors.purple),
                    ),
                    title: const Text("Mode Gelap", style: TextStyle(fontWeight: FontWeight.w600)),
                    value: controller.isDarkMode.value,
                    onChanged: (val) => controller.toggleTheme(val),
                    activeThumbColor: AppTheme.primaryColor,
                  )),
                  
                  const Divider(height: 1),
                  
                  // Logout
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                    onTap: () {
                      _showLogoutDialog(context, controller);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String label, required RxInt valueObx, required Color color}) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            "${valueObx.value}x", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: context.textTheme.bodyLarge?.color)
          ),
        ],
      ),
    ));
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      cancelTextColor: Colors.black,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      backgroundColor: context.theme.cardColor,
      titleStyle: TextStyle(color: context.textTheme.bodyLarge?.color),
      middleTextStyle: TextStyle(color: context.textTheme.bodyLarge?.color),
      onConfirm: () {
        Get.back(); // Tutup Dialog
        controller.logout(); // Jalankan logout dengan cleanup memori
      }
    );
  }
}