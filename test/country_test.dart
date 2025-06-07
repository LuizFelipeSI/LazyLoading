// test/country_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:paizes/models/country.dart';
import 'package:paizes/services/pais_service.dart';

import 'country_test.mocks.dart';

@GenerateMocks([PaisService, http.Client])
void main() {
  late MockPaisService mockPaisService;

  setUp(() {
    mockPaisService = MockPaisService();
  });

  group('Cenário 01 – Listagem bem-sucedida', () {
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

    test('Deve retornar lista de países não vazia', () async {
      when(mockPaisService.listarPaises())
          .thenAnswer((_) async => mockCountries);

      final result = await mockPaisService.listarPaises();

      expect(result, isNotEmpty);
      verify(mockPaisService.listarPaises()).called(1);
    });

    test('Deve retornar o primeiro país correto com campos válidos', () async {
      when(mockPaisService.listarPaises())
          .thenAnswer((_) async => mockCountries);

      final result = await mockPaisService.listarPaises();
      final firstCountry = result.first;

      expect(firstCountry.name, 'Brasil');
      expect(firstCountry.capital, 'Brasília');
      expect(firstCountry.flagUrl, 'https://flagcdn.com/br.svg');
      expect(firstCountry.population, greaterThan(0));
    });
  });

  group('Cenário 02 – Erro na requisição de países', () {
    test('Deve lançar exceção quando a API falha', () async {
      when(mockPaisService.listarPaises())
          .thenThrow(Exception('Erro na API'));

      expect(() => mockPaisService.listarPaises(), throwsException);
    });
  });

  group('Cenário 03 – Busca de país por nome com resultado', () {
    final mockCountry = Country(
      name: 'Japão',
      flagUrl: 'https://flagcdn.com/jp.svg',
      capital: 'Tóquio',
      population: 125836021,
      region: 'Asia',
      currency: 'Yen',
    );

    test('Deve retornar país não nulo com dados corretos', () async {
      when(mockPaisService.buscarPaisPorNome('Japão'))
          .thenAnswer((_) async => mockCountry);

      final result = await mockPaisService.buscarPaisPorNome('Japão');

      expect(result, isNotNull);
      expect(result?.name, 'Japão');
      expect(result?.capital, 'Tóquio');
      expect(result?.population, 125836021);
    });
  });

  group('Cenário 04 – Busca de país por nome com resultado vazio', () {
    test('Deve retornar null quando país não existe', () async {
      when(mockPaisService.buscarPaisPorNome('Atlântida'))
          .thenAnswer((_) async => null);

      final result = await mockPaisService.buscarPaisPorNome('Atlântida');

      expect(result, isNull);
    });

    test('Deve lançar erro controlado quando país não existe', () async {
      when(mockPaisService.buscarPaisPorNome('Atlântida'))
          .thenThrow(CountryNotFoundException('País não encontrado'));

      expect(() => mockPaisService.buscarPaisPorNome('Atlântida'),
          throwsA(isA<CountryNotFoundException>()));
    });
  });

  group('Cenário 05 – País com dados incompletos', () {
    test('Deve lidar com país sem capital', () async {
      final mockCountry = Country(
        name: 'Nauru',
        flagUrl: 'https://flagcdn.com/nr.svg',
        capital: 'N/A',
        population: 10834,
        region: 'Oceania',
        currency: 'Dólar australiano',
      );

      when(mockPaisService.buscarPaisPorNome('Nauru'))
          .thenAnswer((_) async => mockCountry);

      final result = await mockPaisService.buscarPaisPorNome('Nauru');

      expect(result?.capital, 'N/A');
    });

    test('Deve lidar com país sem bandeira', () async {
      final mockCountry = Country(
        name: 'Vaticano',
        flagUrl: '',
        capital: 'Cidade do Vaticano',
        population: 825,
        region: 'Europe',
        currency: 'Euro',
      );

      when(mockPaisService.buscarPaisPorNome('Vaticano'))
          .thenAnswer((_) async => mockCountry);

      final result = await mockPaisService.buscarPaisPorNome('Vaticano');

      expect(result?.flagUrl, isEmpty);
    });
  });

  group('Cenário 06 – Verificar chamada ao método', () {
    test('Deve verificar se listarPaises() foi chamado', () async {
      when(mockPaisService.listarPaises()).thenAnswer((_) async => []);

      await mockPaisService.listarPaises();

      verify(mockPaisService.listarPaises()).called(1);
    });

    test('Deve verificar se buscarPaisPorNome() foi chamado com parâmetro correto', () async {
      when(mockPaisService.buscarPaisPorNome('Canadá')).thenAnswer((_) async => null);

      await mockPaisService.buscarPaisPorNome('Canadá');

      verify(mockPaisService.buscarPaisPorNome('Canadá')).called(1);
    });
  });

  // CENÁRIOS OPCIONAIS (EXTRA)
  group('Cenário 07 – Simular lentidão da API', () {
    test('Deve lidar com atraso na resposta', () async {
      final mockCountries = [Country(
        name: 'Austrália',
        flagUrl: 'https://flagcdn.com/au.svg',
        capital: 'Canberra',
        population: 25687041,
        region: 'Oceania',
        currency: 'Dólar australiano',
      )];

      when(mockPaisService.listarPaises()).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return mockCountries;
      });

      final future = mockPaisService.listarPaises();
      
      // Verifica se ainda está carregando
      expect(future, isA<Future<List<Country>>>());
      
      final result = await future;
      expect(result, isNotEmpty);
    });
  });

  group('Cenário 08 – Múltiplas chamadas com parâmetros diferentes', () {
    test('Deve lidar com diferentes buscas por nome', () async {
      final mockItaly = Country(
        name: 'Itália',
        flagUrl: 'https://flagcdn.com/it.svg',
        capital: 'Roma',
        population: 59554023,
        region: 'Europe',
        currency: 'Euro',
      );
      
      final mockJapan = Country(
        name: 'Japão',
        flagUrl: 'https://flagcdn.com/jp.svg',
        capital: 'Tóquio',
        population: 125836021,
        region: 'Asia',
        currency: 'Yen',
      );

      when(mockPaisService.buscarPaisPorNome('Itália')).thenAnswer((_) async => mockItaly);
      when(mockPaisService.buscarPaisPorNome('Japão')).thenAnswer((_) async => mockJapan);

      final italy = await mockPaisService.buscarPaisPorNome('Itália');
      final japan = await mockPaisService.buscarPaisPorNome('Japão');

      expect(italy?.name, 'Itália');
      expect(japan?.name, 'Japão');
      
      verifyInOrder([
        mockPaisService.buscarPaisPorNome('Itália'),
        mockPaisService.buscarPaisPorNome('Japão'),
      ]);
    });
  });

  group('Cenário 09 – Filtragem de países', () {
    test('Deve filtrar países por região', () async {
      final mockCountries = [
        Country(
          name: 'Brasil',
          flagUrl: 'https://flagcdn.com/br.svg',
          capital: 'Brasília',
          population: 213993437,
          region: 'Americas',
          currency: 'Real'),
        Country(
          name: 'Argentina',
          flagUrl: 'https://flagcdn.com/ar.svg',
          capital: 'Buenos Aires',
          population: 45376763,
          region: 'Americas',
          currency: 'Peso argentino'),
        Country(
          name: 'Japão',
          flagUrl: 'https://flagcdn.com/jp.svg',
          capital: 'Tóquio',
          population: 125836021,
          region: 'Asia',
          currency: 'Yen'),
      ];

      when(mockPaisService.listarPaises()).thenAnswer((_) async => mockCountries);

      final result = await mockPaisService.listarPaises();
      final americasCountries = result.where((c) => c.region == 'Americas').toList();

      expect(americasCountries, hasLength(2));
      expect(americasCountries[0].name, 'Brasil');
      expect(americasCountries[1].name, 'Argentina');
    });
  });
}

class CountryNotFoundException implements Exception {
  final String message;
  CountryNotFoundException(this.message);
  
  @override
  String toString() => message;
}