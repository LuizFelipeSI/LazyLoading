import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class PaisService {
  static const String _baseUrl = 'https://restcountries.com/v3.1/independent?status=true&fields=capital,name,flags,population,region,currencies,png';
  final http.Client client;

  PaisService({required this.client});

  Future<List<Country>> listarPaises() async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/independent?status=true&fields=capital,name,flags,population,region,currencies,png')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        throw Exception('Falha ao carregar países: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<Country?> buscarPaisPorNome(String nome) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/name/$nome?fields=capital,name,flags,population,region,currencies,png')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Country.fromJson(data[0]);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Falha ao buscar país: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}