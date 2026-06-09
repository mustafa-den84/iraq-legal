import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'ar';
  
  String get currentLang => _currentLang;
  
  bool get isRtl => _currentLang == 'ar' || _currentLang == 'ku';
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('lang') ?? 'ar';
    notifyListeners();
  }
  
  Future<void> setLanguage(String lang) async {
    _currentLang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    notifyListeners();
  }
  
  void toggleLanguage() {
    if (_currentLang == 'ar') {
      setLanguage('ku');
    } else if (_currentLang == 'ku') {
      setLanguage('en');
    } else {
      setLanguage('ar');
    }
  }
}
