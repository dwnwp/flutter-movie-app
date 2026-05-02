import 'package:flutter/material.dart';
import 'package:review888/details/moviedetail.dart';
import 'package:review888/details/tvseriesdetail.dart';
import 'package:review888/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class descriptioncheckui extends StatefulWidget {
  var newid;
  var newtype;

  descriptioncheckui(this.newid, this.newtype, {super.key});

  @override
  State<descriptioncheckui> createState() => _descriptioncheckuiState();
}

Widget errorUI(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.surface.withAlpha(230),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter_rounded,
              color: AppColors.accent, size: 28),
          const SizedBox(width: 8),
          const Text('FlixSphere'),
        ],
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(FontAwesomeIcons.circleArrowLeft),
        iconSize: 28,
        color: AppColors.accent,
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            "Content not available",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This media type is not supported yet.",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text("Go Back"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _descriptioncheckuiState extends State<descriptioncheckui> {
  checktype() {
    if (widget.newtype == 'movie') {
      return Moviedetail(widget.newid);
    } else if (widget.newtype == 'tv' || widget.newtype == 'TV') {
      return TvSeriesDetails(id: widget.newid);
    } else {
      return errorUI(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: checktype(),
    );
  }
}
