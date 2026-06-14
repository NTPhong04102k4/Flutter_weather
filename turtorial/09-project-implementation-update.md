# Cap nhat da implement trong du an

- Da noi API that bang Open-Meteo:
  - Geocoding API (`city -> lat/lon`)
  - Forecast API (`temperature_2m`, `weather_code`)
- Da ap dung Riverpod:
  - `weatherRepositoryProvider`
  - `weatherControllerProvider`
- Da viet test module weather:
  - `test/features/weather/data/weather_repository_test.dart`
  - `test/features/weather/presentation/weather_page_test.dart`
