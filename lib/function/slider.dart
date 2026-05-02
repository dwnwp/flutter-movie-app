import 'package:flutter/material.dart';
import 'package:review888/details/moviedetail.dart';
import 'package:review888/details/tvseriesdetail.dart';
import 'package:review888/theme/app_theme.dart';

Widget sliderlist(
    List firstlistname, String categorytitle, String type, int itemCount) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 20, bottom: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              categorytitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 260,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          padding: const EdgeInsets.only(left: 13),
          itemBuilder: (context, index) {
            if (index >= firstlistname.length) return const SizedBox();
            final item = firstlistname[index];
            return GestureDetector(
              onTap: () {
                Widget targetPage;
                if (type == 'movie') {
                  targetPage = Moviedetail(item['id']);
                } else if (type == 'tv' || type == 'TV') {
                  targetPage = TvSeriesDetails(id: item['id']);
                } else {
                  return;
                }
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => targetPage,
                    transitionsBuilder: (_, anim, __, child) {
                      return FadeTransition(opacity: anim, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 13, bottom: 8),
                width: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  image: item['poster_path'] != null
                      ? DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500/${item["poster_path"]}',
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.background.withAlpha(180),
                        AppColors.background.withAlpha(230),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 0.85, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating badge at top-left
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
                                item['vote_average'] != null
                                    ? item['vote_average'] is double
                                        ? item['vote_average']
                                            .toStringAsFixed(1)
                                        : item['vote_average'].toString()
                                    : 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Title at bottom
                        if (item['name'] != null)
                          Text(
                            item['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
