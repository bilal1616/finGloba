class Borsa {
  final String name;
  final double price;
  final double change;
  final String currency;
  final String time;

  Borsa({
    required this.name,
    required this.price,
    required this.change,
    required this.currency,
    required this.time,
  });

  factory Borsa.fromJson(Map<String, dynamic> json) {
    return Borsa(
      name: (json['name'] ?? json['title'] ?? 'Bilinmiyor').toString(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      change: double.tryParse(json['rate'].toString()) ?? 0.0,
      currency: json['currency']?.toString() ?? 'TRY',
      time: json['time']?.toString() ?? '-',
    );
  }
}
