import 'package:get/get.dart';
import 'admin_controllers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Pastikan Auth & Profile Controller User ada (karena Admin butuh data user/login)
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // 2. Masukkan Controller Khusus Admin
    Get.put<AdminDashboardController>(AdminDashboardController());
    Get.put<AdminServiceController>(AdminServiceController());
    Get.put<AdminNotificationController>(AdminNotificationController());
    Get.put<AdminProfileController>(AdminProfileController());
  }
}