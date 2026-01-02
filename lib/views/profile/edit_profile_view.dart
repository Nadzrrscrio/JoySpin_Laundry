import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.cardColor,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: context.theme.cardColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- AVATAR PREVIEW ---
            Center(
              child: Obx(() => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: controller.userAvatarUrl.value.isNotEmpty
                    ? NetworkImage(controller.userAvatarUrl.value)
                    : null,
              )),
            ),
            const SizedBox(height: 10),
            const Text(
              "Avatar dibuat otomatis dari inisial nama Anda", 
              style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
            const SizedBox(height: 40),

            // --- FORM SECTION ---
            TextField(
              controller: controller.nameC,
              style: TextStyle(color: context.textTheme.bodyLarge?.color),
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person),
                hintText: "Contoh: Budi Santoso"
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.emailC,
              readOnly: true,
              style: TextStyle(color: context.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: context.theme.brightness == Brightness.dark 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade100,
                suffixIcon: const Icon(Icons.lock, size: 16, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 50),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.isLoading.value 
                    ? null 
                    : () => controller.updateProfile(),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN PERUBAHAN"),
              ),
            )),
          ],
        ),
      ),
    );
  }
}