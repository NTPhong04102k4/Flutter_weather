class Weather {
  const Weather({
    required this.city,
    required this.temperatureC,
    required this.description,
    required this.updatedAt,
  });

  final String city;
  final double temperatureC;
  final String description;
  final DateTime updatedAt;
}
