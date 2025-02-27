import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

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
                  child: Text('📊 Günlük Değişim (Artan)')),
              const PopupMenuItem(
                  value: SortOption.changeDesc,
                  child: Text('📊 Günlük Değişim (Azalan)')),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getCrypto(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            cryptoList = snapshot.data!.map((e) => Crypto.fromJson(e)).toList();
            _sortCryptoList();

            if (cryptoList.isEmpty) {
              return const Center(child: Text('📉 Veri bulunamadı.'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            // <-- YENİ: Flexible yerleşim
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💵 Fiyat: ${crypto.price.toStringAsFixed(2)} ${crypto.currency}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
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
                                      color: Color.fromARGB(255, 141, 141, 141),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '🪙 Dolaşımda: ${crypto.circulatingSupply} ${crypto.code}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 141, 141, 141),
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
            );
          }
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
