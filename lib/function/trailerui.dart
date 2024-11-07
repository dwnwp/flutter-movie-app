import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class trailerwatch extends StatefulWidget {
  var trailerytid;
  trailerwatch(this.trailerytid, {super.key});

  @override
  State<trailerwatch> createState() => _trailerwatchState();
}

class _trailerwatchState extends State<trailerwatch> {
  late YoutubePlayerController _controller;
  @override
  void initState() {
    final videoid = YoutubePlayer.convertUrlToId(widget.trailerytid);
    _controller = YoutubePlayerController(
      initialVideoId: videoid.toString(),
      flags: const YoutubePlayerFlags(
        enableCaption: true,
        autoPlay: false,
        mute: false,
        forceHD: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: YoutubePlayer(
        thumbnail: Image.network(
          "${"https://img.youtube.com/vi/" + widget.trailerytid}/hqdefault.jpg",
          fit: BoxFit.cover,
        ),
        controlsTimeOut: const Duration(milliseconds: 1500),
        aspectRatio: 16 / 9,
        controller: _controller,
        showVideoProgressIndicator: true,
        bufferIndicator: const Center(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
        ),
        progressIndicatorColor: Colors.blue,
        bottomActions: [
          CurrentPosition(),
          ProgressBar(
            isExpanded: true,
            colors: const ProgressBarColors(
                playedColor: Colors.white, handleColor: Colors.blue),
          ),
          RemainingDuration(),
          FullScreenButton(),
        ],
      ),
    );
  }
}