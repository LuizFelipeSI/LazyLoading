class Country {
  final String name;
  final String flagUrl;
  final String capital;
  final int population;
  final String region;
  final String currency;

  Country({
    required this.name,
    required this.flagUrl,
    required this.capital,
    required this.population,
    required this.region,
    required this.currency,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    String getCurrencyName(Map<String, dynamic> currenciesJson) {
      if (currenciesJson.isEmpty) return 'N/A';
      final firstKey = currenciesJson.keys.first;
      return currenciesJson[firstKey]['name'] ?? 'N/A';
    }

    return Country(
      name: json['name']['common'] ?? '',
      flagUrl: json['flags']['png'] ?? '',
      capital: (json['capital'] != null && json['capital'].isNotEmpty)
          ? json['capital'][0]
          : 'N/A',
      population: json['population'] ?? 0,
      region: json['region'] ?? '',
      currency: json['currencies'] != null
          ? getCurrencyName(Map<String, dynamic>.from(json['currencies']))
          : 'N/A',
    );
  }
}