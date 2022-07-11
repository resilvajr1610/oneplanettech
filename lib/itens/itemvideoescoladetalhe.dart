import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../design.dart';
import '../layout.dart';

class ItemVideoEscolaDetalhe extends StatefulWidget {
  final DocumentSnapshot document;
  final bool controle;

  ItemVideoEscolaDetalhe(this.document, this.controle);

  @override
  _ItemVideoEscolaDetalheState createState() => _ItemVideoEscolaDetalheState();
}

class _ItemVideoEscolaDetalheState extends State<ItemVideoEscolaDetalhe> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(widget.document['video'].toString())
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar(''),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : SizedBox(
                  height: 220.0,
                  width: MediaQuery.of(context).size.width,
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 220.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                      )
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: InkWell(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Container(
                color: Colors.white60,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  icon: Icon(_controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  iconSize: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
