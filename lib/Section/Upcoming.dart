import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:review888/function/slider.dart';
import 'package:http/http.dart' as http;
import 'package:review888/apikey/api.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  List<Map<String, dynamic>> getUpcominglist = [];
  late Future<void> _upcomingFuture;

  Future<void> getUpcoming() async {
    var url = Uri.parse(
        'https://api.themoviedb.org/3/movie/upcoming?api_key=$apikey');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      for (var i = 0; i < json['results'].length; i++) {
        getUpcominglist.add({
          "poster_path": json['results'][i]['poster_path'],
          "name": json['results'][i]['title'],
          "vote_average": json['results'][i]['vote_average'],
          "Date": json['results'][i]['release_date'],
          "id": json['results'][i]['id'],
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _upcomingFuture = getUpcoming();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _upcomingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sliderlist(getUpcominglist, "Upcoming", "movie", 20),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 15, bottom: 40),
                child: Row(
                  children: [
                    Icon(Icons.upcoming_rounded,
                        color: AppColors.accent.withAlpha(150), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Many more coming soon...",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 13, top: 15),
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
          );
        }
      },
    );
  }
}
