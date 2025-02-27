import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

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
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getLiveBorsa(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            borsaList = snapshot.data!.map((e) => Borsa.fromJson(e)).toList();
            _sortBorsaList();

            if (borsaList.isEmpty) {
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
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '📊 Değişim: ${borsa.change.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  borsa.change >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '🕒 Zaman: ${borsa.time}',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 141, 141, 141)),
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
