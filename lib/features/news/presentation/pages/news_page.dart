import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../widgets/article_card.dart';
import '../widgets/error_view.dart';
import '../widgets/load_more_footer.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>()..add(const NewsStarted()),
      child: const NewsView(),
    );
  }
}

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final bloc = context.read<NewsBloc>();
      // После ошибки автоподгрузку не запускаем: ждём нажатия «Повторить».
      if (bloc.state.failure == null) {
        bloc.add(const NewsLoadMoreRequested());
      }
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<NewsBloc>();
    final completer = Completer<void>();
    bloc.add(NewsRefreshed(completer: completer));
    await completer.future;

    if (!mounted) return;
    final failure = bloc.state.failure;
    if (failure != null) {
      _showMessage('Не удалось обновить: ${failure.message}');
    }
  }

  Future<void> _openArticle(Article article) async {
    final uri = Uri.tryParse(article.url ?? '') ??
        Uri.parse('https://news.ycombinator.com/item?id=${article.id}');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _showMessage('Не удалось открыть ссылку');
    } catch (_) {
      if (mounted) _showMessage('Не удалось открыть ссылку');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hacker News')),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          return switch (state.status) {
            NewsStatus.initial ||
            NewsStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            NewsStatus.failure => ErrorView(
                failure: state.failure ?? const UnknownFailure(),
                onRetry: () =>
                    context.read<NewsBloc>().add(const NewsStarted()),
              ),
            NewsStatus.success => _buildList(state),
          };
        },
      ),
    );
  }

  Widget _buildList(NewsState state) {
    if (state.articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(child: Text('Пока нет новостей. Потяните вниз, чтобы обновить')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: state.articles.length + 1,
        itemBuilder: (context, index) {
          if (index < state.articles.length) {
            final article = state.articles[index];
            return ArticleCard(
              article: article,
              onTap: () => _openArticle(article),
            );
          }
          return LoadMoreFooter(
            isLoading: state.isLoadingMore,
            hasReachedEnd: state.hasReachedEnd,
            failure: state.failure,
            onRetry: () =>
                context.read<NewsBloc>().add(const NewsLoadMoreRequested()),
          );
        },
      ),
    );
  }
}
