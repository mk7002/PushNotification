import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Fetches payload templates from a remote URL (GitHub raw JSON).
class RemotePayloadService {
  RemotePayloadService._internal();
  static final RemotePayloadService _instance = RemotePayloadService._internal();
  factory RemotePayloadService() => _instance;

  /// Fetches and parses a list of payload maps from the given URL.
  /// Returns an empty list on failure.
  Future<List<Map<String, dynamic>>> fetchPayloads(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }
      }
    } catch (e) {
      debugPrint('RemotePayloadService: Error fetching payloads from $url: $e');
    }
    return [];
  }
}
