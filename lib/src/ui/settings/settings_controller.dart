import 'package:bossa/src/url/http_requester.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool _gradient = true;
  String _selectedLanguageCode = 'en'; // Default to English
  String _selectedCountryCode = 'US'; // Default to US
  String _youTubeProvider = 'youtube_explode';
  String _providerInstanceUrl = '';
  SharedPreferences? _prefs;
  bool get gradient => _gradient;

  String get selectedLanguageCode => _selectedLanguageCode;
  String get selectedCountryCode => _selectedCountryCode;
  String get selectedLocale => '${_selectedLanguageCode}_$_selectedCountryCode';
  String get youTubeProvider => _youTubeProvider;
  String get providerInstanceUrl => _providerInstanceUrl;

  void setGradientOnPlayer(bool newValue) {
    _gradient = newValue;
    notifyListeners();
  }

  Future<void> setSelectedLanguage(
      String languageCode, String countryCode) async {
    _selectedLanguageCode = languageCode;
    _selectedCountryCode = countryCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', languageCode);
    await prefs.setString('selectedCountryCode', countryCode);

    notifyListeners();
  }

  Future<void> loadLanguageSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguageCode = _prefs!.getString('selectedLanguageCode') ?? 'en';
    _selectedCountryCode = _prefs!.getString('selectedCountryCode') ?? 'US';
    _youTubeProvider = _prefs!.getString('youTubeProvider') ?? 'youtube_explode';
    _providerInstanceUrl = _prefs!.getString('providerInstanceUrl') ?? '';
    notifyListeners();
  }

  Future<void> setYouTubeProvider(
      String provider, String instanceUrl) async {
    _youTubeProvider = provider;
    _providerInstanceUrl = instanceUrl;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('youTubeProvider', provider);
    await prefs.setString('providerInstanceUrl', instanceUrl);

    notifyListeners();
  }

  Future<void> loadYouTubeProviderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _youTubeProvider = prefs.getString('youTubeProvider') ?? 'youtube_explode';
    _providerInstanceUrl = prefs.getString('providerInstanceUrl') ?? '';
    notifyListeners();
  }

  double _stringVersionParse(String version) {
    String output = version.replaceAll('v', '');
    List<String> splittedOutput = output.split('.');
    output =
        '${splittedOutput[0]}.${splittedOutput.join().replaceFirst(splittedOutput[0], "")}';
    return double.parse(output);
  }

  Future<bool> hasUpdate() async {
    dynamic results = await HttpRequester().retriveFromUrl(
        'https://api.github.com/repos/BarbosaRT/Bossa/releases');
    List<dynamic> resultsList = results as List<dynamic>;
    List<Map<String, dynamic>> versions = [];

    for (var result in resultsList) {
      versions.add(result as Map<String, dynamic>);
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    double version = _stringVersionParse(packageInfo.version);
    double latestVersion =
        _stringVersionParse(versions[0]["tag_name"] as String);

    if (latestVersion > version) {
      return true;
    }
    return false;
  }
}
