class HisseSenedi {
  final double rate;
  final double lastPrice;
  final String lastPriceStr;
  final double hacim;
  final String hacimStr;
  final String text;
  final String code;

  HisseSenedi({
    required this.rate,
    required this.lastPrice,
    required this.lastPriceStr,
    required this.hacim,
    required this.hacimStr,
    required this.text,
    required this.code,
  });

  factory HisseSenedi.fromJson(Map<String, dynamic> json) {
    return HisseSenedi(
      rate: json['rate']?.toDouble() ?? 0.0,
      lastPrice: json['lastprice']?.toDouble() ?? 0.0,
      lastPriceStr: json['lastpricestr'] ?? '',
      hacim: json['hacim']?.toDouble() ?? 0.0,
      hacimStr: json['hacimstr'] ?? '',
      text: json['text'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
