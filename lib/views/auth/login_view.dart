import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../app_theme.dart';

class LoginView extends StatelessWidget {
  // Inject Controller di sini agar aman
  final AuthController authC = Get.put(AuthController());
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(Icons.local_laundry_service, size: 80, color: AppTheme.secondaryColor),
              const SizedBox(height: 20),
              Text(
                "JoySpin\nLaundry App",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor),
              ),
              const SizedBox(height: 5),
              Text(
                "Solusi cucian bersih & wangi",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),

              // Card Putih dengan Shadow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailC,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: passC,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Login
                    Obx(() => authC.isLoading.value
                        ? const CircularProgressIndicator(color: AppTheme.secondaryColor)
                        : SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => authC.login(emailC.text, passC.text),
                              child: const Text("MASUK SEKARANG"),
                            ),
                          )),
                    const SizedBox(height: 20),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text("DAFTAR AKUN BARU"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}