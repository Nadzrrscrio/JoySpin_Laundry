import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
// Import controller admin untuk dihapus juga saat logout
import '../views/admin/admin_controllers.dart';

class ProfileController extends GetxController {
  // Text Controller
  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  
  // State Variables
  var isLoading = false.obs;
  var userAvatarUrl = ''.obs;
  var fullName = ''.obs;
  var email = ''.obs;
  
  // Statistik
  var totalOrders = 0.obs;
  var totalSpend = 0.0.obs;

  // Theme Mode
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Set tema awal sesuai settingan GetX
    isDarkMode.value = Get.isDarkMode;
    fetchProfileData();
  }

  // --- LOGIC DARK MODE ---
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // --- FETCH DATA ---
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final user = SupabaseService.client.auth.currentUser;
      
      if (user != null) {
        email.value = user.email ?? '';
        emailC.text = email.value;

        // Ambil Data Profil
        final profileData = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          fullName.value = profileData['full_name'] ?? 'Pengguna Baru';
          nameC.text = fullName.value;
        } else {
          // Fallback jika profil belum ada di tabel
          fullName.value = user.userMetadata?['full_name'] ?? 'Pengguna';
          nameC.text = fullName.value;
        }

        // Generate Avatar berdasarkan nama yang didapat
        generateAvatar(fullName.value);

        // Hitung Statistik (Hanya untuk user biasa)
        final orderData = await SupabaseService.client
            .from('orders')
            .select('total_price')
            .eq('user_id', user.id);

        totalOrders.value = orderData.length;
        double spend = 0;
        for (var item in orderData) {
          spend += (item['total_price'] ?? 0).toDouble();
        }
        totalSpend.value = spend;
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- UPDATE DATA ---
  Future<void> updateProfile() async {
    if (nameC.text.isEmpty) {
      Get.snackbar("Error", "Nama tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      final user = SupabaseService.client.auth.currentUser;

      if (user != null) {
        // Update Table Profiles
        await SupabaseService.client.from('profiles').upsert({
          'id': user.id,
          'full_name': nameC.text,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Update Auth Metadata
        await SupabaseService.client.auth.updateUser(
          UserAttributes(data: {'full_name': nameC.text})
        );

        // Refresh Data di Halaman Utama
        fullName.value = nameC.text;
        generateAvatar(nameC.text);
        
        Get.back(); // Kembali
        Get.snackbar("Sukses", "Profil berhasil diperbarui", 
          backgroundColor: Colors.green.shade100);
      }
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e", backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper: Generate Avatar URL
  void generateAvatar(String name) {
    String cleanName = name.replaceAll(' ', '+');
    userAvatarUrl.value = "https://ui-avatars.com/api/?name=$cleanName&background=00BFA5&color=fff&size=512&bold=true";
  }

  // --- LOGOUT (FIX MEMORY LEAK) ---
  Future<void> logout() async {
    // 1. Sign out dari Supabase
    await SupabaseService.client.auth.signOut();
    
    // 2. Reset Variabel Lokal
    fullName.value = '';
    email.value = '';
    totalOrders.value = 0;
    userAvatarUrl.value = '';

    // 3. HAPUS CONTROLLER DARI MEMORI (PENTING!)
    // Ini memastikan saat user lain login, controller dibuat baru (fresh)
    // dan tidak menggunakan data sisa dari Admin.
    Get.delete<ProfileController>(force: true);
    
    // Hapus juga controller Admin jika ada
    if (Get.isRegistered<AdminDashboardController>()) Get.delete<AdminDashboardController>(force: true);
    if (Get.isRegistered<AdminServiceController>()) Get.delete<AdminServiceController>(force: true);
    if (Get.isRegistered<AdminProfileController>()) Get.delete<AdminProfileController>(force: true);

    // 4. Kembali ke halaman Login
    Get.offAllNamed('/login');
  }
}