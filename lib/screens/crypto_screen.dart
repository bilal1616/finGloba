import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../services/api_services.dart';
import '../models/crypto_model.dart';

enum SortOption { priceAsc, priceDesc, changeAsc, changeDesc }

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({Key? key}) : super(key: key);

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Crypto> cryptoList = [];
  SortOption? _currentSort;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCryptoData();
  }

  // 📌 Önce local storage'dan veri al, sonra API'den çek
  Future<void> _loadCryptoData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (!forceRefresh) {
      final cachedData = prefs.getString('crypto_data');
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        setState(() {
          cryptoList = jsonList.map((e) => Crypto.fromJson(e)).toList();
          isLoading = false;
        });
      }
    }

    try {
      final List<dynamic> apiData = await apiService.getCrypto();
      setState(() {
        cryptoList = apiData.map((e) => Crypto.fromJson(e)).toList();
        isLoading = false;
      });

      // 📌 Yeni verileri önbelleğe kaydet
      prefs.setString('crypto_data', json.encode(apiData));
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
          '💹 Kripto Paralar',
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
                _sortCryptoList();
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
        onRefresh: () => _loadCryptoData(forceRefresh: true),
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
            : cryptoList.isEmpty
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
                        childAspectRatio: 0.70,
                      ),
                      itemCount: cryptoList.length,
                      itemBuilder: (context, index) {
                        final crypto = cryptoList[index];
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
                                  '${crypto.name} (${crypto.code})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '💵 Fiyat: ${crypto.price.toStringAsFixed(2)} ${crypto.currency}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '📊 Günlük Değişim: ${crypto.changeDay.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: crypto.changeDay >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '🌎 Piyasa Değeri: \$${crypto.marketCap.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 141, 141, 141),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '🪙 Dolaşımda: ${crypto.circulatingSupply} ${crypto.code}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 141, 141, 141),
                                          ),
                                        ),
                                      ],
                                    ),
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

  void _sortCryptoList() {
    if (_currentSort != null) {
      switch (_currentSort!) {
        case SortOption.priceAsc:
          cryptoList.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOption.priceDesc:
          cryptoList.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOption.changeAsc:
          cryptoList.sort((a, b) => a.changeDay.compareTo(b.changeDay));
          break;
        case SortOption.changeDesc:
          cryptoList.sort((a, b) => b.changeDay.compareTo(a.changeDay));
          break;
      }
    }
  }
}
