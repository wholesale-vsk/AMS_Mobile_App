// lib/services/image/image_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ImageService {
  static const String baseUrl = 'http://149.102.154.118:9000/images';
  final Logger _logger = Logger();

  // Fetch all images from the server
  Future<List<String>> getAllImages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        _logger.e('Failed to load images: ${response.statusCode}');
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching images', error: e);
      throw Exception('Error fetching images: $e');
    }
  }

  // Get a specific image by ID or path
  Future<Image> getImage(String imagePath) async {
    final url = '$baseUrl/$imagePath';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return Image.memory(
          response.bodyBytes,
          fit: BoxFit.cover,
        );
      } else {
        _logger.e('Failed to load image: ${response.statusCode}');
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching image', error: e);
      throw Exception('Error fetching image: $e');
    }
  }

  // Upload an image to the server
  Future<bool> uploadImage(List<int> imageBytes, String filename) async {
    try {
      var request = http.MultipartRequest('GET', Uri.parse(baseUrl));

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
      ));

      var response = await request.send();
      final success = response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        _logger.i('Image uploaded successfully: $filename');
      } else {
        _logger.e('Failed to upload image: ${response.statusCode}');
      }

      return success;
    } catch (e) {
      _logger.e('Error uploading image', error: e);
      throw Exception('Error uploading image: $e');
    }
  }

  // Delete an image from the server
  Future<bool> deleteImage(String imagePath) async {
    final url = '$baseUrl/$imagePath';

    try {
      final response = await http.delete(Uri.parse(url));
      final success = response.statusCode == 200;

      if (success) {
        _logger.i('Image deleted successfully: $imagePath');
      } else {
        _logger.e('Failed to delete image: ${response.statusCode}');
      }

      return success;
    } catch (e) {
      _logger.e('Error deleting image', error: e);
      throw Exception('Error deleting image: $e');
    }
  }
}