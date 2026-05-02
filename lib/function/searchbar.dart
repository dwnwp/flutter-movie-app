import 'package:flutter/material.dart';
import 'package:review888/apikey/api.dart';
import 'package:review888/details/checker.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class searchbarfunc extends StatefulWidget {
  const searchbarfunc({super.key});

  @override
  State<searchbarfunc> createState() => _searchbarfuncState();
}

class _searchbarfuncState extends State<searchbarfunc> {
  List<Map<String, dynamic>> searchresult = [];
  final TextEditingController searchtext = TextEditingController();
  Timer? _debounce;
  Future<void>? _searchFuture;
  String _lastQuery = '';

  Future<void> searchlistfunction(String val) async {
    if (val.isEmpty) return;
    searchresult.clear();
    var searchurl =
        'https://api.themoviedb.org/3/search/multi?api_key=$apikey&query=$val';
    var searchresponse = await http.get(Uri.parse(searchurl));
    if (searchresponse.statusCode == 200) {
      var tempdata = jsonDecode(searchresponse.body);
      var searchjson = tempdata['results'];
      for (var i = 0; i < searchjson.length; i++) {
        if (searchjson[i]['id'] != null &&
            searchjson[i]['poster_path'] != null &&
            searchjson[i]['vote_average'] != null &&
            searchjson[i]['media_type'] != null) {
          searchresult.add({
            'id': searchjson[i]['id'],
            'poster_path': searchjson[i]['poster_path'],
            'vote_average': searchjson[i]['vote_average'],
            'media_type': searchjson[i]['media_type'],
            'popularity': searchjson[i]['popularity'],
            'overview': searchjson[i]['overview'] ?? '',
            'title': searchjson[i]['title'] ??
                searchjson[i]['name'] ??
                'Unknown',
          });
          if (searchresult.length >= 20) break;
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value != _lastQuery) {
        _lastQuery = value;
        setState(() {
          _searchFuture = searchlistfunction(value);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchtext.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, top: 24, bottom: 16, right: 16),
        child: Column(
          children: [
            // Search Input
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: TextField(
                autofocus: false,
                controller: searchtext,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                onSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (value.isNotEmpty) {
                    _lastQuery = value;
                    setState(() {
                      _searchFuture = searchlistfunction(value);
                    });
                  }
                },
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  suffixIcon: searchtext.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Search Cleared",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: AppColors.surface,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                            setState(() {
                              searchtext.clear();
                              searchresult.clear();
                              _lastQuery = '';
                              _searchFuture = null;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        )
                      : null,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  hintText: 'Search movies & TV shows...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Search Results
            if (searchtext.text.isNotEmpty && _searchFuture != null)
              FutureBuilder(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (searchresult.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            const Text(
                              'No results found',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: searchresult.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4),
                        itemBuilder: (context, index) {
                          final item = searchresult[index];
                          return _buildSearchResultCard(
                              context, item);
                        },
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(
      BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                descriptioncheckui(item['id'], item['media_type']),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceLight,
                    child: const Icon(Icons.broken_image_rounded,
                        color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Badges row
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: AppDecorations.ratingBadge(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.accent, size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '${item['vote_average']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Media type
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(height: 8),
                    // Overview
                    Expanded(
                      child: Text(
                        item['overview'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted.withAlpha(100),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
