import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class ItemVideo extends StatefulWidget {
  final DocumentSnapshot document;
  ItemVideo(this.document);
  @override
  _ItemVideoState createState() => _ItemVideoState();
}

class _ItemVideoState extends State<ItemVideo> {

  bool curtiu = false;
  String videoId='';
  late YoutubePlayerController controller;



  @override
  void initState() {
    super.initState();
    if (widget.document['linkyoutube'] != null) {
      videoId = YoutubePlayer.convertUrlToId(widget.document['linkyoutube'])!;
      controllerYoutube(videoId);
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void controllerYoutube(videoId) {
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return item(
        widget.document, controller, videoId,
        context);
  }


  Widget item(document, controller, videoId, context) {
    return GestureDetector(
      onTap: () async {
        if (kIsWeb) {
          var url = document['linkyoutube'];
          if (await canLaunch(url) != null) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  height: 250.0,
                  child:
                  (!kIsWeb) ?
                  YoutubePlayer(
                    key: ObjectKey(controller),
                    controller: controller,
                    actionsPadding: EdgeInsets.only(left: 16.0),
                    bottomActions: [
                      CurrentPosition(),
                      SizedBox(width: 10.0),
                      ProgressBar(isExpanded: true),
                      SizedBox(width: 10.0),
                      RemainingDuration(),
                      FullScreenButton(),
                    ],
                  ) : Container(

                    child: InkWell(
                      onTap: () async {
                        var url = document['linkyoutube'];
                        if (await canLaunch(url) != null) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 250.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(image:
                                NetworkImage(
                                    'https://img.youtube.com/vi/$videoId/0.jpg'),
                                    fit: BoxFit.contain
                                )),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                          ),
                          Center(
                            child: Icon(Icons.play_arrow, color: Colors.white,
                                size: 50),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}