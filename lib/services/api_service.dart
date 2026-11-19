import 'package:dio/dio.dart';
import '../models/article.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.spaceflightnewsapi.net/v4',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<ArticleResponse> getArticles({int limit = 10, int offset = 0, String? search}) async {
    try {
      final response = await _dio.get('/articles/', queryParameters: {
        'limit': limit,
        'offset': offset,
        if (search != null && search.isNotEmpty) 'title_contains': search,
      });

      return ArticleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timed out. Please check your internet connection.";
    }
    if (e.type == DioExceptionType.connectionError) {
      return "No internet connection. Please check your network and try again.";
    }
    if (e.type == DioExceptionType.badResponse) {
      return "Server error (${e.response?.statusCode}). Please try again later.";
    }
    return "No internet connection. Please check your network and try again.";
  }
}
