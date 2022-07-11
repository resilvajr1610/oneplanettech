import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../design.dart';
import '../layout.dart';
import '../mensagemintra.dart';
import '../pesquisa.dart';

class MenuMensagem extends StatefulWidget {
  final DocumentSnapshot usuario;

  MenuMensagem(this.usuario);

  @override
  _MenuMensagemState createState() => _MenuMensagemState();
}

class _MenuMensagemState extends State<MenuMensagem> {

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().menuMensagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Layout().appbar('Chat Interno'),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Layout().espacolateral(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Nomes().mensagensinternasbanco)
                          .where("buscaparametros",
                              arrayContainsAny: [widget.usuario.id])
                          .orderBy("datacomparar", descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> conversaSnapshot) {
                        if (conversaSnapshot.hasError) {
                          print(conversaSnapshot.error);
                          return Text(
                              'Isto é um erro. Por gentileza, contate o suporte.');
                        }
                        switch (conversaSnapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return (conversaSnapshot.data!.docs.length >= 1)
                                ? ListView(
                                    children: conversaSnapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      return Layout().itemMensagemTelaInterna(
                                          document, widget.usuario, context);
                                    }).toList(),
                                  )
                                : Container();
                        }
                      }),
                ),
                Layout().espacolateral(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          Navigator.pop(context);
          Pesquisa().irpara(MensagemIntra(widget.usuario), context);
        },
        child: new Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<DocumentSnapshot> getOtherUser(
      DocumentSnapshot conversaDoc, DocumentSnapshot user) async {
    List ids = conversaDoc['buscaparametros'];
    String outroUserID = ids[0];
    if (ids[0] == user.id) {
      outroUserID = ids[1];
    }
    return FirebaseFirestore.instance
        .collection(Nomes().usersbanco)
        .doc(outroUserID)
        .get();
  }
}
