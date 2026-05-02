import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class trailerwatch extends StatefulWidget {
  final String trailerytid;
  const trailerwatch(this.trailerytid, {super.key});

  @override
  State<trailerwatch> createState() => _trailerwatchState();
}

class _trailerwatchState extends State<trailerwatch> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailerytid,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}
