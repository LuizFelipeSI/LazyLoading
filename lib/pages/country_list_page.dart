import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';
import 'country_detail_page.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<Country> _allCountries = [];
  int _currentPage = 0;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _allCountries = jsonData
            .map((countryJson) => Country.fromJson(countryJson))
            .toList();
        _allCountries.sort((a, b) => a.name.compareTo(b.name));
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
      appBar: AppBar(
        title: Text('Países do Mundo'),
        centerTitle: true,
      ),
      body: _allCountries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _pagedCountries.length,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      ElevatedButton.icon(
                        onPressed: _previousPage,
                        icon: Icon(Icons.arrow_back),
                        label: Text('Anteriores'),
                      ),
                      Text('Página ${_currentPage + 1}',
                          style: TextStyle(fontSize: 16)),
                      ElevatedButton.icon(
                        onPressed: _nextPage,
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Próximos'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}