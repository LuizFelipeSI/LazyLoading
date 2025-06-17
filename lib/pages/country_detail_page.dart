import 'package:flutter/material.dart';
import '../models/country.dart';

class CountryDetailPage extends StatelessWidget {
  final Country country;

  const CountryDetailPage(this.country, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          key: const Key('country_detail_column'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 120,
              child: Image.network(
                country.flagUrl,
                key: const Key('country_flag_image'),
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Capital: ${country.capital}',
              key: const Key('capital_text'),
            ),
            const SizedBox(height: 10),
            Text(
              'Região: ${country.region}',
              key: const Key('region_text'),
            ),
            const SizedBox(height: 10),
            Text(
              'População: ${country.population}',
              key: const Key('population_text'),
            ),
            const SizedBox(height: 10),
            Text(
              'Moeda: ${country.currency}',
              key: const Key('currency_text'),
            ),
          ],
        ),
      ),
    );
  }
}