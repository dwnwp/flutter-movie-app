import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:review888/function/slider.dart';
import 'package:review888/function/review.dart';
import 'package:review888/Homepage/Homepage.dart';
import 'package:review888/function/trailerui.dart';
import 'package:review888/apikey/api.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class TvSeriesDetails extends StatefulWidget {
  var id;
  TvSeriesDetails({super.key, this.id});
  @override
  State<TvSeriesDetails> createState() => _TvSeriesDetailsState();
}

class _TvSeriesDetailsState extends State<TvSeriesDetails> {
  Map<String, dynamic> detail = {};
  List genres = [];
  List creators = [];
  List seasons = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> similarList = [];
  List<Map<String, dynamic>> recommendList = [];
  List<Map<String, dynamic>> trailers = [];
  late Future<void> _detailFuture;

  Future<void> _fetchDetails() async {
    final base = 'https://api.themoviedb.org/3/tv/${widget.id}';
    final responses = await Future.wait([
      http.get(Uri.parse('$base'), headers: apiHeaders),
      http.get(Uri.parse('$base/reviews'), headers: apiHeaders),
      http.get(Uri.parse('$base/similar'), headers: apiHeaders),
      http.get(Uri.parse('$base/recommendations'), headers: apiHeaders),
      http.get(Uri.parse('$base/videos'), headers: apiHeaders),
    ]);

    if (responses[0].statusCode == 200) {
      var d = jsonDecode(responses[0].body);
      detail = {
        'title': d['original_name'], 'vote_average': d['vote_average'],
        'overview': d['overview'], 'status': d['status'],
        'releasedate': d['first_air_date'], 'backdrop_path': d['backdrop_path'],
      };
      genres = (d['genres'] as List).map((g) => g['name']).toList();
      creators = (d['created_by'] as List).map((c) => {
        'name': c['name'], 'profile_path': c['profile_path'],
      }).toList();
      seasons = (d['seasons'] as List).map((s) => {
        'name': s['name'], 'episode_count': s['episode_count'],
        'poster_path': s['poster_path'],
      }).toList();
    }

    if (responses[1].statusCode == 200) {
      for (var r in jsonDecode(responses[1].body)['results']) {
        reviews.add({
          'name': r['author'], 'review': r['content'],
          'rating': r['author_details']['rating']?.toString() ?? 'N/A',
          'avatarphoto': r['author_details']['avatar_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${r['author_details']['avatar_path']}'
              : 'https://www.gravatar.com/avatar/?d=mp',
          'creationdate': r['created_at'].substring(0, 10),
        });
      }
    }

    if (responses[2].statusCode == 200) {
      for (var s in jsonDecode(responses[2].body)['results']) {
        similarList.add({'poster_path': s['poster_path'], 'name': s['original_name'],
          'vote_average': s['vote_average'], 'id': s['id'], 'Date': s['first_air_date']});
      }
    }

    if (responses[3].statusCode == 200) {
      for (var r in jsonDecode(responses[3].body)['results']) {
        recommendList.add({'poster_path': r['poster_path'], 'name': r['original_name'],
          'vote_average': r['vote_average'], 'id': r['id'], 'Date': r['first_air_date']});
      }
    }

    if (responses[4].statusCode == 200) {
      for (var v in jsonDecode(responses[4].body)['results']) {
        if (v['type'] == 'Trailer') trailers.add({'key': v['key']});
      }
      if (trailers.isEmpty) trailers.add({'key': 'aJ0cZTcTh90'});
    }
  }

  @override
  void initState() { super.initState(); _detailFuture = _fetchDetails(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppColors.surface.withAlpha(200),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.movie_filter_rounded, color: AppColors.accent, size: 24),
          const SizedBox(width: 8), const Text('FlixSphere'),
        ]),
        centerTitle: true, automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () => Navigator.pop(context),
          icon: const FaIcon(FontAwesomeIcons.circleArrowLeft), iconSize: 24, color: AppColors.accent),
        actions: [IconButton(onPressed: () {
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const MyHomePage()), (_) => false);
        }, icon: const FaIcon(FontAwesomeIcons.houseUser), iconSize: 22, color: AppColors.accent)],
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Shimmer.fromColors(
              baseColor: AppColors.accent, highlightColor: AppColors.accentLight,
              child: const Icon(Icons.tv_rounded, size: 48)));
          }
          if (detail.isEmpty) return const Center(child: Text('Failed to load', style: TextStyle(color: AppColors.textMuted)));

          return CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.black,
                width: double.infinity,
                child: trailerwatch(trailers[0]['key']),
              ),
            ),
            SliverList(delegate: SliverChildListDelegate([
              Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title
                Text(detail['title'] ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                // Rating + Status + Date
                Wrap(spacing: 10, runSpacing: 8, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: AppDecorations.ratingBadge(),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 20), const SizedBox(width: 4),
                      Text('${detail['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ])),
                  _chip(Icons.info_outline_rounded, detail['status'] ?? '?'),
                  _chip(Icons.calendar_today_rounded, detail['releasedate'] ?? '?'),
                ]),
                const SizedBox(height: 16),
                // Genres
                SizedBox(height: 36, child: ListView.builder(physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal, itemCount: genres.length,
                  itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: AppDecorations.genreChip,
                    child: Center(child: Text(genres[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)))))),
                const SizedBox(height: 24),
                // Overview
                _sectionTitle('Overview'),
                const SizedBox(height: 10),
                Text(detail['overview'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                const SizedBox(height: 24),
                // Seasons & Episodes info
                Row(children: [
                  Expanded(child: _statCard(Icons.video_library_rounded, AppColors.accent, 'Seasons', '${seasons.length}')),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(Icons.play_circle_outline_rounded, AppColors.teal, 'Total Episodes',
                    '${seasons.fold<int>(0, (sum, s) => sum + ((s['episode_count'] ?? 0) as int))}')),
                ]),

              ])),
              // Reviews
              Padding(padding: const EdgeInsets.only(left: 16, top: 8), child: ReviewUI(reviews)),
              if (similarList.isNotEmpty) sliderlist(similarList, 'Similar Series', 'tv', similarList.length),
              if (recommendList.isNotEmpty) sliderlist(recommendList, 'Recommended', 'tv', recommendList.length),
              const SizedBox(height: 40),
            ])),
          ]);
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: AppDecorations.genreChip,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: AppColors.accent), const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
    ]));

  Widget _sectionTitle(String t) => Row(children: [
    Container(width: 4, height: 20, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  ]);

  Widget _statCard(IconData icon, Color color, String label, String value) => Container(
    padding: const EdgeInsets.all(16), decoration: AppDecorations.glassCard,
    child: Column(children: [
      Icon(icon, color: color, size: 24), const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)), const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
    ]));
}
