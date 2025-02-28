import 'dart:convert';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool isLoading = true;
  bool isError = false;
  SortOption? _currentSort;

  @override
  void initState() {
    super.initState();
    _loadPariteData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 📌 Önce local storage'dan veri al, sonra API'den çek
  Future<void> _loadPariteData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (!forceRefresh) {
      final cachedData = prefs.getString('parite_data');
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        setState(() {
          pariteList = jsonList.map((e) => Parite.fromJson(e)).toList();
          isLoading = false;
        });
      }
    }

    try {
      final List<Parite> apiData = await apiService.getParite();
      setState(() {
        pariteList = apiData;
        _applySort();
        isLoading = false;
      });

      // 📌 Yeni verileri önbelleğe kaydet
      prefs.setString('parite_data', json.encode(apiData));
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  // 🔍 Filtreleme işlemi
  void _applySort() {
    setState(() {
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
              _currentSort = value;
              _applySort();
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
      body: CustomRefreshIndicator(
        onRefresh: () => _loadPariteData(forceRefresh: true),
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
            ? const Center(child: CircularProgressIndicator.adaptive())
            : isError
                ? const Center(
                    child: Text(
                      "⚡ Lütfen daha sonra tekrar deneyin!",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  )
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
                      itemCount: pariteList.length,
                      itemBuilder: (context, index) {
                        final parite = pariteList[index];
                        return _buildPariteCard(parite);
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

  Widget _buildPariteCard(Parite parite) {
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
            Text('💰 Alış: ${parite.buying.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 16)),
            Text('💵 Satış: ${parite.selling.toStringAsFixed(4)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            Text(
              '🔄 Değişim: ${parite.rate.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: parite.rate >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Parite İsmini "Euro (EUR) / Sterlin (GBP)" Formatına Dönüştürme**
  String _formatPariteName(String text, String name) {
    final parts = name.split('/');
    if (parts.length == 2) {
      return '${text.split(' ')[0]} ($parts[0]) / ${text.split(' ')[1]} ($parts[1])';
    }
    return text;
  }
}
