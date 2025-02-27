import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hisse_model.dart';
import '../services/api_services.dart';

enum SortOption { priceAsc, priceDesc, changeAsc, changeDesc }

class HisseScreen extends StatefulWidget {
  const HisseScreen({Key? key}) : super(key: key);

  @override
  State<HisseScreen> createState() => _HisseScreenState();
}

class _HisseScreenState extends State<HisseScreen> {
  late ApiService apiService;
  List<HisseSenedi> hisseSenetleri = [];
  bool isLoading = true;
  bool isError = false;
  late ScrollController _scrollController;
  SortOption? _currentSort;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    _scrollController = ScrollController();
    _loadHisseData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHisseData() async {
    try {
      final data = await apiService.getHisseSenedi();
      setState(() {
        hisseSenetleri = data;
        _applySort(); // 🎯 Varsayılan filtre uygulanır
        isLoading = false;
        isError = data.isEmpty;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      debugPrint('⚡ Hisse senedi verileri alınamadı: $e');
    }
  }

  // 🔍 Filtreleme işlemi
  void _applySort() {
    setState(() {
      if (_currentSort != null) {
        switch (_currentSort!) {
          case SortOption.priceAsc:
            hisseSenetleri.sort((a, b) => a.lastPrice.compareTo(b.lastPrice));
            break;
          case SortOption.priceDesc:
            hisseSenetleri.sort((a, b) => b.lastPrice.compareTo(a.lastPrice));
            break;
          case SortOption.changeAsc:
            hisseSenetleri.sort((a, b) => a.rate.compareTo(b.rate));
            break;
          case SortOption.changeDesc:
            hisseSenetleri.sort((a, b) => b.rate.compareTo(a.rate));
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '📊 Hisse Senedi Fiyatları',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Popins",
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
        actions: [
          // 🎛️ Filtreleme menüsü
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              _currentSort = value;
              _applySort();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: SortOption.priceAsc,
                  child: Text('💲 Son Fiyat (Artan)')),
              const PopupMenuItem(
                  value: SortOption.priceDesc,
                  child: Text('💲 Son Fiyat (Azalan)')),
              const PopupMenuItem(
                  value: SortOption.changeAsc,
                  child: Text('📈 Değişim Oranı (Artan)')),
              const PopupMenuItem(
                  value: SortOption.changeDesc,
                  child: Text('📈 Değişim Oranı (Azalan)')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : isError
              ? const Center(
                  child: Text(
                    "⚡ Lütfen daha sonra tekrar deneyin!",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: hisseSenetleri.length,
                  itemBuilder: (context, index) {
                    final hisse = hisseSenetleri[index];
                    return _buildHisseCard(hisse);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  Widget _buildHisseCard(HisseSenedi hisse) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${hisse.text} (${hisse.code})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text('💲 Son Fiyat: ${hisse.lastPriceStr} ₺',
                style: const TextStyle(fontSize: 14)),
            Text('📈 Değişim Oranı: %${hisse.rate.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14)),
            Text('💹 Hacim: ${hisse.hacimStr} ₺',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
