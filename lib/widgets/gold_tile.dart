import 'package:flutter/material.dart';
import '../models/gold_model.dart';

class GoldTile extends StatelessWidget {
  final Gold gold;
  const GoldTile({required this.gold, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(gold.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Alış: ${gold.buying} TL | Satış: ${gold.selling} TL'),
      ),
    );
  }
}
