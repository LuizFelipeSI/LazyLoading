import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paizes/models/country.dart';
import 'package:paizes/pages/country_detail_page.dart';

void main() {
  final testCountry = Country(
    name: 'Test Country',
    flagUrl: 'https://flagcdn.com/test.svg',
    capital: 'Test Capital',
    population: 1000000,
    region: 'Test Region',
    currency: 'Test Currency',
  );

  testWidgets('CountryDetailPage displays correct information',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CountryDetailPage(testCountry),
      ),
    );

    expect(find.text('Test Country'), findsOneWidget);
    expect(find.byKey(const Key('country_flag_image')), findsOneWidget);
    expect(find.text('Capital: Test Capital'), findsOneWidget);
    expect(find.text('Região: Test Region'), findsOneWidget);
    expect(find.text('População: 1000000'), findsOneWidget);
    expect(find.text('Moeda: Test Currency'), findsOneWidget);
  });
}