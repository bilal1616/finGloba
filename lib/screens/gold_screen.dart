import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../services/api_services.dart';
import '../models/gold_model.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({Key? key}) : super(key: key);

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Gold> goldList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoldData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 📌 Önce local storage'dan veri al, sonra API'den çek
  Future<void> _loadGoldData({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (!forceRefresh) {
      final cachedData = prefs.getString('gold_data');
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        setState(() {
          goldList = jsonList.map((e) => Gold.fromJson(e)).toList();
          isLoading = false;
        });
      }
    }

    try {
      final List<dynamic> apiData = await apiService.getGoldPrices();
      setState(() {
        goldList = apiData.map((e) => Gold.fromJson(e)).toList();
        isLoading = false;
      });

      // 📌 Yeni verileri önbelleğe kaydet
      prefs.setString('gold_data', json.encode(apiData));
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
          '🪙 Altın Fiyatları',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Popins",
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () => _loadGoldData(forceRefresh: true),
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
            : goldList.isEmpty
                ? const Center(child: Text('📉 Veri bulunamadı.'))
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      controller: _scrollController,
                      itemCount: goldList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) =>
                          _buildGoldCard(goldList[index]),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  Widget _buildGoldCard(Gold gold) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🪙",
              style: TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 10),
            Text(
              gold.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '💰 Alış: ${gold.buying.toStringAsFixed(2)} ₺',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '💵 Satış: ${gold.selling.toStringAsFixed(2)} ₺',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
