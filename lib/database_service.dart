import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class DatabaseService {
  // Update this to match your backend server URL
  static const String baseUrl = 'http://localhost:5000';

  // Fetch data from Recon_Summary table
  static Future<Map<String, dynamic>> getReconSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recon-summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload single file
  static Future<Map<String, dynamic>> uploadFile(PlatformFile file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );

      if (file.bytes != null) {
        // For web
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null) {
        // For mobile/desktop
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
          ),
        );
      } else {
        throw Exception('File data not available');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Upload multiple files
  static Future<List<Map<String, dynamic>>> uploadMultipleFiles(
      List<PlatformFile> files) async {
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < files.length; i++) {
      try {
        final result = await uploadFile(files[i]);
        results.add({
          'index': i,
          'filename': files[i].name,
          'success': true,
          'result': result
        });
      } catch (e) {
        results.add({
          'index': i,
          'filename': files[i].name,
          'success': false,
          'error': e.toString()
        });
      }
    }

    return results;
  }

  // Start processing
  static Future<Map<String, dynamic>> startProcessing() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/start-processing'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Processing failed to start');
      }
    } catch (e) {
      throw Exception('Processing error: $e');
    }
  }

  // Get processing status
  static Future<Map<String, dynamic>> getProcessingStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/processing-status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Status error: $e');
    }
  }

  // Refresh data
  static Future<Map<String, dynamic>> refreshData() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to refresh: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Refresh error: $e');
    }
  }

  // Get uploaded files
  static Future<Map<String, dynamic>> getUploadedFiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/uploaded-files'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Files error: $e');
    }
  }

  // Delete file
  static Future<Map<String, dynamic>> deleteFile(String filename) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-file/$filename'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Delete failed');
      }
    } catch (e) {
      throw Exception('Delete error: $e');
    }
  }

  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Health check error: $e');
    }
  }
}
