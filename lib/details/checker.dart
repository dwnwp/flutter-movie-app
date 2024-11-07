import 'package:flutter/material.dart';
import 'package:review888/details/moviedetail.dart';
import 'package:review888/details/tvseriesdetail.dart';
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
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(18, 18, 18, 0.9),
      title: const Text('FlixSphere'), // ใส่ชื่อของ AppBar
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(FontAwesomeIcons.circleArrowLeft),
        iconSize: 28,
        color: Colors.amber,
      ),
    ),
    body: const Center(
      child: Text("Error"),
    ),
  );
}

class _descriptioncheckuiState extends State<descriptioncheckui> {
  checktype() {
    if (widget.newtype == 'movie') {
      return Moviedetail(widget.newid);
    } else if (widget.newtype == 'TV') {
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
