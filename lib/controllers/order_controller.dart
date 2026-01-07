import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import '../models/order_model.dart';

class OrderController extends GetxController {
  final SupabaseService _supabase = SupabaseService();

  var selectedCategory = ''.obs;
  var selectedService = ''.obs;
  var selectedPickup = ''.obs;
  var quantity = 1.obs;
  var unitPrice = 0.0.obs;
  var isLoading = false.obs;
  var pickupAddress = ''.obs;
  var allServices = <Map<String, dynamic>>[].obs;
  var searchText = ''.obs;
  var sortOption = 'default'.obs;

  // Mendapatkan kategori unik untuk Tampilan Home (Agar icon muncul otomatis)
  List<String> get uniqueCategories {
    if (allServices.isEmpty) return [];

    // 1. Ambil kategori unik
    List<String> cats = allServices
        .map((e) => e['category'] as String)
        .toSet()
        .toList();

    // 2. Sorting agar urutan rapi (Prioritas: Kering, Setrika, Satuan, Sepatu, ...Lainnya)
    final priority = [
      'Cuci Kering',
      'Cuci Setrika',
      'Cuci Satuan',
      'Cuci Sepatu',
    ];

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

  List<Map<String, dynamic>> get currentServices {
    var list = allServices
        .where((item) => item['category'] == selectedCategory.value)
        .toList();
    if (searchText.value.isNotEmpty) {
      list = list
          .where(
            (item) => item['name'].toString().toLowerCase().contains(
              searchText.value.toLowerCase(),
            ),
          )
          .toList();
    }
    switch (sortOption.value) {
      case 'lowest_price':
        list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
        break;
      case 'highest_price':
        list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
        break;
      case 'name_az':
        list.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        break;
      default:
        list.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    }

    return list;
  }

  @override
  void onInit() {
    super.onInit();
    fetchServices(); // AMBIL DATA SAAT APLIKASI DIBUKA
  }

  // --- FUNGSI FETCH DATA ---
  void fetchServices() async {
    try {
      // Kita pakai fungsi yang sama dengan Admin (Reuse code)
      final data = await _supabase.getServices();
      allServices.assignAll(data);
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  // --- LOGIC UI HELPERS ---
  bool get isSelfService =>
      selectedCategory.value.toLowerCase().contains('kering');

  String get quantityUnit {
    String cat = selectedCategory.value.toLowerCase();
    if (cat.contains('setrika')) return 'Kg';
    if (cat.contains('kering')) return 'Load';
    if (cat.contains('sepatu')) return 'Pasang';
    if (cat.contains('karpet')) return 'Mtr';
    return 'Pcs';
  }

  // --- LOGIC ORDER ---
  void startNewOrder(String category) {
    selectedCategory.value = category;
    searchText.value = '';
    sortOption.value = 'default';
    selectedService.value = '';
    pickupAddress.value = '';
    selectedPickup.value = isSelfService ? 'Datang ke Outlet' : '';
    quantity.value = 1;
    unitPrice.value = 0.0;

    // Refresh data biar harga update real-time
    fetchServices();
    Get.toNamed('/service-selection');
  }

  void setService(String name, int price) {
    selectedService.value = name;
    unitPrice.value = price.toDouble();
  }

  void incrementQty() => quantity.value++;
  void decrementQty() {
    if (quantity.value > 1) quantity.value--;
  }

  double get totalPrice => unitPrice.value * quantity.value;

  Future<void> submitOrder() async {
    if (selectedService.value.isEmpty) {
      Get.snackbar("Peringatan", "Mohon pilih jenis layanan");
      return;
    }

    if (!isSelfService && selectedPickup.value.isEmpty) {
      Get.snackbar("Peringatan", "Mohon pilih metode pengambilan");
      return;
    }

    if (selectedPickup.value == 'Dijemput' && pickupAddress.value.isEmpty) {
      Get.snackbar("Peringatan", "Mohon tentukan lokasi penjemputan pada peta");
      return;
    }

    try {
      isLoading.value = true;
      String finalPickup = isSelfService
          ? 'Self Service (Outlet)'
          : selectedPickup.value;

      String detailService =
          "${selectedService.value} (${quantity.value} $quantityUnit)";
      if (finalPickup == 'Dijemput') {
        detailService += "\n[Lokasi: ${pickupAddress.value}]";
      }

      final order = OrderModel(
        type: selectedCategory.value,
        service: detailService,
        pickupMethod: finalPickup,
        status: 'Menunggu Konfirmasi',
        price: totalPrice,
      );

      await _supabase.createOrder(order.toJson());

      Get.offAllNamed('/dashboard');
      Get.snackbar(
        "Berhasil",
        "Cucian dibuat! Total: Rp ${totalPrice.toStringAsFixed(0)}",
        backgroundColor: const Color(0xFF333333),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal membuat cucian: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
