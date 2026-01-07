import 'package:get/get.dart';

class HistoryController extends GetxController {
  // Default: 'Terbaru'
  var sortOrder = 'Terbaru'.obs; 
  var selectedStatus = 'Semua'.obs;
  var selectedPickup = 'Semua'.obs;

  void setSort(String? value) {
    if (value != null) sortOrder.value = value;
  }

  void setStatusFilter(String value) {
    selectedStatus.value = value;
  }

  void setPickupFilter(String value) {
    selectedPickup.value = value;
  }
}