import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  AppCache._();

  static Future<bool> saveValue<T>(String key, T value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (T) {
      case String:
        return prefs.setString(key, value as String);
      case int:
        return prefs.setInt(key, value as int);
      case double:
        return prefs.setDouble(key, value as double);
      case bool:
        return prefs.setBool(key, value as bool);
      case List:
        return prefs.setStringList(key, List.generate((value as List).length, (index) => (value as List)[index].toString()).toList());
    }
    return false;
  }

  static Future<T> getValue<T>(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key) as T;
    } else {
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  static Future<void> secureSaveValue(String key, String value,{IOSOptions iosOptions,AndroidOptions androidOptions}) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.write(key: key, value: value,iOptions: iosOptions,aOptions: androidOptions);
  }

  static Future<String> secureGetValue(String key,{IOSOptions iosOptions,AndroidOptions androidOptions}) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.read(key: key,iOptions: iosOptions,aOptions: androidOptions);
  }

  static Future<void> secureRemove(String key,{IOSOptions iosOptions,AndroidOptions androidOptions}) async {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.delete(key: key,iOptions: iosOptions,aOptions: androidOptions);
  }

}
