import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../services/api_services.dart';
import '../models/borsa_model.dart';

enum SortOption { priceAsc, priceDesc, changeAsc, changeDesc }

class BorsaScreen extends StatefulWidget {
  const BorsaScreen({Key? key}) : super(key: key);

  @override
  State<BorsaScreen> createState() => _BorsaScreenState();
}

class _BorsaScreenState extends State<BorsaScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Borsa> borsaList = [];
  SortOption? _currentSort;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBorsaData();
  }

  // 📌 Önce local storage'dan veri al, sonra API'den çek
  Future<void> _loadBorsaData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (!forceRefresh) {
      final cachedData = prefs.getString('borsa_data');
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        setState(() {
          borsaList = jsonList.map((e) => Borsa.fromJson(e)).toList();
          isLoading = false;
        });
      }
    }

    try {
      final List<dynamic> apiData = await apiService.getLiveBorsa();
      setState(() {
        borsaList = apiData.map((e) => Borsa.fromJson(e)).toList();
        isLoading = false;
      });

      // 📌 Yeni verileri önbelleğe kaydet
      prefs.setString('borsa_data', json.encode(apiData));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚡ Veri yüklenirken hata oluştu!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '📈 Borsa Endeksleri',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Popins",
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _currentSort = value;
                _sortBorsaList();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: SortOption.priceAsc, child: Text('💵 Fiyat (Artan)')),
              const PopupMenuItem(
                  value: SortOption.priceDesc,
                  child: Text('💵 Fiyat (Azalan)')),
              const PopupMenuItem(
                  value: SortOption.changeAsc,
                  child: Text('📊 Değişim (Artan)')),
              const PopupMenuItem(
                  value: SortOption.changeDesc,
                  child: Text('📊 Değişim (Azalan)')),
            ],
          )
        ],
      ),
      body: CustomRefreshIndicator(
        onRefresh: () => _loadBorsaData(forceRefresh: true),
        builder: (context, child, controller) {
          return Stack(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Positioned(
                    top: controller.value * 100 - 50,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
              Transform.translate(
                offset: Offset(0, controller.value * 100),
                child: child,
              ),
            ],
          );
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : borsaList.isEmpty
                ? const Center(child: Text('📉 Veri bulunamadı.'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      controller: _scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: borsaList.length,
                      itemBuilder: (context, index) {
                        final borsa = borsaList[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "✨ ${borsa.name.isNotEmpty ? borsa.name : 'Bilinmiyor'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '💵 Fiyat: ${borsa.price.toStringAsFixed(2)} ${borsa.currency}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '📊 Değişim: ${borsa.change.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: borsa.change >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '🕒 Zaman: ${borsa.time}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 141, 141, 141),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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

  void _sortBorsaList() {
    if (_currentSort != null) {
      switch (_currentSort!) {
        case SortOption.priceAsc:
          borsaList.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.priceDesc:
          borsaList.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOption.changeAsc:
          borsaList.sort((a, b) => a.change.compareTo(b.change));
          break;
        case SortOption.changeDesc:
          borsaList.sort((a, b) => b.change.compareTo(a.change));
          break;
      }
    }
  }
}
