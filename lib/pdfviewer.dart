import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:scalifra/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'design.dart';
import 'pesquisa.dart';

class DocumentoDetalhes extends StatefulWidget {
  DocumentSnapshot documento, usuario;
  bool controle;
  String tipo;
  DocumentoDetalhes(this.tipo, this.documento, this.usuario, this.controle);

  @override
  _DocumentoDetalhesState createState() => _DocumentoDetalhesState();
}

class _DocumentoDetalhesState extends State<DocumentoDetalhes> {
  //PDFDocument pdfdoc;
  String stringpdf='';

  @override
  void initState() {
    super.initState();
    if (widget.documento == null && widget.tipo == null) {
      stringpdf = '';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('TelaInicio/' + 'termos.pdf');
      storageReference.getDownloadURL().then((value) async {
        if(mounted){
        setState(() {
          stringpdf = value.toString();
        });}
        // PDFDocument.fromURL(stringpdf).then((pdf) {
        //   if (mounted) {
        //     setState(() {
        //       pdfdoc = pdf;
        //       print(pdfdoc);
        //     });
        //   }
        // });
        if (kIsWeb) {
          abrirpdfweb();
        }
      });
    } else {
      if (widget.tipo == 'regras' &&
          widget.documento != null &&
          widget.documento['regraspdf'] != null) {
        if(mounted){
        setState(() {
          stringpdf = widget.documento['regraspdf'];
        });}
      } else if (widget.tipo == 'sobreescola' &&
          widget.documento != null &&
          widget.documento['sobreescolapdf'] != null) {
        if(mounted){
        setState(() {
          stringpdf = widget.documento['sobreescolapdf'];
        });}
      } else if (widget.documento != null &&
          widget.documento['documento'] != null) {
        if(mounted){
        setState(() {
          stringpdf = widget.documento['documento'];
          print(stringpdf);
        });}
      }
      // PDFDocument.fromURL(stringpdf).then((pdf) {
      //   if (mounted) {
      //     setState(() {
      //       pdfdoc = pdf;
      //       print(pdfdoc);
      //     });
      //   }
      // });
      if (kIsWeb) {
        abrirpdfweb();
      }

      if (!widget.controle &&
          widget.usuario['email'] != 'elaine@master.com.br') {
        widget.documento.reference.update({
          "cientes": FieldValue.arrayUnion([widget.usuario.id])
        });
      }
    }
    Pesquisa().sendAnalyticsEvent(tela: Nomes().pdfViewer);
  }

  abrirpdfweb() async {
    var url = stringpdf;
    if (await canLaunch(url) != null) {
      await launch(url);
    } else {
      throw 'Não conseguimos abrir a página $url';
    }
    Navigator.pop(context);
  }

  _download() async {
    String url = widget.documento['documento'];
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (widget.documento == null && widget.tipo == null)
            ? Container()
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
        title: Text(
          (widget.documento != null)
              ? (widget.documento['nomeDocumento'] != null)
                  ? widget.documento['nomeDocumento']
                  : ""
              : "",
          style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.5),
        ),
        backgroundColor: Cores().corprincipal,
        actions: <Widget>[
          (widget.documento == null && widget.tipo == null)
              ? FlatButton(
            color: Colors.red,
                  onPressed: () async {
                    await widget.usuario.reference.update({
                      'aceito': true,
                      'visualizacao': FieldValue.arrayUnion(['capa'])
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => MyHomePage()),
                        (route) => false);
                  },
                  child: Text(
                    'Aceito os Termos',
                    style: TextStyle(color: Colors.white),
                  ))
              : FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    _download();
                  },
                  child: Icon(Icons.save_alt),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
        ],
      ),
       body:
        // pdfdoc != null
      //     ? Center(
      //         child: PDFViewer(document: pdfdoc),
      //       )
      //     :
        CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 1.0,
            ),
    );
  }
}
