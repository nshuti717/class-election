class Weather {
  const Weather({
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.weatherCode,
    required this.time,
  });

  final double temperature;
  final int humidity;
  final double wind;
  final int weatherCode;
  final String time;

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode >= 1 && weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Cloudy';
    if (weatherCode == 45 || weatherCode == 48) return 'Fog';
    if (weatherCode >= 51 && weatherCode <= 57) return 'Drizzle';
    if (weatherCode >= 61 && weatherCode <= 67) return 'Rain';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain showers';
    if (weatherCode >= 95) return 'Thunderstorm';
    return 'Unknown';
  }
}
