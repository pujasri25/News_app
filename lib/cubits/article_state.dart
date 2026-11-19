import '../models/article.dart';

enum ArticleStatus { initial, loading, loaded, error }

class ArticleState {
  final ArticleStatus status;
  final List<Article> articles;
  final String? errorMessage;
  final bool hasMore;
  final bool isLoadingMore;

  const ArticleState({
    this.status = ArticleStatus.initial,
    this.articles = const [],
    this.errorMessage,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ArticleState copyWith({
    ArticleStatus? status,
    List<Article>? articles,
    String? errorMessage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ArticleState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
