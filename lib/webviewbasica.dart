import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';

class WebviewBasic extends StatefulWidget {
  final String url;
  
  WebviewBasic(this.url);

  @override
  _WebviewBasicState createState() => _WebviewBasicState();
}



class _WebviewBasicState extends State<WebviewBasic> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().webviewScalifra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar(''),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Builder(builder: (BuildContext context) {
              return  WebView(
                initialUrl:
                widget.url,
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
