import 'package:fingloba/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gold_model.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({Key? key}) : super(key: key);

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

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
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.getGoldPrices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            final golds = snapshot.data!.map((e) => Gold.fromJson(e)).toList();
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: golds.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) => _buildGoldCard(golds[index]),
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
            Text(
              "🪙",
              style: TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 10),
            Text(
              gold.name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
