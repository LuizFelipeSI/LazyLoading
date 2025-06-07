import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../services/pais_service.dart';
import 'country_detail_page.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<Country> _allCountries = [];
  int _currentPage = 0;
  final int _perPage = 10;
  final PaisService _paisService = PaisService(client: http.Client());
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final countries = await _paisService.listarPaises();
      setState(() {
        _allCountries = countries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar países: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Country> get _pagedCountries {
    final start = _currentPage * _perPage;
    final end = (_currentPage + 1) * _perPage;
    return _allCountries.sublist(
      start,
      end > _allCountries.length ? _allCountries.length : end,
    );
  }

  void _nextPage() {
    if ((_currentPage + 1) * _perPage < _allCountries.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Países do Mundo'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _pagedCountries.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemBuilder: (context, index) {
                          final country = _pagedCountries[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  country.flagUrl,
                                  width: 60,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                country.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CountryDetailPage(country),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _previousPage,
                            child: Text('Anteriores'),
                          ),
                          Text(
                            'Página ${_currentPage + 1}',
                            style: TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                            onPressed: _nextPage,
                            child: Text('Próximos'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}