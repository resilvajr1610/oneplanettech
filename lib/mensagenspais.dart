import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'design.dart';
import 'layout.dart';
import 'pesquisa.dart';
import 'publicar.dart';

class MensagensPais extends StatefulWidget {
  DocumentSnapshot usuario, aluno;

  MensagensPais(this.usuario, this.aluno);

  @override
  _MensagensPaisState createState() => _MensagensPaisState();
}

class _MensagensPaisState extends State<MensagensPais> {

  @override
  void initState() {
    super.initState();
    Pesquisa().sendAnalyticsEvent(tela: Nomes().msgPais);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores().corfundo,
      appBar: Layout().appbar('Mensagens'),
      body: Row(
        children: [
          Layout().espacolateral(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(Nomes().mensagensbanco)
                    .orderBy("datacomparar", descending: true)
                    .where("origem", isEqualTo: widget.usuario.id)
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
                    default:
                      return (snapshot.data!.docs.length >= 1)
                          ? ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return Layout().itemMensagemTela(
                                    document,
                                    widget.usuario, false, 'pais', context, null);
                              }).toList(),
                            )
                          : Center(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Não há mensagens ainda.\nPara enviar nova mensagem, clique no lápis.', style: TextStyle(fontSize: 18.0),),
                          ));
                  }
                }),
          ),
          Layout().espacolateral(context)
        ],
      ),
      floatingActionButton: floatingactionbar(Icons.edit, "Incluir", context),
    );
  }

  Widget floatingactionbar(icon, tip, context) {
    return FloatingActionButton(
        backgroundColor: Cores().corprincipal,
        onPressed: () {
          floatingaction(context);
        },
        tooltip: tip,
        child: Icon(icon));
  }

  void floatingaction(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Publicar( widget.usuario, widget.aluno)));
  }
}
