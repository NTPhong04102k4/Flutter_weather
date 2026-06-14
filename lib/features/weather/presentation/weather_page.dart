import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/weather.dart';
import 'weather_controller.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final TextEditingController _cityController = TextEditingController(
    text: 'Ho Chi Minh City',
  );

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadWeather);
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    await ref
        .read(weatherControllerProvider.notifier)
        .fetch(_cityController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadWeather(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.isLoading ? null : _loadWeather,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 24),
            if (state.isLoading) const CircularProgressIndicator(),
            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (state.weather != null && !state.isLoading)
              _WeatherCard(weather: state.weather!),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(weather.city, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${weather.temperatureC.toStringAsFixed(1)}°C'),
            Text(weather.description),
            const SizedBox(height: 8),
            Text('Updated: ${weather.updatedAt}'),
          ],
        ),
      ),
    );
  }
}
