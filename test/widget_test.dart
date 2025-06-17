import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:paizes/models/country.dart';
import 'package:paizes/pages/country_detail_page.dart';
import 'package:paizes/pages/country_list_page.dart';
import 'package:paizes/services/pais_service.dart';
import 'dart:typed_data';

import 'widget_test.mocks.dart';

@GenerateMocks([PaisService, http.Client])
void main() {
  late MockPaisService mockPaisService;
  final mockCountries = [
    Country(
      name: 'Brasil',
      flagUrl: 'https://flagcdn.com/br.svg',
      capital: 'Brasília',
      population: 213993437,
      region: 'Americas',
      currency: 'Real',
    ),
    Country(
      name: 'Argentina',
      flagUrl: 'https://flagcdn.com/ar.svg',
      capital: 'Buenos Aires',
      population: 45376763,
      region: 'Americas',
      currency: 'Peso argentino',
    ),
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockPaisService = MockPaisService();
    when(mockPaisService.listarPaises()).thenAnswer((_) async => mockCountries);
  });

  testWidgets('Cenário 01 – Verificar se o nome do país é carregado no componente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CountryListPage(service: mockPaisService),
      ),
    );

    await tester.pump();
    expect(find.text('Brasil'), findsOneWidget);
    expect(find.text('Argentina'), findsOneWidget);
    expect(find.byKey(const Key('country_name_Brasil')), findsOneWidget);
    expect(find.byKey(const Key('country_name_Argentina')), findsOneWidget);
  });

  testWidgets('Cenário 02 – Verificar se ao clicar em um país os dados são abertos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CountryListPage(service: mockPaisService),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('country_tile_Brasil')));
    await tester.pumpAndSettle();

    expect(find.text('Brasil'), findsOneWidget);
    expect(find.byType(CountryDetailPage), findsOneWidget);
  });

  testWidgets('Cenário 03 – Verificar se um componente de imagem é carregado com a bandeira',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CountryListPage(service: mockPaisService),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('country_list_flag_Brasil')), findsOneWidget);
    expect(find.byKey(const Key('country_list_flag_Argentina')), findsOneWidget);
  });

  testWidgets('Test loading state', (WidgetTester tester) async {
    when(mockPaisService.listarPaises()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return mockCountries;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CountryListPage(service: mockPaisService),
      ),
    );

    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loading_indicator')), findsNothing);
    expect(find.byKey(const Key('country_list_view')), findsOneWidget);
  });

  testWidgets('Test error state', (WidgetTester tester) async {
    when(mockPaisService.listarPaises()).thenThrow(Exception('Test error'));

    await tester.pumpWidget(
      MaterialApp(
        home: CountryListPage(service: mockPaisService),
      ),
    );

    await tester.pump();
    expect(find.text('Erro ao carregar países: Exception: Test error'), findsOneWidget);
  });
}