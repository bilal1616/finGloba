class Crypto {
  final String name;
  final String code;
  final String currency;
  final double price;
  final double changeDay;
  final double changeWeek;
  final double changeHour;
  final double volume;
  final String circulatingSupply;
  final double marketCap;

  Crypto({
    required this.name,
    required this.code,
    required this.currency,
    required this.price,
    required this.changeDay,
    required this.changeWeek,
    required this.changeHour,
    required this.volume,
    required this.circulatingSupply,
    required this.marketCap,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: (json['name'] ?? 'Bilinmiyor').toString(),
      code: (json['code'] ?? '---').toString(),
      currency: (json['currency'] ?? 'USD').toString(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      changeDay: double.tryParse(json['changeDay'].toString()) ?? 0.0,
      changeWeek: double.tryParse(json['changeWeek'].toString()) ?? 0.0,
      changeHour: double.tryParse(json['changeHour'].toString()) ?? 0.0,
      volume: double.tryParse(json['volume'].toString()) ?? 0.0,
      circulatingSupply: (json['circulatingSupply'] ?? 'Bilinmiyor').toString(),
      marketCap: double.tryParse(json['marketCap'].toString()) ?? 0.0,
    );
  }
}
