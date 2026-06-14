import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather/features/weather/data/weather_repository.dart';
import 'package:weather/features/weather/domain/weather.dart';
import 'package:weather/features/weather/presentation/weather_controller.dart';
import 'package:weather/features/weather/presentation/weather_page.dart';

class _SuccessRepository implements WeatherRepository {
  @override
  Future<Weather> fetchCurrentWeather(String city) async {
    return Weather(
      city: city,
      temperatureC: 28.0,
      description: 'Clear sky',
      updatedAt: DateTime(2026, 4, 9, 7, 0),
    );
  }
}

class _FailureRepository implements WeatherRepository {
  @override
  Future<Weather> fetchCurrentWeather(String city) async {
    throw const WeatherRepositoryException('City not found.');
  }
}

void main() {
  testWidgets('renders weather data from repository', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(_SuccessRepository()),
        ],
        child: const MaterialApp(home: WeatherPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Ho Chi Minh City'), findsNWidgets(2));
    expect(find.text('28.0°C'), findsOneWidget);
    expect(find.text('Clear sky'), findsOneWidget);
  });

  testWidgets('renders error message when repository fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(_FailureRepository()),
        ],
        child: const MaterialApp(home: WeatherPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('City not found.'), findsOneWidget);
  });
}
