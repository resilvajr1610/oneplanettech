import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'design.dart';
import 'pesquisa.dart';


class FotoDetalhe extends StatelessWidget {
  String foto;
  FotoDetalhe(this.foto);

  _download() async {
    String url = foto;
    if (await canLaunch(url)) {
      await launch(url);
      Pesquisa().sendAnalyticsEvent(tela: Nomes().baixouFoto);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores().corprincipal,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              _download();
            },
            child: Icon(Icons.save_alt),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child:    Hero(
          tag: foto,
          child: PhotoView(
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration:
            BoxDecoration(color: Colors.transparent),
            imageProvider: NetworkImage(foto.replaceAll("_500x500.jpg", ".jpg")),
          ),
        ) ,
      ),
    );
  }
}
