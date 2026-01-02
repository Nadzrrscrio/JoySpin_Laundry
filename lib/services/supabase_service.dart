import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // --- AUTH ---
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // --- ORDERS (USER SIDE) ---
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    
    orderData['user_id'] = user.id;
    await client.from('orders').insert(orderData);
  }

  // Stream untuk User (Hanya melihat data sendiri, Realtime)
  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    return client
        .from('orders')
        .stream(primaryKey: ['id']) 
        .eq('user_id', client.auth.currentUser!.id) 
        .order('created_at');
  }

  // --- ADMIN & SERVICES ---

  // 1. SERVICES (Realtime update harga)
  Future<List<Map<String, dynamic>>> getServices() async {
    final data = await client.from('services').select().order('id');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addService(String category, String name, int price) async {
    await client.from('services').insert({
      'category': category,
      'name': name,
      'price': price,
    });
  }

  Future<void> updateService(int id, String name, int price) async {
    await client.from('services').update({
      'name': name,
      'price': price,
    }).eq('id', id);
  }

  Future<void> deleteService(int id) async {
    await client.from('services').delete().eq('id', id);
  }

  // 2. ADMIN: GET ALL ORDERS (Melihat SEMUA data user, Realtime)
  Stream<List<Map<String, dynamic>>> getAllOrdersStream() {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
  
  // 3. ADMIN: UPDATE STATUS ORDER
  Future<void> updateOrderStatus(dynamic id, String newStatus) async {
    await client.from('orders').update({'status': newStatus}).eq('id', id);
  }

  // 4. ADMIN: TOTAL PENDAPATAN
  Future<double> getTotalRevenue() async {
    final data = await client.from('orders').select('total_price');
    double total = 0;
    for (var item in data) {
      total += (item['total_price'] ?? 0).toDouble();
    }
    return total;
  }

  // 5. NOTIFIKASI
  Future<void> sendNotification(String title, String body) async {
    await client.from('notifications').insert({
      'title': title,
      'body': body,
    });
  }

  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}