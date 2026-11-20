import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';

class AdminService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int nimAdminId = 792 + 162;
  static const String fileName = 'admins.json';
  static const String webStorageKey = 'admins_json';

  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'Browser LocalStorage (Web Chrome)\nKey: "$webStorageKey"';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  static Future<List<dynamic>> _fetchInitialData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) return decoded;
      }
    } catch (_) {}
    return _defaultAdmins;
  }

  static Future<List<dynamic>> _readJsonData() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return jsonDecode(cachedJson) as List<dynamic>;
      }
      final initial = await _fetchInitialData();
      await prefs.setString(webStorageKey, jsonEncode(initial));
      return initial;
    }

    final file = await _getLocalFile();
    if (file != null && await file.exists()) {
      final contents = await file.readAsString();
      if (contents.trim().isNotEmpty) {
        return jsonDecode(contents) as List<dynamic>;
      }
    }
    final initial = await _fetchInitialData();
    if (file != null) {
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(initial));
    }
    return initial;
  }

  static Future<void> _writeJsonData(List<dynamic> admins) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(admins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);
    if (!kIsWeb) {
      final file = await _getLocalFile();
      if (file != null) await file.writeAsString(jsonString);
    }
  }

  static Future<List<Admin>> getAdmins() async {
    final data = await _readJsonData();
    return data
        .map((item) => Admin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<Admin> getAdmin(int id) async {
    final data = await _readJsonData();
    final item = data.cast<Map>().firstWhere(
      (element) => element['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    if (item.isNotEmpty) {
      return Admin.fromJson(Map<String, dynamic>.from(item));
    }
    throw Exception('Data Admin dengan ID $id tidak ditemukan');
  }

  static Future<bool> deleteAdmin(int id) async {
    final data = await _readJsonData();
    final index = data.indexWhere((item) => item['id'] == id);
    if (index == -1) return false;
    data.removeAt(index);
    await _writeJsonData(data);
    return true;
  }

  static final List<Map<String, dynamic>> _defaultAdmins = [
    for (int id = 1; id <= 10; id++)
      {
        'id': id,
        'name': 'Admin $id',
        'email': 'admin$id@example.com',
        'department': 'Information Technology',
      },
  ];
}
