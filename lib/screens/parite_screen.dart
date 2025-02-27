import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parite_model.dart';
import '../services/api_services.dart';

enum SortOption { sellingAsc, sellingDesc, rateAsc, rateDesc }

class PariteScreen extends StatefulWidget {
  const PariteScreen({Key? key}) : super(key: key);

  @override
  State<PariteScreen> createState() => _PariteScreenState();
}

class _PariteScreenState extends State<PariteScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Parite> pariteList = [];
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
          '🌍 Parite Bilgileri',
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
                _sortPariteList();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: SortOption.sellingAsc,
                  child: Text('📈 Satış Fiyatı (Artan)')),
              const PopupMenuItem(
                  value: SortOption.sellingDesc,
                  child: Text('📉 Satış Fiyatı (Azalan)')),
              const PopupMenuItem(
                  value: SortOption.rateAsc,
                  child: Text('🔄 Değişim Oranı (Artan)')),
              const PopupMenuItem(
                  value: SortOption.rateDesc,
                  child: Text('🔄 Değişim Oranı (Azalan)')),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<Parite>>(
        future: apiService.getParite(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            pariteList = snapshot.data!;
            _sortPariteList();

            if (pariteList.isEmpty) {
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
                itemCount: pariteList.length,
                itemBuilder: (context, index) {
                  final parite = pariteList[index];
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
                            _formatPariteName(parite.text, parite.name),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💰 Alış: ${parite.buying.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '💵 Satış: ${parite.selling.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '🔄 Değişim: ${parite.rate.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: parite.rate >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '📅 Tarih: ${parite.date} - ${parite.time}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 107, 107, 107),
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

  void _sortPariteList() {
    if (_currentSort != null) {
      switch (_currentSort!) {
        case SortOption.sellingAsc:
          pariteList.sort((a, b) => a.selling.compareTo(b.selling));
          break;
        case SortOption.sellingDesc:
          pariteList.sort((a, b) => b.selling.compareTo(a.selling));
          break;
        case SortOption.rateAsc:
          pariteList.sort((a, b) => a.rate.compareTo(b.rate));
          break;
        case SortOption.rateDesc:
          pariteList.sort((a, b) => b.rate.compareTo(a.rate));
          break;
      }
    }
  }

  /// **Parite İsmini "Euro (EUR) / Sterlin (GBP)" Formatına Dönüştürme**
  String _formatPariteName(String text, String name) {
    final parts = name.split('/');
    if (parts.length == 2) {
      final fromCurrency = parts[0];
      final toCurrency = parts[1];

      final textParts = text.split(' ');
      if (textParts.length >= 2) {
        final fromName = textParts.sublist(0, textParts.length ~/ 2).join(' ');
        final toName = textParts.sublist(textParts.length ~/ 2).join(' ');

        return '$fromName ($fromCurrency) / $toName ($toCurrency)';
      }
    }
    return text;
  }
}
