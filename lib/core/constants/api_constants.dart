class ApiConstants {
  // Ganti URL ini dengan URL backend yang sedang berjalan
  static const String baseUrl = 'http://10.0.2.2:5000';

  static const String shoes      = '$baseUrl/shoes';
  static const String chat       = '$baseUrl/chat';
  static const String authLogin  = '$baseUrl/auth/login';
  static const String authLogout = '$baseUrl/auth/logout';
  static const String authMe     = '$baseUrl/auth/me';

  static String chatHistory(String sessionId) =>
      '$baseUrl/chat/history/$sessionId';
  static String shoeDetail(int id) => '$baseUrl/shoes/$id';
}
