import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../services/pais_service.dart';
import 'country_detail_page.dart';

class CountryListPage extends StatefulWidget {
  final PaisService? service;

  const CountryListPage({Key? key, this.service}) : super(key: key);

  @override
  CountryListPageState createState() => CountryListPageState(service: service);
}

class CountryListPageState extends State<CountryListPage> {
  List<Country> allCountries = [];
  int currentPage = 0;
  final int perPage = 10;
  late final PaisService paisService;
  bool isLoading = true;
  String? errorMessage;

  CountryListPageState({PaisService? service}) {
    paisService = service ?? PaisService(client: http.Client());
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final countries = await paisService.listarPaises();
      setState(() {
        allCountries = countries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar países: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  List<Country> get pagedCountries {
    final start = currentPage * perPage;
    final end = (currentPage + 1) * perPage;
    return allCountries.sublist(
      start,
      end > allCountries.length ? allCountries.length : end,
    );
  }

  void nextPage() {
    if ((currentPage + 1) * perPage < allCountries.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('country_list_app_bar'),
        title: const Text('Países do Mundo'), 
        centerTitle: true
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(key: const Key('loading_indicator')))
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        key: const Key('country_list_view'),
                        itemCount: pagedCountries.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final country = pagedCountries[index];
                          return Card(
                            key: Key('country_card_${country.name}'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              key: Key('country_tile_${country.name}'),
                              contentPadding: const EdgeInsets.all(12),
                              leading: SizedBox(
                                width: 60,
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    country.flagUrl,
                                    fit: BoxFit.cover,
                                    key: Key('country_list_flag_${country.name}'),
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey,
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                country.name,
                                key: Key('country_name_${country.name}'),
                                style: const TextStyle(
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
                        key: const Key('pagination_controls'),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            key: const Key('previous_page_button'),
                            onPressed: previousPage,
                            child: const Text('Anteriores'),
                          ),
                          Text(
                            'Página ${currentPage + 1}',
                            key: const Key('page_number_text'),
                            style: const TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                            key: const Key('next_page_button'),
                            onPressed: nextPage,
                            child: const Text('Próximos'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}