// test/mocks.dart
import 'package:mockito/annotations.dart';
import 'package:paizes/services/pais_service.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([PaisService, http.Client])
void main() {}