import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/article_cubit.dart';
import '../../cubits/article_state.dart';
import '../widgets/article_card.dart';
import '../widgets/article_grid_card.dart';
import 'detail_screen.dart';

const double _kTabletBreakpoint = 600;

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleCubit>().fetchArticles();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ArticleCubit>().loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ArticleCubit>().searchArticles(query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle Text
                  Text(
                    'News from all around the world',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Input Field Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey[500], size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth >= _kTabletBreakpoint;
                  return BlocConsumer<ArticleCubit, ArticleState>(
                    listener: (context, state) {
                      if (state.status == ArticleStatus.loaded) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _onScroll());
                      }
                    },
                    builder: (context, state) {
                      return _buildBody(context, state, isTablet, constraints.maxWidth);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ArticleState state,
    bool isTablet,
    double maxWidth,
  ) {
    if (state.status == ArticleStatus.loading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ArticleStatus.error && state.articles.isEmpty) {
      final isNoInternet =
          state.errorMessage?.toLowerCase().contains('no internet') ?? false;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                  size: 56,
                  color: const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isNoInternet ? 'No Internet Connection' : 'Something Went Wrong',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ??
                    'Please check your network settings and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 150,
                height: 46,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<ArticleCubit>().fetchArticles(isRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.articles.isEmpty) {
      return const Center(child: Text('No articles found.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ArticleCubit>().fetchArticles(isRefresh: true),
      child: isTablet
          ? _buildGrid(context, state, maxWidth)
          : _buildList(context, state),
    );
  }

  void _openDetail(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(initialIndex: index),
      ),
    );
  }

  Widget _buildList(BuildContext context, ArticleState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final article = state.articles[index];
        return ArticleCard(
          article: article,
          onTap: () => _openDetail(context, index),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, ArticleState state, double maxWidth) {
    final crossAxisCount = maxWidth >= 900 ? 3 : 2;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final article = state.articles[index];
        return ArticleGridCard(
          article: article,
          onTap: () => _openDetail(context, index),
        );
      },
    );
  }
}
