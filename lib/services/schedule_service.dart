import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Schedule Service (Frontend Only)
/// Uses local storage (SharedPreferences) to persist classes
/// Backend/Firebase integration will be added after frontend completion
class ScheduleService {
  static const String _keyClasses = 'user_classes';
  static final ScheduleService _instance = ScheduleService._internal();

  factory ScheduleService() {
    return _instance;
  }

  ScheduleService._internal();

  // Convert Color to hex string
  String _colorToHex(Color color) {
    final value = color.value;
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Convert hex string to Color
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  // Save classes to local storage
  Future<void> saveClasses(List<Map<String, dynamic>> classes) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert classes to JSON-serializable format
    final List<Map<String, dynamic>> serializableClasses = classes.map((classItem) {
      final Map<String, dynamic> serializable = Map.from(classItem);
      
      // Convert Color to hex string
      if (serializable['color'] is Color) {
        serializable['color'] = _colorToHex(serializable['color'] as Color);
      }
      
      return serializable;
    }).toList();
    
    final jsonString = jsonEncode(serializableClasses);
    await prefs.setString(_keyClasses, jsonString);
  }

  // Load classes from local storage
  Future<List<Map<String, dynamic>>> loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyClasses);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      
      // Convert back to proper format with Color objects
      return decoded.map((classItem) {
        final Map<String, dynamic> item = Map<String, dynamic>.from(classItem);
        
        // Convert hex string back to Color
        if (item['color'] is String) {
          item['color'] = _hexToColor(item['color'] as String);
        }
        
        return item;
      }).toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  // Clear all classes (for testing/logout)
  Future<void> clearClasses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyClasses);
  }
}

