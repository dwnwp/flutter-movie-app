import 'package:flutter_dotenv/flutter_dotenv.dart';

String apikey = dotenv.env['TMDB_API_KEY'] ?? '';

Map<String, String> get apiHeaders => {
      'Authorization': 'Bearer $apikey',
      'accept': 'application/json',
    };
