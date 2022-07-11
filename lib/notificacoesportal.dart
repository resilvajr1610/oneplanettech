import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scalifra/pesquisa.dart';

import 'design.dart';
import 'layout.dart';

class NotificacoesPortal extends StatefulWidget {
  DocumentSnapshot usuario;

  NotificacoesPortal(this.usuario);

  @override
  _NotificacoesPortalState createState() => _NotificacoesPortalState();
}

class _NotificacoesPortalState extends State<NotificacoesPortal> {
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection(Nomes().publicacoesportal)
        .where('email', isEqualTo: widget.usuario['email'])
        .where('lida', isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({'lida': true});
      });
    });
    
    Pesquisa().sendAnalyticsEvent(tela: Nomes().notificacoesbanco);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: AppBar(
          backgroundColor: Cores().corprincipal, title: Text("Notificações")),
      body: Row(
        children: [
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                )
              : Container(),
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(
                    child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Nomes().publicacoesportal)
                      .where('email', isEqualTo: widget.usuario['email'])
                      .orderBy("datacomparar", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Text(
                          'Isto é um erro. Por gentileza, contate o suporte.');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                        break;
                      default:
                        return ListView(
                          children: snapshot.data!.docs.map((doc) {
                            return Layout().itemPublicacaoPortal(
                                doc, widget.usuario, context);
                          }).toList(),
                        );
                    }
                  },
                )),
              ],
            ),
          ),
          (MediaQuery.of(context).size.width > 850)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                )
              : Container(),
        ],
      ),
    );
  }
}
