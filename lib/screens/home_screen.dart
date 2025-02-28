import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'gold_screen.dart';
import 'crypto_screen.dart';
import 'borsa_screen.dart';
import 'hisse_screen.dart';
import 'parite_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _navigateToScreen(BuildContext context, Widget screen) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitCircle(
          color: Color.fromARGB(255, 158, 10, 10),
          size: 50.0,
        ),
      ),
    );

    await Future.delayed(
        const Duration(seconds: 1)); // Simüle edilen yükleme süresi

    Navigator.pop(context); // Yüklenme ekranını kapat
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'FinGloba',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Popins",
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 158, 10, 10),
      ),
      body: Stack(
        children: [
          // 🖼️ Üst kısma opacity'li resim
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/fingloba.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 🖼️ Alt kısma opacity'li resim
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/fingloba.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 📊 Ana içerik (GridView)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final screens = [
                    {
                      'title': '🪙 Altın Fiyatları',
                      'screen': const GoldScreen()
                    },
                    {
                      'title': '💹 Kripto Paralar',
                      'screen': const CryptoScreen()
                    },
                    {
                      'title': '📈 Borsa Endeksleri',
                      'screen': const BorsaScreen()
                    },
                    {
                      'title': '📊 Hisse Senetleri',
                      'screen': const HisseScreen()
                    },
                    {
                      'title': '🌍 Parite Bilgileri',
                      'screen': const PariteScreen()
                    },
                  ];

                  return GestureDetector(
                    onTap: () => _navigateToScreen(
                        context, screens[index]['screen'] as Widget),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          screens[index]['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: "Popins",
                            color: Color.fromARGB(255, 158, 10, 10),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
