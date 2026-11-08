import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRecord {
  const MenuRecord({required this.name, required this.restaurant, required this.price});
  final String name;
  final String restaurant;
  final int price;
}

class MenuRepository {
  static bool get configured => const String.fromEnvironment('SUPABASE_URL').isNotEmpty &&
      const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty;

  static Future<List<MenuRecord>> fetchAvailable() async {
    if (!configured) return [];
    final client = Supabase.instance.client;
    final rows = await client
        .from('menu_items')
        .select('name, price_uzs, restaurants!inner(name)')
        .eq('is_available', true)
        .eq('restaurants.is_active', true)
        .order('name');
    return (rows as List).map((raw) {
      final row = raw as Map<String, dynamic>;
      final restaurant = row['restaurants'] as Map<String, dynamic>?;
      return MenuRecord(
        name: row['name'] as String,
        restaurant: restaurant?['name'] as String? ?? 'Restoran',
        price: (row['price_uzs'] as num).toInt(),
      );
    }).toList();
  }
}
