import 'dart:async';

// import 'package:audioplayer/audioplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../design.dart';



class ItemAudio extends StatefulWidget {
  DocumentSnapshot document;
  ItemAudio(this.document);

  @override
  _ItemAudioState createState() => _ItemAudioState();
}

enum PlayerState { stopped, playing, paused }

class _ItemAudioState extends State<ItemAudio> {
 // AudioPlayer audioPlayer = AudioPlayer();
  String kurl='';


  late Duration duration;
  late Duration position;
  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';


  late StreamSubscription _positionSubscription;
  late StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
   //initAudioPlayer();
    kurl = widget.document['audio'];
    //play();
  }

  // void initAudioPlayer() {
  //   audioPlayer = AudioPlayer();
  //   _positionSubscription = audioPlayer.onAudioPositionChanged
  //       .listen((p) => setState(() => position = p));
  //   _audioPlayerStateSubscription =
  //       audioPlayer.onPlayerStateChanged.listen((s) {
  //         if (s == AudioPlayerState.PLAYING) {
  //           setState(() => duration = audioPlayer.duration);
  //         } else if (s == AudioPlayerState.STOPPED) {
  //           onComplete();
  //           setState(() {
  //             position = duration;
  //           });
  //         }
  //       }, onError: (msg) {
  //         setState(() {
  //           playerState = PlayerState.stopped;
  //           duration = Duration(seconds: 0);
  //           position = Duration(seconds: 0);
  //         });
  //       });
  // }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
 //  audioPlayer.stop();
   _positionSubscription.cancel();
   _audioPlayerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controle();
  }


  //
  // Future play() async {
  //   await audioPlayer.play(kurl);
  //   setState(() {
  //     playerState = PlayerState.playing;
  //   });
  // }
  //
  // Future pause() async {
  //   await audioPlayer.pause();
  //   setState(() => playerState = PlayerState.paused);
  // }
  //
  // Future stop() async {
  //   await audioPlayer.stop();
  //   setState(() {
  //     playerState = PlayerState.stopped;
  //     position = Duration();
  //   });
  // }


  Widget controle() => Container(
    padding: EdgeInsets.only(bottom:42.0),
    child: Card(
      color: Colors.white54,
      child: Container(
        height: 60.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row(mainAxisSize: MainAxisSize.min, children: [
            //   IconButton(
            //     onPressed: isPlaying ? () => pause() : () => play(),
            //     iconSize: 30.0,
            //     icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
            //     color: Cores().corprincipal,
            //   ),
            //   IconButton(
            //     onPressed: isPlaying || isPaused ? () => stop() : null,
            //     iconSize: 30.0,
            //     icon: Icon(Icons.stop),
            //     color: Cores().corprincipal,
            //   ),
            //   if (duration != null)
            //     Slider(
            //         value: position?.inMilliseconds?.toDouble()/3.0 ?? 0.0,
            //         onChanged: (double value) {
            //           return audioPlayer.seek((value / 3000).roundToDouble());
            //         },
            //         min: 0.0,
            //         max: duration.inMilliseconds.toDouble()/3.0),
            // ]),

//            if (position != null) _buildProgressView()
          ],
        ),
      ),
    ),
  );

}
