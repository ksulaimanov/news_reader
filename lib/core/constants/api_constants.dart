class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';
  static const String topStories = '/topstories.json';
  static String item(int id) => '/item/$id.json';

  static const int pageSize = 20;
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
