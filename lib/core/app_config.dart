class AppConfig {
  // Production Render URL
  static const String _productionUrl = 'https://rkj-fashions.onrender.com/api';

  // Local Dev URL
  // static const String _localUrl = 'http://localhost:3000/api';

  static String get baseUrl {
    return _productionUrl;
  }
}
