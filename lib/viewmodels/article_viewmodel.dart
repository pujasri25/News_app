import 'package:flutter/material.dart';
import '../models/article.dart';
import '../repositories/article_repository.dart';

enum ViewState { initial, loading, loaded, error, loadingMore }

class ArticleViewModel extends ChangeNotifier {
  final ArticleRepository _repository = ArticleRepository();

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchArticles({bool isRefresh = false}) async {
    if (isRefresh) {
      _offset = 0;
      _articles = [];
      _hasMore = true;
      _state = ViewState.loading;
    } else if (_state == ViewState.initial) {
      _state = ViewState.loading;
    } else {
      _state = ViewState.loadingMore;
    }
    
    notifyListeners();

    try {
      final response = await _repository.fetchArticles(
        limit: _limit,
        offset: _offset,
        search: _searchQuery,
      );

      if (isRefresh) {
        _articles = response.results;
      } else {
        _articles.addAll(response.results);
      }

      _offset += _limit;
      _hasMore = response.next != null;
      _state = ViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  void searchArticles(String query) {
    _searchQuery = query;
    fetchArticles(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (_state == ViewState.loadingMore || !_hasMore) return;
    await fetchArticles();
  }
}
