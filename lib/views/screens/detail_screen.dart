import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cubits/article_cubit.dart';
import '../../cubits/article_state.dart';
import '../../models/article.dart';

class DetailScreen extends StatefulWidget {
  final int initialIndex;

  const DetailScreen({super.key, required this.initialIndex});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch article URL')),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildPublisherLogo(String newsSite) {
    String displayInitial = newsSite.isNotEmpty ? newsSite.substring(0, 1).toUpperCase() : 'N';
    if (newsSite.toLowerCase().contains('cnn')) {
      displayInitial = 'CNN';
    } else if (newsSite.length >= 3 && !newsSite.contains(' ')) {
      displayInitial = newsSite.substring(0, 3).toUpperCase();
    }

    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFCC0000),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayInitial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: displayInitial.length > 2 ? 10 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ArticleCubit, ArticleState>(
        builder: (context, state) {
          return PageView.builder(
            controller: _pageController,
            itemCount: state.articles.length + (state.hasMore ? 1 : 0),
            onPageChanged: (index) {
              if (index >= state.articles.length - 1 && state.hasMore) {
                context.read<ArticleCubit>().loadMore();
              }
            },
            itemBuilder: (context, index) {
              if (index == state.articles.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final article = state.articles[index];
              return _buildArticleDetail(context, article);
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleDetail(BuildContext context, Article article) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.52;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            children: [
              // Cover Image
              CachedNetworkImage(
                imageUrl: article.imageUrl,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: imageHeight,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: imageHeight,
                  color: Colors.grey[400],
                  child: const Icon(Icons.broken_image, size: 60, color: Colors.white54),
                ),
              ),

              // Dark Gradient Overlay
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),

              // Top Bar Floating Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: _buildCircleIconButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // Category, Title & Meta Information Overlay
              Positioned(
                left: 20,
                right: 20,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge / News Site Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.newsSite,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Meta Info (Trending & Time)
                    Text(
                      'Trending • ${_formatTimeAgo(article.publishedAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Content Sheet
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher Info Row
                  Row(
                    children: [
                      _buildPublisherLogo(article.newsSite),
                      const SizedBox(width: 10),
                      Text(
                        article.newsSite,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF1E88E5),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Article Summary Body Text
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Full Article Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _launchUrl(article.url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Read Full Article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
