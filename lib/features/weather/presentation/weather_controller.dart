import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/weather_repository.dart';
import '../domain/weather.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return HttpWeatherRepository(client: client);
});

final weatherControllerProvider =
    StateNotifierProvider<WeatherController, WeatherViewState>(
      (ref) => WeatherController(ref.read(weatherRepositoryProvider)),
    );

class WeatherViewState {
  const WeatherViewState({
    this.weather,
    this.isLoading = false,
    this.errorMessage,
  });

  final Weather? weather;
  final bool isLoading;
  final String? errorMessage;

  WeatherViewState copyWith({
    Weather? weather,
    bool? isLoading,
    String? errorMessage,
    bool clearWeather = false,
    bool clearError = false,
  }) {
    return WeatherViewState(
      weather: clearWeather ? null : (weather ?? this.weather),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WeatherController extends StateNotifier<WeatherViewState> {
  WeatherController(this._repository) : super(const WeatherViewState());

  final WeatherRepository _repository;

  Future<void> fetch(String city) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final weather = await _repository.fetchCurrentWeather(city);
      state = state.copyWith(
        weather: weather,
        isLoading: false,
        clearError: true,
      );
    } on WeatherRepositoryException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        clearWeather: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Can not load weather right now.',
        clearWeather: true,
      );
    }
  }
}
