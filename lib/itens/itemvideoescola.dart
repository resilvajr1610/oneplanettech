
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import 'itemvideoescoladetalhe.dart';
import '../pesquisa.dart';
import '../design.dart';
import '../layout.dart';

class ItemVideoEscola extends StatefulWidget {
  final DocumentSnapshot document;


  ItemVideoEscola(this.document);

  @override
  _ItemVideoEscolaState createState() => _ItemVideoEscolaState();
}

class _ItemVideoEscolaState extends State<ItemVideoEscola> {
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
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Pesquisa().irpara(
                    ItemVideoEscolaDetalhe(widget.document, false), context);
              },
              child: Column(
                children: [


                  InkWell(
                    onTap: () {
                      Pesquisa().irpara(
                          ItemVideoEscolaDetalhe(widget.document, false),
                          context);
                    },
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
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: 10,
          child: IconButton(
            color: Colors.white70,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 60),
        ),
        Positioned(
          bottom: 50,
          left: 10,
          child: IconButton(
            color: Colors.white70,
            onPressed: () {
              Pesquisa().irpara(
                  ItemVideoEscolaDetalhe(widget.document, false), context);
            },
            icon: Icon(Icons.fullscreen),
            iconSize: 60,
          ),
        ),
      ],
    );
  }
}
