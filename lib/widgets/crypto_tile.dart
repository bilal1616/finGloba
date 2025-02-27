import 'package:flutter/material.dart';
import '../models/crypto_model.dart';

class CryptoTile extends StatelessWidget {
  final Crypto crypto;
  const CryptoTile({required this.crypto, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          '${crypto.name} (${crypto.code})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '💵 Fiyat: ${crypto.price.toStringAsFixed(2)} ${crypto.currency}'),
            Text('🪙 Dolaşımda: ${crypto.circulatingSupply}'),
            Text('🌎 Piyasa Değeri: \$${crypto.marketCap.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Text(
          '📊 ${crypto.changeDay.toStringAsFixed(2)}%',
          style: TextStyle(
            color: crypto.changeDay >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
