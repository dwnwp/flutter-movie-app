import 'dart:async';
import 'package:review888/Section/Movies.dart';
import 'package:review888/Section/TVseries.dart';
import 'package:review888/Section/Upcoming.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:review888/details/checker.dart';
import 'package:review888/function/searchbar.dart';
import 'package:review888/apikey/api.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> trendingweek = [];
  late TabController _tabController;
  late Future<void> _trendingFuture;

  Future<void> trendinglist() async {
    var trendingweekurl =
        'https://api.themoviedb.org/3/trending/all/week?api_key=$apikey';
    var trendingweekresponse = await http.get(Uri.parse(trendingweekurl));
    if (trendingweekresponse.statusCode == 200) {
      var tempdata = jsonDecode(trendingweekresponse.body);
      var trendingweekjson = tempdata['results'];
      for (var i = 0; i < trendingweekjson.length; i++) {
        trendingweek.add({
          'id': trendingweekjson[i]['id'],
          'poster_path': trendingweekjson[i]['poster_path'],
          'vote_average': trendingweekjson[i]['vote_average'],
          'media_type': trendingweekjson[i]['media_type'],
          'title': trendingweekjson[i]['title'] ??
              trendingweekjson[i]['name'] ??
              '',
          'indexno': i,
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trendingFuture = trendinglist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surfaceLighter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withAlpha(200),
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_filter_rounded,
                color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
            Text(
              'FlixSphere',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Carousel ──
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: MediaQuery.of(context).size.height * 0.52,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FutureBuilder(
                future: _trendingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildCarousel(context);
                  } else {
                    return _buildShimmerCard();
                  }
                },
              ),
            ),
          ),

          // ── Content Area ──
          SliverList(
            delegate: SliverChildListDelegate([
              const searchbarfunc(),

              // Tab Bar
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  physics: const BouncingScrollPhysics(),
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  isScrollable: true,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppColors.primaryGradient,
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.background,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(child: Text('TV Series')),
                    Tab(child: Text('Movies')),
                    Tab(child: Text('Upcoming')),
                  ],
                ),
              ),

              // Tab Content
              SizedBox(
                height: 1100,
                width: MediaQuery.of(context).size.width,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    TVseries(),
                    Movies(),
                    Upcoming(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    if (trendingweek.isEmpty) {
      return Center(
        child: Text(
          'No trending content',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.82,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        autoPlayCurve: Curves.easeInOutCubic,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        height: MediaQuery.of(context).size.height * 0.55,
      ),
      items: trendingweek.map((item) {
        return Builder(builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      descriptioncheckui(item['id'], item['media_type']),
                  transitionsBuilder: (_, anim, __, child) {
                    return FadeTransition(
                      opacity: anim,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
                image: item['poster_path'] != null
                    ? DecorationImage(
                        image: NetworkImage(
                          'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.background.withAlpha(200),
                      AppColors.background.withAlpha(240),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      if (item['title'] != null &&
                          item['title'].toString().isNotEmpty)
                        Text(
                          item['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Rating badge + media type
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: AppDecorations.ratingBadge(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.accent, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${item['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(50),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.secondary.withAlpha(80),
                              ),
                            ),
                            child: Text(
                              item['media_type'] == 'movie'
                                  ? '🎬 Movie'
                                  : '📺 TV',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}
