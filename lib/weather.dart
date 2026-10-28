import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/weather.dart';

const _weatherUrl =
    'https://api.open-meteo.com/v1/forecast?latitude=-1.9441&longitude=30.0619&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=Africa%2FKigali';

Future<Weather> fetchWeather() async {
  final response = await http
      .get(Uri.parse(_weatherUrl))
      .timeout(const Duration(seconds: 12));
  if (response.statusCode != 200) {
    throw Exception('Weather request failed (${response.statusCode})');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final current = data['current'] as Map<String, dynamic>;
  return Weather(
    temperature: (current['temperature_2m'] as num).toDouble(),
    humidity: (current['relative_humidity_2m'] as num).toInt(),
    wind: (current['wind_speed_10m'] as num).toDouble(),
    weatherCode: (current['weather_code'] as num).toInt(),
    time: current['time'] as String,
  );
}
