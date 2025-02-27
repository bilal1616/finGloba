import 'package:flutter/material.dart';
import '../models/borsa_model.dart';

class BorsaTile extends StatelessWidget {
  final Borsa borsa;
  const BorsaTile({Key? key, required this.borsa}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          borsa.name.isNotEmpty ? borsa.name : 'Bilinmiyor',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('Fiyat: ${borsa.price.toStringAsFixed(2)} ₺'),
        trailing: Text(
          '${borsa.change.toStringAsFixed(2)}%',
          style: TextStyle(
            color: borsa.change >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
