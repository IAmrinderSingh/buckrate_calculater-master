import 'dart:convert';
import 'dart:html';

class WebSessionStorage {
  
  static Storage getAll() {
    return window.sessionStorage;
  }

  static dynamic get(String key) {
    return window.sessionStorage[key];
  }

  static void set({
    required String key,
    required String data,
  }) {
    window.sessionStorage[key] = data;
  }

  static dynamic getStringJson(String key) {
    return jsonDecode(window.sessionStorage[key] ?? "[]");
  }

  static bool setStringJson({
    required String key,
    required dynamic data,
  }) {
    window.sessionStorage[key] = jsonEncode(data);
    return true;
  }

  static removeAKey(String key) {
    window.sessionStorage.remove(key);
  }

  static clearAllData() {
    window.sessionStorage.clear();
  }
}
