import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/layout.dart';
import 'package:scalifra/pesquisa.dart';
import 'package:simple_rc4/simple_rc4.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'design.dart';

class WebViewTela extends StatefulWidget {
  late DocumentSnapshot alunodoc, usuario;
  String tipo='', unidade='';
  @override
  _WebViewTelaState createState() => _WebViewTelaState();
}

class _WebViewTelaState extends State<WebViewTela> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  bool carregando = true;
  String data='';
 String codigoenviar='', dataenviar='', unidadeenviar='', linkinicial = 'https://sts.scalifra.net/portalalu/calendario.php';
 // String codigoenviar, dataenviar, unidadeenviar, linkinicial = 'https://www.scalifra.org.br/content/home/default1.asp';

@override
  void initState() {
    super.initState();

    RC4 rc4 = new RC4('cdx2801tb75');
    RC4 rc4data = new RC4('cdx2801tb75');
    RC4 rc4unidade = new RC4('cdx2801tb75');

    if(widget.alunodoc != null){
    setState(() {
    codigoenviar = rc4.encodeString(widget.alunodoc['codigo']);
    dataenviar = rc4data.encodeString(Pesquisa().hojesembarra());
    unidadeenviar = rc4unidade.encodeString(widget.alunodoc['unidade']);
  });}
    if(widget.usuario != null){
      setState(() {
        codigoenviar = rc4.encodeString(widget.usuario['codigo']);
        dataenviar = rc4data.encodeString(Pesquisa().hojesembarra());
        unidadeenviar = rc4unidade.encodeString(widget.usuario['unidade']);
      });}
    FirebaseFirestore.instance.collection(Nomes().unidadebanco).doc(widget.unidade).get().then((value) {
      // if(widget.tipo == "Aluno"){
      //   setState(() {
      //     linkinicial = value['linkportalaluno'];
      //   });
      // }
      // if(widget.tipo == "Responsável"){
      //   setState(() {
      //     linkinicial = value['linkportalfinanceiro'];
      //   });
      // }
      // if(widget.tipo == "Professor"){
      //   setState(() {
      //     linkinicial = value['linkportalprofessor'];
      //   });
      // }
      if (kIsWeb) {
        abrirpdfweb();
      }
   });



  }

  abrirpdfweb() async {
    var url = '$linkinicial?c=$codigoenviar&d=$dataenviar&u=$unidadeenviar';
    if (await canLaunch(url) != null) {
      await launch(url);
    } else {
      throw 'Não conseguimos abrir a página $url';
    }
    Navigator.pop(context);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar('Calendário'),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Builder(builder: (BuildContext context) {
              return  WebView(
                initialUrl:
                '$linkinicial?c=$codigoenviar&d=$dataenviar&u=$unidadeenviar&t=F',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },

                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                setState(() {
                  carregando = false;
                });
                },
              onWebResourceError: (WebResourceError error){
                  Layout().dialog1botaofecha2(context, 'Algo deu errado', 'Por favor, verifique sua conexão');
              },

                navigationDelegate: (NavigationRequest request) {


                  return NavigationDecision.navigate;
                },
                gestureNavigationEnabled: true,
              ) ;
            }),
          ),
          (carregando) ? Center(
              child: CircularProgressIndicator(
                valueColor:
                new AlwaysStoppedAnimation<Color>(
                    Cores().corprincipal),
              )) : Container(),
        ],
      ),
    );

  }
}
