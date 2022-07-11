import 'dart:html';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:scalifra/pesquisa.dart';
import 'package:url_launcher/url_launcher.dart';

import 'layout.dart';
import 'design.dart';

class Regimento extends StatefulWidget {
  String tipo;
  Regimento(this.tipo);
  @override
  _RegimentoState createState() => _RegimentoState();
  }

  class _RegimentoState extends State<Regimento> {
    // PDFDocument document;
    Reference storageReference = FirebaseStorage.instance.ref().child(Nomes().regimento);
    @override
    void initState() {
      super.initState();
      storageReference.getDownloadURL().then((value) async{
        if (kIsWeb) {
          var url = value.toString();
          if (await canLaunch(url) != null) {
            await launch(url);
          }
          return;
        } else{
          // PDFDocument doc = await PDFDocument.fromURL(value.toString());
          // setState(() {
          //   document = doc;
          // });
        }
      });
      Pesquisa().sendAnalyticsEvent(tela: Nomes().regimentoPage);
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: Layout().appbar(widget.tipo),
        body:
        document!=null ? Center(
          // child: PDFViewer(document: document),
        ) : CircularProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 1.0,
        ),
      );
    }
  }

