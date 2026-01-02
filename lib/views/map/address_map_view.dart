import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../app_theme.dart';

class AddressMapView extends StatefulWidget {
  const AddressMapView({super.key});

  @override
  State<AddressMapView> createState() => _AddressMapViewState();
}

class _AddressMapViewState extends State<AddressMapView> {
  final MapController _mapController = MapController();
  
  // KOORDINAT DEFAULT (Toko JoySpin Laundry)
  // Jl. Joyosari No.555, Merjosari, Kec. Lowokwaru, Kota Malang
  // Koordinat perkiraan area Merjosari/Lowokwaru
  final LatLng _defaultLocation = const LatLng(-7.9427, 112.6053); 
  final String _defaultAddress = "Jl. Joyosari No.555, Merjosari, Kec. Lowokwaru, Kota Malang, Jawa Timur";

  LatLng? _pickedLocation;
  String _address = "Menyiapkan peta...";
  bool _isLoading = true; // Loading awal

  @override
  void initState() {
    super.initState();
    // Jalankan inisialisasi lokasi saat pertama kali dibuka
    _initializeLocation();
  }

  // --- LOGIC UTAMA: MENENTUKAN LOKASI AWAL ---
  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek Apakah GPS Aktif?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // JIKA GPS MATI -> Pakai Lokasi Toko (Default)
      _useDefaultLocation("GPS tidak aktif. Menggunakan lokasi default toko.");
      return;
    }

    // 2. Cek Izin Lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // JIKA IZIN DITOLAK -> Pakai Lokasi Toko (Default)
        _useDefaultLocation("Izin lokasi ditolak. Menggunakan lokasi default toko.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // JIKA DITOLAK PERMANEN -> Pakai Lokasi Toko (Default)
      _useDefaultLocation("Izin lokasi ditolak permanen. Menggunakan lokasi default toko.");
      return;
    }

    // 3. JIKA GPS AKTIF & DIIZINKAN -> Ambil Posisi User
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      final userLatLng = LatLng(position.latitude, position.longitude);
      
      // Update UI ke lokasi user
      _updateLocationManually(userLatLng, isAutoDetected: true);

    } catch (e) {
      // Jika terjadi error lain, tetap fallback ke default
      _useDefaultLocation("Gagal mendeteksi lokasi. Menggunakan default.");
    }
  }

  // Fungsi Helper: Menggunakan Lokasi Default Toko
  void _useDefaultLocation(String message) {
    // Tampilkan snackbar info (opsional)
    // Get.snackbar("Info", message, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
    
    setState(() {
      _pickedLocation = _defaultLocation;
      _address = _defaultAddress;
      _isLoading = false; // Stop loading agar tombol bisa diklik
    });
    
    // Pindahkan kamera ke toko
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_defaultLocation, 15.0);
    });
  }

  // Fungsi Helper: Update Lokasi saat User Klik Map
  Future<void> _updateLocationManually(LatLng point, {bool isAutoDetected = false}) async {
    setState(() {
      _pickedLocation = point;
      _isLoading = true; // Mulai loading address
      if (!isAutoDetected) {
        _address = "Memuat detail alamat...";
      }
    });

    if (isAutoDetected) {
      _mapController.move(point, 15.0);
    }

    try {
      // Geocoding: Koordinat -> Alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude, 
        point.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // Format Alamat Lengkap
          _address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        });
      } else {
         setState(() {
          _address = "Alamat tidak ditemukan di titik ini.";
        });
      }
    } catch (e) {
      setState(() {
        // Jika gagal load alamat (misal offline), tetap tampilkan koordinat
        // agar user TETAP BISA lanjut order
        _address = "Lokasi Terpilih (${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)})";
      });
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  // --- LOGIC ZOOM ---
  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Titik Penjemputan"),
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        actions: [
          // Tombol Reset ke Lokasi Saat Ini (Re-center)
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _initializeLocation,
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Initial center sementara sebelum logic jalan
              initialCenter: _defaultLocation, 
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                // User klik manual di peta -> Update lokasi
                _updateLocationManually(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.joyspin.app',
              ),
              if (_pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on, 
                        color: Colors.red, 
                        size: 50
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // --- TOMBOL ZOOM ---
          Positioned(
            right: 16,
            bottom: 240, 
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "btnZoomIn",
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: AppTheme.secondaryColor),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "btnZoomOut",
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: AppTheme.secondaryColor),
                ),
              ],
            ),
          ),

          // --- CARD ALAMAT ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      const Text("Lokasi Terpilih:", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tampilkan Alamat
                  Text(
                    _address,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: context.textTheme.bodyLarge?.color 
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // Button aktif jika sedang TIDAK loading, ATAU jika sudah ada lokasi terpilih (default/gps)
                      onPressed: (_isLoading && _pickedLocation == null) 
                          ? null 
                          : () {
                              if (_pickedLocation != null) {
                                // Kembalikan string alamat final ke halaman sebelumnya
                                Get.back(result: _address);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                      child: _isLoading 
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                SizedBox(width: 10),
                                Text("Memuat Alamat...")
                              ],
                            ) 
                          : const Text("Gunakan Lokasi Ini"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}