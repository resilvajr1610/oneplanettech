import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'layout.dart';
import 'design.dart';
import 'pesquisa.dart';

class MensagemPara extends StatefulWidget {
  final DocumentSnapshot aluno, usuario;
  final String perfil;

  MensagemPara(this.usuario, this.aluno, this.perfil);

  @override
  _MensagemParaState createState() => _MensagemParaState();
}

class _MensagemParaState extends State<MensagemPara> {

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().mensagemPara);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar("Para quem?"),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Nomes().usersbanco)
                  .where('alunos', arrayContainsAny: [widget.aluno.id])
                  .orderBy('nome')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Isto é um erro. Por gentileza, contate o suporte.');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                    break;
                  default:
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        if (doc['email'] != 'elaine@master.com') {
                            return Layout().itempai(widget.usuario, doc, widget.aluno, widget.perfil, context);
                        }
                        return Container();
                      }).toList(),
                    );
                }
              },
            ),
          ),
          Layout().espacolateral(context),
        ],
      )
    );
  }
}
