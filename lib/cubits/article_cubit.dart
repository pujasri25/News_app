import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/article_repository.dart';
import 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticleRepository _repository = ArticleRepository();

  int _offset = 0;
  final int _limit = 10;
  String _searchQuery = '';

  ArticleCubit() : super(const ArticleState());

  Future<void> fetchArticles({bool isRefresh = false}) async {
    if (isRefresh) {
      _offset = 0;
      emit(state.copyWith(
        status: state.articles.isEmpty ? ArticleStatus.loading : state.status,
        hasMore: true,
      ));
    } else if (state.status == ArticleStatus.initial) {
      emit(state.copyWith(status: ArticleStatus.loading));
    } else {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));
    }

    try {
      final response = await _repository.fetchArticles(
        limit: _limit,
        offset: _offset,
        search: _searchQuery,
      );

      final newArticles = isRefresh
          ? response.results
          : [...state.articles, ...response.results];

      _offset += _limit;

      emit(state.copyWith(
        status: ArticleStatus.loaded,
        articles: newArticles,
        hasMore: response.next != null,
        isLoadingMore: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.articles.isEmpty ? ArticleStatus.error : ArticleStatus.loaded,
        errorMessage: e.toString(),
        isLoadingMore: false,
      ));
    }
  }

  void searchArticles(String query) {
    _searchQuery = query;
    fetchArticles(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await fetchArticles();
  }
}
