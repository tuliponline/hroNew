import 'package:chewie_audio/chewie_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    const ChewieAudioDemo(),
  );
}

class ChewieAudioDemo extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const ChewieAudioDemo({this.title = 'Chewie Audio Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieAudioDemoState();
  }
}

class _ChewieAudioDemoState extends State<ChewieAudioDemo> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool play = false;
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieAudioController _chewieAudioController;

  bool haveOrder = false;
  _realTimeDB() async {
    db.collection("orders").snapshots().listen((event) async {
      await db
          .collection("orders")
          .where("status", isEqualTo: "1")
          .get()
          .then((value) {
        var _jsonData = setList2Json(value);
        List<OrderList> _orderList = orderListFromJson(_jsonData);
        if (_orderList.length > 0) {
          haveOrder = true;
        }else{
          
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieAudioController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    play = true;
    _videoPlayerController1 = VideoPlayerController.network(
        'https://www.w3schools.com/html/mov_bbb.mp4');
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _chewieAudioController = ChewieAudioController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData.light().copyWith(
        platform: _platform ?? Theme.of(context).platform,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Container(
              child: IconButton(
                  onPressed: () {
                    if (play) {
                      _videoPlayerController1.dispose();
                      play = false;
                    } else {
                      initializePlayer();
                    }
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    size: 60,
                  )),
            ),
          )),
    );
  }
}
