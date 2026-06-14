import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather/features/weather/data/weather_repository.dart';

void main() {
  group('HttpWeatherRepository', () {
    test('returns weather when API payload is valid', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return http.Response('''
            {
              "results":[{"name":"Ho Chi Minh City","latitude":10.75,"longitude":106.67}]
            }
            ''', 200);
        }
        return http.Response('''
          {
            "current": {
              "temperature_2m": 30.2,
              "weather_code": 3,
              "time": "2026-04-09T01:00"
            }
          }
          ''', 200);
      });

      final repository = HttpWeatherRepository(client: client);
      final weather = await repository.fetchCurrentWeather('Ho Chi Minh City');

      expect(weather.city, 'Ho Chi Minh City');
      expect(weather.temperatureC, 30.2);
      expect(weather.description, 'Partly cloudy');
    });

    test('throws when city not found', () async {
      final client = MockClient(
        (_) async => http.Response('{"results":[]}', 200),
      );
      final repository = HttpWeatherRepository(client: client);

      expect(
        () => repository.fetchCurrentWeather('Unknown'),
        throwsA(isA<WeatherRepositoryException>()),
      );
    });
  });
}
