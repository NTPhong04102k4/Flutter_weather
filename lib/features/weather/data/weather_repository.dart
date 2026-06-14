import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/weather.dart';

abstract class WeatherRepository {
  Future<Weather> fetchCurrentWeather(String city);
}

class HttpWeatherRepository implements WeatherRepository {
  HttpWeatherRepository({required http.Client client}) : _client = client;

  final http.Client _client;

  static const _geocodingHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';

  @override
  Future<Weather> fetchCurrentWeather(String city) async {
    final cityName = city.trim();
    if (cityName.isEmpty) {
      throw const WeatherRepositoryException('City must not be empty.');
    }

    final geoUri = Uri.https(_geocodingHost, '/v1/search', {
      'name': cityName,
      'count': '1',
      'language': 'en',
      'format': 'json',
    });
    final geoResponse = await _client.get(geoUri);
    if (geoResponse.statusCode != 200) {
      throw WeatherRepositoryException(
        'Geocoding request failed (${geoResponse.statusCode}).',
      );
    }
    final geoJson = jsonDecode(geoResponse.body) as Map<String, dynamic>;
    final results = geoJson['results'];
    if (results is! List || results.isEmpty) {
      throw WeatherRepositoryException('City not found.');
    }
    final firstResult = results.first as Map<String, dynamic>;
    final latitude = (firstResult['latitude'] as num?)?.toDouble();
    final longitude = (firstResult['longitude'] as num?)?.toDouble();
    final resolvedCity = firstResult['name'] as String? ?? cityName;
    if (latitude == null || longitude == null) {
      throw const WeatherRepositoryException('Invalid location coordinates.');
    }

    final forecastUri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,weather_code',
      'timezone': 'auto',
    });
    final forecastResponse = await _client.get(forecastUri);
    if (forecastResponse.statusCode != 200) {
      throw WeatherRepositoryException(
        'Forecast request failed (${forecastResponse.statusCode}).',
      );
    }
    final forecastJson =
        jsonDecode(forecastResponse.body) as Map<String, dynamic>;
    final current = forecastJson['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const WeatherRepositoryException('Current weather is unavailable.');
    }

    final temperature = (current['temperature_2m'] as num?)?.toDouble();
    final weatherCode = current['weather_code'] as int?;
    final timeRaw = current['time'] as String?;
    if (temperature == null || weatherCode == null || timeRaw == null) {
      throw const WeatherRepositoryException('Malformed weather payload.');
    }

    return Weather(
      city: resolvedCity,
      temperatureC: temperature,
      description: _mapWeatherCode(weatherCode),
      updatedAt: DateTime.tryParse(timeRaw) ?? DateTime.now(),
    );
  }

  String _mapWeatherCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1 || code == 2 || code == 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Drizzle';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}

class WeatherRepositoryException implements Exception {
  const WeatherRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
