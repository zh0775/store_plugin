import 'package:shared_preferences/shared_preferences.dart';

class UserDefault {
  // static Future<bool> saveBool(String key, bool value) async {
  //   userDefault.write("key", {});
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.setBool(key, value);
  // }
  static Future<bool> saveBool(String key, bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(key, value);
  }

  static Future<bool> saveStr(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(key, value);
  }

  static Future<bool> saveStrList(String key, List<String> value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setStringList(key, value);
  }

  static Future<bool> saveInt(String key, int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setInt(key, value);
  }

  static Future<bool> saveDouble(String key, double value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setDouble(key, value);
  }

  static Future<dynamic> get(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }

  static Future<dynamic> removeByKey(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.remove(key);
  }

  // static void set(String key, dynamic data) {
  //   GetStorage().write(key, data);
  //   setToDisk(key, data);
  // }

  // static void setToDisk(String key, dynamic data) async {
  //   await GetStorage().write(key, data);
  // }

  // static dynamic get(String key) {
  //   return GetStorage().read(key);
  // }

  // static Future<dynamic> getToDisk(String key) async {
  //   return await GetStorage().read(key);
  // }
}
