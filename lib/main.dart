// main.dart

import 'package:flutter/material.dart';
import 'pages/country_list_page.dart';

void main() {
  runApp(MyApp());
}

/// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Países do Mundo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: CountryListPage(),
    );
  }
}