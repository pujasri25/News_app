import '../models/article.dart';
import '../services/api_service.dart';

class ArticleRepository {
  final ApiService _apiService = ApiService();

  Future<ArticleResponse> fetchArticles({int limit = 10, int offset = 0, String? search}) {
    return _apiService.getArticles(limit: limit, offset: offset, search: search);
  }
}
