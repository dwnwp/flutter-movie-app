import 'package:flutter/material.dart';
import 'package:review888/apikey/api.dart';
import 'package:review888/Homepage/Homepage.dart';
import 'package:review888/function/slider.dart';
import 'package:review888/theme/app_theme.dart';
import 'dart:convert';
import 'package:review888/function/trailerui.dart';
import 'package:review888/function/review.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class Moviedetail extends StatefulWidget {
  var id;
  Moviedetail(this.id, {super.key});
  @override
  State<Moviedetail> createState() => _MoviedetailState();
}

class _MoviedetailState extends State<Moviedetail> {
  List<Map<String, dynamic>> Detail = [];
  List<Map<String, dynamic>> Review = [];
  List<Map<String, dynamic>> similar = [];
  List<Map<String, dynamic>> recommend = [];
  List<Map<String, dynamic>> trailer = [];
  List Moviegenre = [];
  late Future<void> _detailFuture;

  Future<void> _fetchMovieDetail() async {
    final base = 'https://api.themoviedb.org/3/movie/${widget.id}';
    final responses = await Future.wait([
      http.get(Uri.parse('$base'), headers: apiHeaders),
      http.get(Uri.parse('$base/reviews'), headers: apiHeaders),
      http.get(Uri.parse('$base/similar'), headers: apiHeaders),
      http.get(Uri.parse('$base/recommendations'), headers: apiHeaders),
      http.get(Uri.parse('$base/videos'), headers: apiHeaders),
    ]);

    if (responses[0].statusCode == 200) {
      var d = jsonDecode(responses[0].body);
      Detail.add({
        "backdrop_path": d['backdrop_path'], "title": d['title'],
        "vote_average": d['vote_average'], "overview": d['overview'],
        "release_date": d['release_date'], "runtime": d['runtime'],
        "budget": d['budget'], "revenue": d['revenue'],
      });
      for (var g in d['genres']) Moviegenre.add(g['name']);
    }
    if (responses[1].statusCode == 200) {
      var d = jsonDecode(responses[1].body);
      for (var r in d['results']) {
        Review.add({
          "name": r['author'], "review": r['content'],
          "rating": r['author_details']['rating']?.toString() ?? "N/A",
          "avatarphoto": r['author_details']['avatar_path'] != null
              ? "https://image.tmdb.org/t/p/w500${r['author_details']['avatar_path']}"
              : "https://www.gravatar.com/avatar/?d=mp",
          "creationdate": r['created_at'].substring(0, 10),
        });
      }
    }
    if (responses[2].statusCode == 200) {
      for (var m in jsonDecode(responses[2].body)['results']) {
        similar.add({"poster_path": m['poster_path'], "name": m['title'],
          "vote_average": m['vote_average'], "Date": m['release_date'], "id": m['id']});
      }
    }
    if (responses[3].statusCode == 200) {
      for (var m in jsonDecode(responses[3].body)['results']) {
        recommend.add({"poster_path": m['poster_path'], "name": m['title'],
          "vote_average": m['vote_average'], "Date": m['release_date'], "id": m['id']});
      }
    }
    if (responses[4].statusCode == 200) {
      for (var v in jsonDecode(responses[4].body)['results']) {
        if (v['type'] == "Trailer") trailer.add({"key": v['key']});
      }
      if (trailer.isEmpty) trailer.add({'key': 'aJ0cZTcTh90'});
    }
  }

  String _fmt(dynamic v) {
    if (v == null || v == 0) return 'N/A';
    int a = v is int ? v : int.tryParse(v.toString()) ?? 0;
    if (a >= 1e9) return '\$${(a / 1e9).toStringAsFixed(1)}B';
    if (a >= 1e6) return '\$${(a / 1e6).toStringAsFixed(1)}M';
    return '\$$a';
  }

  @override
  void initState() { super.initState(); _detailFuture = _fetchMovieDetail(); }

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
              child: const Icon(Icons.movie_rounded, size: 48)));
          }
          if (Detail.isEmpty) return const Center(child: Text('Failed to load', style: TextStyle(color: AppColors.textMuted)));
          return CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.black,
                width: double.infinity,
                child: trailerwatch(trailer[0]['key']),
              ),
            ),
            SliverList(delegate: SliverChildListDelegate([
              Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(Detail[0]['title'] ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                // Rating + Runtime + Date
                Wrap(spacing: 10, runSpacing: 8, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: AppDecorations.ratingBadge(),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 20), const SizedBox(width: 4),
                      Text('${Detail[0]['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ])),
                  _chip(Icons.access_time_rounded, '${Detail[0]['runtime'] ?? '?'} min'),
                  _chip(Icons.calendar_today_rounded, '${Detail[0]['release_date'] ?? '?'}'),
                ]),
                const SizedBox(height: 16),
                // Genres
                SizedBox(height: 36, child: ListView.builder(physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal, itemCount: Moviegenre.length,
                  itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: AppDecorations.genreChip,
                    child: Center(child: Text(Moviegenre[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)))))),
                const SizedBox(height: 24),
                _sectionTitle('Story'),
                const SizedBox(height: 10),
                Text(Detail[0]['overview'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                const SizedBox(height: 24),
                // Budget & Revenue
                Row(children: [
                  Expanded(child: _statCard(Icons.account_balance_rounded, AppColors.accent, 'Budget', _fmt(Detail[0]['budget']))),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(Icons.trending_up_rounded, AppColors.teal, 'Revenue', _fmt(Detail[0]['revenue']))),
                ]),
              ])),
              Padding(padding: const EdgeInsets.only(left: 16, top: 8), child: ReviewUI(Review)),
              if (similar.isNotEmpty) sliderlist(similar, "Similar Movies", "movie", similar.length),
              if (recommend.isNotEmpty) sliderlist(recommend, "Recommended", "movie", recommend.length),
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
