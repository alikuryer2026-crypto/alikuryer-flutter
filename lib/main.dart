import 'package:flutter/material.dart';

void main() => runApp(const AlikuryerApp());

const red = Color(0xFFD71920);

class AlikuryerApp extends StatelessWidget {
  const AlikuryerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Alikuryer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: red), useMaterial3: true),
    home: const WelcomeScreen(),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: red,
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.delivery_dining, size: 110, color: Colors.white),
        const SizedBox(height: 24),
        const Text('ALIKURYER', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
        const Text('FOOD DELIVERY', style: TextStyle(letterSpacing: 4, color: Colors.white)),
        const SizedBox(height: 36),
        const Text('Hamma narsa siz uchun!', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 42),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: red, minimumSize: const Size.fromHeight(54)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())), child: const Text('Boshlash')),
        const SizedBox(height: 16),
        const Text('Sinov versiyasi · SMS va to‘lovlar ulanmagan', style: TextStyle(color: Colors.white70)),
      ]),
    )),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  final tabs = const ['Bosh sahifa', 'Qidiruv', 'Buyurtmalar', 'Sevimlilar', 'Profil'];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Alikuryer · ${tabs[selected]}'), backgroundColor: red, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      if (selected == 0) ...[
        const Text('Namangan · Taom yetkazib berish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const SearchBar(hintText: 'Taom yoki restoran qidiring'),
        const SizedBox(height: 18),
        Card(color: red, child: const Padding(padding: EdgeInsets.all(24), child: Text('Sevimli taomlaringiz tez va qulay! 🍔', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 18),
        const Text('Kategoriyalar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Wrap(spacing: 8, children: [Chip(label: Text('Burger')), Chip(label: Text('Pizza')), Chip(label: Text('Osh')), Chip(label: Text('Lavash'))]),
        const SizedBox(height: 12),
        const Text('Restoranlar (demo)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        for (final name in ['EVOS', 'Pepperoni', 'Osh Markazi', 'KFC']) Card(child: ListTile(leading: const Icon(Icons.restaurant, color: red), title: Text(name), subtitle: const Text('Namuna ma’lumot'), trailing: const Icon(Icons.chevron_right))),
      ] else ...[
        Text(tabs[selected], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Bu bo‘lim ishlab chiqilmoqda. Hozircha demo versiya.'),
      ],
    ]),
    bottomNavigationBar: NavigationBar(selectedIndex: selected, onDestinationSelected: (value) => setState(() => selected = value), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Bosh'),
      NavigationDestination(icon: Icon(Icons.search), label: 'Qidiruv'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Buyurtma'),
      NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Sevimli'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
    ]),
  );
}
