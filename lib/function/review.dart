import 'package:flutter/material.dart';
import 'package:review888/theme/app_theme.dart';

class ReviewUI extends StatefulWidget {
  final List revdetails;
  const ReviewUI(this.revdetails, {super.key});

  @override
  State<ReviewUI> createState() => _ReviewUIState();
}

class _ReviewUIState extends State<ReviewUI> {
  bool showall = false;

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withAlpha(60),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar, name, date, rating
          Row(
            children: [
              // Avatar
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withAlpha(60),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(review['avatarphoto']),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    review['avatarphoto'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceLighter,
                      child: const Icon(Icons.person,
                          color: AppColors.textMuted, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] ?? 'Anonymous',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['creationdate'] ?? '',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: AppDecorations.ratingBadge(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      review['rating'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review text
          Text(
            review['review'] ?? '',
            maxLines: showall ? null : 4,
            overflow: showall ? null : TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List reviewdetail = widget.revdetails;
    if (reviewdetail.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 12, top: 16),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.rate_review_rounded,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'User Reviews',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${reviewdetail.length}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (reviewdetail.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showall = !showall;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showall ? 'Show Less' : 'Show All',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          showall
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Reviews
        if (showall)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: reviewdetail.length,
              padding: const EdgeInsets.only(right: 16),
              itemBuilder: (context, index) {
                return _buildReviewCard(reviewdetail[index]);
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildReviewCard(reviewdetail[0]),
          ),
      ],
    );
  }
}
