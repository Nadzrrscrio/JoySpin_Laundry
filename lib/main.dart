import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';

// Views User
import 'views/dashboard/dashboard_binding.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/dashboard/main_wrapper.dart';
import 'views/order/service_selection_view.dart';
import 'views/order/checkout_view.dart';

// Views & Binding Admin
import 'views/admin/admin_views.dart'; 
import 'views/admin/admin_binding.dart'; // IMPORT BINDING YANG BARU DIBUAT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://ijvyswrwwawctcstkcim.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlqdnlzd3J3d2F3Y3Rjc3RrY2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcyODQwNDksImV4cCI6MjA4Mjg2MDA0OX0.vYOnhJ_cQB9-IdHoCZ2b-XeM1u2Pbus1Z58-esHM070',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JoySpin Laundry',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, 
      
      initialRoute: '/login', 
      
      getPages: [
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/register', page: () => RegisterView()),
        
        // Route User
        GetPage(
          name: '/dashboard', 
          page: () => const MainWrapper(), 
          binding: DashboardBinding() 
        ),
        GetPage(name: '/service-selection', page: () => const ServiceSelectionView()),
        GetPage(name: '/checkout', page: () => const CheckoutView()),

        // --- RUTE ADMIN (REVISI: TAMBAHKAN BINDING) ---
        GetPage(
          name: '/admin-dashboard', 
          page: () => const AdminMainWrapper(), // const ditambahkan untuk optimasi
          binding: AdminBinding(), // INI SOLUSI ERROR "AUTHCONTROLLER NOT FOUND"
        ),
      ],
    );
  }
}