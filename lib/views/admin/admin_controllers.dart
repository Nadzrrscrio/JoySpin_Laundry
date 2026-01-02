import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/supabase_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

// Controller Dashboard Admin
class AdminDashboardController extends GetxController {
  var tabIndex = 0.obs;
  void changeTabIndex(int index) => tabIndex.value = index;
}

// Controller Service
class AdminServiceController extends GetxController {
  final SupabaseService _supabase = SupabaseService();
  var services = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  void fetchServices() async {
    try {
      isLoading.value = true;
      final data = await _supabase.getServices();
      services.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  List<String> get uniqueCategories {
    List<String> cats = services.map((e) => e['category'] as String).toSet().toList();
    final priority = ['Cuci Kering', 'Cuci Setrika', 'Cuci Satuan', 'Cuci Sepatu'];

    cats.sort((a, b) {
      int indexA = priority.indexOf(a);
      int indexB = priority.indexOf(b);
      if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.compareTo(b);
    });

    return cats;
  }

  List<Map<String, dynamic>> getItemsByCategory(String category) {
    return services.where((e) => e['category'] == category).toList();
  }

  Future<void> addService(String category, String name, String priceStr) async {
    int? price = int.tryParse(priceStr);
    if (category.isEmpty || name.isEmpty || price == null) {
      Get.snackbar("Error", "Data tidak valid/Lengkap");
      return;
    }
    await _supabase.addService(category, name, price);
    fetchServices();
    Get.back();
  }

  Future<void> updateService(int id, String name, String priceStr) async {
    int? price = int.tryParse(priceStr);
    if (price == null) return;
    await _supabase.updateService(id, name, price);
    fetchServices();
    Get.back();
  }

  Future<void> deleteService(int id) async {
    await _supabase.deleteService(id);
    fetchServices();
  }
}

// --- CONTROLLER NOTIFIKASI (UPDATED: CRUD LENGKAP) ---
class AdminNotificationController extends GetxController {
  final SupabaseService _supabase = SupabaseService();
  var isLoading = false.obs;
  
  // List untuk menampung notifikasi agar bisa ditampilkan, diedit, dan dihapus
  var notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Bind stream notifikasi ke variabel notifications
    notifications.bindStream(_supabase.getNotificationsStream());
  }

  // Kirim (Tambah) Notifikasi
  Future<void> sendNotif(String title, String body) async {
    if (title.isEmpty || body.isEmpty) {
      Get.snackbar("Error", "Form tidak boleh kosong");
      return;
    }
    try {
      isLoading.value = true;
      await _supabase.sendNotification(title, body);
      Get.snackbar("Sukses", "Notifikasi berhasil dibuat");
      // Reset form atau logic lain jika perlu
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Hapus Notifikasi
  Future<void> deleteNotif(int id) async {
    try {
      await SupabaseService.client.from('notifications').delete().eq('id', id);
      Get.snackbar("Sukses", "Notifikasi dihapus");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus: $e");
    }
  }

  // Edit Notifikasi
  Future<void> updateNotif(int id, String title, String body) async {
    try {
      await SupabaseService.client.from('notifications').update({
        'title': title,
        'body': body
      }).eq('id', id);
      Get.back(); // Tutup Dialog
      Get.snackbar("Sukses", "Notifikasi diperbarui");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal update: $e");
    }
  }
}

// Controller Profile
class AdminProfileController extends GetxController {
  final SupabaseService _supabase = SupabaseService();
  AuthController get authC => Get.find<AuthController>();
  ProfileController get userProfileC => Get.find<ProfileController>();

  var totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRevenue();
  }

  void fetchRevenue() async {
    double total = await _supabase.getTotalRevenue();
    totalRevenue.value = total;
  }
}