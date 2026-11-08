import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_repository.dart';

const red = Color(0xFFE31827);
const ink = Color(0xFF171717);
const bg = Color(0xFFF7F7F7);
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://bjgffagonedmvasamtlo.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_sGmCLa3T1L-_ha1Ga6oBdA_yYiCiMKJ');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const AlikuryerApp());
}

class Food {
  const Food(this.name, this.restaurant, this.price, this.emoji, this.category);
  final String name, restaurant, emoji, category;
  final int price;
}

const foods = [
  Food('Mol go‘shtli lavash', 'Alikuryer Kitchen', 34000, '🌯', 'Lavash'),
  Food('Pepperoni pizza', 'Pizza House', 79000, '🍕', 'Pizza'),
  Food('Double burger', 'Burger Station', 45000, '🍔', 'Burger'),
  Food('Namangan oshi', 'Osh Markazi', 38000, '🍚', 'Milliy'),
  Food('Tovuq shashlik', 'Kabob House', 42000, '🍢', 'Milliy'),
  Food('Cezar salat', 'Fresh Food', 29000, '🥗', 'Salat'),
];

String money(int n) => '${n.toString().replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]} ')} so‘m';

class AlikuryerApp extends StatelessWidget {
  const AlikuryerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Alikuryer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: ink, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    ),
    home: const CustomerApp(),
  );
}

class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});
  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  int tab = 0;
  String query = '';
  String category = 'Barchasi';
  final Map<int, int> cart = {};
  bool placedOrder = false;
  List<Food>? liveFoods;
  String? loadError;
  List<Food> get catalog => MenuRepository.configured ? (liveFoods ?? <Food>[]) : foods;
  @override
  void initState() {
    super.initState();
    if (MenuRepository.configured) _loadMenu();
  }
  Future<void> _loadMenu() async {
    try {
      final records = await MenuRepository.fetchAvailable();
      if (!mounted) return;
      setState(() {
        cart.clear();
        liveFoods = records.map((r) => Food(r.name, r.restaurant, r.price, '🍽️', 'Barchasi')).toList();
        loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        liveFoods = [];
        loadError = 'Taomlarni yuklab bo‘lmadi. Ulanish va RLS sozlamalarini tekshiring.';
      });
    }
  }


  int get count => cart.values.fold(0, (a, b) => a + b);
  int get total => cart.entries.fold(0, (a, b) => a + catalog[b.key].price * b.value);
  void add(int i) => setState(() => cart[i] = (cart[i] ?? 0) + 1);
  void remove(int i) => setState(() {
    final next = (cart[i] ?? 0) - 1;
    if (next <= 0) { cart.remove(i); } else { cart[i] = next; }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: tab, children: [
      _home(),
      _catalog(),
      _orders(),
      _profile(),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFFFE5E8),
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: red), label: 'Bosh'),
        NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu, color: red), label: 'Taomlar'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: red), label: 'Buyurtma'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: red), label: 'Profil'),
      ],
    ),
    floatingActionButton: count > 0 && tab != 2 ? FloatingActionButton.extended(
      backgroundColor: ink, foregroundColor: Colors.white,
      onPressed: () => _showCart(),
      icon: const Icon(Icons.shopping_bag_outlined),
      label: Text('Savatcha ($count) · ${money(total)}'),
    ) : null,
  );

  Widget _heading(String title, {String? subtitle}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: ink)),
    if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.black54)),
  ]);

  Widget _home() => ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 100), children: [
    Row(children: [
      const Icon(Icons.location_on, color: red),
      const SizedBox(width: 5),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YETKAZIB BERISH MANZILI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black54)),
        Text('Namangan, O‘zbekiston', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ])),
      Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.notifications_none)),
    ]),
    const SizedBox(height: 25),
    const Text('ALIKURYER', style: TextStyle(fontSize: 33, fontWeight: FontWeight.w900, color: red, letterSpacing: -1.5)),
    const Text('Mazali taomlar — tez yetkazib berish', style: TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 20),
    TextField(onChanged: (v) => setState(() {query = v; tab = 1;}), decoration: InputDecoration(hintText: 'Qaysi taomni izlayapsiz?', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
    const SizedBox(height: 20),
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(24)), child: Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('OCH QOLDINGIZMI?', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 2)),
        SizedBox(height: 10),
        Text('Sevimli taomingiz bir necha bosishda!', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
      ])),
      const Text('🛵', style: TextStyle(fontSize: 65)),
    ])),
    const SizedBox(height: 26),
    _heading('Kategoriyalar'),
    const SizedBox(height: 14),
    SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, children: ['Barchasi', 'Lavash', 'Pizza', 'Burger', 'Milliy', 'Salat'].map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(c), onPressed: () => setState(() {category = c; tab = 1;}), backgroundColor: Colors.white))).toList())),
    const SizedBox(height: 18),
    _heading('Mashhur taomlar', subtitle: MenuRepository.configured ? 'Supabase katalogi' : 'Hozircha namunaviy katalog'),
    if (MenuRepository.configured && liveFoods == null) const LinearProgressIndicator(),
    if (loadError != null) Text(loadError!, style: const TextStyle(color: red)),
    if (MenuRepository.configured && liveFoods?.isEmpty == true && loadError == null) const Text('Hozircha faol restoran yoki taom yo‘q'),
    const SizedBox(height: 12),
    ...List.generate(catalog.length < 4 ? catalog.length : 4, (i) => _foodCard(i)),
  ]);

  Widget _catalog() {
    final matches = List.generate(catalog.length, (i) => i).where((i) => (category == 'Barchasi' || catalog[i].category == category) && ('${catalog[i].name} ${catalog[i].restaurant}').toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 110), children: [
      _heading('Taomlar', subtitle: MenuRepository.configured ? 'Supabase katalogi' : 'Alikuryer katalogi · demo'),
      if (MenuRepository.configured && liveFoods == null) const LinearProgressIndicator(),
      if (loadError != null) Text(loadError!, style: const TextStyle(color: red)),
      const SizedBox(height: 18),
      TextField(controller: TextEditingController(text: query)..selection = TextSelection.collapsed(offset: query.length), onChanged: (v) => setState(() => query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Taom yoki restoran', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
      const SizedBox(height: 12),
      Wrap(spacing: 6, children: ['Barchasi', 'Lavash', 'Pizza', 'Burger', 'Milliy', 'Salat'].map((c) => ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c))).toList()),
      const SizedBox(height: 12),
      if (matches.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Taom topilmadi')),
      ...matches.map(_foodCard),
    ]);
  }

  Widget _foodCard(int i) {
    final f = catalog[i];
    return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(13), child: Row(children: [
      Container(width: 82, height: 82, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFFFF1F1), borderRadius: BorderRadius.circular(17)), child: Text(f.emoji, style: const TextStyle(fontSize: 43))),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(f.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(f.restaurant, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 8),
        Text(money(f.price), style: const TextStyle(color: red, fontWeight: FontWeight.w900, fontSize: 15)),
      ])),
      IconButton.filled(onPressed: () => add(i), style: IconButton.styleFrom(backgroundColor: red), icon: const Icon(Icons.add, color: Colors.white)),
    ])));
  }

  void _showCart() => showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, backgroundColor: Colors.white, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _heading('Savatcha', subtitle: 'Demo buyurtma · haqiqiy to‘lov olinmaydi'),
    const SizedBox(height: 15),
    ...cart.entries.map((e) => ListTile(contentPadding: EdgeInsets.zero, title: Text(catalog[e.key].name), subtitle: Text(money(catalog[e.key].price * e.value)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: () {remove(e.key); Navigator.pop(ctx); _showCart();}, icon: const Icon(Icons.remove_circle_outline)),
      Text('${e.value}'),
      IconButton(onPressed: () {add(e.key); Navigator.pop(ctx); _showCart();}, icon: const Icon(Icons.add_circle_outline, color: red)),
    ]))),
    const SizedBox(height: 10),
    Text('Jami: ${money(total)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    FilledButton(onPressed: count == 0 ? null : () {
      setState(() {placedOrder = true; cart.clear(); tab = 2;});
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo buyurtma yaratildi. Restoranga yuborilmadi.')));
    }, child: const Text('Demo buyurtma berish')),
  ]))));

  Widget _orders() => Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Buyurtmalarim'),
    const SizedBox(height: 24),
    if (placedOrder) const Card(color: Colors.white, child: ListTile(leading: Icon(Icons.check_circle, color: red), title: Text('Demo buyurtma qabul qilindi'), subtitle: Text('Bu sinov. Haqiqiy restoran yoki kuryerga yuborilmadi.')))
    else const Center(child: Padding(padding: EdgeInsets.only(top: 90), child: Column(children: [
      Icon(Icons.receipt_long_outlined, size: 75, color: Colors.black26),
      SizedBox(height: 16),
      Text('Hozircha buyurtmalar yo‘q', style: TextStyle(fontWeight: FontWeight.w700)),
    ]))),
  ]));

  Widget _profile() => Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Profil'),
    const SizedBox(height: 24),
    const Card(color: Colors.white, child: ListTile(leading: CircleAvatar(backgroundColor: Color(0xFFFFE5E8), child: Icon(Icons.person, color: red)), title: Text('Mehmon foydalanuvchi'), subtitle: Text('Supabase autentifikatsiyasi hali ulanmagan'))),
    const SizedBox(height: 12),
    const Card(color: Colors.white, child: ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Manzillar'), subtitle: Text('Keyingi bosqichda ulanadi'))),
    const Card(color: Colors.white, child: ListTile(leading: Icon(Icons.support_agent), title: Text('Yordam'), subtitle: Text('Demo versiya'))),
    const Spacer(),
    const Text('ALIKURYER · Namangan\nFlutter + Supabase professional v1', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45)),
  ]));
}
