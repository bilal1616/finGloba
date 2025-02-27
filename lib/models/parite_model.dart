class Parite {
  final String name;
  final String text;
  final double buying;
  final double selling;
  final double rate;
  final String time;
  final String date;

  Parite({
    required this.name,
    required this.text,
    required this.buying,
    required this.selling,
    required this.rate,
    required this.time,
    required this.date,
  });

  factory Parite.fromJson(Map<String, dynamic> json) {
    return Parite(
      name: json['name'] ?? '',
      text: json['text'] ?? '',
      buying: double.tryParse(json['buying'].toString()) ?? 0.0,
      selling: double.tryParse(json['selling'].toString()) ?? 0.0,
      rate: double.tryParse(json['rate'].toString()) ?? 0.0,
      time: json['time'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
