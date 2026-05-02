import 'package:flutter/material.dart';
import 'package:review888/apikey/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:review888/function/slider.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  List<Map<String, dynamic>> popularmovie = [];
  List<Map<String, dynamic>> nowplaymovie = [];
  List<Map<String, dynamic>> topratemovie = [];
  late Future<void> _moviesFuture;

  var popularmovieurl =
      'https://api.themoviedb.org/3/movie/popular';
  var nowplayingmovieurl =
      'https://api.themoviedb.org/3/movie/now_playing';
  var topratemovieurl =
      'https://api.themoviedb.org/3/movie/top_rated';

  Future<void> movieslist() async {
    var popularmovieresponse = await http.get(Uri.parse(popularmovieurl), headers: apiHeaders);
    if (popularmovieresponse.statusCode == 200) {
      var tempdata = jsonDecode(popularmovieresponse.body);
      var popularmoviejson = tempdata['results'];
      for (var i = 0; i < popularmoviejson.length; i++) {
        popularmovie.add({
          'name': popularmoviejson[i]['title'],
          'poster_path': popularmoviejson[i]['poster_path'],
          'vote_average': popularmoviejson[i]['vote_average'],
          'Date': popularmoviejson[i]['release_date'],
          'id': popularmoviejson[i]['id'],
        });
      }
    }

    var nowplayresponse = await http.get(Uri.parse(nowplayingmovieurl), headers: apiHeaders);
    if (nowplayresponse.statusCode == 200) {
      var tempdata = jsonDecode(nowplayresponse.body);
      var nowplayjson = tempdata['results'];
      for (var i = 0; i < nowplayjson.length; i++) {
        nowplaymovie.add({
          'name': nowplayjson[i]['title'],
          'poster_path': nowplayjson[i]['poster_path'],
          'vote_average': nowplayjson[i]['vote_average'],
          'Date': nowplayjson[i]['release_date'],
          'id': nowplayjson[i]['id'],
        });
      }
    }

    var topratedmovieresponse = await http.get(Uri.parse(topratemovieurl), headers: apiHeaders);
    if (topratedmovieresponse.statusCode == 200) {
      var tempdata = jsonDecode(topratedmovieresponse.body);
      var topratedmoviejson = tempdata['results'];
      for (var i = 0; i < topratedmoviejson.length; i++) {
        topratemovie.add({
          'name': topratedmoviejson[i]['title'],
          'poster_path': topratedmoviejson[i]['poster_path'],
          'vote_average': topratedmoviejson[i]['vote_average'],
          'Date': topratedmoviejson[i]['release_date'],
          'id': topratedmoviejson[i]['id'],
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = movieslist();
  }

  Widget _buildShimmerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(left: 13, top: 15, bottom: 20),
          child: SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.surfaceLight,
                highlightColor: AppColors.surfaceLighter,
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerList();
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              sliderlist(popularmovie, "Popular Movies", "movie", 20),
              sliderlist(nowplaymovie, "Now Playing", "movie", 20),
              sliderlist(topratemovie, "Top Rated", "movie", 20),
            ],
          );
        }
      },
    );
  }
}
