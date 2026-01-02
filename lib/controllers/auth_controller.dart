import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class AuthController extends GetxController {
  final SupabaseService _supabase = SupabaseService();
  var isLoading = false.obs;

  // Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.signIn(email, password);
      
      // LOGIKA ADMIN CHECK
      if (email.toLowerCase() == 'joyspinlaundry@gmail.com') {
        Get.offAllNamed('/admin-dashboard'); // Masuk Mode Admin
      } else {
        Get.offAllNamed('/dashboard'); // Masuk Mode User Biasa
      }
      
    } catch (e) {
      Get.snackbar("Login Gagal", e.toString(), backgroundColor: Colors.red[100]);
    } finally {
      isLoading.value = false;
    }
  }

  // Register (User Biasa)
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.signUp(email, password, name);
      Get.snackbar("Sukses", "Akun berhasil dibuat, silakan login.");
      Get.offNamed('/login');
    } catch (e) {
      Get.snackbar("Register Gagal", e.toString(), backgroundColor: Colors.red[100]);
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.signOut();
    Get.offAllNamed('/login');
  }
}