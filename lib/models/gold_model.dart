class Gold {
  final String name;
  final double buying;
  final double selling;

  Gold({required this.name, required this.buying, required this.selling});

  factory Gold.fromJson(Map<String, dynamic> json) => Gold(
        name: json['name'],
        buying: double.parse(json['buying'].toString()),
        selling: double.parse(json['selling'].toString()),
      );
}
