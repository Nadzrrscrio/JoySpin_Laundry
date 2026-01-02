import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_controllers.dart';
import '../../app_theme.dart';
import '../../services/supabase_service.dart';
import '../profile/edit_profile_view.dart'; 

// --- MAIN WRAPPER ADMIN ---
class AdminMainWrapper extends GetView<AdminDashboardController> {
  const AdminMainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          AdminServiceCategoryView(), 
          const AdminAllHistoryView(),    
          AdminNotificationView(),  
          const AdminProfileView(),       
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service), label: 'Cucian'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notif'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Admin'),
        ],
      )),
    );
  }
}

// =============================================================================
// TAB 1: KELOLA LAYANAN
// =============================================================================
class AdminServiceCategoryView extends GetView<AdminServiceController> {
  const AdminServiceCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Layanan"),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
           color: context.textTheme.bodyLarge?.color, 
           fontSize: 18, fontWeight: FontWeight.bold
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        label: const Text("Kategori Baru", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.secondaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        final categories = controller.uniqueCategories;
        if (categories.isEmpty) return const Center(child: Text("Belum ada layanan."));

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (ctx, i) {
            return _buildCategoryCard(context, categories[i]);
          },
        );
      }),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String categoryName) {
    IconData icon = Icons.local_laundry_service;
    if (categoryName.contains('Sepatu')) icon = Icons.hiking;
    if (categoryName.contains('Setrika')) icon = Icons.iron;
    if (categoryName.contains('Satuan')) icon = Icons.checkroom;
    if (categoryName.contains('Kering')) icon = Icons.dry_cleaning;

    return Container(
      decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: AppTheme.secondaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]),
      child: InkWell(
        onTap: () => Get.to(() => AdminServiceDetailView(categoryName: categoryName)),
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
            ),
            const SizedBox(height: 15),
            Text(categoryName,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: context.textTheme.bodyLarge?.color)),
             const SizedBox(height: 4),
            Text("Ketuk untuk edit", 
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600))
          ],
        ),
      ),
    );
  }

  // --- REVISI: FORM INPUT STYLE MIRIP LOGIN/REGISTER ---
  void _showAddCategoryDialog(BuildContext context) {
    final catC = TextEditingController();
    final nameC = TextEditingController();
    final priceC = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Buat Kategori Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: catC, 
                decoration: const InputDecoration(
                  labelText: "Nama Kategori", 
                  hintText: "Cth: Cuci Karpet",
                  prefixIcon: Icon(Icons.category_outlined), // Icon
                )
              ),
              const SizedBox(height: 20), // Jarak lebih lebar
              
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text("Item Pertama:", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),

              TextField(
                controller: nameC, 
                decoration: const InputDecoration(
                  labelText: "Nama Item", 
                  hintText: "Cth: Karpet 2x3",
                  prefixIcon: Icon(Icons.label_outline), // Icon
                )
              ),
              const SizedBox(height: 16),

              TextField(
                controller: priceC, 
                keyboardType: TextInputType.number, 
                decoration: const InputDecoration(
                  labelText: "Harga (Rp)",
                  prefixIcon: Icon(Icons.attach_money), // Icon
                )
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () => controller.addService(catC.text, nameC.text, priceC.text),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }
}

class AdminServiceDetailView extends StatelessWidget {
  final String categoryName;
  final AdminServiceController controller = Get.find(); 

  AdminServiceDetailView({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        final items = controller.getItemsByCategory(categoryName);
        if (items.isEmpty) return const Center(child: Text("Kategori ini kosong"));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (c, i) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final item = items[i];
            return Card(
              elevation: 0,
              color: context.theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currencyFormat.format(item['price']), style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(context, item)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(item['id'])),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- REVISI: FORM INPUT STYLE MIRIP LOGIN/REGISTER ---
  void _showAddItemDialog(BuildContext context) {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Tambah ke $categoryName"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameC, 
              decoration: const InputDecoration(
                labelText: "Nama Item", 
                prefixIcon: Icon(Icons.label_outline) // Icon
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceC, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                labelText: "Harga", 
                prefixIcon: Icon(Icons.attach_money) // Icon
              )
            ),
        ]),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () => controller.addService(categoryName, nameC.text, priceC.text), 
            child: const Text("Simpan", style: TextStyle(color: Colors.white))
          )
        ],
      )
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    final nameC = TextEditingController(text: item['name']);
    final priceC = TextEditingController(text: item['price'].toString());
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Item"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameC, 
              decoration: const InputDecoration(
                labelText: "Nama Layanan",
                prefixIcon: Icon(Icons.edit_outlined)
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceC, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                labelText: "Harga",
                prefixIcon: Icon(Icons.attach_money)
              )
            ),
        ]),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => controller.updateService(item['id'], nameC.text, priceC.text), 
            child: const Text("Update")
          )
        ],
      )
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: "Hapus Item?", middleText: "Item akan dihapus permanen.",
      textConfirm: "Hapus", confirmTextColor: Colors.white, buttonColor: Colors.red,
      textCancel: "Batal", 
      onConfirm: () { Get.back(); controller.deleteService(id); }
    );
  }
}

// =============================================================================
// TAB 2: HISTORY
// =============================================================================
class AdminAllHistoryView extends StatelessWidget {
  const AdminAllHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseService service = SupabaseService();
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Semua Cucian Masuk")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getAllOrdersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text("Belum ada pesanan masuk"));

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final item = orders[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: context.theme.cardColor,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(item['status']).withOpacity(0.2),
                    child: Icon(Icons.local_laundry_service, color: _getStatusColor(item['status'])),
                  ),
                  title: Text(item['type'] + " - " + currencyFormat.format(item['total_price']), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['service'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("Status: ${item['status']}", style: TextStyle(color: _getStatusColor(item['status']), fontWeight: FontWeight.bold)),
                  ]),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) => service.updateOrderStatus(item['id'], val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "Menunggu Konfirmasi", child: Text("Menunggu")),
                      const PopupMenuItem(value: "Diproses", child: Text("Diproses")),
                      const PopupMenuItem(value: "Siap Diambil", child: Text("Siap Diambil")),
                      const PopupMenuItem(value: "Selesai", child: Text("Selesai")),
                      const PopupMenuItem(value: "Dibatalkan", child: Text("Batalkan")),
                    ],
                    icon: const Icon(Icons.edit_note, color: Colors.blue),
                  ),
                ),
              );
            },
          );
        },
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

// =============================================================================
// TAB 3: NOTIFIKASI (REVISI: FORM INPUT STYLE)
// =============================================================================
class AdminNotificationView extends GetView<AdminNotificationController> {
  final titleC = TextEditingController();
  final bodyC = TextEditingController();

  AdminNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Notifikasi")),
      body: Column(
        children: [
          // BAGIAN INPUT (FORM DENGAN ICON)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Buat Notifikasi Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),
                
                TextField(
                  controller: titleC, 
                  decoration: const InputDecoration(
                    labelText: "Judul", 
                    prefixIcon: Icon(Icons.title), // Icon
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                  )
                ),
                const SizedBox(height: 15),
                
                TextField(
                  controller: bodyC, 
                  maxLines: 2, 
                  decoration: const InputDecoration(
                    labelText: "Isi Pesan", 
                    prefixIcon: Icon(Icons.message_outlined), // Icon
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                  )
                ),
                const SizedBox(height: 20),
                
                Obx(() => SizedBox(width: double.infinity, height: 45, child: ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: controller.isLoading.value ? const Text("Mengirim...") : const Text("Kirim"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor, foregroundColor: Colors.white),
                    onPressed: controller.isLoading.value ? null : () {
                      controller.sendNotif(titleC.text, bodyC.text);
                      titleC.clear();
                      bodyC.clear();
                      FocusScope.of(context).unfocus();
                    },
                )))
              ],
            ),
          ),

          // LIST NOTIFIKASI
          Expanded(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return const Center(child: Text("Belum ada notifikasi aktif"));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.notifications.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final item = controller.notifications[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.notifications, color: Colors.white)),
                      title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item['body'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditNotifDialog(context, item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }

  void _showEditNotifDialog(BuildContext context, Map<String, dynamic> item) {
    final tC = TextEditingController(text: item['title']);
    final bC = TextEditingController(text: item['body']);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Notifikasi"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: tC, decoration: const InputDecoration(labelText: "Judul", prefixIcon: Icon(Icons.title))),
            const SizedBox(height: 16),
            TextField(controller: bC, maxLines: 3, decoration: const InputDecoration(labelText: "Pesan", prefixIcon: Icon(Icons.message_outlined))),
        ]),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(onPressed: () => controller.updateNotif(item['id'], tC.text, bC.text), child: const Text("Update"))
        ],
      )
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: "Hapus?", 
      middleText: "Notifikasi akan dihapus dari semua user.",
      textConfirm: "Hapus", 
      confirmTextColor: Colors.white, 
      buttonColor: Colors.red,
      textCancel: "Batal", 
      onConfirm: () { Get.back(); controller.deleteNotif(id); }
    );
  }
}

// =============================================================================
// TAB 4: PROFILE ADMIN
// =============================================================================
class AdminProfileView extends GetView<AdminProfileController> {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileC = controller.userProfileC; 
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor, 
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      colors: [Color(0xFF00BFA5), Color(0xFF004D40)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                
                Positioned(
                  top: 50, right: 20,
                  child: IconButton(
                    onPressed: () => Get.to(() => const EditProfileView()),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -60,
                  child: Column(
                    children: [
                      Obx(() => Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileC.userAvatarUrl.value.isNotEmpty
                              ? NetworkImage(profileC.userAvatarUrl.value)
                              : null,
                        ),
                      )),
                      const SizedBox(height: 15),
                      Obx(() => Text(profileC.fullName.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textTheme.bodyLarge?.color))),
                      const Text("Administrator Mode", style: TextStyle(fontSize: 14, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Pendapatan", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(currencyFormat.format(controller.totalRevenue.value), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.wallet, color: Colors.white, size: 30),
                    )
                  ],
                ),
              )),
            ),

            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: context.theme.cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.dark_mode, color: Colors.purple),
                    ),
                    title: const Text("Mode Gelap", style: TextStyle(fontWeight: FontWeight.w600)),
                    value: profileC.isDarkMode.value,
                    onChanged: (val) => profileC.toggleTheme(val),
                    activeThumbColor: AppTheme.primaryColor,
                  )),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                    onTap: () {
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
                          Get.back(); 
                          profileC.logout(); 
                        }
                      );
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
}