import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Validates an address using the Nominatim (OpenStreetMap) API.
  ///
  /// Returns `true` if the address is found and considered specific enough,
  /// otherwise returns `false`.
  ///
  /// [address] The full address to validate.
  Future<bool> validateAddress(String address) async {
    if (address.trim().isEmpty) {
      return false;
    }

    final params = {
      'q': address,
      'format': 'json',
      'limit': '1',
      // 'addressdetails': '1', // Uncomment for more detailed response
    };

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

      // Nominatim usage policy requires a custom User-Agent.
      final headers = {
        'User-Agent': 'Softbee Flutter App (for academic project)',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        if (results.isEmpty) {
          // No result found for the address
          // print('Geocoding validation failed for "$address": No results found.');
          return false;
        }

        // A simple check is to see if any result is returned.
        // For a more robust validation, you could inspect the result's properties.
        // For example, Nominatim provides an 'importance' score or 'type' of result.
        // A 'residential' type or a high importance score could indicate a valid address.
        final firstResult = results.first;
        final importance = firstResult['importance'] as double?;

        // print('Geocoding validation for "$address": Found result with importance ${importance ?? 'N/A'}.');

        // We consider the address valid if we get a result with importance > 0.4
        // This is an arbitrary threshold to filter out very generic results.
        // You may need to adjust it based on testing.
        if (importance != null && importance > 0.4) {
          return true;
        } else {
          // Result found, but it might be too generic (e.g., just a city name)
          return false;
        }
      } else {
        // Handle non-200 responses
        // print('Geocoding API request failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle exceptions like network errors
      // print('An error occurred during geocoding validation: $e');
      // In a real app, you might want to re-throw or handle this differently.
      // For this use case, we'll consider it a validation failure.
      return false;
    }
  }
}
